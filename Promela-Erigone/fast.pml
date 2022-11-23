/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Lamport's fast mutual exclusion algorithm
   Verify Safety with -ll20 -ls10 -lt1000
*/

byte  gate1 = 0, gate2 = 0;
bool  want[3] = false;
byte  critical = 0;

active [3] proctype p() {
byte I;
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
        I = 1;
        do
        :: I > 3 -> break
        :: else ->
           want[I-1] == false;
           I++
        od;
        if
        :: gate2 != _pid+1 -> 
				    (gate2 == 0); 
            goto start;
        :: else
        fi
		:: else
		fi;
    printf("%d in CS\n", _pid);
    critical++;
    assert (critical == 1);
    critical--;
    gate2 = 0;
		want[_pid] = false;
    od
}
