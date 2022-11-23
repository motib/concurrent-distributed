/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   First attempt 
   Simulate non-termination of non-CS
   Verify Safety - invalid end state
*/

byte	turn = 1;
byte  critical = 0;

active proctype p() {
	do 
	:: 	
		if 			/* NCS does nothing or halts */
		:: true 
		:: true -> false
		fi;
		(turn == 1);
     printf("p in CS\n");
     critical++;
     assert (critical == 1);
	   critical--;
		turn = 2
	od
}

active proctype q() {	
	do 
	:: 	
		(turn == 2);
     printf("q in CS\n");
     critical++;
     assert (critical == 1);
	   critical--;
		turn = 1
	od
}
