/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Barz's implementation of general semaphores
      by binary semaphores
   Verify Safety with the following properties:
      []bingate (gate is a binary semaphore)
      [](count0 -> gate0)
      []((gate0 && notInTest) -> count0)
*/

#define NPROCS 3
#define K      2
#define PID
#include "critical.h"

byte gate = ((K == 0) -> 0 : 1);
int count = K;

/* Definitions for LTL properties */
#define bingate (gate <= 1)
#define count0 (count == 0)
#define gate0 (gate == 0)
bool test[NPROCS] = false;
#define notInTest ((test[0]==false) && (test[1]==false) && (test[2]==false))

active [NPROCS] proctype P () {	
	do :: 
		/* Wait */
		atomic { gate > 0; gate--; test[_pid] = true; }
		assert(gate0);
		d_step {
			count--;
			if
			:: count > 0 -> gate++;
			:: else
			fi;
			test[_pid] = false;
		}

    	critical_section();

		/* Signal */
		d_step {
			count++;
			if
			:: count == 1 -> gate++;
			:: else
			fi;
		}
	od
}

