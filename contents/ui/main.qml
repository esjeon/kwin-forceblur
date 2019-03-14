import QtQuick 2.0
import QtQuick.Window 2.12
import org.kde.plasma.core 2.0 as PlasmaCore;
import org.kde.plasma.components 2.0 as Plasma;
import org.kde.kwin 2.0;

Item {
    id: root

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

        if (client.resourceClass.toString() === "st-256color") {
            var wid = "0x" + client.windowId.toString(16);
            shell.run("xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id " + wid);
        }
    }

    Component.onCompleted: {
        console.log("FORCE-BLUR: starting the script");

        var clients = workspace.clientList();
        for (var i = 0; i < clients.length; i++) {
            root.onClientAdded(clients[i]);
        }

        workspace.onClientAdded.connect(root.onClientAdded);

        console.log("patterns=" + KWin.readConfig("patterns", ""));
    }
}
