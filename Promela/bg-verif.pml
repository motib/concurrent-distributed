/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
	Byzantine Generals algorithm
	Version specialized for verification
    See readme.txt for verification instructions
*/

#include "for.h"

mtype = { A, R } ;

/* (sender, plan of, A or R) */
/* Channels without buffers, so must synchronize rounds */
/* For traitor, just choose non-deterministically */
chan ch[3] = [0] of { byte, byte, mtype } ;
byte   waitFor;

typedef vector {
	mtype p[4]
};

typedef matrix {
    vector v[4]
};

matrix plans[3];
/*
   plans[I].v[J].p[K] is:
     In General I, K thinks that this is J's plan
*/
mtype  choice[3];
#define T 3  /* ID of traitor */

inline send( to, about) {
  ch[to] ! myID, about, plans[myID].v[about].p[about];
}

proctype LoyalSend(mtype p; byte myID; byte g1; byte g2) {
    plans[myID].v[myID].p[myID] = p;
    atomic {
		send(g1, myID);
		send(g2, myID);
    }
    (waitFor == 3);
    atomic {
		send(g1, g2);
		send(g1, T);
		send(g2, g1);
		send(g2, T);
    }
}

inline ComputeMajority(myID) {
	byte choseR, choseA;
	byte Rs, As;
    d_step {
		choseR = 0;
		choseA = 0;
		for (I, 0, 3)
            Rs = 0; 
            As = 0;
            for (N, 0, 3)
                if
                :: (plans[myID].v[I].p[N] == A) -> As++;
                :: (plans[myID].v[I].p[N] == R) -> Rs++;
                ::  else
                fi;
            rof (N);
            if
            :: (Rs >= As) -> choseR++
            :: (As > Rs) -> choseA++
            fi
        rof (I);
        choice[myID] = ((choseR >= choseA) -> R : A);
	}
}

inline Display() {
    d_step {
        printf("MSC: At %d:\n", myID);
        for (M, 0, 3)
            printf("MSC: %e %e %e %e\n", 
                plans[myID].v[M].p[0], plans[myID].v[M].p[1], 
				plans[myID].v[M].p[2], plans[myID].v[M].p[3])
        rof(M)
    }
}

proctype LoyalReceive(byte myID; byte g1; byte g2) {
    byte I, J;
    mtype M;
    ch[myID] ? I, _, M; plans[myID].v[I].p[I] = M;
	ch[myID] ? I, _, M; plans[myID].v[I].p[I] = M;
	if :: plans[myID].v[T].p[T] = A :: plans[myID].v[T].p[T] = R fi;
	Display();
	waitFor++;
    ch[myID] ? I, J, M; plans[myID].v[J].p[I] = M;
    ch[myID] ? I, J, M; plans[myID].v[J].p[I] = M;
    ch[myID] ? I, J, M; plans[myID].v[J].p[I] = M;
    ch[myID] ? I, J, M; plans[myID].v[J].p[I] = M;
	if :: plans[myID].v[g1].p[T] = A :: plans[myID].v[g1].p[T] = R fi; 
	if :: plans[myID].v[g2].p[T] = A :: plans[myID].v[g2].p[T] = R fi; 
	Display();
    ComputeMajority(myID)
}

init {
	atomic {
		/*  Choose initial plans nondeterministically.
		    If you can't verify for all choices of plans,
		    verify each choice separately.
			By symmetry there are four: AAA, AAR, ARR, RRR
		*/		
/*
		mtype plan;
		if :: plan = A :: plan = R fi; 
		run LoyalSend(plan, 0, 1, 2);
		if :: plan = A :: plan = R fi; 
		run LoyalSend(plan, 1, 0, 2);
		if :: plan = A :: plan = R fi; 
		run LoyalSend(plan, 2, 0,1 );
*/
/* */
		run LoyalSend(A, 0, 1, 2);
		run LoyalSend(A, 1, 0, 2);
		run LoyalSend(R, 2, 0,1 );
/* */
		run LoyalReceive(0, 1, 2);
		run LoyalReceive(1, 0, 2);
		run LoyalReceive(2, 0, 1);
	}
	(_nr_pr == 1);
    printf("MSC: Choices are %e %e %e\n", choice[0], choice[1], choice[2]);
    assert( (choice[0] == choice[1]) && (choice[1] == choice[2]) )
}

