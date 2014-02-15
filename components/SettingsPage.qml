import QtQuick 2.0
import QtWebKit 3.0
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
            Button {
                text: "Sign In"
                onClicked: {
                    loginView.account = systemName.text
                    loginView.getToken()
                }
            }
        }
        Row {
            WebView {
                width: settingsLayout.width
                height: settingsLayout.width
                id: loginView
                onUrlChanged: OAuth.urlChanged(url)
                property string account: ""
                function getToken() {
                    var http = new XMLHttpRequest()
                    var url = "https://" + account + ".freshbooks.com/oauth/oauth_request.php?"
                    var data = {
                        oauth_consumer_key: "nucleussystems",
                        oauth_signature_method: "PLAINTEXT",
                        oauth_signature: "mHASXW64WpgvPMGYg5CqD9Wy6kUC7gm9D&",
                        oauth_version: "1.0",
                        oauth_timestamp: parseInt(String(Date.now() / 1000)),
                        oauth_nonce: Math.random().toString(36),
                        oauth_callback: "oob",
                    }
                    for (var key in data) {
                        url += encodeURIComponent(key) + "=" + encodeURIComponent(data[key]) + "&"
                    }
                    http.open("POST", url, true);
                    http.setRequestHeader("Connection", "close");
                    http.onreadystatechange = function() {
                        if (http.readyState == 4) {
                            console.log(http.responseText)
                        }
                    }
                    http.send()
                }
            }
        }
    }
}
