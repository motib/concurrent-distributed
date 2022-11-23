/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Monitor emulation of semaphores
   Verify Safety
*/

#define NPROCS 4
#define K 2
#define PID
#include "for.h"
#include "monitor.h"
#include "critical.h"

byte Sem = K;
Condition notZero;

inline SemWait() {
	enterMon();
	if :: Sem == 0 -> waitC(notZero) :: else fi;
	Sem--;
	leaveMon();
}

inline SemSignal() {
	Sem++
}

active [NPROCS] proctype p() {
	do ::
		SemWait();
		critical_section();
		SemSignal()
	od
}

