/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Concurrent increment of a variable in two processes.
   Verify Safety gives a scenario in which the final value is two!
*/

#include "for.h"
#define TIMES 10
byte	n = 0;

proctype P() {
	byte temp;
	for (i,1,TIMES)
		temp = n;
		n = temp + 1;
	rof (i);
}

init {
	atomic { run P(); run P(); }
	(_nr_pr == 1);	
	printf("MSC: The value is %d\n", n);
	assert (n > 2);
}
