/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Third attempt
   Verify Safety - invalid end state because of deadlock
*/

#include "critical.h"

bool inCSp = false, inCSq = false;

active proctype p() {
    do
    ::
           inCSp = true;
           (inCSq == false);
           critical_section('p');
           inCSp = false;
	od
}

active proctype q() {	
	do 
	:: 	
           inCSq = true;
           (inCSp == false);
           critical_section('q');
           inCSq = false;
	od
}
