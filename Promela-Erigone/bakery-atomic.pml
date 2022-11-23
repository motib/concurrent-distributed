/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Bakery algorithm with atomic choice of ticket numbers
   Verify Safety with ticket numbers limited to 20
   and arguments -s -ll400 -ls200 -lt6000
*/
byte	number[3] = 0;
byte  critical  = 0;

active [3] proctype p() {
	byte max, I;
	do
    ::
    d_step {  
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
      if :: max > 20 -> goto stop :: else fi;
      number[_pid] = 1 + max;
    }
    I = 0;
    do
    :: I > 2 -> break
    :: else ->
        if 
        :: I != _pid ->
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
stop: skip
}
