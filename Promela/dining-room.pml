/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Dining philosophers with channels
   Limit to four philosophers in the room
   Verify Safety
*/

#include "sem.h"
byte room = 4;
chan forks[5] = [0] of { bool };
byte numEating = 0;

proctype Phil(byte n; chan left; chan right ) {
	do ::
		wait(room);
		left ? _;
		right ? _;
		numEating++;
		printf("MSC: %d eating, total = %d\n", n, numEating);
		assert (numEating <= 2);
		numEating--;
		right ! true;
		left ! true;
		signal(room);
	od
}

proctype Fork(chan ch) {
	do ::
		ch ! true;
		ch ? _;
	od
}

init {
	atomic {
	  run Fork(forks[0]);
	  run Fork(forks[1]);
	  run Fork(forks[2]);
	  run Fork(forks[3]);
	  run Fork(forks[4]);
	  run Phil(0, forks[0], forks[1]);
	  run Phil(1, forks[1], forks[2]);
	  run Phil(2, forks[2], forks[3]);
	  run Phil(3, forks[3], forks[4]);
 	  run Phil(4, forks[4], forks[0]);
	}
}
