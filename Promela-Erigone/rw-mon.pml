/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Monitor for readers and writers
*/

bool lock = false;
byte Readers = 0 ;
bool Writing = false ;
bool OKtoReadgate;
byte OKtoReadwaiting;
bool OKtoWritegate;
byte OKtoWritewaiting;

active [3] proctype reader() {
  byte I = 1;
	do
	:: I > 2 -> break
	:: else ->

    /* StartRead */
   atomic {
      !lock;
      lock = true;
   }
    if 
    :: (Writing || !(OKtoWritewaiting == 0)) ->
         atomic {  /* waitC */
            OKtoReadwaiting++;
            lock = false;          /* Exit monitor */
            OKtoReadgate;          /* Wait for gate */
            lock = true;           /* IRR */
            OKtoReadgate = false;  /* Reset gate */
            OKtoReadwaiting--;
         }
    :: else 
    fi;
    Readers++ ;
    assert (!Writing);
    atomic {  /* signalC */
       if 
       :: (OKtoReadwaiting > 0) -> /* Signal only if waiting */
           OKtoReadgate = true;
           !lock;                  /* IRR - wait for released lock */
           lock = true;            /* Take lock again */
       :: else
       fi;
    }
    lock = false;

    printf("process %d reading %d\n", _pid, I);
            
    /* EndRead */
   atomic {
      !lock;
      lock = true;
   }
    Readers--;
    if 
    :: (Readers == 0) ->
        atomic {  /* signalC */
           if 
           :: (OKtoWritewaiting > 0) -> /* Signal only if waiting */
               OKtoWritegate = true;
               !lock;                  /* IRR - wait for released lock */
               lock = true;            /* Take lock again */
           :: else
           fi;
        }
    :: else -> 
    fi;
   lock = false;

    I++
  od
}

active [2] proctype writer() {
  byte I = 1;
	do
	:: I > 2 -> break
	:: else ->

	  /* StartWrite */
   atomic {
      !lock;
      lock = true;
   }
    if 
    :: ((Readers != 0) || Writing) ->
         atomic {  /* waitC */
            OKtoWritewaiting++;
            lock = false;          /* Exit monitor */
            OKtoWritegate;          /* Wait for gate */
            lock = true;           /* IRR */
            OKtoWritegate = false;  /* Reset gate */
            OKtoWritewaiting--;
         }
    :: else 
    fi;
    Writing = true ;
    assert (Readers == 0);
   lock = false;

   printf("process %d writing %d\n", _pid, I);

    /* EndWrite */
   atomic {
      !lock;
      lock = true;
   }
    Writing = false;
    if 
    :: (OKtoReadwaiting == 0) ->
        atomic {  /* signalC */
           if 
           :: (OKtoWritewaiting > 0) -> /* Signal only if waiting */
               OKtoWritegate = true;
               !lock;                  /* IRR - wait for released lock */
               lock = true;            /* Take lock again */
           :: else
           fi;
        }
    :: else ->
        atomic {  /* signalC */
           if 
           :: (OKtoReadwaiting > 0) -> /* Signal only if waiting */
               OKtoReadgate = true;
               !lock;                  /* IRR - wait for released lock */
               lock = true;            /* Take lock again */
           :: else
           fi;
        }
    fi;
    lock = false;

    I++
  od
}
