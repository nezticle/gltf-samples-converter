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

        PerspectiveCamera {
            id: camera
            z: 600
            function resetView() {
                position = Qt.vector3d(0, 0, 600)
                camera.eulerRotation = Qt.vector3d(0, 0, 0)
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
        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            text: "[ ]"
            onClicked: {
                window.isFullscreen = !window.isFullscreen
            }
        } 
    }


    WasdController {
        id: wasdController
        controlledObject: camera
        keysEnabled: true
    }

    Item {
        id: mobileWasd
        visible: isMobile
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: parent.width * 0.2
        height: parent.height * 0.2

        property real buttonWidth: width / 3 - 3 * 2
        property real buttonHeight: height / 2 - 2 * 2

        Grid {
            anchors.fill: parent
            rows: 2
            columns: 3
            spacing: 2

            Rectangle {
                width: mobileWasd.buttonWidth
                height: mobileWasd.buttonHeight
                radius: 10
                color: "#55FFFFFF"
                Text {
                    anchors.centerIn: parent
                    text: "Down"
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        wasdController.downPressed()
                    }
                    onReleased: {
                        wasdController.downReleased()
                    }
                    onExited: {
                        wasdController.downReleased()
                    }
                }
            }
            Rectangle {
                width: mobileWasd.buttonWidth
                height: mobileWasd.buttonHeight
                radius: 10
                color: "#55FFFFFF"
                Text {
                    anchors.centerIn: parent
                    text: "W"
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        wasdController.forwardPressed()
                    }
                    onReleased: {
                        wasdController.forwardReleased()
                    }
                    onExited: {
                        wasdController.forwardReleased()
                    }
                }
            }
            Rectangle {
                width: mobileWasd.buttonWidth
                height: mobileWasd.buttonHeight
                radius: 10
                color: "#55FFFFFF"
                Text {
                    anchors.centerIn: parent
                    text: "Up"
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        wasdController.upPressed()
                    }
                    onReleased: {
                        wasdController.upReleased()
                    }
                    onExited: {
                        wasdController.upReleased()
                    }
                }
            }
            Rectangle {
                width: mobileWasd.buttonWidth
                height: mobileWasd.buttonHeight
                radius: 10
                color: "#55FFFFFF"
                Text {
                    anchors.centerIn: parent
                    text: "A"
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        wasdController.leftPressed()
                    }
                    onReleased: {
                        wasdController.leftReleased()
                    }
                    onExited: {
                        wasdController.leftReleased()
                    }
                }
            }
            Rectangle {
                width: mobileWasd.buttonWidth
                height: mobileWasd.buttonHeight
                radius: 10
                color: "#55FFFFFF"
                Text {
                    anchors.centerIn: parent
                    text: "S"
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        wasdController.backPressed()
                    }
                    onReleased: {
                        wasdController.backReleased()
                    }
                    onExited: {
                        wasdController.backReleased()
                    }
                }
            }
            Rectangle {
                width: mobileWasd.buttonWidth
                height: mobileWasd.buttonHeight
                radius: 10
                color: "#55FFFFFF"
                Text {
                    anchors.centerIn: parent
                    text: "D"
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        wasdController.rightPressed()
                    }
                    onReleased: {
                        wasdController.rightReleased()
                    }
                    onExited: {
                        wasdController.rightReleased()
                    }
                }
            }
        }
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
                onClicked: camera.resetView()
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