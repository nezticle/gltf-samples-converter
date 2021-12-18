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
                    loadedItem.bounds = loadedItem.getItemVisualBounds();
                    loadedItem.boundsSize = Qt.vector3d(loadedItem.bounds.maximum.x - loadedItem.bounds.minimum.x,
                                                 loadedItem.bounds.maximum.y - loadedItem.bounds.minimum.y,
                                                 loadedItem.bounds.maximum.z - loadedItem.bounds.minimum.z)
                    loadedItem.boundsDiameter = Math.max(loadedItem.boundsSize.x, loadedItem.boundsSize.y, loadedItem.boundsSize.z)
                    loadedItem.boundsCenter = Qt.vector3d((loadedItem.bounds.maximum.x + loadedItem.bounds.minimum.x) / 2,
                                                   (loadedItem.bounds.maximum.y + loadedItem.bounds.minimum.y) / 2,
                                                   (loadedItem.bounds.maximum.z + loadedItem.bounds.minimum.z) / 2 )
                    originNode.position = loadedItem.boundsCenter
                    cameraNode.position = Qt.vector3d(0, 0, loadedItem.boundsDiameter * 1.5)
                    originNode.eulerRotation = Qt.vector3d(0, 0, 0)
                }
            }
        }

        Loader3D {
            id: loadedItem
            source: testsModel.get(listView.currentIndex).source

            property var bounds: createBounds()
            property vector3d boundsSize: Qt.vector3d(0, 0, 0)
            property real boundsDiameter: 0
            property vector3d boundsCenter: Qt.vector3d(0, 0, 0)

            onItemChanged: {
                // Reset Bounds
                bounds = createBounds()
                boundsSize = Qt.vector3d(0, 0, 0);
                boundsDiameter = 0
                boundsCenter = Qt.vector3d(0, 0, 0);
            }

//            Model {
//                id: boundsModel
//                source: "#Cube"
//                materials: PrincipledMaterial {
//                    baseColor: "red"
//                }
//                opacity: 0.2
//                position: loadedItem.boundsCenter
//                scale: Qt.vector3d(loadedItem.boundsSize.x / 100,
//                                   loadedItem.boundsSize.y / 100,
//                                   loadedItem.boundsSize.z / 100)
//            }

            function createBounds(): Bounds {
                return {
                    minimum: Qt.vector3d(0, 0, 0),
                    maximum: Qt.vector3d(0,0,0),
                    isEmpty: function() {
                        return this.minimum.x === 0.0 &&
                            this.minimum.y === 0.0 &&
                            this.minimum.z === 0.0 &&
                            this.maximum.x === 0.0 &&
                            this.maximum.y === 0.0 &&
                            this.maximum.z === 0.0;
                    }
                }
            }

            function boundsCorners(bounds: Bounds) {
                let corners = []
                corners.push(Qt.vector3d(bounds.minimum.x, bounds.minimum.y, bounds.minimum.z));
                corners.push(Qt.vector3d(bounds.maximum.x, bounds.minimum.y, bounds.minimum.z));
                corners.push(Qt.vector3d(bounds.minimum.x, bounds.maximum.y, bounds.minimum.z));
                corners.push(Qt.vector3d(bounds.minimum.x, bounds.minimum.y, bounds.maximum.z));

                corners.push(Qt.vector3d(bounds.maximum.x, bounds.maximum.y, bounds.maximum.z));
                corners.push(Qt.vector3d(bounds.minimum.x, bounds.maximum.y, bounds.maximum.z));
                corners.push(Qt.vector3d(bounds.maximum.x, bounds.minimum.y, bounds.maximum.z));
                corners.push(Qt.vector3d(bounds.maximum.x, bounds.maximum.y, bounds.minimum.z));
                return corners;
            }

            function getBoundsRecursive(baseNode : Node, node : Node, bounds : Bounds) {
                if (node === undefined)
                    return
                // If this node is a model, expand the bounds
                if (node instanceof Model) {
                    let corners  = boundsCorners(node.bounds);
                    for (let j = 0; j < corners.length; ++j) {
                        let originalPoint = corners[j];
                        let point = node.mapPositionToNode(baseNode, originalPoint);
                        if (bounds.isEmpty()) {
                            bounds.minimum = point
                            bounds.maximum = point
                        } else {
                            bounds = includeVector(bounds, point);
                        }
                    }
                }
                for (let i = 0; i < node.children.length; ++i) {
                    let element = node.children[i]
                    getBoundsRecursive(baseNode, element, bounds)
                }
            }

            function vec3Minimum(first: vector3d, second: vector3d): vector3d {
                return Qt.vector3d(Math.min(first.x, second.x),
                                   Math.min(first.y, second.y),
                                   Math.min(first.z, second.z));
            }

            function vec3Maximum(first: vector3d, second: vector3d): vector3d {
                return Qt.vector3d(Math.max(first.x, second.x),
                                   Math.max(first.y, second.y),
                                   Math.max(first.z, second.z));
            }

            function includeVector(target: Bounds, source: vector3d): Bounds {
                target.minimum = vec3Minimum(target.minimum, source);
                target.maximum = vec3Maximum(target.maximum, source);
                return target;
            }

            function getItemVisualBounds(): Bounds {
                let bounds = createBounds()
                getBoundsRecursive(loadedItem, loadedItem.item, bounds);
                return bounds;
            }
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
            Button {
                onClicked: cameraNode.resetView()
                text: "Recenter view"
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
        }
    }
}
