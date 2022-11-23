/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   First attempt 
   Simulate non-termination of non-CS
   Verify Safety - invalid end state
*/

#define NOSTARVE
#include "critical.h"

byte	turn = 1;

active proctype p() {
	do 
	:: 	
		if 			/* NCS does nothing or halts */
		:: true 
		:: true -> false
		fi;
		(turn == 1);
    	critical_section('p');
		turn = 2
	od
}

active proctype q() {	
	do 
	:: 	
		(turn == 2);
     	critical_section('q');
		turn = 1
	od
}
