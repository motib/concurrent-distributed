/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Concurrent increment of a variable in two processes.
   Verify Safety gives a scenario in which the final value is two!
*/

byte	n = 0;

proctype P() {
	byte temp;
	byte i = 1;
	do
	:: i > 10 -> break
	:: else -> 
		temp = n;
		n = temp + 1;
		i++
  od
}

init {
	atomic { run P(); run P(); }
	(_nr_pr == 1);	
	printf("The value is %d\n", n);
	assert (n > 2);
}
