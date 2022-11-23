/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/*
   Distributed consensus by flooding
   One set of plans can be chosen arbitrary or any set nondeterministically
   See readme.txt for verification instructions,
	Version specialized for verification:
		store all plans in one byte and use masking to access
*/

#include "for.h"
#define A0 1
#define R0 2
#define A1 4
#define R1 8
#define A2 16
#define R2 32
#define A3 64
#define R3 128

/* (sender, plan of, A or R) */
chan ch[4] = [0] of { byte };

byte plans[4];
bool choice0, choice1;
bool crashed2, crashed3;
hidden byte  waitFor;
hidden byte Rs;
hidden byte As;
hidden byte ARmask[4];

inline ComputeMajority(myID) {
	d_step {
	    Rs = 0;
		As = 0;
		if
		:: (plans[myID] & ARmask[0] == A0) -> As++;
		:: (plans[myID] & ARmask[0] == R0) -> Rs++;
		::  else
		fi;
		if
		:: (plans[myID] & ARmask[1] == A1) -> As++;
		:: (plans[myID] & ARmask[1] == R1) -> Rs++;
		::  else
		fi;
		if
		:: (plans[myID] & ARmask[2] == A2) -> As++;
		:: (plans[myID] & ARmask[2] == R2) -> Rs++;
		::  else
		fi;
		if
		:: (plans[myID] & ARmask[3] == A3) -> As++;
		:: (plans[myID] & ARmask[3] == R3) -> Rs++;
		::  else
		fi;
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
		byte b;
		b = received & ARmask[g1];
		if :: (plans[myID] & ARmask[g1] == 0) && (b != 0) -> 
				plans[myID] = plans[myID] & ~ARmask[g1] | b ::  else fi;
		b = received & ARmask[g2];
		if :: (plans[myID] & ARmask[g2] == 0) && (b != 0) -> 
				plans[myID] = plans[myID] & ~ARmask[g2] | b ::  else fi;
		b = received & ARmask[g3];
		if :: (plans[myID] & ARmask[g3] == 0) && (b != 0) -> 
				plans[myID] = plans[myID] & ~ARmask[g3] | b ::  else fi;
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
	byte received;
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
	byte received;
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
			:: crashed2 -> ch[0] ! 0
			:: !crashed2 -> ch[0] ! plans[2];
			:: !crashed2 -> ch[0] ! 0; crashed2 = true
			fi;
			if
			:: crashed2 -> ch[1] ! 0
			:: !crashed2 -> ch[1] ! plans[2];
			:: !crashed2 -> ch[1] ! 0; crashed2 = true
			fi;
			if
			:: crashed2 -> ch[3] ! 0
			:: !crashed2 -> ch[3] ! plans[2];
			:: !crashed2 -> ch[3] ! 0; crashed2 = true
			fi;
		}
		waitFor >= 4*(T+1)
	rof (T);
}

proctype TraitorSend3() {
	for (T, 0, 2) 
		atomic {
			if
			:: crashed3 -> ch[0] ! 0
			:: !crashed2 -> ch[0] ! plans[3];
			:: !crashed3 -> ch[0] ! 0; crashed3 = true
			fi;
			if
			:: crashed3 -> ch[1] ! 0
			:: !crashed2 -> ch[1] ! plans[3];
			:: !crashed3 -> ch[1] ! 0; crashed3 = true
			fi;
			if
			:: crashed3 -> ch[2] ! 0
			:: !crashed2 -> ch[2] ! plans[3];
			:: !crashed3 -> ch[2] ! 0; crashed3 = true
			fi;
		}
		waitFor >= 4*(T+1)
	rof (T);
}

proctype TraitorReceive2() {
	byte received;
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
	byte received;
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
		ARmask[0] = 3; ARmask[1] = 12; ARmask[2] = 48; ARmask[3] = 192; 

        /* Choose arbitrary plan */

		plans[0] = A0; 
		plans[1] = R1;
		plans[2] = A2; 
		plans[3] = R3;

        /* Choose plan nondeterministically */
/*
		if :: plans[0] = A0; :: plans[0] = R0 fi;
		if :: plans[1] = A1; :: plans[1] = R1 fi;
		if :: plans[2] = A2; :: plans[2] = R2 fi;
		if :: plans[3] = A3; :: plans[3] = R3 fi;
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

