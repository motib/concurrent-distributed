/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Dekker's algorithm 
  Verify Safety
  Verify Acceptance with <>nostarve
*/

#define NOSTARVE
#include "critical.h"

bool    wantp = false, wantq = false;
byte    turn = 1;

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
        critical_section('p');
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
        critical_section('q');
        turn = 1;
        wantq = false
    od
}
