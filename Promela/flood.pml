/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Distributed consensus by flooding
   Verify with specialized versions
*/

#include "for.h"
#define NPROCS 4
#define TRAITORS 2
#define MESSAGES 3

mtype = { A, R } ;
typedef vector {
	mtype p[NPROCS]
};

/* (sender, plan of, A or R) */
chan ch[NPROCS] = [MESSAGES] of { vector } ;

mtype choice[NPROCS];

inline Display() {
    d_step {
        printf("MSC: At %d:\n", myID);
        for (M, 0, NPROCS-1)
            printf("MSC: %e %e %e %e\n", 
                plans.p[0], plans.p[1], plans.p[2], plans.p[3])
        rof(M)
    }
}

inline ComputeMajority() {
    byte Rs = 0, As = 0;
    for (N, 0, NPROCS-1)
        if
        :: (plans.p[N] == A) -> As++;
        :: (plans.p[N] == R) -> Rs++;
        ::  else
        fi;
    rof (N);
    if
    :: (Rs >= As) -> choice[myID] = R
    :: (As > Rs) -> choice[myID] = A
    fi
}

proctype Loyal( byte myID) {
	vector plans;
	vector received;
    
    /* Choose plan */
    if :: plans.p[myID] = A; :: plans.p[myID] = R fi;

	for (T, 0, TRAITORS) 
		/* Send plan to other generals */
		for (I, 0, NPROCS-1)
			if 
			:: I != myID -> ch[I] ! plans
			:: else
			fi
		rof (I);
		
		/* Receive plans from other generals */
		for (I, 0, NPROCS-1)
			if
			:: I != myID -> 
				ch[myID] ? received;
				for (N, 0, NPROCS-1)
					if
					:: (plans.p[N] == 0) && (received.p[N] != 0) -> 
						plans.p[N] = received.p[N]
					::  else
					fi;
				rof (N)
			:: else
			fi
		rof (I);
		Display();	
	rof (T);
	
    ComputeMajority();
    printf("MSC: At %d, choice is %e\n", myID, choice[myID]) 
}

proctype Traitor( byte myID) {
	vector plans;
	vector received;
	vector zeros;
	bool crashed = false;
    
    /* Choose plan */
    if :: plans.p[myID] = A; :: plans.p[myID] = R fi;

	for (T, 0, TRAITORS) 
		/* Send plan to other generals */
		for (I, 0, NPROCS-1)
			if 
			:: I != myID ->
				if
				:: crashed -> ch[I] ! zeros
				:: !crashed -> ch[I] ! plans
				:: !crashed -> ch[I] ! zeros; crashed = true
				fi
			:: else
			fi
		rof (I);
		
		/* Receive plans from other generals */
		for (I, 0, NPROCS-1)
			if
			:: I != myID -> 
				ch[myID] ? received;
				if
				:: !crashed ->
					for (N, 0, NPROCS-1)
						if
						:: (plans.p[N] == 0) && (received.p[N] != 0) -> 
							plans.p[N] = received.p[N]
						::  else
						fi;
					rof (N)
				:: else
				fi
			:: else
			fi
		rof (I);
		Display();	
	rof (T);
}

init {
    atomic {
        run Loyal(0);
		run Loyal(1);
		run Traitor(2);
		run Traitor(3);
    }
    (_nr_pr == 1);
    assert((choice[0] != 0) && (choice[0] == choice[1]))
}

