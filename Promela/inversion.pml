/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
	Priority inversion
	Processes: 
		data - high priority
		comm - medium priority
		telem - low prioirty

    Verify Safety with inherit(p) defined as false shows
        that telem in CS and comm in long is possible
    Verify Safety with inherit(p) defined as (p == CS) shows
        that telem in CS and comm in long is not possible
*/

mtype = { idle, blocked, nonCS, CS, long };
mtype data = idle, comm = idle, telem = idle;
bit sem = 1;   /* Binary semaphore for CS */

/* A process is ready if it is not idle and not blocked */
#define ready(p)  (p != idle && p != blocked)

/* For priority inheritance: if process in CS, it can execute */
   #define inherit(p) false         /* No inheritance */
/* #define inherit(p) (p == CS) */   /* Inheritance */

inline enterCS(state) {
    atomic {
        if
        ::  sem != 0 ->
 sem = 0;
        ::  sem == 0 -> state = blocked;
 sem != 0;
 
        fi;
		state = CS
    }
}

inline exitCS(state) {
    atomic {
        sem = 1;
 state = idle
    }
}

active proctype Data() 
{
    do
    ::  data = nonCS;
		assert( ! (telem == CS && comm == long) ); 
        enterCS(data);
        exitCS(data);
        data = idle;
    od
}

active proctype Comm() 
	provided (!ready(data) && !inherit(telem)) {
    do
    ::  comm = long;
        comm = idle;
    od
}

active proctype Telem() 
	provided  (!ready(data) && !ready(comm) || inherit(telem)) {
    do
    ::  telem = nonCS;
        enterCS(telem);
        exitCS(telem);
        telem = idle;
    od
}

