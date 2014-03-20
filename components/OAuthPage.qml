import QtQuick 2.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import Ubuntu.Components 0.1
import "../oauth.js" as OAuth

Page {
    title: i18n.tr("Freshbooks Login")

    Column {
        id: settingsLayout
        spacing: units.gu(1)

        anchors {
            fill: parent
            margins: root.margins
        }

        Row {
            id: labelRow
            Label {
                text: i18n.tr("Freshbooks Account Name")
            }
        }
        Row {
            id: systemNameRow
            TextField {
                id: systemName
                text: ""
                width: settingsLayout.width
            }
        }
        Row {
            id: buttonRow
            GreenButton {
                text: "Sign In"
                onClicked: {
                    loginView.account = systemName.text
                    loginView.getToken()
                    loginView.visible = true
                }
            }
        }
        Row {
            WebView {
                width: settingsLayout.width
                height: settingsLayout.height - labelRow.height - systemNameRow.height - buttonRow.height - units.gu(3)
                visible: false
                id: loginView
                onTitleChanged: {
                    var verifier = OAuth.getVerifier(title)
                    if (verifier) {
                        OAuth.request(
                            OAuth.url(account, "access", OAuth.config({
                                oauth_verifier: verifier,
                                oauth_token: oauth_token
                            })),
                            function(responseText) {
                                var response = responseText.parseQuery()
                                options.setAuthentication(account, response.oauth_token, response.oauth_token_secret)

                                pageStack.pop()
                                loginView.visible = false
                                systemName.text = ""
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
