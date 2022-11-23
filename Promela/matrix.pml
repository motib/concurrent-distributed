/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Matrix multiplication in array of processors
   If run in jSpin set Settings/Max steps >= 1000
*/

#include "for.h"
#define SIZE 3
#define SIZESQ 12

chan EWC[SIZESQ] = [0] of { byte }; // East<->West Channels
chan NSC[SIZESQ] = [0] of { byte }; // North<->South Channels

proctype Multiplier(byte Coeff; chan North; chan East; chan South; chan West) {
	byte Sum, X;
	for (i,0,SIZE-1)
		if :: North ? X -> East ? Sum;
		   :: East  ? Sum -> North ? X; 
		fi;
		South ! X;
		Sum = Sum + X*Coeff;
		West  ! Sum;
	rof (i)
}

proctype Zero(chan West) {
	for (i,0,SIZE-1)
		West ! 0;
	rof (i)
}

proctype Sink(chan North) {
	for (i,0,SIZE-1)
		North ? _;
	rof (i)
}

proctype Result(byte Row; chan East) {
	byte N;
	for (i,0,SIZE-1)
		East ? N;
		printf("MSC: Result is %d %d = %d\n", Row, i+1, N);
	rof (i)
}

proctype Source(chan South; byte V0; byte V1; byte V2) { 
	South ! V0;
	South ! V1;
	South ! V2;
}

init {
	atomic {
		for (i,0,SIZE-1)
			run Zero( EWC[i*(SIZE+1)+SIZE] );
			run Sink( NSC[i*(SIZE+1)+SIZE] );
			run Result(i+1, EWC[i*(SIZE+1)] );
		rof (i);
		run Source(NSC[0], 1, 0, 2);
		run Source(NSC[4], 0, 1, 2);
		run Source(NSC[8], 1, 0, 0);
		run Multiplier(1, NSC[0],  EWC[1],  NSC[1],  EWC[0]);
		run Multiplier(2, NSC[4],  EWC[2],  NSC[5],  EWC[1]);
		run Multiplier(3, NSC[8],  EWC[3],  NSC[9],  EWC[2]);
		run Multiplier(4, NSC[1],  EWC[5],  NSC[2],  EWC[4]);
		run Multiplier(5, NSC[5],  EWC[6],  NSC[6],  EWC[5]);
		run Multiplier(6, NSC[9],  EWC[7],  NSC[10], EWC[6]);
		run Multiplier(7, NSC[2],  EWC[9],  NSC[3],  EWC[8]);
		run Multiplier(8, NSC[6],  EWC[10], NSC[7],  EWC[9]);
		run Multiplier(9, NSC[10], EWC[11], NSC[11], EWC[10]);
	}
}

