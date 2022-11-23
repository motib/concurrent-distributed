/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Critical section problem a busy-wait semaphore
   Verify Safety
*/

byte sem = 1;
byte critical = 0;

active proctype P () { 
	do ::
    atomic { sem > 0 ; sem-- }
    printf("P in CS\n");
    critical++;
    assert(critical == 1);
    critical--;
    sem++
  od
}

active proctype Q () { 
	do :: 
    atomic { sem > 0 ; sem-- }
    printf("Q in CS\n");
    critical++;
    assert(critical == 1);
    critical--;
    sem++
	od
}

