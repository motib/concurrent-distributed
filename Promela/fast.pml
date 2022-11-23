/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Lamport's fast mutual exclusion algorithm
   Verify Safety
*/

#define NPROCS 3
#include "for.h"
#define PID
#include "critical.h"

byte  gate1 = 0, gate2 = 0;
bool  want[NPROCS] = false;

active [NPROCS] proctype p() {
end:
start:
	do
    ::  
    want[_pid] = true;
		gate1 = _pid+1;
		if
		:: gate2 != 0 -> 
			  want[_pid] = false;
        (gate2 == 0); 
        goto start;
		:: else
		fi;
		gate2 = _pid+1;
		if
		:: gate1 != _pid+1 -> 
			  want[_pid] = false;
        for (I, 1, NPROCS)
				  want[I-1] == false;
        rof (I);
        if
        :: gate2 != _pid+1 -> 
				    (gate2 == 0); 
            goto start;
        :: else
        fi
		:: else
		fi;
    critical_section();
    gate2 = 0;
		want[_pid] = false;
    od
}
