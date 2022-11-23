/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Third attempt
   Verify Safety - invalid end state because of deadlock
*/

bool inCSp = false, inCSq = false;
byte  critical = 0;

active proctype p() {
  do
  ::
     inCSp = true;
     (inCSq == false);
     printf("p in CS\n");
     critical++;
     assert (critical == 1);
     critical--;
     inCSp = false;
	od
}

active proctype q() {	
	do 
	:: 	
     inCSq = true;
     (inCSp == false);
     printf("q in CS\n");
     critical++;
     assert (critical == 1);
	   critical--;
     inCSq = false;
	od
}
