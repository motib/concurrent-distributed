/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Monitor emulation of semaphores
   Verify Safety
*/

byte Sem = 2;
byte critical = 0;
bool lock = false;
bool notZerogate;
byte notZerowaiting;

active [4] proctype p() {
	do
	::
    atomic {
       !lock;
       lock = true;
    }
    if
    :: Sem == 0 ->
         atomic {
            notZerowaiting++;
            lock = false;         /* Exit monitor */
            notZerogate;          /* Wait for gate */
            lock = true;          /* IRR */
            notZerogate = false;  /* Reset gate */
            notZerowaiting--;
         }
    :: else
    fi;
    Sem--;
    lock = false;
    printf("%d in CS\n", _pid);
    critical++;
    assert (critical <= 2);
    critical--;
    Sem++
	od
}
