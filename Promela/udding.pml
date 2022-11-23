/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
  Uddings's implementation of starvation-free mutual exclusion
  using weak semaphores.
  Verify Safety.
  Verify Acceptance with <>nostarve.
*/

#define NPROCS 3
#include "for.h"
#include "weak-sem-3.h"  /* Change if NPROCS != 3 */

#define NOSTARVE
#define PID
#include "critical.h"

Semaphore gate1;
Semaphore gate2;
Semaphore onlyOne;
byte numGate1 = 0, numGate2 = 0;

proctype P () {	
end:do :: 
		wait(gate1);
		numGate1++;
		signal(gate1);
		wait(onlyOne);
		wait(gate1);
		numGate1--;
		numGate2++;
		if
		:: numGate1 > 0 -> signal(gate1);
		:: else -> signal(gate2);
		fi;
		signal(onlyOne);
		wait(gate2);
		numGate2--;
    critical_section();
    if
		:: numGate2 > 0 -> signal(gate2);
		:: else -> signal(gate1);
		fi;
	od
}

init {
	atomic {
		initSem(gate1,1);
		initSem(gate2,0);
		initSem(onlyOne,1);
		for (i,1,NPROCS)
			run P()
		rof (i)
	}
}

