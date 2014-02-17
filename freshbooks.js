
Qt.include("oauth.js")

function configToHeader(options) {
    var values = []
    for (var key in options) {
        values.push(key + "\"" + options[key] + "\"")
    }
    return values.join(",")
}

function url(account) {
    return "https://" + account + ".freshbooks.com/api/2.1/xml-in"
}

function request(account, token, body, onReady) {
    var http = new XMLHttpRequest()
    var url = url(account)
    var authorization = config({
        "OAuth realm": "",
        oauth_token: token,
    })
    http.open("POST", url, true);
    http.setRequestHeader("Content-length", body.length);
    http.setRequestHeader("Connection", "close");
    http.setRequestHeader("Authorization", configToHeader(authorization))
    http.onreadystatechange = function() {
        if (http.readyState == 4) {
            xml = http.responseText
            reload()
        }
    }
    http.send(body)
}
