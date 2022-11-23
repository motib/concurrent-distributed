/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Distributed consensus with crash failure
*/

#include "for.h"
#define NPROCS 3	 /* Works for three generals including one traitor */
#define MESSAGES 4   /* 2 first round and 1 + 1 second round */

mtype = { A, R } ;

/* (sender, plan of, A or R) */
chan ch[NPROCS] = [MESSAGES] of { byte, byte, mtype } ;

mtype choice[NPROCS];

typedef vector {
	mtype p[NPROCS]
}

inline Display() {
    d_step {
        printf("MSC: At %d:\n", myID);
        for (M, 0, NPROCS-1)
            printf("MSC: %e %e %e \n", 
                plans[M].p[0], plans[M].p[1], plans[M].p[2])
        rof(M)
    }
}

inline ComputeMajority(G) {
    byte Rs, As;
    Rs = 0; 
    As = 0;
    for (N, 0, NPROCS-1)
        if
        :: (plans[G].p[N] == A) -> As++;
        :: (plans[G].p[N] == R) -> Rs++;
        ::  else
        fi;
    rof (N);
    if
    :: (Rs >= As) -> majority[G] = R; choseR++
    :: (As > Rs) -> majority[G] = A; choseA++
    fi
}

proctype Loyal( byte myID) {
	/* plans[I] - what is known about node I in this node: */
	/* plans[myID].p[myID] - what this node chose */
	/* plans[I].p[I] - what node I sent to this node */
	/* plans[I].p[J] - what node J sent to this node about node I */
	vector plans[NPROCS];
    
    /* Choose plan */
    if :: plans[myID].p[myID] = A; :: plans[myID].p[myID] = R fi;

	/* Send my plan to other generals */
	for (I, 0, NPROCS-1)
		if 
		:: I != myID -> ch[I] ! myID, myID, plans[myID].p[myID]
		:: else
		fi
	rof (I);
	
	/* Receive plans from other generals */
	for (I, 0, NPROCS-1)
		if
		:: I != myID -> ch[myID] ?? eval(I), eval(I), plans[I].p[I]
		:: else
		fi
	rof (I);
    Display();	

	/* Report plans of generals */
	for (I, 0, NPROCS-1)
		for (J, 0, NPROCS-1)
			if 
			:: (I != myID) && (J != myID) && (J != I) -> 
                ch[I] ! myID, J, plans[J].p[J]
            :: else
		    fi
		rof (J)
	rof (I);
	
	/* Receive report plans of generals */
	for (I, 0, NPROCS-1)
		for (J, 0, NPROCS-1)
			if 
			:: (I != myID) && (J != myID) && (J != I) -> 
                ch[myID] ?? eval(I), eval(J), plans[J].p[I]
            :: else
		    fi
		rof (J)
	rof (I);
    Display();	

    /* Compute majorities and decision */
	mtype majority[NPROCS];
    byte choseR = 0, choseA = 0;
    for (I, 0, NPROCS-1)
        ComputeMajority(I);
    rof (I);
    choice[myID] = ((choseR >= choseA) -> R : A);
    printf("MSC: At %d, majority vector is: %e %e %e, choice is %e\n", 
        myID, majority[0], majority[1], majority[2], choice[myID]) 
}

proctype Traitor( byte myID) {
	/* For crash failures, same as loyal but nondeterministically send 0 */
	vector plans[NPROCS];
	bool crashed = false;
    
    /* Choose plan */
    if :: plans[myID].p[myID] = A; :: plans[myID].p[myID] = R fi;

	/* Send my plan to other generals */
	for (I, 0, NPROCS-1)
		if 
		:: I != myID -> 
			if
			:: crashed -> ch[I] ! myID, myID, 0; crashed = true
			:: !crashed -> ch[I] ! myID, myID, plans[myID].p[myID]
			:: !crashed -> ch[I] ! myID, myID, 0; crashed = true
			fi
		:: else
		fi
	rof (I);
	
	/* Receive plans from other generals */
	for (I, 0, NPROCS-1)
		if
		:: I != myID -> ch[myID] ?? eval(I), eval(I), plans[I].p[I]
		:: else
		fi
	rof (I);
    Display();

	/* Report plans of generals */
	for (I, 0, NPROCS-1)
		for (J, 0, NPROCS-1)
			if
			:: (I != myID) && (J != myID) && (J != I) -> 
				if
				:: crashed -> ch[I] ! myID, J, 0
				:: !crashed -> ch[I] ! myID, J, 0; crashed = true
                :: !crashed -> ch[I] ! myID, J, plans[J].p[J]
				fi
            :: else
		    fi
		rof (J)
	rof (I);
	
	/* Receive report plans of generals */
	for (I, 0, NPROCS-1)
		for (J, 0, NPROCS-1)
			if 
			:: (I != myID) && (J != myID) && (J != I) -> 
                ch[myID] ? _, _, _
            :: else
		    fi
		rof (J)
	rof (I);
}

init {
    atomic {
        for (I, 0, NPROCS-2)
            run Loyal(I)
        rof (I);
        run Traitor(NPROCS-1)
    }
    (_nr_pr == 1);
    assert(choice[0] == choice[1])
}

