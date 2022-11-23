/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Dijkstra-Scholten algorithm for distributed termination
   Verify Safety
   Verify Acceptance with [](allTerminated -> <>announceTermination
*/

#include "for.h"
#define NPROCS 4
#define M 2             /* Number of messages */

#define allTerminated (terminated[1] && terminated[2] && terminated[3])
#define announceTermination (outDeficit[0] == 0)

mtype = { message, signal } ;
chan ch[NPROCS] = [M] of { mtype, byte } ;

typedef edges {        /* Simulate two-dimensional array */
	byte e[NPROCS];
};

short	parent[NPROCS] = -1;
edges	inDeficit[NPROCS];
byte	inSum[NPROCS];
byte	outDeficit[NPROCS];
bool	terminated[NPROCS];

/* 
	Outgoing nodes are stored in channels of bytes
	which are passed to each SendMessage processes
	and the environment process during initialization.
*/

proctype Env(chan outgoing) {
	byte outg;
	do
	:: empty(outgoing) -> break; 
	:: outgoing ? outg ->
		outDeficit[0]++;
		ch[outg] ! message, 0; 
		printf("MSC: Sent message from environment to %d\n", outg)
	od;
	printf("MSC: Environment waiting\n");
	(outDeficit[0] == 0);
	printf("MSC: Termination!!\n");
	assert(allTerminated)
}

proctype SendMessage( byte myID; chan outgoing ) {
	byte outg;
	(parent[myID] != -1);
	for (count, 1, M)
		/* Select outgoing node and replace */
		outgoing ? outg; outgoing ! outg;
		outDeficit[myID]++;
		ch[outg] ! message, myID; 
		printf("MSC: Sent message from %d to %d\n", myID, outg)
	rof (count);
	terminated[myID] = true;
}

proctype ReceiveMessage( byte myID ) {
	byte source;
	atomic {
end:	do
		::	ch[myID] ? message, source;
			printf("MSC: Received message at %d from %d\n", myID, source);
			if
			::	parent[myID] == -1 -> parent[myID] = source
			::	else
			fi;
			inDeficit[myID].e[source]++;
			inSum[myID]++
		od
	}
}

proctype SendSignal( byte myID ) {
	byte current; /* For search of positive inDeficit */
	atomic {
end:	do
		:: inSum[myID] > 1 ->
			if
			:: (inDeficit[myID].e[current] > 1) ||
			   ((current != parent[myID]) && (inDeficit[myID].e[current] == 1)) ->
					ch[current] ! signal, 0;
					printf("MSC: Sent signal from %d to %d\n", myID, current);
					inSum[myID]--; 
					inDeficit[myID].e[current]--
			:: else
			fi;
			current = (current + 1) % NPROCS;
		:: terminated[myID] && (parent[myID] != -1) && (inSum[myID] == 1) && (outDeficit[myID] == 0) ->
			ch[parent[myID]] ! signal, 0; 
			printf("MSC: Sent signal from %d to parent %d\n", myID, parent[myID]);
			inSum[myID] = 0;
			inDeficit[myID].e[parent[myID]] = 0;
			parent[myID] = -1; 
		od
	}
}

proctype ReceiveSignal( byte myID ) {
	atomic {
end:	do
		::	ch[myID] ? signal, _;
			printf("MSC: Received signal at %d\n", myID);
			outDeficit[myID]--
		od
	}
}

inline InitNode(ID, out) {
	run SendMessage(ID, out); 
	run ReceiveMessage(ID); 
	run SendSignal(ID); 
	run ReceiveSignal(ID); 
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
		run ReceiveSignal(0);
		InitNode(1, out1); 
		InitNode(2, out2); 
		InitNode(3, out3); 
    }
}

