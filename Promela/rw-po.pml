/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Protected object for readers and writers
   Verify Safety
*/

#include "for.h"

bool lock = false;
#define enterPO(cond) atomic {!lock && (cond); lock = true; }
#define leavePO() lock = false;

byte Readers = 0 ;
bool Writing = false ;

inline StartRead() {
	enterPO(!Writing);
	Readers++ ;
	assert(!Writing);
	leavePO();
}

inline EndRead() {
	enterPO(true);
	Readers--;
	leavePO();
}

inline StartWrite() {
	enterPO(((Readers == 0) && !Writing));
	Writing = true ;
	assert (Readers == 0);
	leavePO();
}

inline EndWrite() {
	enterPO(true);
	Writing = false;
	leavePO();
}

#define N 2

active [3] proctype reader() {
	for(I, 1, N)
	    StartRead();
        printf("MSC: process %d reading %d\n", _pid, I);
	    EndRead();
	rof(I)
}

active [2] proctype writer() {
    for(I, 1, N)
	StartWrite();
       	printf("MSC: process %d writing %d\n", _pid, I);
	EndWrite();
	rof(I)
}

