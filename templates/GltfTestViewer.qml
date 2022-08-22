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
        id: view
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
                    cameraOrigin.position = loadedItem.boundsCenter
                    cameraOrigin.eulerRotation = Qt.vector3d(0, 0, 0)
                    position.z = loadedItem.boundsDiameter * 2.0
                }
            }
        }

        Node {
            Loader3D {
                id: loadedItem
                property var bounds: { "minimum": Qt.vector3d(0.0, 0.0, 0.0), "maximum": Qt.vector3d(0.0, 0.0, 0.0) }
                function updateBounds() {
                    function isModel(node) {
                        return node instanceof Model
                    }

                    function expandBounds(baseNode, modelNode, accBounds)
                    {
                        function getCorners(bounds) {
                            let outPoints = [];
                            outPoints.push(Qt.vector3d(bounds.minimum.x, bounds.minimum.y, bounds.minimum.z));
                            outPoints.push(Qt.vector3d(bounds.maximum.x, bounds.minimum.y, bounds.minimum.z));
                            outPoints.push(Qt.vector3d(bounds.minimum.x, bounds.maximum.y, bounds.minimum.z));
                            outPoints.push(Qt.vector3d(bounds.minimum.x, bounds.minimum.y, bounds.maximum.z));
                            outPoints.push(Qt.vector3d(bounds.maximum.x, bounds.maximum.y, bounds.maximum.z));
                            outPoints.push(Qt.vector3d(bounds.minimum.x, bounds.maximum.y, bounds.maximum.z));
                            outPoints.push(Qt.vector3d(bounds.maximum.x, bounds.minimum.y, bounds.maximum.z));
                            outPoints.push(Qt.vector3d(bounds.maximum.x, bounds.maximum.y, bounds.minimum.z));
                            return outPoints;
                        }

                        function includePoint(bounds, point) {
                            let outBounds = bounds
                            outBounds.minimum = Qt.vector3d(Math.min(bounds.minimum.x, point.x), Math.min(bounds.minimum.y, point.y), Math.min(bounds.minimum.z, point.z))
                            outBounds.maximum = Qt.vector3d(Math.max(bounds.maximum.x, point.x), Math.max(bounds.maximum.y, point.y), Math.max(bounds.maximum.z, point.z))
                            return outBounds
                        }

                        let outBounds = accBounds;
                        let bounds2Corners = getCorners(modelNode.bounds);
                        bounds2Corners.forEach((corner) => {
                            let mappedCorner = modelNode.mapPositionToNode(baseNode, corner);
                            outBounds = includePoint(outBounds, mappedCorner)
                        });

                        return outBounds;
                    }

                    function getBounds(baseNode, node, accBounds)
                    {
                        let bounds = accBounds;
                        if (isModel(node))
                            bounds = expandBounds(baseNode, node, bounds);

                        for (var i = 0; i < node.children.length; ++i)
                            bounds = getBounds(baseNode, node.children[i], bounds)

                        return bounds
                    }

                    // reset
                    bounds.minimum = Qt.vector3d(0.0, 0.0, 0.0)
                    bounds.maximum = Qt.vector3d(0.0, 0.0, 0.0)

                    // recurse all children looking for model bounds
                    bounds = getBounds(loadedItem, loadedItem, bounds);
                }
                property bool needsBoundUpdate: false
                property real boundsDiameter: 0
                property vector3d boundsCenter
                property vector3d boundsSize

                source: pathHelper.modelLocation(testsModel.get(listView.currentIndex).source)
                onLoaded: needsBoundUpdate = true
                onBoundsChanged: {
                    boundsSize = Qt.vector3d(bounds.maximum.x - bounds.minimum.x,
                                             bounds.maximum.y - bounds.minimum.y,
                                             bounds.maximum.z - bounds.minimum.z)
                    boundsDiameter = Math.max(boundsSize.x, boundsSize.y, boundsSize.z)
                    boundsCenter = Qt.vector3d((bounds.maximum.x + bounds.minimum.x) / 2,
                                               (bounds.maximum.y + bounds.minimum.y) / 2,
                                               (bounds.maximum.z + bounds.minimum.z) / 2 )
                    camera.resetView()
                }

                FrameAnimation {
                    running: loadedItem.needsBoundUpdate
                    onTriggered: {
                        loadedItem.needsBoundUpdate = false;
                            loadedItem.updateBounds();
                    }
                }
            }
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
