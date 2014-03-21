import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    title: i18n.tr("Settings")

    Column {
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            left: parent.left
        }
        ListItem.Subtitled {
            text: options.oauthToken ? "Log-out of Freshbooks" : "Log-in to Freshbooks"
            subText: options.freshbooksAccount

            onClicked: {
                if (options.oauthToken) {
                    options.oauthToken = ""
                    options.oauthTokenSecret = ""
                    options.freshbooksAccount = ""
                } else {
                    oauthPage.show()
                }
            }
        }
    }

}
