/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Lamport's fast mutual exclusion algorithm for two processes
   Verify Safety
*/

byte gate1 = 0, gate2 = 0;
bool wantp = false, wantq = false;
byte critical = 0;

active proctype p() {
end:
start:
	do
    ::  wantp = true;
		gate1 = 1;
		if
		:: gate2 != 0 -> 
			wantp = false;
			(gate2 == 0); 
			goto start;
		:: else
		fi;
		gate2 = 1;
		if
		:: gate1 != 1 -> 
			wantp = false;
			(wantq == false);
			if
			:: gate2 != 1 -> 
				(gate2 == 0); 
				goto start;
			:: else
			fi
		:: else
		fi;
    printf("p in CS\n");
    critical++;
    assert (critical == 1);
    critical--;
    gate2 = 0;
		wantp = false;
  od
}

active proctype q() {
end:
start:
	do
    ::  wantq = true;
    	gate1 = 2;
		if
		:: gate2 != 0 -> 
			wantq = false;
			(gate2 == 0);
			goto start;
		:: else
		fi;
		gate2 = 2;
		if
		:: gate1 != 2 -> 
			wantq = false;
			(wantp == false);
			if
			:: gate2 != 2 -> 
				(gate2 == 0);
				goto start;
			:: else
			fi
		:: else
		fi;
    printf("q in CS\n");
    critical++;
    assert (critical == 1);
    critical--;
    gate2 = 0;
		wantq = false;
  od
}
