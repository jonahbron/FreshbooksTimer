import QtQuick 2.0
import QtQuick.XmlListModel 2.0

XmlListModel {
    query: "/response/projects/project"
    namespaceDeclarations: "declare default element namespace 'http://www.freshbooks.com/api/';"
    XmlRole { name: "project_id"; query: "project_id/string()" }
    XmlRole { name: "name"; query: "name/string()" }
    Component.onCompleted: load()

    function load() {
        var http = new XMLHttpRequest()
        var url = "https://c4f327f50410448fa2b68bd800d6cc0f@nucleussystems.freshbooks.com/api/2.1/xml-in"
        var body = "<?xml version=\"1.0\" encoding=\"utf-8\"?><request method=\"project.list\"></request>"
        http.open("POST", url, true);
        http.setRequestHeader("Content-length", body.length);
        http.setRequestHeader("Connection", "close");
        http.onreadystatechange = function() {
            if (http.readyState == 4) {
                xml = http.responseText
                reload()
            }
        }
        http.send(body)
    }
    function getName(idx) {
        return (idx >= 0 && idx < count) ? get(idx).name : "";
    }
    function getProjectId(idx) {
        return (idx >= 0 && idx < count) ? get(idx).project_id : 0.0;
    }
}
