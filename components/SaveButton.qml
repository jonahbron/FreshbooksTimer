import QtQuick 2.0
import Ubuntu.Components 0.1

Button {
    width: pageLayout.width
    text: "Save"
    property bool isSaving: false
    onClicked: {
        var currentTime = timer.currentTime
        if (currentTime.time == 0) {
            cannotTimer.restart()
            return
        }

        currentTime.stopTimer()

        var http = new XMLHttpRequest()
        var url = "https://c4f327f50410448fa2b68bd800d6cc0f@nucleussystems.freshbooks.com/api/2.1/xml-in"
        var body = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
                "<request method=\"time_entry.create\">" +
                "<time_entry>" +
                "<project_id>" + projects.getProjectId(projectSelector.projectIndex) + "</project_id>" +
                "<task_id>" + tasks.getTaskId(taskSelector.taskIndex) + "</task_id>" +
                "<hours>" + (currentTime.time / 3600) + "</hours>" +
                "</time_entry>" +
                "</request>"
        http.open("POST", url, true);
        http.setRequestHeader("Content-length", body.length);
        http.setRequestHeader("Connection", "close");
        http.onreadystatechange = function() {
            if (http.readyState == 4) {
                isSaving = false
                // Have to use regex, parsing XML throws stack error
                if (http.responseText.match(/status=\"ok\"/)) {
                    currentTime.setTime(0)
                    savedTimer.restart()
                }
            }
        }
        http.send(body)
        isSaving = true
    }

}
