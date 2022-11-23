/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Bakery algorithm for two processes
   Verify Safety - the ticket numbers can overflow
   Verify with pan option -m500: no overflow at that depth
   Verify Acceptance with <>nostarve
*/

#define NOSTARVE
#include "critical.h"
byte    np = 0, nq = 0;

active proctype p() {
	do
    ::  np = nq + 1;
		((nq == 0) || (np <= nq));
	    critical_section('p');
    	np = 0
    od
}

active proctype q() {
	do
    ::  nq = np + 1;
		((np == 0) || (nq < np));
    	critical_section('q');
    	nq = 0
    od
}
