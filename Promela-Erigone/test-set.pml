/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Critical section problem with test-and-set
   Verify Safety
*/
bit common = 0;
byte critical = 0;

active proctype p() {
  bit localp;
  do
  :: atomic { localp = common; common = 1 }
     do
     :: (localp == 0) -> break
     :: else -> atomic { localp = common; common = 1 }
     od;
     printf("p in CS\n");
     critical++;
     assert (critical == 1);
     critical--;
     common = 0;
	od
}

active proctype q() {	
  bit localq;
  do
  :: atomic { localq = common; common = 1 }
     do
     :: (localq == 0) -> break
     :: else -> atomic { localq = common; common = 1 }
     od;
     printf("q in CS\n");
     critical++;
     assert (critical == 1);
     critical--;
     common = 0;
	od
}
