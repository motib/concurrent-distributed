/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Mattern's credit-recovery algorithm for distributed termination
   Verify Safety
   Verify Acceptance [](allTerminated -> <>announceTermination)
*/

#include "for.h"
#define NPROCS 4
#define M 2             /* Number of messages */
#define INITIAL 128     /* Start with initial positive credit */

#define allTerminated (terminated[1] && terminated[2] && terminated[3])
#define announceTermination (weight[0] == INITIAL)

/* Send message/signal, weight */
mtype = { message, signal } ;
chan ch[NPROCS] = [M] of { mtype, byte } ;
byte 	weight[NPROCS];
bool	terminated[NPROCS];

/* 
	Outgoing nodes are stored in channels of bytes
	which are passed to each SendMessage processes
	and the environment process during initialization.
*/

proctype Env(chan outgoing) {
	byte outg, w;
    weight[0] = INITIAL;
    printf("MSC: Start with weight %x\n", weight[0]);
	do
	:: empty(outgoing) -> break; 
	:: outgoing ? outg ->
		weight[0] = weight[0] / 2;
		ch[outg] ! message, weight[0]; 
	od;
	printf("MSC: Environment waiting\n");
    do	
    ::  atomic {
		    ch[0] ? signal, w;
			printf("MSC: Received signal with weight %x at environment\n", w);
			weight[0] = weight[0] + w;
            if 	:: weight[0] == INITIAL -> break :: else fi
		}
	od;
	printf("MSC: Termination!!\n");
	assert(allTerminated)
}

proctype SendMessage( byte myID; chan outgoing ) {
	byte outg;
	(weight[myID] > 0);
	for (count, 1, M)
        atomic {
            /* Select outgoing node and replace */
            outgoing ? outg; outgoing ! outg;
            weight[myID] = weight[myID] / 2;
            ch[outg] ! message, weight[myID]; 
        }
	rof (count);
	terminated[myID] = true;
}

proctype ReceiveMessage( byte myID ) {
	byte w;
end:do
	::	atomic {
            ch[myID] ? message, w;
			printf("MSC: Received message with weight %x at %d\n", w, myID);
			if
			:: !terminated[myID] && (weight[myID] == 0) -> weight[myID] = w;
			::	else -> ch[0] ! signal, w
			fi;
            
		}
	od
}

proctype SendSignal( byte myID ) {
    atomic {
        terminated[myID];
        ch[0] ! signal, weight[myID];
        weight[myID] = 0;
    }
}

inline InitNode(ID, out) {
	run SendMessage(ID, out); 
	run ReceiveMessage(ID); 
	run SendSignal(ID); 
}

init {
	atomic {
		/* Initialize according to graph in book */
		chan outEnv = [2] of { byte };
		outEnv ! 1; outEnv ! 2;
		chan out1 = [2] of { byte };
		out1 ! 2; out1 ! 3;
		chan out2 = [1] of { byte };
		out2 ! 1;
		chan out3 = [1] of { byte };
		out3 ! 2;

		run Env(outEnv);
		InitNode(1, out1); 
		InitNode(2, out2); 
		InitNode(3, out3); 
    }
}

