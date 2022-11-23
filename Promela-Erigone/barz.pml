/* Copyright (C) 2006-9 M. Ben-Ari. See copyright.txt */
/* 
   Barz's implementation of general semaphores
      by binary semaphores
   Verify Safety with the following properties:
      ![]#(gate <= 1)#
      ![](#(count == 0)# -> #(gate == 0)#)
      ![]((#(gate==0)# && #(test==0)#) -> #(count==0)#)
*/

byte gate     = 1;
byte count    = 2;
byte test     = 0;
byte critical = 0;

active [3] proctype P () {	
	do :: 
		/* Wait */
		atomic { gate > 0; gate--; test++ }
		assert(gate == 0);
		d_step {
			count--;
			if
			:: count > 0 -> gate++;
			:: else
			fi;
			test--
		}

    printf("%d in CS\n", _pid);
    critical++;
    assert (critical <= 2);
    critical--;

		/* Signal */
		d_step {
			count++;
			if
			:: count == 1 -> gate++;
			:: else
			fi;
		}
	od
}
