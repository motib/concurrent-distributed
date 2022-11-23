/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Critical section problem with exchange
   Verify Safety
*/

bit common = 1;
byte critical = 0;

active proctype p() {
  bit localp = 0;
  bit temp;
  do
  :: atomic { temp = common; common = localp; localp = temp; }
     do
     :: (localp == 1) -> break
     :: else -> atomic { temp = common; common = localp; localp = temp; }
     od;
     printf("p in CS\n");
     critical++;
     assert (critical == 1);
     critical--;
     atomic { temp = common; common = localp; localp = temp; }
	od
}

active proctype q() {	
  bit localq;
  bit temp;
  do
  :: atomic { temp = common; common = localq; localq = temp; }
     do
     :: (localq == 1) -> break
     :: else -> atomic { temp = common; common = localq; localq = temp; }
     od;
     printf("q in CS\n");
     critical++;
     assert (critical == 1);
     critical--;
     atomic { temp = common; common = localq; localq = temp; }
	od
}
