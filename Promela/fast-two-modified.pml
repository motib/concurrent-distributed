/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
	Lamport's fast mutual exclusion for two processes
	as modified by Moti Ben-Ari
*/

#define P 1
#define Q 2

bool	wantp, wantq = false;
byte    gate1 = 0, gate2 = 0;
bool	criticalp = false, criticalq = false;
bool	tryp = false, tryq = false;

active proctype p() {
p1:
	do
    ::  gate1 = P;
		wantp = true;
		if
		:: gate2 != 0 -> 
			wantp = false;
            goto p1
		:: else
		fi;
		assert (wantp);
 		gate2 = P;
		tryp = true;
		assert (wantp);
		assert (!(gate1 == P) || (gate2 != 0));
		if
		:: gate1 != P -> 
			wantp = false;
			assert (!tryq || wantq);
			(!wantq);
			tryp = false;
			assert ( !(gate2 == P) || !(tryq || criticalq) );
			if 
			:: gate2 != P -> goto p1
			:: else -> wantp = true;
			fi
		:: else
		fi;
		tryp = false;
		criticalp = true;
		assert (wantp);
		assert( (gate2 != 0) && (!criticalq) && (!tryq || (gate1 != Q)) );
		criticalp = false;
		gate2 = 0;
        wantp = false;
    od
}

active proctype q() {
q1:
    do
    ::  gate1 = Q;
		wantq = true;
		if
		:: gate2 != 0 -> 
			wantq = false; goto q1
		:: else -> skip
		fi;
		assert (wantq);
		gate2 = Q;
		tryq = true;
		assert (wantq);
		assert (!(gate1 == Q) || (gate2 != 0));
		if
		:: gate1 != Q -> 
			wantq = false; 
			assert (!tryp || wantp);
			(!wantp);
			tryq = false;
			assert ( !(gate2 == Q) || !(tryp || criticalp) );
			if 
			:: gate2 != Q -> goto q1
			:: else -> wantq = true;
			fi
		:: else
		fi;
		tryq = false;
		criticalq = true;
		assert (wantq);
		assert( (gate2 != 0) && (!criticalp) && (!tryp || (gate1 != P)) );
		criticalq = false;
		gate2 = 0;
        wantq = false;
    od
}
