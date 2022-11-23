/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Semaphore solution for producer-consumer problem
   Verify Safety
*/

byte B[4] = 0 ;         /* The buffer */
byte InPtr = 0, OutPtr = 0, Count = 0 ;

byte notFull = 4, notEmpty = 0;

/* Make sure append and take are executed in order */
byte lastAppend = 0, lastTake = 0;

active proctype producer() {
   byte I = 1;
   do
   :: I > 10 -> break
   :: else
      printf("Appending %d\n", I);
      atomic {notFull > 0 ; notFull-- }
      assert (Count < 4);
      B[InPtr] = I;
      lastAppend = I;
      assert (lastTake < lastAppend);
      InPtr = ( InPtr + 1 ) % 4;
      Count++;
      notEmpty++;
      I++
   od
}

active proctype consumer() {
   byte J;
   byte I = 1;
   do
   :: I > 10 -> break
   :: else
       atomic {notEmpty > 0 ; notEmpty-- }
       assert(Count > 0);
       J = B[OutPtr];
       lastTake = J;
       assert (lastTake <= lastAppend);
       OutPtr = ( OutPtr + 1 ) % 4;
       Count--;
       notFull++;
       printf("Taken %d\n", J);
       I++
   od
}
