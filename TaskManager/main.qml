import QtQuick 2.5
//import QtQuick.Controls 1.5
//import QtQuick.Dialogs 1.2

import Qt.labs.controls 1.0
import com.taskManager.task 1.0


import QtQuick.Layouts 1.3
import Qt.labs.controls.material 1.0
//import Qt.labs.controls.universal 1.0

//import Qt.labs.settings 1.0




ApplicationWindow {
    id:majorWindow
    property bool myStatus: true


    width: 360
    height: 480
    visible: true

    title: "Text"

    //Material.theme: Material.Dark
    //Material.accent: Material.Purple

    //Universal.theme: Universal.Dark
    //Universal.accent: Universal.Violet


//    Settings {
//        id: settings
//        property string style: "Unversal"
//    }


    header: ToolBar{
        id: header

        RowLayout{
            anchors.fill: parent
            Label{
                id: labelHeader
                text: "Name project"
                font.pixelSize: 20
                Layout.fillWidth: true
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter

            }
            ToolButton{

                label: Image{
                    //anchors.fill: parent
                    anchors.centerIn:  parent
                    source: "qrc:/images/menu.png"
                    //sourceSize.width: parent.width
                    //sourceSize.height: parent.height
                }

                onClicked: {
                    if(!myStatus){
                    contentArea.pop();

                    myStatus = true;
                    }
                    else{}
                }

            }

        }


    }


    StackView{
        id: contentArea
        anchors.fill: parent

        initialItem:Pane{
                anchors.fill: parent

            Frame{
                id: baseFrame
                anchors.fill: parent
                //content



            }


            ToolButton{
                width: 60
                height: 60
                property int myPadding: 10

                x: majorWindow.contentItem.width - width - myPadding
                y: majorWindow.contentItem.height - height - myPadding

                label: Image{
                    source: "qrc:/images/actionButton.svg"
                    anchors.fill: parent
                    anchors.centerIn: parent

                    //smooth: true
                    mipmap: true
                }




                onClicked:{
                    if(myStatus){
                        contentArea.push("qrc:/pages/ViewProfilePage.qml");

                        labelHeader.text = "Nick_name";
                        myStatus = false;
                    }
                    else{
                        //contentArea.pop();

                        //myStatus = true;
                    }

                }
            }

          }
    }




//    footer: ToolBar{
//        id:footer
//        height: 50
//        RowLayout{
//            //width: parent.width
//            anchors.fill: parent

//            ToolButton{
//                height: parent.height
//                width: parent.height
//                Layout.alignment: Qt.AlignLeft
//                //background: Rectangle{width: 50; height:50;}
//            }
//            ToolButton{
//                Layout.alignment: Qt.AlignHCenter
//                //background: Rectangle{width: 50; height:50;}
//            }
//            ToolButton{
//                Layout.alignment: Qt.AlignRight
//                //background: Rectangle{width: 50; height:50;}

//            }

//        }
//    }




}



