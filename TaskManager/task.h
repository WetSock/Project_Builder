#ifndef TASK_H
#define TASK_H

#include <QObject>
#include <QList>
#include <QDebug>



enum kindTask{NotKind=0, StageTask=1, SubTask=2};

class Task : public QObject
{
    Q_OBJECT

    //Q_PROPERTY(QList<Task *> subTasks)// WRITE addSubTask)// WRITE addSubTask NOTIFY subTasksChanged)
    Q_PROPERTY(Task * stageTask READ getStageTask WRITE setStageTask)// NOTIFY stageTaskChanged)
    Q_PROPERTY(Task * parentTask READ getParentTask)// WRITE setParentTask NOTIFY parentTaskChanged)
    Q_PROPERTY(kindTask kindControl READ getKindControl)// READ kindControl WRITE setKindControl NOTIFY kindControlChanged)



    QList<Task *> m_subTasks;
    Task * m_stageTask=nullptr;
    Task * m_parentTask=nullptr;
    kindTask m_kindControl=NotKind;

public:
    static QList<Task *> * allTasks;

    //конструкторы
    explicit Task(QObject *parent = 0);
    Task(Task *, kindTask, QObject *parent = 0);

    //деструкторы
    ~Task();

    //методы подзадач
    Q_INVOKABLE QList<QString> getSubTasks();
    Q_INVOKABLE void addSubTask(Task *);


    //методы этапов
    Task * getStageTask() const;
    void setStageTask(Task *);

    //методы родителя
    Task * getParentTask() const;

    //методы для списка всех объектов
    //Q_INVOKABLE static Task * findTask() const;
    //Q_INVOKABLE static QList<Task *> * findTasks() const;





    kindTask getKindControl() const;

signals:

public slots:


};

#endif // TASK_H
