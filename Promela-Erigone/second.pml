/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Second attempt 
   Verify Safety - assertion of mutual exclusion violated
*/

bool inCSp = false, inCSq = false;
byte  critical = 0;

active proctype p() {
  do
  ::
     (inCSq == false);
     inCSp = true;
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
     (inCSp == false);
     inCSq = true;
     printf("q in CS\n");
     critical++;
     assert (critical == 1);
	   critical--;
     inCSq = false;
	od
}
