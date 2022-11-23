/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Monitor for readers and writers 
   Verify Safety
   Verify Acceptance with <>isReading && <>isWriting
*/

#include "for.h"
#include "monitor.h"

byte Readers = 0 ;
bool Writing = false ;
Condition OKtoRead;
Condition OKtoWrite;

bool isReading = false;
bool isWriting = false;

inline StartRead() {
	enterMon();
	if 
	:: (Writing || !emptyC(OKtoWrite) ) -> waitC(OKtoRead) 
	:: else 
	fi;
	Readers++ ;
	assert (!Writing);
	signalC(OKtoRead);
	leaveMon();
}

inline EndRead() {
	enterMon();
	Readers--;
	if 
	:: (Readers == 0) -> signalC(OKtoWrite) 
        :: else -> 
	fi;
	leaveMon();
}

inline StartWrite() {
	enterMon();
	if 
	:: ((Readers != 0) || Writing) -> waitC(OKtoWrite) 
	:: else 
	fi;
	Writing = true ;
	assert (Readers == 0);
	leaveMon();
}

inline EndWrite() {
	enterMon();
	Writing = false;
	if 
	:: (emptyC(OKtoRead)) -> signalC(OKtoWrite) 
	:: else -> signalC(OKtoRead)
	fi;
	leaveMon();
}

#define N 2

active [3] proctype reader() {
	for(I, 1, N)
	    StartRead();
    	    if :: (_pid == 0) -> isReading = true :: else fi;
            printf("MSC: process %d reading %d\n", _pid, I);
	    EndRead();
	rof(I)
}

active [2] proctype writer() {
    for(I, 1, N)
	StartWrite();
        if :: (_pid == 3) -> isWriting = true :: else fi;
       	printf("MSC: process %d writing %d\n", _pid, I);
	EndWrite();
	rof(I)
}
