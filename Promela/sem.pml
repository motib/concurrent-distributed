/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Critical section problem a busy-wait semaphore
   Verify Safety
*/

#include "sem.h"
#define NOSTARVE
#include "critical.h"

byte sem = 1;

active proctype P () { 
	do ::
                wait(sem);
                critical_section('p');
                signal(sem)
        od
}

active proctype Q () { 
	do :: 
                wait(sem);
                critical_section('q');
                signal(sem)
	od
}

