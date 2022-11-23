/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Berman-Garay king algorithm for distributed consensus
   Version specialized for verification
   See readme.txt for verification instructions

*/

#include "for.h"
#define NPROCS 5
#define OVERWHELMING 3
#define MESSAGES 10

mtype = { A, R } ;

/* (sender, plan of, A or R) */
chan ch[NPROCS] = [MESSAGES] of { byte, mtype } ;

mtype choice[NPROCS];

hidden byte Rs, As;

inline ComputeMajority() {
    d_step {
        Rs = 0; 
        As = 0;
        for (N, 0, NPROCS-1)
            if
            :: (plans[N] == A) -> As++;
            :: (plans[N] == R) -> Rs++;
            ::  else
            fi;
        rof (N);
        if
        :: (Rs >= As) -> myMajority = R; votesForMajority = Rs
        :: (As > Rs) -> myMajority = A; votesForMajority = As
        fi
    }
}

proctype Loyal(byte myID; mtype myPlan; bool first; bool second) {
	mtype plans[NPROCS];
    mtype myMajority, kingPlan;
    byte votesForMajority;
    byte turn;
    
    plans[myID] = myPlan;
    do
    :: turn == 2 -> break
    :: else ->
        /* Send my plan to other generals */
        for (I, 0, NPROCS-1)
            if 
            :: I != myID -> ch[I] ! myID, plans[myID]
            :: else
            fi
        rof (I);
        
        /* Receive plans from other generals */
        mtype p;
        byte J;
        for (I, 0, NPROCS-2)
            ch[myID] ? J, p;
            plans[J] = p
        rof (I);
        ComputeMajority();

        /* Send and receive king's plan */
        if
        :: ((turn == 0) && first) || ((turn == 1) && second) ->
            for (I, 0, NPROCS-1)
                if 
                :: I != myID -> ch[I] ! myID, myMajority
                :: else
                fi
            rof (I);
            plans[myID] = myMajority
        :: else ->
                ch[myID] ? _, kingPlan;
                if 
                :: votesForMajority > OVERWHELMING -> plans[myID] = myMajority
                :: else -> plans[myID] = kingPlan
                fi
        fi;
        turn++;
    od;

    choice[myID] = plans[myID];
    printf("MSC: At %d, choice is %e\n", myID, choice[myID]) 
}

proctype Traitor(byte myID; bool first; bool second) {
    byte turn;
    do
    :: turn == 2 -> break
    :: else ->
        /* Send my plan to other generals */
        for (I, 0, NPROCS-1)
            if 
            :: I != myID -> ch[I] ! myID, A
            :: I != myID -> ch[I] ! myID, R
            :: else
            fi
        rof (I);
        /* Receive plans from other generals */
        for (I, 0, NPROCS-2)
            ch[myID] ? _, _
        rof (I);

        /* Send and receive king's plan */
        if
        :: ((turn == 0) && first) || ((turn == 1) && second) ->
            for (I, 0, NPROCS-1)
                if 
                :: I != myID -> ch[I] ! myID, A
                :: I != myID -> ch[I] ! myID, R
                :: else
                fi
            rof (I);
        :: else -> ch[myID] ? _, _
        fi;
        turn++;
    od;
}

init {
    atomic {
        bool k1 = false, k2 = true;
        run Loyal(0, A, k1, k2);
        run Loyal(1, R, false, false);
        run Loyal(2, A, false, false);
        run Loyal(3, R, false, false);
        run Traitor(4, k2, k1);
    }
    (_nr_pr == 1);
    assert( (choice[0] == choice[1]) && 
            (choice[1] == choice[2]) && (choice[2] == choice[3]))
}

