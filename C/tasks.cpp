#include "stdafx.h"
#include "tasks.h"


Tasks::Tasks(Date _startPlan, Date _endPlan)
{
	dates.sDates.startPlan = _startPlan;
	dates.sDates.endPlan = _endPlan;
}


Tasks::~Tasks()
{
}


Date Tasks::enterDate(unsigned short _dd, unsigned short _mm, unsigned short _yyyy)
{
	Date date;
	date.sDate.dd = _dd;
	date.sDate.mm = _mm;
	date.sDate.yyyy = _yyyy;
	return date;
}
