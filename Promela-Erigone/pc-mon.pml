/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Monitor solution for producer-consumer
   Verify Safety
*/

byte B[4] = 0 ;         /* The buffer */
byte InPtr = 0, OutPtr = 0, Count = 0 ;
bool lock = false;
bool notFullgate;
byte notFullwaiting;
bool notEmptygate;
byte notEmptywaiting;

/* Make sure append and take are executed in order */
byte lastAppend = 0, lastTake = 0;

active proctype producer() {
  byte I = 1;
  do
  :: I > 10 -> break
  :: else ->
     printf("Appending %d\n", I);
      atomic {
        !lock;
        lock = true;
      }
     atomic {
        if
        :: (Count == 4) ->
             atomic {
                notFullwaiting++;
                lock = false;    /* Exit monitor */
                notFullgate;          /* Wait for gate */
                lock = true;     /* IRR */
                notFullgate = false;  /* Reset gate */
                notFullwaiting--;
             }
        :: else
        fi;
        assert (Count < 4);
     }
     B[InPtr] = I;
     lastAppend = I;
     assert (lastTake < lastAppend);
     InPtr = ( InPtr + 1 ) % 4;
     Count++;
     atomic {
       if 
           /* Signal only if waiting */
        :: (notEmptywaiting > 0) ->
           notEmptygate = true;
           !lock;       /* IRR - wait for released lock */
           lock = true; /* Take lock again */
        :: else
        fi;
     }
     lock = false;
     I++
   od;
}

active proctype consumer() {
   byte J;
   byte I = 1;
   do
   :: I > 10 -> break
   :: else ->
      atomic {
        !lock;
        lock = true;
      }
     atomic {
        if
        :: (Count == 0) -> 
             atomic {
                notEmptywaiting++;
                lock = false;    /* Exit monitor */
                notEmptygate;          /* Wait for gate */
                lock = true;     /* IRR */
                notEmptygate = false;  /* Reset gate */
                notEmptywaiting--;
             }
        :: else
        fi;
        assert(Count > 0);
     }
     I = B[OutPtr];
     lastTake = I;
     assert (lastTake <= lastAppend);
     OutPtr = ( OutPtr + 1 ) % 4;
     Count--;
     atomic {
       if 
           /* Signal only if waiting */
        :: (notFullwaiting > 0) ->
           notFullgate = true;
           !lock;       /* IRR - wait for released lock */
           lock = true; /* Take lock again */
        :: else
        fi;
     }
     lock = false;
     printf("Taken %d\n", J);
     I++
   od;
}
