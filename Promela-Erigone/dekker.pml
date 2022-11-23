/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Dekker's algorithm 
  Verify Safety
  Verify Acceptance with <>nostarve
*/

bool    wantp = false, wantq = false;
byte    turn = 1;
byte critical = 0;
bool pcs = false;

active proctype p() {
  do
  ::  wantp = true;
      do
      :: !wantq -> break;
      :: else ->
          if
          :: (turn == 1)
          :: (turn == 2) ->
              wantp = false;
              (turn == 1);
              wantp = true
          fi
      od;
      printf("p in CS\n");
      critical++;
      assert (critical == 1);
      pcs = true;
      pcs = false;
      critical--;
      turn = 2;
      wantp = false
  od
}

active proctype q() {
  do
  ::  wantq = true;
      do
      :: !wantp -> break;
      :: else ->
          if
          :: (turn == 2)
          :: (turn == 1) ->
              wantq = false;
              (turn == 2);
              wantq = true
          fi
      od;
      printf("q in CS\n");
      critical++;
      assert (critical == 1);
      critical--;
      turn = 1;
      wantq = false
  od
}
