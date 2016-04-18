#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QSettings>
#include <QDebug>


#include "task.h"
#include <user.h>


int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    //QSettings settings;
    //qputenv("QT_LABS_CONTROLS_STYLE", settings.value("style").toByteArray());


    Task * tester = new Task(); tester->setObjectName("tester");
    Task * stage = new Task(tester, StageTask); stage->setObjectName("stage");
    Task * one = new Task(tester,SubTask); one->setObjectName("one");
    Task * two = new Task(tester,SubTask); two->setObjectName("two");
    Task * three = new Task(tester,SubTask); three->setObjectName("three");
    delete two;
    //qDebug() << "main message:"; tester->getSubTasks();

    //"создаем" библиотеки QML из классов: Task, User
    //подключить в QML их можно с помощью: import com.taskManager.* 1.0
    qmlRegisterType<Task>("com.taskManager.task",1,0,"Task");
    engine.rootContext()->setContextProperty("multyObj", tester);
    //qmlRegisterType<QLine>("com.mycompany.line",1,0,"Line");
    //qmlRegisterType<User>("com.taskManager.user",1,0,"User");
    //delete tester;








    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

//    тесты конструктора и деструктора



    return app.exec();
}
