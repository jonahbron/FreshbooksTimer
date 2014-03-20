import QtQuick 2.0
import Ubuntu.Components 0.1

OptionSelector {
    id: projectSelector
    property int projectIndex: 0
    width: pageLayout.width
    containerHeight: pageLayout.height / 2
    model: projects
    delegate: OptionSelectorDelegate {
        text: name
        onClicked: {
            projectSelector.projectIndex = index
            tasks.loadByProjectId(projects.getProjectId(index))
        }
    }
    height: model.count > 0 ? undefined : units.gu(6.2)

    ActivityIndicator {
        running: projects.count < 1
        visible: running
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}
