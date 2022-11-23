/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Bakery algorithm for two processes
   Verify Safety - the ticket numbers overflow and cause assert failure
   Limit the numbers to <255 and verify safety with -ls10 -lt40
*/

byte  np = 0, nq = 0;
byte  critical  = 0;

active proctype p() {
	do
  :: nq > 254 -> break
  :: else ->
      np = nq + 1;
      ((nq == 0) || (np <= nq));
      printf("p in CS\n");
      critical++;
      assert (critical == 1);
      critical--;
      np = 0
  od
}

active proctype q() {
	do
  :: np > 254 -> break
  :: else ->
      nq = np + 1;
      ((np == 0) || (nq < np));
      printf("q in CS\n");
      critical++;
      assert (critical == 1);
      critical--;
      nq = 0
  od
}
