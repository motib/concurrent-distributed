/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Bakery algorithm
   Verify Safety - I couldn't get the ticket numbers can overflow
   Verify with pan option -m500: no overflow at that depth
   Verify Acceptance with <>nostarve
*/

#define NPROCS 3
#include "for.h"
#define PID
#define NOSTARVE
#include "critical.h"

bool	choosing[NPROCS] = false;
byte	number[NPROCS] = 0;

active [NPROCS] proctype p() {
	byte max;
	do
    ::  choosing[_pid] = true;
		max = 0;
		for (I,0,NPROCS-1)
			if 
			:: number[I] > max -> 
				max = number[I] 
			:: else
			fi;
		rof (I);
		number[_pid] = 1 + max;
		choosing[_pid] = false;
		for (I, 0, NPROCS-1)
			if 
			:: I != _pid ->
				(choosing[I] == false);
				(number[I] == 0) || 
				(number[_pid] < number[I]) ||
				((number[_pid] == number[I]) &&
				 (_pid < I))
			:: else
			fi;
		rof (I);
    	critical_section();
    	number[_pid] = 0;
    od
}
