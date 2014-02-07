import QtQuick 2.0
import Ubuntu.Components 0.1
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import "components"

/*!
    \brief MainView with a Label and Button elements.
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

    Page {
        title: i18n.tr("Freshbooks Timer")

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

        ActivityIndicator {
            anchors.right: parent.right
            running: projectsFetcher.status !== XmlListModel.Ready
        }

        ActivityIndicator {
            anchors.right: parent.right
            running: tasksFetcher.status !== XmlListModel.Ready
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
                }
            }
        }
    }
}
