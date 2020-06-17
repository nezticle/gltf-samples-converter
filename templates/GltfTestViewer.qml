import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick3D 1.15
import QtQuick3D.Helpers 1.15

Window {
	visible: true
	width: 1920
	height: 1280
	title: qsTr("GLTF Viewer")




	Node {
        id: sceneRoot

        PerspectiveCamera {
            id: camera
            z: 600
            x: 0
            y: 0
            function resetView() {
                position = Qt.vector3d(0, 0, 600)
                //cameraOrigin.position = Qt.vector3d(0,0,0)
                //cameraOrigin.eulerRotation = Qt.vector3d(0, 0, 0)
                camera.eulerRotation = Qt.vector3d(0, 0, 0)
            }
        }

        DirectionalLight {

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

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            onEntered: {
                wasdController.focus = true
                wasdController.keysEnabled = true
                wasdController.mouseEnabled = true
            }
        }
    }


    WasdController {
        id: wasdController
        controlledObject: camera
        keysEnabled: true
    }

    Rectangle {
        id: selectionRect
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 200
        Column {
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
            Rectangle {
                width: parent.width
                height: 55
                z: 1
                Button {
                    anchors.fill: parent
                    onClicked: camera.resetView()
                    text: "Recenter view"
                }
            }

            ListView {
                id: listView
                width: parent.width
                height: parent.height - 55
                model: testsModel
                delegate: testDelegate
                highlight: highlightBar
                highlightFollowsCurrentItem: true
             }
        }
    }

}