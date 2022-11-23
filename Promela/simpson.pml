/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/*
	Simpson's four-slot asynchronous communications mechanism
	Writes a two-byte data type
    Verify Safety checks that separate reads do not give inconsistent values
*/

#include "for.h"
#define K 8  /* Number of reads and writes */

typedef DATA {
	byte d1, d2;
};

typedef SLOT {
	DATA sl[2];
};

SLOT data[2];
bit currentSlot[2];
bit lastWrittenPair, lastReadPair;

inline writeSlots() {
	printf("MSC: slots = (%d%d, %d%d), (%d%d, %d%d)\n",
		data[0].sl[0].d1, data[0].sl[0].d2,
		data[0].sl[1].d1, data[0].sl[1].d2,
		data[1].sl[0].d1, data[1].sl[0].d2,
		data[1].sl[1].d2, data[1].sl[1].d2);
}

active proctype Writer() {
	bit writePair, writeSlot;
	for (I, 0, K)
		writePair = 1 - lastReadPair;
		writeSlot = 1 - currentSlot[writePair];
		data[writePair].sl[writeSlot].d1 = I;
		data[writePair].sl[writeSlot].d2 = I;
		currentSlot[writePair] = writeSlot;
		printf("MSC: wrote %d%d\n", I, I);
		writeSlots();
		lastWrittenPair = writePair
	rof (I)
}

active proctype Reader() {
	bit readPair, readSlot;
	byte item1, item2;
	for (I, 0, K)
		readPair = lastWrittenPair;
		lastReadPair = readPair;
		readSlot = currentSlot[readPair];
		item1 = data[readPair].sl[readSlot].d1;
		item2 = data[readPair].sl[readSlot].d2;
		assert (item1 == item2);
		printf("MSC: read %d%d\n", item1, item2);
		writeSlots();
	rof (I)
}
