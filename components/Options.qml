import QtQuick 2.0
import U1db 1.0 as U1db

Item {
    id: options

    property bool authentication: false

    property string freshbooksAccount: optionsDocument.contents.freshbooks_account
    property string oauthToken: optionsDocument.contents.oauth_token
    property string oauthTokenSecret: optionsDocument.contents.oauth_token_secret

    onFreshbooksAccountChanged: {
        set("freshbooks_account", freshbooksAccount)
    }
    onOauthTokenChanged: {
        set("oauth_token", oauthToken)
    }

    onOauthTokenSecretChanged: {
        set("oauth_token_secret", oauthTokenSecret)
    }

    function set(key, value) {
        var tempContents = optionsDocument.contents
        tempContents[key] = value
        optionsDocument.contents = tempContents
    }
    function get(key) {
        return optionsDocument.contents[key]
    }

    function setAuthentication(account, token, tokenSecret) {
        freshbooksAccount = account
        oauthToken = token
        oauthTokenSecret = tokenSecret

        // Trigger onAccountChanged event
        authentication = !authentication
    }

    U1db.Database {
        id: optionsDatabase
        path: "options"
    }

    U1db.Document {
        id: optionsDocument
        database: optionsDatabase
        docId: 'options'
        create: true
        defaults: {
            "freshbooks_account": "",
            "oauth_token": "",
            "oauth_token_secret": ""
        }
    }
}
