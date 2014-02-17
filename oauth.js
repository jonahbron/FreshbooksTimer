
function config(options) {
    options.oauth_consumer_key = "nucleussystems";
    options.oauth_signature_method = "PLAINTEXT";
    options.oauth_signature = "mHASXW64WpgvPMGYg5CqD9Wy6kUC7gm9D&";
    options.oauth_version = "1.0";
    options.oauth_timestamp = parseInt(String(Date.now() / 1000));
    options.oauth_nonce = Math.random().toString(36);
    options.oauth_callback = "oob";
    return options;
}

function url(account, action, options) {
    return "https://" + account + ".freshbooks.com/oauth/oauth_" + action + ".php?" + options.toQuery()
}

function exposeToken(webView) {
    webView.experimental.evaluateJavaScript("var m=document.getElementById('oauth_box_main').innerHTML.match(new RegExp('Verifier\:<\/strong> ([a-zA-Z0-9]{33})'));if (m!=null)document.title='oauth_verifier=' + m[1];")
}

function request(url, onReady) {
    var http = new XMLHttpRequest()
    http.open("POST", url, true);
    http.setRequestHeader("Connection", "close");
    http.onreadystatechange = function() {
        if (http.readyState == 4) {
            onReady(http.responseText)
        }
    }
    http.send()
}

function getVerifier(title) {
    var match = title.match(/oauth_verifier\=([a-zA-Z0-9]{33})/)
    if (match !== null) {
        return match[1]
    } else {
        return false
    }
}
