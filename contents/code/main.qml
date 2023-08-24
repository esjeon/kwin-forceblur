import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore;
import org.kde.plasma.components 2.0 as Plasma;
import org.kde.kwin 2.0;

Item {
    id: root

    readonly property var patterns: (
        KWin.readConfig("patterns", "yakuake\nurxvt\nkeepassxc")
            .split("\n")
            .map(function(rule) {
                return rule.trim().toLowerCase();
            })
    )

    readonly property var blurMatching: (
        KWin.readConfig("blurMatching", true)
    )

    readonly property var blurContent: (
        KWin.readConfig("blurContent", false)
    )

    PlasmaCore.DataSource {
        id: shell
        engine: 'executable'
        connectedSources: []

        function run(cmd) {
            connectSource(cmd);
        }

        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(sourceName, exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName)
        }

        onSourceConnected: {
            connected(source)
        }

        signal connected(string source)
        signal exited(string shell, int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
    target: shell
    function onExited(shell, exitCode, exitStatus, stdout, stderr) {
        console.log('onExited', shell, exitCode, exitStatus, stdout, stderr)
        console.log('exited out', stdout)
        console.log('exited err', sterr)
    }
    function onConnected(source) {
      console.log('connected', source)
    }
    }

    /*
     * create a new blur region for a window
     * client : the window you want to target
     */
    function onClientAdded(client) {
        if (!shell) return;
        console.log('FORCE-BLUR: targeting the following client:', JSON.stringify(client))

        var cls = client.resourceClass.toString().toLowerCase();
        var name = client.resourceName.toString().toLowerCase();
        var clsMatches = root.patterns.indexOf(cls) >= 0 || root.patterns.indexOf(name) >= 0;

        if (clsMatches == root.blurMatching) {
            if (root.blurContent) {
                registerHintUpdater(client);
            } else {
                //var wid = "0x" + client.windowId.toString(16);
                var wid = client.windowId;
                console.log('FORCE-BLUR: targeting the following id:', wid)
                console.log('FORCE-BLUR: executed: xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id ', wid)
                shell.run("xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id " + wid);
            }
        }
    }

    /*
     * debug function
     */
    function debug(client) {
        print("------ on debug ------", client)
        print("------ on debug ------", client.windowId)
    }

    function registerHintUpdater(client) {
        var prevWidth  = client.geometry.width;
        var prevHeight = client.geometry.height;
        var handler = function() {
            try { if (!root) return; } catch(e) {
                client.geometryChanged.disconnect(handler);
                throw e;
            }

            root.onClientGeometryChanged(client, prevWidth, prevHeight);

            prevWidth  = client.geometry.width;
            prevHeight = client.geometry.height;
        }

        client.geometryChanged.connect(handler);
        root.onClientGeometryChanged(client, 0, 0);
    }

    /*
     * Update the blur area when the geometry of the window change
     * client : the targeted window
     * prevWidth : the width value before the change
     * prevHeight : the height value before the change
     */
    function onClientGeometryChanged(client, prevWidth, prevHeight) {
        if (!shell) return;

        /* Skip if window *size* isn't really changed */
        if (client.geometry.width === prevWidth && client.geometry.height === prevHeight)
            return;

        //var wid = "0x" + client.windowId.toString(16);
        var wid = client.windowId;
        var region = "0,0," + client.geometry.width + "," + client.geometry.height;
        var cmd = "xprop -id " + wid + " -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION " + region
        shell.run(cmd);
    }

    Component.onCompleted: {
        console.log("FORCE-BLUR: starting the script");
        console.log(JSON.stringify(root.patterns));

        var clients = workspace.clientList();
        console.log("FORCE-BLUR: current list of clients:", JSON.stringify(clients));

        for (var i = 0; i < clients.length; i++) {
            root.onClientAdded(clients[i]);
        }

        workspace.onClientAdded.connect(root.onClientAdded);
        workspace.onClientAdded.connect(root.debug);
    }
}
