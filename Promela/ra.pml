/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
    Ricart-Agrawala algorithm for distributed mutual exclusion
    See readme.txt for verification instructions
*/

#include "for.h"
#define NPROCS 3
#define PID
#include "critical.h"

/* Channel has extra capacity to enable out of order transmission */
mtype = { request, reply } ;
chan ch[NPROCS] = [NPROCS] of { mtype, byte, byte } ;

byte myNum[NPROCS];
byte highestNum[NPROCS];
bool requestCS[NPROCS];
chan deferred[NPROCS] = [NPROCS] of { byte };

proctype Main( byte myID ) {
    do ::
    atomic {
      requestCS[myID] = true ;
      myNum[myID] = highestNum[myID] + 1 ;
    }
    for (J,0,NPROCS-1)
      if
      :: J != myID ->
          ch[J] ! request, myID, myNum[myID];
      :: else
      fi
    rof (J);
    for (K,0,NPROCS-2)
        ch[myID] ?? reply, _ , _;
    rof (K);
    critical_section();
    requestCS[myID] = false;
    byte N;
    do
      :: empty(deferred[myID]) -> break;
      :: deferred[myID] ? N -> ch[N] ! reply, 0, 0
    od
    od
}

proctype Receive( byte myID ) {
    byte reqNum, source;
    do ::
        ch[myID] ?? request, source, reqNum;
        highestNum[myID] =
            ((reqNum > highestNum[myID]) ->
                reqNum : highestNum[myID]);
        atomic {
            if
            :: requestCS[myID] &&
                 ( (myNum[myID] < reqNum) ||
                 ( (myNum[myID] == reqNum) &&
                        (myID < source)
                 ) ) ->
                    deferred[myID] ! source
            :: else ->
                ch[source] ! reply, 0, 0
            fi
        }
    od
}

init {
    atomic {
        for(I,0,NPROCS-1)
            run Main(I) ;
            run Receive(I) ;
        rof(I)
    }
}

