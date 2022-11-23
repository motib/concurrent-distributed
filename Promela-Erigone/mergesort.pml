/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Merge sort
   Run on initial data in process init
*/

byte a[8], result[8];
byte sem = 0, start = false;

/* Insertion sort of each half of the array */
active proctype Sort1 () {
	byte max, temp, I, J;
	start == true;
	I = 0;
	do :: I > 3-1 -> break
	   :: else ->
		max = I;
		J = I+1;
		do :: J > 3 -> break
		   :: else ->
			if :: a[J] < a[max] -> max = J :: else fi; 
		  J++
		od;
		temp = a[I]; a[I] = a[max]; a[max] = temp;
		I++
	od;
	sem++
}

/* Insertion sort of each half of the array */
active proctype Sort2 () {
	byte max, temp, I, J;
	start == true;
	I = 4;
	do :: I > 7-1 -> break
	   :: else ->
		max = I;
		J = I+1;
		do :: J > 7 -> break
		   :: else ->
			if :: a[J] < a[max] -> max = J :: else fi; 
		  J++
		od;
		temp = a[I]; a[I] = a[max]; a[max] = temp;
		I++
	od;
	sem++
}

active proctype Merge() {
	byte first, second, r;
	sem == 2;
	first = 0;
	second = 8 / 2;
	r = 0;
	do
	:: (first >= 8/2) && (second >= 8) -> break
	:: (first >= 8/2) && (second < 8) -> 
		result[r] = a[second]; 	r++; 	second++;
	:: (first < 8/2) && (second >= 8) -> 
		result[r] = a[first]; 	r++; 	first++;
	:: (first < 8/2) && (second < 8) -> 
		if 
		:: a[first] < a[second] -> 
		result[r] = a[first]; 	r++; 	first++;
		:: else ->
		 result[r] = a[second]; 	r++; 	second++;
		fi
	od;
	r = 0;
	do 
	:: r >= 8-2 -> break
	:: else ->
	  assert(result[r] < result[r+1]);
		printf(" %d\n", result[r])
	  r++
	od;
	printf(" %d\n", result[8-1])
}

init {
		a[0] = 5; a[1] = 1; a[2] = 10; a[3] = 7;
		a[4] = 4; a[5] = 3; a[6] = 12; a[7] = 8;
		start = true;
}

