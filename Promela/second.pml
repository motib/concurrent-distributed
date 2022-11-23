/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Second attempt 
   Verify Safety - assertion of mutual exclusion violated
*/

#include "critical.h"

bool inCSp = false, inCSq = false;

active proctype p() {
        do
        ::
           (inCSq == false);
           inCSp = true;
           critical_section('p');
           inCSp = false;
	od
}

active proctype q() {	
	do 
	:: 	
           (inCSp == false);
           inCSq = true;
           critical_section('q');
           inCSq = false;
	od
}
