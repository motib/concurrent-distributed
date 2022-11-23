/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
  Critical section problem with weak semaphores
  Two processes can conspire to keep a third
  from entering its critical section
  Verify Safety.
  Verify Acceptance fails with <>nostarve.
*/
byte count = 1;
bool blocked[3] = false;
byte critical = 0;
bool pcs = false;

proctype P () {
	do 
	::
  atomic {
    if
    :: count >= 1 -> count--
    :: else -> blocked[_pid-1] = true; !blocked[_pid-1]
    fi
  }
  printf("%d in CS\n", _pid);
  if :: _pid==1 -> pcs = true; pcs = false; :: else fi;
  critical++;
  assert(critical == 1);
  critical--;
  atomic {
    if
    :: blocked[0] -> blocked[0] = false
    :: blocked[1] -> blocked[1] = false
    :: blocked[2] -> blocked[2] = false
    :: else -> count++
    fi
  }
	od
}

init {
	atomic {
	  run P();
	  run P();
	  run P();
	}
}
