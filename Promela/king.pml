/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Berman-Garay king algorithm for distributed consensus
   Verify with specialized version   
*/

#include "for.h"
#define NPROCS 5
#define OVERWHELMING 3
#define MESSAGES 10   /* 5 in each round */

mtype = { A, R } ;

/* (sender, plan of, A or R) */
chan ch[NPROCS] = [MESSAGES] of { byte, mtype } ;

mtype choice[NPROCS];

inline Display() {
    d_step {
        printf("MSC: At %d: turn = %d/%d-%d, maj = %e, votes = %d, king = %e\n", 
            myID, turn, first, second, myMajority, votesForMajority, kingPlan);
        for (M, 0, NPROCS-1)
            printf("MSC: %e %e %e %e %e\n", 
                plans[0], plans[1], plans[2], plans[3], plans[4])
        rof(M)
    }
}

inline ComputeMajority() {
    byte Rs, As;
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

proctype Loyal(byte myID; bool first; bool second) {
	mtype plans[NPROCS];
    mtype myMajority, kingPlan;
    byte votesForMajority;
    byte turn;
    
    /* Choose plan */
    if :: plans[myID] = A; :: plans[myID] = R fi;

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
        Display();

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
        Display();
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
        bool k1, k2;
        if :: k1 = true :: k2 = true fi;
        run Loyal(0, k1, k2);
        run Loyal(1, false, false);
        run Loyal(2, false, false);
        run Loyal(3, false, false);
        run Traitor(4, k2, k1);
    }
    (_nr_pr == 1);
    assert( (choice[0] == choice[1]) && 
            (choice[1] == choice[2]) && (choice[2] == choice[3]))
}

