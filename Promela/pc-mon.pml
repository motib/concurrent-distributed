/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Monitor solution for producer-consumer
   Verify Safety
*/

#include "for.h"
#include "monitor.h"

#define N 4             /* Slots in buffer */
byte B[N] = 0 ;         /* The buffer */
byte InPtr = 0, OutPtr = 0, Count = 0 ;

Condition notFull, notEmpty;

/* Make sure append and take are executed in order */
byte lastAppend = 0, lastTake = 0;

inline Append (I) {
   enterMon();
   atomic {
      if :: (Count == N) -> waitC(notFull) :: else fi;
      assert (Count < N);
   }
   B[InPtr] = I;
   lastAppend = I;
   assert (lastTake < lastAppend);
   InPtr = ( InPtr + 1 ) % N;
   Count++;
   signalC(notEmpty);
   leaveMon()
}

inline Take( I ) {
   enterMon();
   atomic {
      if :: (Count == 0) -> waitC(notEmpty) :: else fi;
      assert(Count > 0);
   }
   I = B[OutPtr];
   lastTake = I;
   assert (lastTake <= lastAppend);
   OutPtr = ( OutPtr + 1 ) % N;
   Count--;
   signalC(notFull);
   leaveMon()
}

#define NUM 10  /* Number of appends and takes */

active proctype producer() {
   for(I,1,NUM)
      printf("MSC: Appending %d\n", I);
      Append(I)
   rof(I)
}

active proctype consumer() {
   byte J;
   for(I,1,NUM)
      Take(J)
      printf("MSC: Taken %d\n", J);
   rof(I)
}
