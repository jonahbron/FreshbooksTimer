
function setup() {
    String.prototype.parseQuery = function() {
        var query = {}
        var pairs = String(this).split("&")
        for (var i in pairs) {
            var parts = String(pairs[i]).split("=")
            query[parts[0]] = parts[1]
        }
        return query
    }

    Object.prototype.toQuery = function() {
        var parameters = []
        for (var key in this) {
            if (this.hasOwnProperty(key))
                parameters.push(encodeURIComponent(key) + "=" + encodeURIComponent(this[key]))
        }
        var query = parameters.join("&")
        return query
    }
}
