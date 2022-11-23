/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
    Ricart-Agrawala token algorithm for distributed mutual exclusion
    See readme.txt for verification instructions
*/

#include "for.h"
#define NPROCS 3
#include "critical.h"

/* Make sure at most one token at all nodes: []oneToken */
#define oneToken ((haveToken[0]+haveToken[1]+haveToken[2]) <= 1)

mtype = { request, token } ;

typedef vector {
    byte p[NPROCS]
};

chan ch[NPROCS] = [1] of { mtype, byte, byte, vector } ;

byte myNum[NPROCS];
vector requested[NPROCS];
vector granted[NPROCS];
bool inCS[NPROCS];
bool haveToken[NPROCS];

byte current[NPROCS];   /* So that token is not always sent to same node */
vector dummy;

inline Display() {
    d_step {
        printf(". At %d: Requested = %d %d %d, token = %d %d %d\n", myID, 
                requested[myID].p[0],requested[myID].p[1],requested[myID].p[2], 
                granted[myID].p[0],granted[myID].p[1],granted[myID].p[2]); 
    }
}

inline SendToken() {
    byte index;
    for (N, 0, NPROCS-1)
        index = (current[myID] + N) % NPROCS;
        if
        :: requested[myID].p[index] > granted[myID].p[index] ->
            ch[index] ! token, 0, 0, granted[myID];
            printf("MSC: %d sent token to %d", myID, index);
            Display();
            haveToken[myID] = false;
            break
        :: else
        fi;
    rof (N);
    current[myID] = index;
}

proctype Main( byte myID ) {
end:do
    :: 
    atomic {
        if
        :: ! haveToken[myID] ->
            myNum[myID] = myNum[myID] + 1 ;
            for (J,0,NPROCS-1)
                if
                :: J != myID ->
                    ch[J] ! request, myID, myNum[myID], dummy;
                    printf("MSC: %d sending request %d to %d\n", myID, myNum[myID], J);
                :: else
                fi
            rof (J);
            ch[myID] ? token, _, _, granted[myID];
            printf("MSC: %d received token\n", myID );
            haveToken[myID] = true;
        ::  else
        fi;
        inCS[myID] = true
    }
        critical_section(myID + '0');
    atomic {
        granted[myID].p[myID] = myNum;
        inCS[myID] = false;
        SendToken()
    }
    od
}

proctype Receive( byte myID ) {
    byte reqNum, source;
end:do 
    ::
    atomic {
        ch[myID] ? request, source, reqNum, dummy;
        if :: reqNum > requested[myID].p[source] -> 
            requested[myID].p[source] = reqNum
        :: else
        fi;
        printf("MSC: %d received request %d from %d", myID, reqNum, source);
        Display();
        if
        :: haveToken[myID] && !inCS[myID] -> SendToken()
        :: else
        fi
    }
    od
}

init {
    atomic {
        haveToken[0] = true;
        for(I,0,NPROCS-1)
            run Main(I);
            run Receive(I);
        rof(I)
    }
}

