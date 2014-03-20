import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import "../oauth.js" as OAuth

XmlListModel {
    query: "/response/tasks/task"
    namespaceDeclarations: "declare default element namespace 'http://www.freshbooks.com/api/';"
    XmlRole { name: "task_id"; query: "task_id/string()" }
    XmlRole { name: "name"; query: "name/string()" }

    function loadByProjectId(project_id) {
        OAuth.apiCall(
                    options,
                    "<?xml version=\"1.0\" encoding=\"utf-8\"?><request method=\"task.list\"><project_id>" + project_id + "</project_id></request>",
                    function(responseText) {
                        xml = responseText
                        reload()
                    }
                    )
    }
    function getName(idx) {
        return (idx >= 0 && idx < count) ? get(idx).name : "";
    }
    function getTaskId(idx) {
        return (idx >= 0 && idx < count) ? get(idx).task_id : 0.0;
    }
}
