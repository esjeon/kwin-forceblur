import QtQuick 2.0
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

    PlasmaCore.DataSource {
        id: shell
        engine: 'executable'

        connectedSources: []

        function run(cmd) {
            shell.connectedSources.push(cmd);
        }

        onNewData: {
            var arr = shell.connectedSources;
            arr.splice(arr.indexOf(sourceName));
        }
    }

    function onClientAdded(client) {
        if (!shell) return;

        var cls = client.resourceClass.toString().toLowerCase();
        var name = client.resourceName.toString().toLowerCase();
        var clsMatches = root.patterns.indexOf(cls) >= 0 || root.patterns.indexOf(name) >= 0;

        if (clsMatches == root.blurMatching) {
            var wid = "0x" + client.windowId.toString(16);
            shell.run("xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id " + wid);
        }
    }

    Component.onCompleted: {
        console.log("FORCE-BLUR: starting the script");
        console.log(JSON.stringify(root.patterns));

        var clients = workspace.clientList();
        for (var i = 0; i < clients.length; i++) {
            root.onClientAdded(clients[i]);
        }

        workspace.onClientAdded.connect(root.onClientAdded);
    }
}
