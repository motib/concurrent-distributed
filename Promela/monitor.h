/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Definitions for monitor */
bool lock = false;

typedef Condition {
   bool gate;
   byte waiting;
}

inline enterMon() {
   atomic {
      !lock;
      lock = true;
   }
}

inline leaveMon() {
   lock = false;
}

inline waitC(C) {
   atomic {
      C.waiting++;
      lock = false;    /* Exit monitor */
      C.gate;          /* Wait for gate */
      lock = true;     /* IRR */
      C.gate = false;  /* Reset gate */
      C.waiting--;
   }
}

inline signalC(C) {
   atomic {
      if 
         /* Signal only if waiting */
      :: (C.waiting > 0) ->
        C.gate = true;
        !lock;       /* IRR - wait for released lock */
        lock = true; /* Take lock again */
      :: else
      fi;
   }
}

#define emptyC(C) (C.waiting == 0)
