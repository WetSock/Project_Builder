#pragma once
#include <list>
#include <string>


enum statusControl { NotDone, Done, Checked };
enum statusVisible { Open, Close };
//enum months{ Unknown, January, February, Marth, April, May, June, July, August, September, October, November, December };

//��� ������ ����
union Date{
	struct{
		unsigned short dd;
		unsigned short mm;
		unsigned short yyyy;
	} sDate;
	unsigned short aDate[3];
};


//��� ������ �������� ���� ������
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

	//����� �������� ��� ����. ������ �������������:
	//cout << obj.dates.aDates[0].aDate[0];
	//cout << obj.dates.sDates.startPlan.sDate.dd;
	//��� ������ ������ ���� � ����, � ������ ������� ����
	Dates dates;

	//�������
	statusControl control = NotDone;
	statusVisible visible = Close;
	

	//����� ������������� ��� ������������ ������������� � ������ 
	std::list<std::string *> users;

	//����� ����� ��������� ��������, ������ ������� � ������*
	std::list<std::string *> content;

	//����� ����� ��������� ��� ������
	static std::list<Tasks *> allTasks;

	//����� ����� ��������� ���� ������������ ������ 
	std::list<Tasks *> �hildren;

	//����� ����� ��������� ������, ������� ���� ��������� ������ ����� ������ (���������������� ����������)
	std::list<Tasks *> queueTasks;


	//������������� ����� ������
	//������ �������� ������ (List) ����, ������� ����� ���������� �� ��������
	friend std::list<Date *> month();
	friend std::list<Date *> month(Date);
	friend std::list<Date *> month(Tasks *);
	//������� ���� ���� ���� ������������� � ���� ���������� 
	//����� ����� ��������� �� ���� month();
	//����� � ����� ������ ����� ����� ������������ � ������ ������
	friend std::list<Date *> targetDays(Date, Date); 

	//������������� ����� �������� ��� ������ �� ����/����
	friend std::list<Tasks *> tasks();// ����� �� ����? �� ����� ���� �����
	friend std::list<Tasks *> tasks(Date);
	friend std::list<Tasks *> tasks(Date, Date);


	//������� ��� ��� �� ������
	std::list<std::string *>  task(Tasks *);

	//���������� ���� ���
	static Date enterDate(unsigned short, unsigned short,unsigned short);

	//����� ���� �����, � ������� ���������� ������ ������������ � ������ �������������
	friend std::list<Tasks *> tasksUser(std::string *);
	friend std::list<Tasks *> tasksUser(std::list<std::string *>); //����� �� ���?


	//������������ ���������� ���� ����������� (� ������ ������� ���)
	friend unsigned short countDays(Date, Date);


	//������� ���������� ���� �������� ������*, ���������� ������, �������� ������*
	//* - �� ����� � �� ����
	//� ����� ���� ����� ������ ���������� ����� ������� 7 � ������ � ��������� �� 28 �� 42 (������� �������� � ��������� �������) 
	friend std::list<unsigned short> daysMonth(Date);


	//���������� ���������� ���������� ��� ��������� ���
	friend bool operator> (Date& first, Date& second);
	friend bool operator< (Date& first, Date& second);

	friend bool operator>= (Date& first, Date& second);
	friend bool operator<= (Date& first, Date& second);

	friend bool operator== (Date& first, Date& second);
	friend bool operator!= (Date& first, Date& second);
	


};


/*
�������:
�������
Static 
���������� �������

*/

