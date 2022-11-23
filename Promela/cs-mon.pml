/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Monitor solution for critical section
   Verify Safety
*/

#define NPROCS 3
#define PID
#include "for.h"
#include "monitor.h"
#include "critical.h"

active [NPROCS] proctype p() {
	do ::
		enterMon();
		critical_section();
		leaveMon()
	od
}

