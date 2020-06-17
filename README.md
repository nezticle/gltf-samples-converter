# gltf-samples-converter
A script to generate a QtQuick3D project for viewing GLTF2 samples

## Prerequisites
- Qt 6.0 with Qt Quick 3D and Qt Quick Timeline
- [glTF-Samples-Models](https://github.com/KhronosGroup/glTF-Sample-Models)

## Usage

./generate-quick3d-project.py -i input/directory -o output/directory -b location/of/balsam.exe

The objective is to convert the files in the glTF-Sample-Models project.  So here is example of what that looks like:

Source:
```D:/Code/glTF-Sample-Models/```

Output folder:
```D:/Code/gltFSampleViewer```

Balsam Location:
```D:/Code/Qt6/qtbase/bin/balsam.exe```

Examples Command:

```./generate-quick3d-project.py -i D:/Code/glTF-Sample-Models/2.0 -o  D:/Code/gltFSampleViewer -b D:/Code/Qt6/qtbase/bin/balsam.exe```

Then just build the qmake project in the output folder with Qt 6.
