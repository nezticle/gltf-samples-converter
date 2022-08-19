import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import QtQuick3D.Helpers
import glTFSampleViewer

Window {
    id: window
	visible: true
	width: 1920
	height: 1280
	title: qsTr("GLTF Viewer")

    property bool isFullscreen: false

    GltfTestsModel {
        id: testsModel
    }
    PathHelper {
        id: pathHelper
    }

    View3D {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: selectionRect.left
		environment: SceneEnvironment {
            lightProbe: Texture {
                textureData: ProceduralSkyTextureData {
                }
            }
            backgroundMode: SceneEnvironment.SkyBox
            skyboxBlurAmount: 0.4
        }

        Node {
            id: cameraOrigin
            PerspectiveCamera {
                id: camera
                z: 600
                function resetView() {
                    position = Qt.vector3d(0, 0, 600)
                    cameraOrigin.eulerRotation = Qt.vector3d(0, 0, 0)
                }
            }
        }

        Loader3D {
            id: loadedItem
            source: pathHelper.modelLocation(testsModel.get(listView.currentIndex).source)
        }

        OrbitCameraController {
            origin: cameraOrigin
            camera: camera
        }
        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            text: window.isFullscreen ? "Show List" : "Hide List"
            onClicked: {
                window.isFullscreen = !window.isFullscreen
            }
        }
    }

    Pane {
        id: selectionRect
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: !window.isFullscreen
        width: !window.isFullscreen ? 200 : 0
        ColumnLayout {
            anchors.fill: parent

            Button {
                onClicked: camera.resetView()
                text: "Recenter view"
            }
            RowLayout {
                Button {
                    text: "Previous"
                    onClicked: {
                        listView.decrementCurrentIndex()
                    }
                }
                Button {
                    text: "Next"
                    onClicked: {
                        listView.incrementCurrentIndex()
                    }
                }
            }

            ListView {
                id: listView
                width: parent.width
                Layout.fillHeight: true
                model: testsModel
                delegate: ItemDelegate {
                    text: name
                    width: listView.width
                    highlighted: ListView.isCurrentItem
                    onClicked: listView.currentIndex = index
                }
                clip: true
             }
        }
    }
}
