import QtQuick 2.0
import Ubuntu.Components 0.1

Page {
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
