/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Lamport's fast mutual exclusion algorithm for two processes
   Verify Safety
*/

#include "critical.h"
#define P 1
#define Q 2
byte    gate1 = 0, gate2 = 0;
bool	wantp = false, wantq = false;

active proctype p() {
end:
start:
	do
    ::  wantp = true;
		gate1 = P;
		if
		:: gate2 != 0 -> 
			wantp = false;
			(gate2 == 0); 
			goto start;
		:: else
		fi;
		gate2 = P;
		if
		:: gate1 != P -> 
			wantp = false;
			(wantq == false);
			if
			:: gate2 != P -> 
				(gate2 == 0); 
				goto start;
			:: else
			fi
		:: else
		fi;
    critical_section('p');
    gate2 = 0;
		wantp = false;
    od
}

active proctype q() {
end:
start:
	do
    ::  wantq = true;
    	gate1 = Q;
		if
		:: gate2 != 0 -> 
			wantq = false;
			(gate2 == 0);
			goto start;
		:: else
		fi;
		gate2 = Q;
		if
		:: gate1 != Q -> 
			wantq = false;
			(wantp == false);
			if
			:: gate2 != Q -> 
				(gate2 == 0);
				goto start;
			:: else
			fi
		:: else
		fi;
    	critical_section('q');
	    gate2 = 0;
		wantq = false;
    od
}
