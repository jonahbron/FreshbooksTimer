import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import "components"
import "left_zero_pad.js" as LeftZeroPad

/*
 * Timer app for Freshbooks
 *
 * @author Jonah Dahlquist <jonah@nucleussystems.com>
 * @copyright Copyright 2014 Jonah Dahlquist
 * @license BSD 3
 */

MainView {

    id: root
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.developer..FreshbooksTimer"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    width: units.gu(40)
    height: units.gu(75)

    property real margins: units.gu(2)

    PageStack {

        id: pageStack
        Component.onCompleted: {
            LeftZeroPad.setup()
            push(main)
        }

        Page {
            id: main

            title: i18n.tr("Freshbooks Timer")
            visible: false

            tools: ToolbarItems {
                ToolbarButton {
                    action: Action {
                        text: "Settings"
                        iconSource: Qt.resolvedUrl("/usr/share/icons/ubuntu-mobile/actions/scalable/settings.svg")
                        onTriggered: pageStack.push(settings)
                    }
                }
            }

            ListModel {
                id: projects
                function getName(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).name : "";
                }
                function getProjectId(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).project_id : 0.0;
                }
            }

            ListModel {
                id: tasks
                function getName(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).name : "";
                }
                function getTaskId(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).task_id : 0.0;
                }
            }

            Component.onCompleted: {
                projectsFetcher.load()
            }

            XmlListModel {
                id: projectsFetcher
                query: "/response/projects/project"
                namespaceDeclarations: "declare default element namespace 'http://www.freshbooks.com/api/';"
                onStatusChanged: {
                    if (status == XmlListModel.Ready) {
                        projects.clear()
                        for (var i = 0; i < count; i++)
                            projects.append({"project_id": parseInt(get(i).project_id), "name": get(i).name});
                        tasksFetcher.loadByProjectId(projects.getProjectId(0))
                    }
                }
                XmlRole { name: "project_id"; query: "project_id/string()" }
                XmlRole { name: "name"; query: "name/string()" }

                function load() {
                    var http = new XMLHttpRequest()
                    var url = "https://c4f327f50410448fa2b68bd800d6cc0f@nucleussystems.freshbooks.com/api/2.1/xml-in"
                    var body = "<?xml version=\"1.0\" encoding=\"utf-8\"?><request method=\"project.list\"></request>"
                    http.open("POST", url, true);
                    http.setRequestHeader("Content-length", body.length);
                    http.setRequestHeader("Connection", "close");
                    http.onreadystatechange = function() {
                        if (http.readyState == 4) {
                            projectsFetcher.xml = http.responseText
                            projectsFetcher.reload()
                        }
                    }
                    http.send(body)
                }
            }

            XmlListModel {
                id: tasksFetcher
                query: "/response/tasks/task"
                namespaceDeclarations: "declare default element namespace 'http://www.freshbooks.com/api/';"
                onStatusChanged: {
                    if (status == XmlListModel.Ready) {
                        tasks.clear()
                        for (var i = 0; i < count; i++)
                            tasks.append({"task_id": parseInt(get(i).task_id), "name": get(i).name});
                    }
                }
                XmlRole { name: "task_id"; query: "task_id/string()" }
                XmlRole { name: "name"; query: "name/string()" }

                function loadByProjectId(project_id) {
                    var http = new XMLHttpRequest()
                    var url = "https://c4f327f50410448fa2b68bd800d6cc0f@nucleussystems.freshbooks.com/api/2.1/xml-in"
                    var body = "<?xml version=\"1.0\" encoding=\"utf-8\"?><request method=\"task.list\"><project_id>" + project_id + "</project_id></request>"
                    http.open("POST", url, true);
                    http.setRequestHeader("Content-length", body.length);
                    http.setRequestHeader("Connection", "close");
                    http.onreadystatechange = function() {
                        if (http.readyState == 4) {
                            tasksFetcher.xml = http.responseText
                            tasksFetcher.reload()
                        }
                    }
                    http.send(body)
                }
            }

            Component {
                id: projectSelector
                Popover {
                    Column {
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
                        height: pageLayout.height
                        Header {
                            id: header
                            text: i18n.tr("Select project")
                        }
                        ListView {
                            clip: true
                            width: parent.width
                            height: parent.height - header.height
                            model: projects
                            delegate: Standard {
                                text: name
                                onClicked: {
                                    caller.projectIndex = index
                                    tasksFetcher.loadByProjectId(projects.getProjectId(index))
                                    hide()
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: taskSelector
                Popover {
                    Column {
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
                        height: pageLayout.height
                        Header {
                            id: header
                            text: i18n.tr("Select task")
                        }
                        ListView {
                            clip: true
                            width: parent.width
                            height: parent.height - header.height
                            model: tasks
                            delegate: Standard {
                                text: name
                                onClicked: {
                                    caller.taskIndex = index
                                    hide()
                                }
                            }
                        }
                    }
                }
            }

            Column {
                id: pageLayout

                anchors {
                    fill: parent
                    margins: root.margins
                }

                spacing: units.gu(1)

                Row {
                    spacing: units.gu(0)

                    Button {
                        id: selectorProject
                        property int projectIndex: 0
                        text: projects.getName(projectIndex)
                        onClicked: PopupUtils.open(projectSelector, selectorProject)
                        width: pageLayout.width
                        gradient: UbuntuColors.greyGradient

                        ActivityIndicator {
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                rightMargin: units.gu(1)
                            }
                            running: projectsFetcher.status !== XmlListModel.Ready
                        }
                    }
                }

                Row {
                    spacing: units.gu(1)

                    Button {
                        id: selectorTask
                        property int taskIndex: 0
                        text: tasks.getName(taskIndex)
                        onClicked: PopupUtils.open(taskSelector, selectorTask)
                        width: pageLayout.width
                        gradient: UbuntuColors.greyGradient

                        ActivityIndicator {
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                rightMargin: units.gu(1)
                            }
                            running: tasksFetcher.status !== XmlListModel.Ready
                        }
                    }
                }

                Row {
                    spacing: units.gu(1)

                    Label {
                        id: currentTime
                        text: "00:00:00"
                        fontSize: "x-large"
                        width: (pageLayout.width / 2) - (units.gu(1) / 2)
                        horizontalAlignment: Text.AlignHCenter
                        property int time: 0
                        property int lastTime: 0
                        property int startTime: 0
                        function setTime(seconds) {
                            time = seconds
                            lastTime = time
                        }

                        function startTimer() {
                            if (startTime == 0) {
                                startTime = Date.now() / 1000
                                timer.start()
                            }
                        }
                        function stopTimer() {
                            if (startTime != 0) {
                                timer.stop()
                                tick()
                                currentTimeInput.text = String((time / 3600).toFixed(3))
                                startTime = 0
                            }
                            lastTime = time
                        }
                        function tick() {
                            time = ((Date.now() / 1000) - startTime) + lastTime
                        }
                        onTimeChanged: {
                            var seconds = time
                            var floor_hours = Math.max(0, Math.floor(seconds / 3600)).leftZeroPad(2)
                            seconds = seconds % 3600
                            var floor_minutes = Math.max(0, Math.floor(seconds / 60)).leftZeroPad(2)
                            seconds = seconds % 60
                            var floor_seconds = Math.max(0, Math.floor(seconds)).leftZeroPad(2)
                            text = "" + floor_hours + ":" + floor_minutes + ":" + floor_seconds
                        }

                        Timer {
                            id: timer
                            interval: 200
                            running: false
                            repeat: true
                            onTriggered: {
                                currentTime.tick()
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: currentTimeInput.startEdit()
                        }
                    }

                    TextField {
                        id: currentTimeInput
                        errorHighlight: false
                        width: currentTime.width
                        text: "0.0"
                        font.pixelSize: FontUtils.sizeToPixels("large")
                        height: start.height
                        visible: !currentTime.visible
                        function startEdit() {
                            currentTime.stopTimer()
                            currentTime.visible = false
                            currentTimeInput.forceActiveFocus()
                            currentTimeInput.selectAll()
                        }
                        function endEdit() {
                            currentTime.visible = true
                            currentTime.setTime(Math.max(0, Math.floor(parseFloat(text) * 3600)))
                        }
                    }

                    Button {
                        id: start
                        width: (pageLayout.width / 2) - (units.gu(1) / 2)
                        visible: !timer.running && !currentTimeInput.visible
                        text: "Start"
                        onClicked: currentTime.startTimer()
                    }

                    Button {
                        id: pause
                        width: start.width
                        height: start.height
                        text: "Pause"
                        visible: timer.running && !currentTimeInput.visible
                        onClicked: currentTime.stopTimer()
                    }

                    Button {
                        id: set
                        width: start.width
                        height: start.height
                        text: "Set"
                        visible: currentTimeInput.visible
                        gradient: UbuntuColors.greyGradient
                        onClicked: currentTimeInput.endEdit()
                    }
                }

                Row {

                    Button {
                        id: save
                        width: pageLayout.width
                        text: "Save"
                        property bool isSaving: false
                        onClicked: {
                            if (currentTime.time == 0) {
                                cannotTimer.restart()
                                return
                            }

                            currentTime.stopTimer()

                            var http = new XMLHttpRequest()
                            var url = "https://c4f327f50410448fa2b68bd800d6cc0f@nucleussystems.freshbooks.com/api/2.1/xml-in"
                            var body = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
                                    "<request method=\"time_entry.create\">" +
                                    "<time_entry>" +
                                    "<project_id>" + projects.getProjectId(selectorProject.projectIndex) + "</project_id>" +
                                    "<task_id>" + tasks.getTaskId(selectorTask.taskIndex) + "</task_id>" +
                                    "<hours>" + (currentTime.time / 3600) + "</hours>" +
                                    "</time_entry>" +
                                    "</request>"
                            http.open("POST", url, true);
                            http.setRequestHeader("Content-length", body.length);
                            http.setRequestHeader("Connection", "close");
                            http.onreadystatechange = function() {
                                if (http.readyState == 4) {
                                    isSaving = false
                                    if (http.responseXML.documentElement.attributes.status.nodeValue === "ok") {
                                        currentTime.setTime(0)
                                        savedTimer.restart()
                                    }
                                }
                            }
                            http.send(body)
                            isSaving = true
                        }

                    }
                }

                Row {

                    ActivityIndicator {
                        width: pageLayout.width
                        visible: save.isSaving
                        running: save.isSaving
                    }

                    Timer {
                        id: savedTimer
                        interval: 2000
                        running: false
                        repeat: false
                    }

                    Label {
                        visible: savedTimer.running
                        text: "Saved"
                        horizontalAlignment: Text.AlignHCenter
                        width: pageLayout.width
                        fontSize: "large"
                    }

                    Timer {
                        id: cannotTimer
                        interval: 2000
                        running: false
                        repeat: false
                    }

                    Label {
                        visible: cannotTimer.running
                        text: "Cannot save time entry"
                        horizontalAlignment: Text.AlignHCenter
                        width: pageLayout.width
                        fontSize: "large"
                    }
                }
            }
        }

        Page {
            id: settings
            visible: false

            title: i18n.tr("Settings")

            Column {
                id: settingsLayout
                spacing: units.gu(1)

                anchors {
                    fill: parent
                    margins: root.margins
                }

                Row {
                    Label {
                        text: i18n.tr("System Name")
                    }
                }
                Row {
                    TextField {
                        id: systemName
                        text: ""
                        width: settingsLayout.width
                    }
                }
                Row {
                    Label {
                        text: i18n.tr("API Key")
                    }
                }
                Row {
                    TextField {
                        id: apiKey
                        text: ""
                        width: settingsLayout.width
                    }
                }
                Row {
                    Button {
                        text: "Save"
                    }
                }
            }
        }
    }
}
