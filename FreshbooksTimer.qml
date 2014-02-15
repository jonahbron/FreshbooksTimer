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
    applicationName: "com.ubuntu.developer.jonahbron.FreshbooksTimer"

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

            ProjectListModel {
                id: projects
                onStatusChanged: {
                    if (status == XmlListModel.Ready)
                        tasks.loadByProjectId(projects.getProjectId(0))
                }
            }

            TaskListModel {
                id: tasks
            }

            Column {
                id: pageLayout

                anchors {
                    fill: parent
                    margins: root.margins
                }

                spacing: units.gu(1)

                Row {

                    ProjectSelector {
                        id: projectSelector
                    }
                }

                Row {
                    TaskSelector {
                        id: taskSelector
                    }
                }

                TaskTimer {}

                Row {

                    SaveButton {
                        id: save
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

        SettingsPage {
            id: settings
            visible: false
        }
    }
}
