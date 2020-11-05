import QtQuick
import QtQuick3D

Rectangle {
    id: window
	width: 640
	height: 480
    color: "black"

	Node {
        id: sceneRoot

        PerspectiveCamera {
            id: camera
            z: 600
        }

        Loader3D {
            id: loadedItem
            source: ###
            scale: @@@
            y: $$$
        }
    }

    View3D {
        anchors.fill: parent
        importScene: sceneRoot
		environment: SceneEnvironment {
            lightProbe: Texture {
                source: "../environment.hdr"
            }
        }
    }
}