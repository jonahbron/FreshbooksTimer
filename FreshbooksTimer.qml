import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Layouts 0.1
import "components"
import "left_zero_pad.js" as LeftZeroPad
import "parse_query.js" as ParseQuery
import "oauth.js" as OAuth

/*
 * Timer app for Freshbooks
 *
 * @author Jonah Dahlquist <jonah@nucleussystems.com>
 * @copyright Copyright 2014 Jonah Dahlquist
 * @license BSD 3
 */

Window {
    id: topWindow
    visible: true
    width: options.windowWidth
    height: options.windowHeight
    title: "Freshbooks Timer"

    onWidthChanged: options.windowWidth = width
    onHeightChanged: options.windowHeight = height

    MainView {

        id: root
        // objectName for functional testing purposes (autopilot-qt5)
        objectName: "mainView"

        // Note! applicationName needs to match the "name" field of the click manifest
        applicationName: "com.nucleussystems.app.freshbookstimer"

        /*
        This property enables the application to change orientation
        when the device is rotated. The default is false.
        */
        //automaticOrientation: true

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            left: parent.left
        }

        backgroundColor: "#648c0f"

        property real margins: units.gu(2)

        Options {
            id: options

            onAuthenticationChanged: {
                projects.load()
            }
        }

        PageStack {

            id: pageStack
            Component.onCompleted: {
                LeftZeroPad.setup()
                ParseQuery.setup()

                push(main)
                if (!OAuth.canRequest(options)) {
                    oauthPage.show()
                }
            }

            onCurrentPageChanged: {
                topWindow.width = currentPage.windowWidth ? currentPage.windowWidth : options.windowWidth
                topWindow.height = currentPage.windowHeight ? currentPage.windowHeight : options.windowHeight
            }

            Page {
                id: main

                title: i18n.tr("Freshbooks Timer")
                visible: false

                tools: ToolbarItems {
                    ToolbarButton {
                        action: Action {
                            text: "Settings"
                            iconSource: Qt.resolvedUrl("img/settings.svg")
                            onTriggered: pageStack.push(settings)
                        }
                    }
                    ToolbarButton {
                        action: Action {
                            text: "Reload"
                            iconSource: Qt.resolvedUrl("img/reload.svg")
                            onTriggered: {
                                projects.xml = ""
                                tasks.xml = ""
                                projects.load()
                            }
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

                Layouts {
                    objectName: "layouts"
                    id: pageLayout

                    anchors.fill: parent
                    layouts: [
                        ConditionalLayout {
                            name: "1-column"
                            when: pageLayout.width <= units.gu(70)

                            Column {
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                spacing: units.gu(1)

                                ItemLayout {
                                    item: "timer"
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: units.gu(6.2)
                                }
                                ItemLayout {
                                    item: "projectSelector"
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: Math.max(projectSelector.implicitHeight, units.gu(6.2))
                                }
                                ItemLayout {
                                    item: "taskSelector"
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: Math.max(taskSelector.implicitHeight, units.gu(6.2))
                                }
                                ItemLayout {
                                    item: "save"
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: units.gu(6.2)
                                }
                                ItemLayout {
                                    item: "indicators"
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: units.gu(6.2)
                                }

                            }
                        },

                        ConditionalLayout {
                            name: "2-column"
                            when: pageLayout.width > units.gu(70)
                            id: tabletSize

                            Row {
                                anchors.fill: parent
                                anchors.margins: units.gu(1)
                                spacing: units.gu(1)
                                Column {
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: (parent.width / 2) - units.gu(0.5)
                                    spacing: units.gu(1)

                                    ItemLayout {
                                        item: "projectSelector"
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: Math.max(projectSelector.implicitHeight, units.gu(6.2))
                                    }
                                    ItemLayout {
                                        item: "taskSelector"
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: Math.max(taskSelector.implicitHeight, units.gu(6.2))
                                    }
                                }
                                Column {
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: (parent.width / 2) - units.gu(0.5)
                                    spacing: units.gu(1)

                                    ItemLayout {
                                        item: "timer"
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: units.gu(6.2)
                                    }
                                    ItemLayout {
                                        item: "save"
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: units.gu(6.2)
                                    }
                                    ItemLayout {
                                        item: "indicators"
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: units.gu(6.2)
                                    }
                                }
                            }
                        }

                    ]


                    Column {
                        anchors.fill: parent
                        anchors.margins: units.gu(1)
                        spacing: units.gu(1)

                        TaskTimer {
                            id: timer
                            Layouts.item: "timer"
                        }

                        ProjectSelector {
                            id: projectSelector
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: units.gu(6.2)
                            currentlyExpanded: pageLayout.currentLayout == tabletSize.name && !taskSelector.currentlyExpanded
                            Layouts.item: "projectSelector"
                        }
                        TaskSelector {
                            id: taskSelector
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: units.gu(6.2)
                            Layouts.item: "taskSelector"
                        }
                        SaveButton {
                            id: save
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: units.gu(6.2)
                            Layouts.item: "save"
                        }
                        Timer {
                            id: cannotTimer
                            interval: 2000
                            running: false
                            repeat: false
                        }
                        Timer {
                            id: savedTimer
                            interval: 2000
                            running: false
                            repeat: false
                        }
                        Item {
                            Layouts.item: "indicators"

                            ActivityIndicator {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                visible: save.isSaving
                                running: save.isSaving
                            }
                            Label {
                                visible: savedTimer.running
                                text: "Saved"
                                horizontalAlignment: Text.AlignHCenter
                                fontSize: "large"
                                anchors.left: parent.left
                                anchors.right: parent.right
                            }
                            Label {
                                visible: cannotTimer.running
                                text: "Cannot save time entry"
                                horizontalAlignment: Text.AlignHCenter
                                fontSize: "large"
                                anchors.left: parent.left
                                anchors.right: parent.right
                            }
                        }
                    }
                }
            }

            SettingsPage {
                id: settings
                visible: false
            }
            OAuthPage {
                id: oauthPage
            }
        }
    }
}
