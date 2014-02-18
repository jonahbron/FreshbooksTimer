import QtQuick 2.0
import Ubuntu.Components 0.1

Row {
    property alias currentTime: currentTime
    spacing: units.gu(1)

    Label {
        id: currentTime
        text: "00:00:00"
        fontSize: "x-large"
        width: (pageLayout.width / 2) - (units.gu(1) / 2)
        horizontalAlignment: Text.AlignHCenter
        property int time: 0
        property int lastTime: 0
        property int startTime: 0
        function setTime(seconds) {
            time = seconds
            lastTime = time
        }

        function startTimer() {
            if (startTime == 0) {
                startTime = Date.now() / 1000
                ticker.start()
            }
        }
        function stopTimer() {
            if (startTime != 0) {
                ticker.stop()
                tick()
                currentTimeInput.text = String((time / 3600).toFixed(3))
                startTime = 0
            }
            lastTime = time
        }
        function tick() {
            time = ((Date.now() / 1000) - startTime) + lastTime
        }
        onTimeChanged: {
            var seconds = time
            var floor_hours = Math.max(0, Math.floor(seconds / 3600)).leftZeroPad(2)
            seconds = seconds % 3600
            var floor_minutes = Math.max(0, Math.floor(seconds / 60)).leftZeroPad(2)
            seconds = seconds % 60
            var floor_seconds = Math.max(0, Math.floor(seconds)).leftZeroPad(2)
            text = "" + floor_hours + ":" + floor_minutes + ":" + floor_seconds
        }

        Timer {
            id: ticker
            interval: 200
            running: false
            repeat: true
            onTriggered: {
                currentTime.tick()
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: currentTimeInput.startEdit()
        }
    }

    TextField {
        id: currentTimeInput
        errorHighlight: false
        width: currentTime.width
        text: "0.0"
        font.pixelSize: FontUtils.sizeToPixels("large")
        height: start.height
        visible: !currentTime.visible
        onVisibleChanged: {
            text = String((currentTime.time / 3600).toFixed(3))
        }
        function startEdit() {
            currentTime.stopTimer()
            currentTime.visible = false
            currentTimeInput.forceActiveFocus()
            currentTimeInput.selectAll()
        }
        function endEdit() {
            currentTime.setTime(Math.max(0, Math.floor(parseFloat(text) * 3600)))
            currentTime.visible = true
        }
    }

    Button {
        id: start
        width: (pageLayout.width / 2) - (units.gu(1) / 2)
        visible: !ticker.running && !currentTimeInput.visible
        text: "Start"
        onClicked: currentTime.startTimer()
    }

    Button {
        id: pause
        width: start.width
        height: start.height
        text: "Pause"
        visible: ticker.running && !currentTimeInput.visible
        onClicked: currentTime.stopTimer()
    }

    Button {
        id: set
        width: start.width
        height: start.height
        text: "Set"
        visible: currentTimeInput.visible
        gradient: UbuntuColors.greyGradient
        onClicked: currentTimeInput.endEdit()
    }

}
