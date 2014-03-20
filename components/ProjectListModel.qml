import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import "../oauth.js" as OAuth

XmlListModel {
    query: "/response/projects/project"
    namespaceDeclarations: "declare default element namespace 'http://www.freshbooks.com/api/';"
    XmlRole { name: "project_id"; query: "project_id/string()" }
    XmlRole { name: "name"; query: "name/string()" }
    Component.onCompleted: {
        if (OAuth.canRequest(options)) {
            load()
        }
    }


    function load() {
        OAuth.apiCall(
                    options,
                    "<?xml version=\"1.0\" encoding=\"utf-8\"?><request method=\"project.list\"></request>",
                    function(responseText) {
                        xml = responseText
                        reload()
                    }
                    )
    }
    function getName(idx) {
        return (idx >= 0 && idx < count) ? get(idx).name : "";
    }
    function getProjectId(idx) {
        return (idx >= 0 && idx < count) ? get(idx).project_id : 0.0;
    }
}
