/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Merge sort
   Run on initial data in process init
*/

#include "for.h"
#include "sem.h"

#define N  8
byte a[N], result[N];
byte s[2] = 0;

/* Insertion sort of each half of the array */
proctype Sort (byte sem; byte low; byte high) {
	byte max, temp;
	for (I, low, high-1)
		max = I;
		for (J, I+1, high)
			if :: a[J] < a[max] -> max = J :: else fi; 
		rof (J);
		temp = a[I]; a[I] = a[max]; a[max] = temp;
	rof (I);
	signal(s[sem])
}

inline Next(index) {
	result[r] = a[index];
	r++;
	index++;
}

proctype Merge() {
	wait(s[0]);
	wait(s[1]);
	byte first = 0, second = N / 2, r = 0;
	do
	:: (first >= N/2) && (second >= N) -> break
	:: (first >= N/2) && (second < N) -> Next(second)
	:: (first < N/2) && (second >= N) -> Next(first)
	:: (first < N/2) && (second < N) -> 
		if 
		:: a[first] < a[second] -> Next(first)
		:: else -> Next(second)
		fi
	od;
	for (K, 0, N-2)
		assert(result[K] < result[K+1]);
		printf("MSC: %d\n", result[K])
	rof (K);
	printf("MSC: %d\n", result[N-1])
}

init {
	atomic {
		a[0] = 5; a[1] = 1; a[2] = 10; a[3] = 7;
		a[4] = 4; a[5] = 3; a[6] = 12; a[7] = 8;
		run Sort(0, 0, 3);
		run Sort(1, 4, 7);
		run Merge();
	}
}

