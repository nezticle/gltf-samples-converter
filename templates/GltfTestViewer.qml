import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick3D
import QtQuick3D.Helpers

Window {
    id: window
	visible: true
	width: 1920
	height: 1280
	title: qsTr("GLTF Viewer")

    property bool isFullscreen: false

	Node {
        id: sceneRoot

        Node {
            id: originNode
            PerspectiveCamera {
                id: cameraNode
                z: 600
                clipNear: 0.1
                clipFar: 1000
                function resetView() {
                    originNode.position = Qt.vector3d(0, 0, 0)
                    cameraNode.position = Qt.vector3d(0, 0, 600)
                    originNode.eulerRotation = Qt.vector3d(0, 0, 0)
                }
            }
        }

        Loader3D {
            id: loadedItem
            source: testsModel.get(listView.currentIndex).source

        }
    }

    GltfTestsModel {
        id: testsModel
    }

    Component {
        id: testDelegate
        Item {
            id: wrapper
            width: 200; height: 55
            Text {
                text: name
            }
            MouseArea {
                anchors.fill: parent
                onClicked: wrapper.ListView.view.currentIndex = index
            }
        }
    }

    Component {
        id: highlightBar
        Rectangle {
            width: 200; height: 50
            color: "limegreen"
            y: listView.currentItem.y;
        }
    }

    View3D {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: selectionRect.left
        importScene: sceneRoot
		environment: SceneEnvironment {
            lightProbe: Texture {
                source: "environment.hdr"
            }
            backgroundMode: SceneEnvironment.SkyBox
        }
    }

    OrbitCameraController {
        origin: originNode
        camera: cameraNode
    }

    Rectangle {
        id: selectionRect
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: !window.isFullscreen
        width: !window.isFullscreen ? 200 : 0
        ColumnLayout {
            anchors.fill: parent

            RadioButton {
                width: parent.width
                height: 55
                z: 1
                text: "Scale x 1"
                checked: true
                onCheckedChanged: {
                    if (checked)
                        loadedItem.scale = Qt.vector3d(1, 1, 1)
                }
            }
            RadioButton {
                width: parent.width
                height: 55
                z: 1
                text: "Scale x 10"
                onCheckedChanged: {
                    if (checked)
                        loadedItem.scale = Qt.vector3d(10, 10, 10)
                }
            }
            RadioButton {
                width: parent.width
                height: 55
                z: 1
                text: "Scale x 100"
                onCheckedChanged: {
                    if (checked)
                        loadedItem.scale = Qt.vector3d(100, 100, 100)
                }
            }
            RadioButton {
                width: parent.width
                height: 55
                z: 1
                text: "Scale x 1000"
                onCheckedChanged: {
                    if (checked)
                        loadedItem.scale = Qt.vector3d(1000, 1000, 1000)
                }
            }
            RadioButton {
                width: parent.width
                height: 55
                z: 1
                text: "Scale x 10000"
                onCheckedChanged: {
                    if (checked)
                        loadedItem.scale = Qt.vector3d(10000, 10000, 10000)
                }
            }
            Button {
                onClicked: cameraNode.resetView()
                text: "Recenter view"
            }
            Button {
                text: "Previous"
                onClicked: {
                    listView.decrementCurrentIndex()
                }
            }

            ListView {
                id: listView
                width: parent.width
                ColumnLayout.fillHeight: true
                model: testsModel
                delegate: testDelegate
                highlight: highlightBar
                highlightFollowsCurrentItem: true
                clip: true
             }

             Button {
                 text: "Next"
                 onClicked: {
                     listView.incrementCurrentIndex()
                 }
             }
        }
    }
}
