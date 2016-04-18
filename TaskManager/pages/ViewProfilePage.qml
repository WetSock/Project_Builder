import QtQuick 2.6
import QtQuick.Layouts 1.3
import Qt.labs.controls 1.0
import com.taskManager.task 1.0
import "../JS/interfaceLogic.js" as JavaScript







//Frame{


//    anchors.fill: parent




    Flickable{
        id: flickable
        anchors.fill: parent

        contentHeight: contentArea.height
        contentWidth: width

        //Экономия вычислений
        property real mySpacing: column1.columnSpacing*2


        //Для задания корректных размеров контейнеров при вертикальном скроле (и элементов в ListView тоже) в купе с динамическим изменением размера формы
        property bool statusArea: true
        onHeightChanged: {
            stackForList.height = flickable.height-tab.height-column1.columnSpacing; //при запуске tab и column равны 0 для фикса нужен костыль (который располагается)
            statusArea ? statusArea = false: contentArea.height = (tab.y+column1.columnSpacing) + flickable.height;
        }

        //Функция для заполения списков и ее иницализация
        //property bool
        property bool startScript: JavaScript.fillLists()


        Frame{
            id:contentArea
            width: parent.width

            //            frame: Rectangle {
            //                  width: parent.width
            //                  height: parent.height

            //                  color: "transparent"
            //                  border.color: "#ff0000"
            //              }




            GridLayout{
                columns: 2
                id: column1
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    id: profileIconArea
                    width: 100
                    height: 100
                    //anchors.baseline: personInfo.
                    Layout.alignment: Qt.AlignTop


                    Image{
                        id: profileIcon

                        source: "qrc:/images/profileIcon2.svg"
                        anchors.fill: parent
                        //anchors.centerIn: imageArea
                        //smooth: true
                        mipmap: true


                    }
                }

                GridLayout{
                    anchors.left: profileIconArea.right
                    anchors.leftMargin: 10
                    columns: 2
                    Label{
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: 14
                        text: "Имя"
                    }
                    Label{
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: 14
                        text: "Фамилия"
                    }
                    Label{
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: 14
                        text: "Пол"
                    }
                    Label{
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: 14
                        text: "Возраст"
                    }
                    Label{
                        Layout.columnSpan: 2
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: 14
                        text: "Страна, Город"
                    }
                }

                Label{
                    id: pesonInfo

                    font.pixelSize: 14
                    Layout.columnSpan: 2

                    //anchors.left: profileIconArea.right
                    //anchors.leftMargin: 10


                    //anchors.right: parent.right
                    //anchors.top: parent.top
                    //anchors.bottom: tab.bottom
                    //anchors.bottomMargin: 10


                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop


                    text:"Навыки:" // +SelfInfo
                    wrapMode: Label.Wrap
                }




                TabBar{
                    id: tab

                    anchors.left: parent.left
                    anchors.right: parent.right
                    Layout.columnSpan: 2
                    z: 1


                    TabButton{
                        font.pixelSize: 16
                        text: "Проекты"

                        onClicked: {

                            //tabProject.visible = true
                            //tabMessage.visible = false

                        }
                    }
                    TabButton{
                        font.pixelSize: 16
                        text: "Уведомления"

                        onClicked:{
                            //tabProject.visible = false
                            //tabMessage.visible = true
                        }
                    }


                }



                StackLayout{
                    id: stackForList
                    anchors.top: tab.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Layout.columnSpan: 2

                    currentIndex: tab.currentIndex
                    anchors.bottom: flickable.bottom

                    Component{
                        id: maket

                        Frame{
                            id: maketFrame
                            width: stackForList.width


                            ColumnLayout{
                                anchors.right: parent.right
                                anchors.left: parent.left
                                RowLayout{
                                    Label{
                                        text:name
                                        font.pixelSize: 12
                                        Layout.fillWidth: true

                                    }
                                    Label{
                                        text: (Math.round(progress.value *100)) + "%"
                                        font.pixelSize: 12
                                    }
                                }
                                Label{
                                    text: "-"
                                    font.pixelSize: 6
                                }
                                ProgressBar{
                                    id: progress
                                    value: Math.random(100)
                                    Layout.fillWidth: true
                                }
                            }

                        }
                    }


                    ListView{

                        id:tabProject
                        model: ListModel{
                            id: listProjects
                        }

                        delegate: maket
                        width: parent.width

                        height: stackForList.height - tab.height-column1.columnSpacing //это костыль - не трогать!


                    }
                    ListView{

                        id:tabMessage
                        model: ListModel{
                            id: listMessages
                        }

                        delegate: maket
                        width: parent.width

                        height: stackForList.height - tab.height-column1.columnSpacing //это костыль - не трогать!

                    }

                }


            }

        }


    }
