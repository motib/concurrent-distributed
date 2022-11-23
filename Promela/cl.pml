/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Chandy-Lamport algorithm for distributed snapshots
   Run spin -T cl.pml to see output
*/

#include "for.h"
#include "sem.h"
/*
#define DEBUG
*/

#define NPROCS 4
#define M 4             /* Number of messages */

/* (message/marker, source, number) */
mtype = { message, marker } ;
chan ch[NPROCS] = [M] of { mtype, byte, byte } ;

typedef edges {        /* Simulate two-dimensional array */
	byte e[NPROCS];
};

edges	lastSent[NPROCS];
edges	lastReceived[NPROCS];
edges	stateAtRecord[NPROCS];
edges	messageAtRecord[NPROCS];
edges	messageAtMarker[NPROCS];

bool    recorded[NPROCS];      /* Flag to avoid comparing arrays */
byte    markerCount[NPROCS];   /* DisplayState executed after markers received*/
byte	sem[NPROCS];           /* Mutual exclusion of send and receive */
byte    total;                 /* For simulations, decide when to send markers */

proctype Env(chan outgoing) {
	byte outg;
    total >= 6;         /* Wait before sending initial markers */
    do
    :: empty(outgoing) -> break;
    :: nempty(outgoing) ->
        outgoing ? outg;
		ch[outg] ! marker, 0, 0; 
#ifdef DEBUG
        printf("MSC: Sent marker from environment to %d\n", outg)
#endif
    od
}

proctype SendMessage( byte myID; chan outgoing ) {
    byte num = len(outgoing);
	byte outg;
	for (count, 1, M)
        for (I, 0, num-1)
			wait(sem[myID]);
            /* Get outgoing channel and replace */
			outgoing ? outg; outgoing ! outg;
            ch[outg] ! message, myID, count;
            lastSent[myID].e[outg] = count;
#ifdef DEBUG
            printf("MSC: Sent message %d from %d to %d\n", count, myID, outg);
#endif
			signal(sem[myID]);
			total++
        rof(I)
	rof (count);
}

proctype ReceiveMessage( byte myID ) {
	byte source, n;
end:	do
		::	ch[myID] ? [message, _, _] ->  /* Poll, then receive message under */
			wait(sem[myID]);               /* mutual exclusion */
			ch[myID] ? message, source, n;
            lastReceived[myID].e[source] = n;
#ifdef DEBUG
            printf("MSC: Received message %d at %d from %d\n", n, myID, source);
#endif
			signal(sem[myID]);
        od
}

proctype ReceiveMarker( byte myID ; chan outgoing ) {
    byte num = len(outgoing);
	byte outg;
    byte source;
end:do
    ::	ch[myID] ? [marker, _] ->  /* Poll, then receive marker under */
        wait(sem[myID]);       /* mutual exclusion */
        ch[myID] ? marker, source;
#ifdef DEBUG
        printf("MSC: Received marker at %d from %d\n", myID, source);
#endif
        if
        ::	messageAtMarker[myID].e[source] == 255 ->
            messageAtMarker[myID].e[source] = lastReceived[myID].e[source];
        :: else
        fi;
        if
        ::  !recorded[myID] ->
            for (I, 0, NPROCS-1)
                stateAtRecord[myID].e[I] = lastSent[myID].e[I];
                messageAtRecord[myID].e[I] = lastReceived[myID].e[I];
            rof (I);
            for (J, 0, num-1)
                outgoing ? outg; outgoing ! outg;
                ch[outg] ! marker, myID, 0;
#ifdef DEBUG
                printf("MSC: Sent marker from %d to %d\n", myID, outg)
#endif
            rof (J);
            recorded[myID] = true;
        :: else
        fi;
        signal(sem[myID]);
        markerCount[myID]++;
    od
}

proctype DisplayState( byte myID ; chan inComing ) {
    byte in;
    /* Execute only when all markers received */
    (markerCount[myID] == len(inComing));
    d_step {
        printf("MSC: Messages sent from %d", myID);
        for (I, 0, NPROCS-1)
            if 
            :: stateAtRecord[myID].e[I] != 255 ->
                printf(" to %d: %d, ", I, stateAtRecord[myID].e[I])
            :: else
            fi
        rof (I);
        printf("\n");
        printf("MSC: Messages received at %d", myID);
        for (I, 0, NPROCS-1)
            if 
            :: messageAtRecord[myID].e[I] != 255 ->
                printf(" from %d: %d, ", I, messageAtRecord[myID].e[I])
            :: else
            fi
        rof (I);
        printf("\n");
    }
    atomic {
        printf("MSC: Channels at %d", myID);
        do
        ::  empty(inComing) -> break;
        ::  nempty(inComing) ->
            inComing ? in;
            if 
            ::	messageAtMarker[myID].e[in] != 255 &&
                messageAtRecord[myID].e[in] != messageAtMarker[myID].e[in] ->
                printf(" in %d: %d to %d, ", in, 
                    messageAtRecord[myID].e[in]+1, messageAtMarker[myID].e[in])
            :: else
            fi
        od;
        printf("\n")
    }
}

inline InitNode(ID, out, in) {
	sem[ID] = 1;
	run SendMessage(ID, out); 
	run ReceiveMessage(ID); 
	run ReceiveMarker(ID, out); 
    run DisplayState(ID, in);
}

init {
	atomic {
		/* Initialize according to graph in book. */
        /* Outgoing and incoming edges are stored in channels of bytes. */

		chan outEnv = [2] of { byte };
		outEnv ! 1; outEnv ! 2;

		chan out1 = [2] of { byte };
		out1 ! 2; out1 ! 3;
		chan out2 = [1] of { byte };
		out2 ! 1;
		chan out3 = [1] of { byte };
		out3 ! 2;

		chan in1 = [2] of { byte };
		in1 ! 0; in1 ! 3;
		chan in2 = [3] of { byte };
		in2 ! 0; in2 ! 1; in2 ! 3;
		chan in3 = [1] of { byte };
		in3 ! 1;

        /* Initialize to 255 instead of -1 so bytes can be used */
		for (I, 0, NPROCS-1)
			for (J, 0, NPROCS-1)
                lastSent[I].e[J] = 255;
                lastReceived[I].e[J] = 255;
				messageAtMarker[I].e[J] = 255;
				messageAtRecord[I].e[J] = 255;
				stateAtRecord[I].e[J] = 255;
			rof (J)
		rof (I);
		
		run Env(outEnv);
		InitNode(1, out1, in1); 
		InitNode(2, out2, in2); 
		InitNode(3, out3, in3); 
    }
}

