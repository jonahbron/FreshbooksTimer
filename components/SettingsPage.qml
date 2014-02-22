import QtQuick 2.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import Ubuntu.Components 0.1
import "../oauth.js" as OAuth

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
            GreenButton {
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
                onTitleChanged: {
                    var verifier = OAuth.getVerifier(title)
                    if (verifier) {
                        console.log(verifier)
                        OAuth.request(
                            OAuth.url(account, "access", OAuth.config({
                                oauth_verifier: verifier,
                                oauth_token: oauth_token
                            })),
                            function(responseText) {
                                var response = responseText.parseQuery()
                                options.oauth_token = response.oauth_token
                                options.freshbooks_account = account
                            }
                        )
                    }
                }
                onLoadingChanged: {
                    if (loadRequest.status == WebView.LoadSucceededStatus) {
                        OAuth.exposeToken(loginView)
                    }
                }
                property string account: ""
                property string oauth_token: ""
                function getToken() {
                    OAuth.request(OAuth.url(account, "request", OAuth.config({})), function(responseText) {
                        var response = responseText.parseQuery()
                        oauth_token = response.oauth_token
                        loginView.url = OAuth.url(account, "authorize", {oauth_token: oauth_token})

                    })
                }
            }
        }
    }
}
