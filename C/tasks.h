#pragma once
#include <list>
#include <string>


enum statusControl { NotDone, Done, Checked };
enum statusVisible { Open, Close };
//enum months{ Unknown, January, February, Marth, April, May, June, July, August, September, October, November, December };

//Тип данных Дата
union Date{
	struct{
		unsigned short dd;
		unsigned short mm;
		unsigned short yyyy;
	} sDate;
	unsigned short aDate[3];
};


//тип данных основные Даты задачи
union Dates{
	struct{
		Date startPlan;
		Date startFact;
		Date endPlan;
		Date endFact;

	} sDates;
	Date aDates[4];

};



class Tasks
{
	

public:
	Tasks(Date, Date);
	~Tasks();

	//Здесь хрянятся все даты. Пример использования:
	//cout << obj.dates.aDates[0].aDate[0];
	//cout << obj.dates.sDates.startPlan.sDate.dd;
	//Обе строки делают одно и тоже, а именно выводят день
	Dates dates;

	//Статусы
	statusControl control = NotDone;
	statusVisible visible = Close;
	

	//Здесь перечисляются все пользователи прикрепленные к задаче 
	std::list<std::string *> users;

	//здесь будут храниться название, тексты заданий и ссылки*
	std::list<std::string *> content;

	//здесь будут храниться все задачи
	static std::list<Tasks *> allTasks;

	//здесь будут храниться дети определенной задачи 
	std::list<Tasks *> сhildren;

	//здесь будут храниться задачи, которые идут следующим этапом после данной (последовательное выполнение)
	std::list<Tasks *> queueTasks;


	//Перегруженный метод месяца
	//Должен выдавать список (List) дней, которые будут отображены на странице
	friend std::list<Date *> month();
	friend std::list<Date *> month(Date);
	friend std::list<Date *> month(Tasks *);
	//выводит лист всех дней перечисленных в этом промежутке 
	//лучше всего построить на базе month();
	//месяц с самой ранней датой будет предназначен к выводу первым
	friend std::list<Date *> targetDays(Date, Date); 

	//перегруженный метод выдающий все задади за дату/даты
	friend std::list<Tasks *> tasks();// нужен ли этот? Но пусть пока будет
	friend std::list<Tasks *> tasks(Date);
	friend std::list<Tasks *> tasks(Date, Date);


	//выведет всю ифу по задаче
	std::list<std::string *>  task(Tasks *);

	//упрощенный ввод дат
	static Date enterDate(unsigned short, unsigned short,unsigned short);

	//поиск всех задач, в которых учавствует данный пользователь и группа пользователей
	friend std::list<Tasks *> tasksUser(std::string *);
	friend std::list<Tasks *> tasksUser(std::list<std::string *>); //нужно ли оно?


	//подсчитывает количество дней впромежутке (с учетом крайних дат)
	friend unsigned short countDays(Date, Date);


	//выводит количество дней прошлого месяца*, выбранного месяца, будущего месяца*
	//* - их может и не быть
	//В сумме всех чисел должно получиться число кратное 7 и лежать в диапазоне от 28 до 42 (Сделать проверки и прощупать тестами) 
	friend std::list<unsigned short> daysMonth(Date);


	//перегрузка логических операторов для сравнения дат
	friend bool operator> (Date& first, Date& second);
	friend bool operator< (Date& first, Date& second);

	friend bool operator>= (Date& first, Date& second);
	friend bool operator<= (Date& first, Date& second);

	friend bool operator== (Date& first, Date& second);
	friend bool operator!= (Date& first, Date& second);
	


};


/*
Гуглить:
Шаблоны
Static 
Перегрузка методов

*/

