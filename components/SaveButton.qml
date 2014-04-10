import QtQuick 2.0
import Ubuntu.Components 0.1
import "../oauth.js" as OAuth

GreenButton {
    width: parent.width
    height: units.gu(6)
    text: "Save"
    property bool isSaving: false
    onClicked: {
        var currentTime = timer.currentTime
        if (currentTime.time == 0) {
            cannotTimer.restart()
            return
        }

        currentTime.stopTimer()

        var body = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
                "<request method=\"time_entry.create\">" +
                "<time_entry>" +
                "<project_id>" + projects.getProjectId(projectSelector.projectIndex) + "</project_id>" +
                "<task_id>" + tasks.getTaskId(taskSelector.taskIndex) + "</task_id>" +
                "<hours>" + (currentTime.time / 3600) + "</hours>" +
                "</time_entry>" +
                "</request>"

        OAuth.apiCall(
                    options,
                    body,
                    function(responseText) {
                        isSaving = false
                        // Have to use regex, parsing XML throws stack error
                        if (responseText.match(/status=\"ok\"/)) {
                            currentTime.setTime(0)
                            savedTimer.restart()
                        }
                    }
                    )
        isSaving = true
    }

}
