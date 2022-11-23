/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
  Fourth attempt 
  Verify Safety
  Verify Acceptance with <>nostarve fails because of starvation
*/

#define NOSTARVE
#include "critical.h"

bool inCSp = false, inCSq = false;

active proctype p() {
        do
        ::
           inCSp = true;
           do
           :: (inCSq == true) ->
                   inCSp = false;
                   inCSp = true;
           :: else
           od;
           critical_section('p');
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
           :: else
           od;
           critical_section('q');
           inCSq = false;
	od
}
