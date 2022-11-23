/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Critical section problem with test-and-set
   Verify Safety
*/

#define NOSTARVE
#include "critical.h"

inline testset (lcl) {
        atomic {
                lcl = common;
                common = 1
        }
}

bit common = 0;

active proctype p() {
        bit localp;
        do
        :: testset(localp);
           do
           :: (localp == 0) -> break
           :: else -> testset(localp)
           od;
           critical_section('p');
           common = 0;
	od
}

active proctype q() {	
        bit localq;
        do
        :: testset(localq);
           do
           :: (localq == 0) -> break
           :: else -> testset(localq)
           od;
           critical_section('q');
           common = 0;
	od
}
