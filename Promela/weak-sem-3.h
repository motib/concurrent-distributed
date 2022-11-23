/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Weak semaphore */
/* NPROCS - the number of processes - must be defined.   */
/* THIS VERSION is specialized for exactly THREE processes */

/* A semaphore is a count plus an array of blocked processes */
typedef Semaphore {
	byte count;
	bool blocked[NPROCS];
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
/* If there are blocked processes, remove one nondeterministically */
inline signal(S) {
   atomic {
     if
     :: S.blocked[0] -> S.blocked[0] = false
     :: S.blocked[1] -> S.blocked[1] = false
     :: S.blocked[2] -> S.blocked[2] = false
     :: else -> S.count++
     fi
   }
}
