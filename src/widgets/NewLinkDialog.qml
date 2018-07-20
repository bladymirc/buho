import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.maui 1.0 as Maui
import org.buho.editor 1.0
import org.kde.kirigami 2.2 as Kirigami

Popup
{
    parent: ApplicationWindow.overlay
    height: previewReady ? parent.height * (isMobile ?  0.8 : 0.7) :
                           contentLayout.implicitHeight
    width: parent.width * (isMobile ?  0.9 : 0.7)

    signal linkSaved(var link)
    property string selectedColor : "#ffffe6"
    property string fgColor: Qt.darker(selectedColor, 2.5)

    property bool previewReady : false
    x: (parent.width / 2) - (width / 2)
    y: (parent.height /2 ) - (height / 2)
    modal: true
    padding: isAndroid ? 1 : "undefined"

    Connections
    {
        target: linker
        onPreviewReady:
        {
            previewReady = true
            fill(link)
        }
    }


    Maui.Page
    {
        id: content
        margins: 0
        anchors.fill: parent
        Rectangle
        {
            id: bg
            color: selectedColor
            z: -1
            anchors.fill: parent
        }

        headBarExit: false
        headBarVisible: previewReady
        footBarVisible: previewReady

        headBar.leftContent: Maui.ToolButton
        {
            id: pinButton
            iconName: "window-pin"
            checkable: true
            iconColor: checked ? highlightColor : textColor
            //                onClicked: checked = !checked
        }

        headBar.rightContent: ColorsBar
        {
            onColorPicked: selectedColor = color
        }

        ColumnLayout
        {
            id: contentLayout
            anchors.fill: parent

            TextField
            {
                id: link
                Layout.fillWidth: true
                Layout.margins: space.medium
                height: rowHeight
                verticalAlignment: Qt.AlignVCenter
                placeholderText: qsTr("URL")
                font.weight: Font.Bold
                font.bold: true
                font.pointSize: fontSizes.large
                color: fgColor
                Layout.alignment: Qt.AlignCenter

                background: Rectangle
                {
                    color: "transparent"
                }

                onAccepted: linker.extract(link.text)
            }

            TextField
            {
                id: title
                visible: previewReady
                Layout.fillWidth: true
                Layout.margins: space.medium
                height: 24
                placeholderText: qsTr("Title")
                font.weight: Font.Bold
                font.bold: true
                font.pointSize: fontSizes.large
                color: fgColor

                background: Rectangle
                {
                    color: "transparent"
                }
            }

            Item
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: previewReady

                ListView
                {
                    id: previewList
                    anchors.fill: parent
                    anchors.centerIn: parent
                    clip: true
                    snapMode: ListView.SnapOneItem
                    orientation: ListView.Horizontal
                    interactive: count > 1
                    highlightFollowsCurrentItem: true
                    model: ListModel{}
                    onMovementEnded:
                    {
                        var index = indexAt(contentX, contentY)
                        currentIndex = index
                    }
                    delegate: ItemDelegate
                    {
                        height: previewList.height
                        width: previewList.width

                        background: Rectangle
                        {
                            color: "transparent"
                        }

                        Image
                        {
                            id: img
                            source: model.url
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            width: parent.width
                            height: parent.height
                            sourceSize.height: height
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                        }
                    }
                }
            }

            Maui.TagsBar
            {
                id: tagBar
                visible: previewReady
                Layout.fillWidth: true
                allowEditMode: true

                onTagsEdited:
                {
                    for(var i in tags)
                        append({tag : tags[i]})
                }
            }
        }

        footBar.leftContent: [

            Maui.ToolButton
            {
                id: favButton
                iconName: "love"
                checkable: true
                iconColor: checked ? "#ff007f" : textColor
            },

            Maui.ToolButton
            {
                iconName: "document-share"
                onClicked: isAndroid ? Maui.Android.shareText(link.text) :
                                       shareDialog.show(link.text)
            },

            Maui.ToolButton
            {
                iconName: "document-export"
            }
        ]

        footBar.rightContent: Row
        {
            spacing: space.medium

            Button
            {
                id: discard
                text: qsTr("Discard")
                onClicked:  clear()
            }

            Button
            {
                id: save
                text: qsTr("Save")
                onClicked:
                {
                    packLink()
                    clear()
                }
            }
        }
    }


    function clear()
    {
        title.clear()
        link.clear()
        previewList.model.clear()
        tagBar.clear()
        previewReady = false
        close()

    }

    function fill(note)
    {
        title.text = note.title[0]
        populatePreviews(note.image)

        open()
    }

    function populatePreviews(imgs)
    {
        for(var i in imgs)
            previewList.model.append({url : imgs[i]})
    }

    function packLink()
    {
        var data = ({
                        link : link.text,
                        title: title.text.trim(),
                        preview: previewList.model.get(previewList.currentIndex).url,
                        color: selectedColor,
                        tag: tagBar.getTags(),
                        pin: pinButton.checked,
                        fav: favButton.checked
                    })
        linkSaved(data)
    }
}
