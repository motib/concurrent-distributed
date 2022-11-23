/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Distributed consensus by flooding
   One set of plans can be chosen arbitrary or any set nondeterministically
   See readme.txt for verification instructions,
     but partially verify with -DBITSTATE instead of -DCOLLAPSE
*/

#include "for.h"

mtype = { A, R } ;
typedef vector {
	mtype p[4]
};

/* (sender, plan of, A or R) */
chan ch[4] = [0] of { vector } ;

vector plans[4];
bool choice0, choice1;
bool crashed2, crashed3;
hidden byte  waitFor;
hidden vector zeros;
hidden byte Rs;
hidden byte As;

inline ComputeMajority(myID) {
	d_step {
	    Rs = 0;
		As = 0;
		for (N, 0, 3)
			if
			:: (plans[myID].p[N] == A) -> As++;
			:: (plans[myID].p[N] == R) -> Rs++;
			::  else
			fi;
		rof (N);
		if
		:: (myID == 0) && (Rs >= As) -> choice0 = true
		:: (myID == 1) && (Rs >= As) -> choice1 = true
		:: (myID == 0) && (As > Rs) -> choice0 = false
		:: (myID == 1) && (As > Rs) -> choice1 = false
		fi;
	}
}

inline Union (myID, g1, g2, g3) {
	d_step {
		if :: (plans[myID].p[g1] == 0) && (received.p[g1] != 0) -> 
				plans[myID].p[g1] = received.p[g1] ::  else fi;
		if :: (plans[myID].p[g2] == 0) && (received.p[g2] != 0) -> 
				plans[myID].p[g2] = received.p[g2] ::  else fi;
		if :: (plans[myID].p[g3] == 0) && (received.p[g3] != 0) -> 
				plans[myID].p[g3] = received.p[g3] ::  else fi;
	}
}

proctype LoyalSend0() {
	for (T, 0, 2) 
		atomic {
			ch[1] ! plans[0];
			ch[2] ! plans[0];
			ch[3] ! plans[0];
		}
		waitFor >= 4*(T+1)
	rof (T);
}

proctype LoyalSend1() {
	for (T, 0, 2) 
		atomic {
			ch[0] ! plans[1];
			ch[2] ! plans[1];
			ch[3] ! plans[1];
		}
		waitFor >= 4*(T+1)
	rof (T);
}

proctype LoyalReceive0() {
	vector received;
	for (T, 0, 2) 
		atomic {
			ch[0] ? received; Union(0, 1, 2, 3);
			ch[0] ? received; Union(0, 1, 2, 3);
			ch[0] ? received; Union(0, 1, 2, 3);
		}
		waitFor++
	rof (T);
}

proctype LoyalReceive1() {
	vector received;
	for (T, 0, 2) 
		atomic {
			ch[1] ? received; Union(1, 0, 2, 3);
			ch[1] ? received; Union(1, 0, 2, 3);
			ch[1] ? received; Union(1, 0, 2, 3);
		}
		waitFor++
	rof (T);
}

proctype TraitorSend2() {
	for (T, 0, 2) 
		atomic {
			if
			:: crashed2 -> ch[0] ! zeros
			:: !crashed2 -> ch[0] ! plans[2]
			:: !crashed2 -> ch[0] ! zeros; crashed2 = true
			fi;
			if
			:: crashed2 -> ch[1] ! zeros
			:: !crashed2 -> ch[1] ! plans[2]
			:: !crashed2 -> ch[1] ! zeros; crashed2 = true
			fi;
			if
			:: crashed2 -> ch[3] ! zeros
			:: !crashed2 -> ch[3] ! plans[2]
			:: !crashed2 -> ch[3] ! zeros; crashed2 = true
			fi;
		}
		waitFor >= 4*(T+1)
	rof (T);
}

proctype TraitorSend3() {
	for (T, 0, 2) 
		atomic {
			if
			:: crashed3 -> ch[0] ! zeros
			:: !crashed3 -> ch[0] ! plans[3]
			:: !crashed3 -> ch[0] ! zeros; crashed3 = true
			fi;
			if
			:: crashed3 -> ch[1] ! zeros
			:: !crashed3 -> ch[1] ! plans[3]
			:: !crashed3 -> ch[1] ! zeros; crashed3 = true
			fi;
			if
			:: crashed3 -> ch[2] ! zeros
			:: !crashed3 -> ch[2] ! plans[3]
			:: !crashed3 -> ch[2] ! zeros; crashed3 = true
			fi;
		}
		waitFor >= 4*(T+1)
	rof (T);
}

proctype TraitorReceive2() {
	vector received;
	for (T, 0, 2)
		atomic {
			ch[2] ? received;
			if :: !crashed2 -> Union(2, 0, 1, 3) :: else fi;
			ch[2] ? received;
			if :: !crashed2 -> Union(2, 0, 1, 3) :: else fi;
			ch[2] ? received;
			if :: !crashed2 -> Union(2, 0, 1, 3) :: else fi;
		}
		waitFor++
	rof (T);
}

proctype TraitorReceive3() {
	vector received;
	for (T, 0, 2)
		atomic {
			ch[3] ? received;
			if :: !crashed3 -> Union(3, 0, 1, 2) :: else fi;
			ch[3] ? received;
			if :: !crashed3 -> Union(3, 0, 1, 2) :: else fi;
			ch[3] ? received;
			if :: !crashed3 -> Union(3, 0, 1, 2) :: else fi;
		}
		waitFor++
	rof (T);
}

init {
    atomic {
        /* Choose arbitrary plan */

		plans[0].p[0] = A; 
		plans[1].p[1] = R;
		plans[2].p[2] = A; 
		plans[3].p[3] = R;

        /* Choose plan nondeterministically */
/*
		if :: plans[0].p[0] = A; :: plans[0].p[0] = R fi;
		if :: plans[1].p[1] = A; :: plans[1].p[1] = R fi;
		if :: plans[2].p[2] = A; :: plans[2].p[2] = R fi;
		if :: plans[3].p[3] = A; :: plans[3].p[3] = R fi;
*/
        run LoyalSend0();
		run LoyalSend1();
        run LoyalReceive0();
		run LoyalReceive1();
		run TraitorSend2();
		run TraitorSend3();
		run TraitorReceive2();
		run TraitorReceive3();
		}
    (_nr_pr == 1);
	ComputeMajority(0);
	ComputeMajority(1);
    assert(choice0 == choice1)
}

