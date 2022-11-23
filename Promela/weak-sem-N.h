/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Weak semaphore */
/* NPROCS - the number of processes - must be defined.   */

/* A semaphore is a count plus an array of blocked processes */
typedef Semaphore {
	byte count;
	bool blocked[NPROCS];
    byte i, choice;
};

/* Initialize semaphore to n */
inline initSem(S, n) {
	S.count = n
}

/* Wait operation: If count is zero, set blocked and wait for unblocked */
inline wait(S) {
   atomic {
     if
     :: S.count >= 1 -> S.count--
     :: else -> S.blocked[_pid-1] = true; !S.blocked[_pid-1]
     fi
   }
}

/* Signal operation: */
/* If there are blocked processes, remove each one and nondeterministically */
inline signal(S) {
   atomic {
     S.i = 0;
     S.choice = 255;
     do
     :: (S.i == NPROCS) -> break
     :: (S.i < NPROCS) && !S.blocked[S.i] -> S.i++
     :: else -> 
         if
         :: (S.choice == 255) -> S.choice = S.i
         :: (S.choice != 255) -> S.choice = S.i
         :: (S.choice != 255) ->
         fi;
         S.i++
     od;
     if
     :: S.choice == 255 -> S.count++
     :: else -> S.blocked[S.choice] = false
     fi
   }
}
