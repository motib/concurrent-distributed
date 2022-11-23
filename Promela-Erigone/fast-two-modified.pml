/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
	Lamport's fast mutual exclusion for two processes
	as modified by Moti Ben-Ari
*/

bool	wantp, wantq = false;
byte  gate1 = 0, gate2 = 0;
bool	criticalp = false, criticalq = false;
bool	tryp = false, tryq = false;

active proctype p() {
p1:
	do
    ::  gate1 = 1;
		wantp = true;
		if
		:: gate2 != 0 -> 
			wantp = false;
            goto p1
		:: else
		fi;
		assert (wantp);
 		gate2 = 1;
		tryp = true;
		assert (wantp);
		assert (!(gate1 == 1) || (gate2 != 0));
		if
		:: gate1 != 1 -> 
			wantp = false;
			assert (!tryq || wantq);
			(!wantq);
			tryp = false;
			assert ( !(gate2 == 1) || !(tryq || criticalq) );
			if 
			:: gate2 != 1 -> goto p1
			:: else -> wantp = true;
			fi
		:: else
		fi;
		tryp = false;
		criticalp = true;
		assert (wantp);
		assert( (gate2 != 0) && (!criticalq) && (!tryq || (gate1 != 2)) );
		criticalp = false;
		gate2 = 0;
    wantp = false;
  od
}

active proctype q() {
q1:
    do
    ::  gate1 = 2;
		wantq = true;
		if
		:: gate2 != 0 -> 
			wantq = false; goto q1
		:: else -> skip
		fi;
		assert (wantq);
		gate2 = 2;
		tryq = true;
		assert (wantq);
		assert (!(gate1 == 2) || (gate2 != 0));
		if
		:: gate1 != 2 -> 
			wantq = false; 
			assert (!tryp || wantp);
			(!wantp);
			tryq = false;
			assert ( !(gate2 == 2) || !(tryp || criticalp) );
			if 
			:: gate2 != 2 -> goto q1
			:: else -> wantq = true;
			fi
		:: else
		fi;
		tryq = false;
		criticalq = true;
		assert (wantq);
		assert( (gate2 != 0) && (!criticalp) && (!tryp || (gate1 != 1)) );
		criticalq = false;
		gate2 = 0;
    wantq = false;
  od
}
