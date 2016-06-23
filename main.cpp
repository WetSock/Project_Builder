#include "widget.h"
#include <QApplication>
#include <QRegularExpression>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    QTextStream out(stdout);

    Widget w;
 //   w.show();


    w.readFiles(); //считывание файлов в оперативку
    QList<QFile *> files = w.getFiles(); //Вызов метода выдающего файлы списком, хранящихся сейчас в памяти


//    получение данных из файла вне foreach (c = 0, где 0 это номер файла в списке всех файлов)
    int c = 0;
    if(c<files.length()){ //с обязательной проверкой на существования иначе можно получить рантайм эррор (компилятор без тестов их не в состоянии найти)
        QFile * file2 = files.at(c);
        QVector<QString> data2 = w.dataFile(file2);
        QVector<QString> names;
        QString minus = QRegularExpression::escape("-");
        QString text;
        bool flag=true;
        int i=0;

        QRegularExpressionMatch match;
        QRegularExpression contentsTableSearch("Таблица");

        while ((i<data2.length()) && flag){  // Поиск строк с названиями таблиц в содержании
            text = data2.at(i);
            match = contentsTableSearch.match(text);
            if (match.hasMatch())
                flag=false;
            else i++;
        }

        flag = true;
        QRegularExpression tableNameRead("Таблица[ 0-9.]+([0-9а-яА-Я " + minus + ",]+)");

        while ((i<data2.length()) && flag){ // Запись названий таблиц в вектор
            text = data2.at(i);
            match = tableNameRead.match(text);
            if (match.hasMatch())
            {
                names << match.captured(1);
                i++;
            }
            else flag=false;
        }


        QRegularExpression tableSearch("Таблица *([0-9]+). *([0-9а-яА-Я " + QRegularExpression::escape("-") + ",.()]+)");
        QRegularExpression dataString(" *[0-9]+[.] *[а-яА-Я ,.]+");
        QRegularExpression lastString("[^ ]+");
        QList<QString> tableString;
        int tableNumber=0;
        QString tableName="";
        flag=false; // Флаг будет использоваться для того, чтобы дописывать новые столбцы к предыдущим значениям
        bool prevWasString=false;

        while (i<data2.length()){ // Запись таблиц в вектора
            text = data2.at(i);

            match = tableSearch.match(text);
            if (match.hasMatch()) // Если текущая строка оказалась таблицей
            {
                if ((tableNumber==(match.captured(1)).toInt())&&(tableName!=match.captured(2))) // Текущая таблица это вторая часть предыдущей таблицы
                {
                        tableName=match.captured(2); // Запись названия таблицы
                        flag=true;
                }
                if (tableNumber!=(match.captured(1)).toInt()) // В случае, если таблица новая
                {
                    tableNumber=(match.captured(1)).toInt(); // Запись номера таблицы
                    tableName=match.captured(2); // Запись названия таблицы
                    flag=false;
                }
                prevWasString=false;
            }
            else
            {
              match = dataString.match(text);
              if (match.hasMatch()) // Если в текущей строчке данные
              {
                  tableString << text;
                  prevWasString=true;
              }
              else // Если в текущей строке не название таблицы и не строка с названием пункта
              {
                  if (prevWasString) // Если в предыдущей строке были данные
                  {
                    match = lastString.match(text);
                    if (!(match.hasMatch())) // Если строка пустая
                        prevWasString=false;
                    else
                        tableString << text;
                  }
              }
            }
            i++;
        }

        int j=0;
        while (j<tableString.length())
            out << tableString[j++] << endl;
    }
    else out << "Файлов нет";



    return a.exec();
}
