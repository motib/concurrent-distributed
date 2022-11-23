/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
  Critical section problem with weak semaphores
  Two processes can conspire to keep a third
  from entering its critical section
  Verify Safety.
  Verify Acceptance fails with <>nostarve.
 
  Select weak semaphore IMPLEMENTATION:
  '3' for array of 3 processes, 'N' for array of N processes
*/

#define NPROCS 3
#define IMPLEMENTATION 'N' 

#if IMPLEMENTATION=='3'
#include "weak-sem-3.h"
#endif
#if IMPLEMENTATION=='N'
#include "weak-sem-N.h"
#endif

#include "for.h"
#define PID
#define NOSTARVE
#include "critical.h"

Semaphore sem;

proctype P () {
	do 
	:: wait(sem);
       critical_section();
	   signal(sem);
	od
}

init {
	initSem(sem, 1);
	atomic {
		for (i,1,NPROCS)
			run P()
		rof (i)
		}
}
