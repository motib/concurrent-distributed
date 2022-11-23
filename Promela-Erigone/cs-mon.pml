/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Monitor solution for critical section
   Verify Safety
*/

bool lock = false;
byte critical = 0;

active [3] proctype p() {
	do ::
   atomic {
      !lock;
      lock = true;
   }
   printf("%d in CS\n", _pid);
   critical++;
   assert (critical == 1);
   critical--;
   lock = false;
	od
}

