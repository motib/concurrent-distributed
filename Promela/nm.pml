/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
    Neilsen-Mizuno token algorithm for distributed mutual exclusion
    See readme.txt for verification instructions
    Make sure at most one token at all nodes: []oneToken
*/

#include "for.h"
#define NPROCS 5
#include "critical.h"

mtype = { request, token } ;

chan ch[NPROCS] = [NPROCS] of { mtype, byte, byte } ;

byte parent[NPROCS];
byte deferred[NPROCS];
bool inCS[NPROCS];
bool haveToken[NPROCS];

#define oneToken ((haveToken[0]+haveToken[1]+haveToken[2]) <= 1)

proctype Main( byte myID ) {
end:do
    :: 
    atomic {
        if
        :: ! haveToken[myID] ->
            ch[parent[myID]] ! request, myID, myID;
            printf("MSC: %d sent request to parent %d\n", myID, parent[myID]);
            parent[myID] = 0;
            ch[myID] ?? token, _, _;
            printf("MSC: %d received token\n", myID );
            haveToken[myID] = true;
        ::  else
        fi;
        inCS[myID] = true
    }
        critical_section(myID + '0');
    atomic {
        inCS[myID] = false;
        if
        ::  deferred[myID] != 0 ->
            ch[deferred[myID]] ! token, 0, 0;
            deferred[myID] = 0;
            haveToken[myID] = false
        ::  else
        fi
    }
    od
}

proctype Receive( byte myID ) {
    byte source, originator;
end:do 
    ::
    atomic {
        ch[myID] ?? request, source, originator;
        printf("MSC: %d received request from %d originated by %d\n", myID, source, originator);
        if 
        ::  parent[myID] == 0 && haveToken[myID] ->
            if
            ::  inCS[myID] ->
                deferred[myID] = originator;
            ::  else ->
                ch[originator] ! token, 0, 0;
                haveToken[myID] = false
            fi
        :: else ->
            ch[parent[myID]] ! request, myID, originator
        fi;
        parent[myID] = source;
    }
    od
}

init {
    atomic {
        haveToken[2] = true;
        parent[2] = 0;
        parent[1] = 2;
        parent[0] = 1;
        parent[3] = 2;
        parent[4] = 3;
        for(I,0,NPROCS-1)
            run Main(I);
            run Receive(I);
        rof(I)
    }
}

