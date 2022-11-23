/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Matrix multiplication in Linda
*/

#include "for.h"
#define SIZE 3		/* SIZE of matrix */
#define WORKERS 2	/* Number of WORKERS */

/* Space is stored in a channel: one byte of id and */
/* four short's of data */
chan space = [25] of { byte, short, short, short, short };

active[WORKERS] proctype Worker() {
	short row, col;
	short r1, r2, r3, c1, c2, c3;
	short ip;
	do
	:: 	/* Remove task note from space */
		space ?? 't',  row, col, _, _;
		/* Read row and column vectors from space */
		space ?? <'a', eval(row), r1, r2, r3>;
		space ?? <'b', eval(col), c1, c2, c3>;
		/* Compute inner product */
		ip = r1*c1 + r2*c2 + r3*c3;
		/* Post result note in space */
		space!'r', row, col, ip, 0;
	od;
}

active proctype Master() {
	/* Post row and column vectors in space */
	space!'a', 1, 1, 2, 3;
	space!'a', 2, 4, 5, 6;
	space!'a', 3, 7, 8, 9;
	space!'b', 1, 1, 0, 1;
	space!'b', 2, 0, 1, 0;
	space!'b', 3, 2, 2, 0;
	/* Post task notes in space */
	for(I,1,SIZE)
		for(J,1,SIZE)
			space ! 't', I, J, 0, 0;
		rof(J)
	rof(I);
	/* Wait to remove all result notes from space */
	short value;
	for(I,1,SIZE)
		for(J,1,SIZE)
			space ?? 'r', eval(I), eval(J), value, _;
		    printf("MSC: %d %d = %d\n", I, J, value);
		rof(J);
	rof(I);
}
