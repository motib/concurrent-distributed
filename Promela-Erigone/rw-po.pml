/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Protected object for readers and writers
   Verify Safety
*/

bool lock = false;
byte Readers = 0 ;
bool Writing = false ;

active [3] proctype reader() {
  byte I = 1;
	do
	:: I > 2 -> break
	:: else ->
    /* StartRead */
    atomic {           /* enterPO */
      !lock && (!Writing);
      lock = true;
    }
    Readers++ ;
    assert(!Writing);
    lock = false;      /* leavePO */

    printf("process %d reading %d\n", _pid, I);

    /* EndRead */
    atomic {           /* enterPO */
      !lock && (true);
      lock = true;
    }
    Readers--;
    lock = false;      /* leavePO */
    I++
  od
}

active [2] proctype writer() {
  byte I = 1;
	do
	:: I > 2 -> break
	:: else ->
	  /* StartWrite */
    atomic {           /* enterPO */
      !lock && (((Readers == 0) && !Writing));
      lock = true;
    }
    Writing = true ;
    assert (Readers == 0);
    lock = false;      /* leavePO */

    printf("process %d writing %d\n", _pid, I);

    /* EndWrite */
    atomic {           /* enterPO */
      !lock && (true);
      lock = true;
    }
    Writing = false;
    lock = false;      /* leavePO */
    I++
  od
}

