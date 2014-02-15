import QtQuick 2.0
import Ubuntu.Components 0.1

OptionSelector {
    property int taskIndex: 0
    width: pageLayout.width
    containerHeight: pageLayout.height / 2
    model: tasks
    delegate: OptionSelectorDelegate {
        text: name
        onClicked: {
            taskSelector.taskIndex = index
        }
    }
}
