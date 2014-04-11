import QtQuick 2.0
import Ubuntu.Components 0.1

OptionSelector {
    property int taskIndex: 0
    width: pageLayout.width
    containerHeight: pageLayout.height - itemHeight - units.gu(3)
    model: tasks.count > 0 ? tasks : emptyList
    delegate: OptionSelectorDelegate {
        text: name
        onClicked: {
            taskSelector.taskIndex = index
        }
    }
    height: model.count > 0 ? undefined : units.gu(6)

    ActivityIndicator {
        running: tasks.count < 1
        visible: running
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    ListModel {
        id: emptyList
        ListElement { name: "" }
    }
}
