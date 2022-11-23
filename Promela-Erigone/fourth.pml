/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
  Fourth attempt 
  Verify Safety
  Verify Acceptance with <>nostarve fails because of starvation
*/

bool inCSp = false, inCSq = false;
byte critical = 0;
bool pcs = false;

active proctype p() {
  do
  ::
     inCSp = true;
     do
     :: (inCSq == true) ->
         inCSp = false;
         inCSp = true;
     :: else -> break
     od;
     printf("p in CS\n");
     critical++;
     assert (critical == 1);
     pcs = true;
     pcs = false;
     critical--;
     inCSp = false;
	od
}

active proctype q() {	
	do 
	:: 	
     inCSq = true;
     do
     :: (inCSp == true) ->
         inCSq = false;
         inCSq = true;
     :: else -> break
     od;
     printf("q in CS\n");
     critical++;
     assert (critical == 1);
     critical--;
     inCSq = false;
	od
}
