/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Critical section problem with exchange
   Verify Safety
*/

#define NOSTARVE
#include "critical.h"

inline exchange (a, b) {
        bit temp;
        atomic {
                temp = a;
                a = b;
                b = temp;
        }
}

bit common = 1;

active proctype p() {
        bit localp = 0;
        do
        :: exchange(common, localp);
           do
           :: (localp == 1) -> break
           :: else -> exchange(common, localp)
           od;
           critical_section('p');
           exchange(common, localp);
	od
}

active proctype q() {	
        bit localq;
        do
        :: exchange(common, localq);
           do
           :: (localq == 1) -> break
           :: else -> exchange(common, localq)
           od;
           critical_section('q');
           exchange(common, localq);
	od
}
