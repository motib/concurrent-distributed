/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Macros for for-loop */
#define for(I,low,high) byte I; I = low ; do :: ( I > high ) -> break :: else ->
#define rof(I) ; I++ od

