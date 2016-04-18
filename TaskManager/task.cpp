#include "task.h"
#include <QDebug>

QList<Task *> * Task::allTasks = new QList<Task *>;

Task::Task(QObject *parent) : QObject(parent)
{
    allTasks->push_front(this);
}

Task::Task(Task * parentTask, kindTask controlKind, QObject *parent) : QObject(parent)
{

    allTasks->push_front(this);
    this->m_parentTask = parentTask;
    m_kindControl = controlKind;

    switch (controlKind) {
    case SubTask:
        parentTask->m_subTasks.push_back(this);
        break;
    case StageTask:
        parentTask->m_stageTask = this;
        break;
    default:
        qDebug() << "Unknown Type Task" << endl;
        break;
    }
}

Task::~Task()
{

    //Деструктор построен таким образом, что будет уничтожать все подчиненные объекты вместе с удаляемым объектом
    //так же он удаляет свой указатель из родителя

    qDebug() << "Delete Object";

    if(m_stageTask!=NULL){
        delete m_stageTask;
        //m_stageTask = NULL; он здесь не нужен, но показательно стоит в комменте
    }

    if(!m_subTasks.isEmpty())
        foreach(Task * del, m_subTasks){
            delete del;
            //del = NULL; он здесь не нужен, но показательно стоит в комменте
        }


    if(m_parentTask!=NULL)
        switch(m_kindControl){
        case StageTask:
            m_parentTask->m_stageTask=NULL;
            break;
        case SubTask:
            m_parentTask->m_subTasks.removeOne(this);
            break;
        default:
            qDebug() << "Don't remove the object pointer within parentTask (Stage and Sub)"; //с англицким я не силен, поправь если прочтешь (не удалил указатель на объект в parentTask)
            break;
        }

    allTasks->removeOne(this);

}


QList<QString> Task::getSubTasks()
{
    QList<QString> strings;
        foreach(Task * var, m_subTasks){
            qDebug() << var->objectName();
            strings.push_back(var->objectName());
        }
    return strings;
}



Task *Task::getStageTask() const
{
    return m_stageTask;
}

void Task::addSubTask(Task *subTask)
{
    m_subTasks.push_back(subTask);
}

void Task::setStageTask(Task *stageTask)
{
    m_stageTask = stageTask;
}

Task *Task::getParentTask() const
{
    return m_parentTask;
}

kindTask Task::getKindControl() const
{
    return m_kindControl;
}


