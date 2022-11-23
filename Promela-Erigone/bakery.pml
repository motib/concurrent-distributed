/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Bakery algorithm
   Verify Safety with ticket numbers limited to 10
   and arguments -s -ll1000 -ls500 -lt20000
*/

bool	choosing[3] = false;
byte	number[3] = 0;
byte  critical  = 0;

active [3] proctype p() {
	byte max, I;
	do
    ::
    choosing[_pid] = true;
		max = 0;
    I = 0;
    do
    :: I > 2 -> break
    :: else ->
			if 
			:: number[I] > max -> max = number[I] 
			:: else
			fi;
			I++
		od;
		if
		:: max == 10 -> goto stop
		:: else
		fi;
		number[_pid] = 1 + max;
		choosing[_pid] = false;
    I = 0;
    do
    :: I > 2 -> break
    :: else ->
			if 
			:: I != _pid ->
          (choosing[I] == false);
          (number[I] == 0) || 
          (number[_pid] < number[I]) ||
          ((number[_pid] == number[I]) && (_pid < I))
			:: else
			fi;
			I++
		od;
    printf("%d in CS\n", _pid);
    critical++;
    assert (critical == 1);
    critical--;
    number[_pid] = 0;
  od;
stop:
  choosing[_pid] = false
}
