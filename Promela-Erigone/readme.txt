            Source code for the textbook
                     M. Ben-Ari.
  Principles of Concurrent and Distributed Programming
                  (Second Edition)
      Addison-Wesley / Pearson Education Limited, 2006.

Copyright 2006-9 by M. Ben-Ari.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.

This version of the source code archive is intended for use with the
Erigone model checker: http://code.google.com/p/erigone/. Modifications
have been made to remove unsupported constructs like preprocessor
definitions. The more complex programs have been removed. To study them,
start working with Spin!

Chapter  2
----------
count             Counter

Chapter  3
----------
dekker            Dekker's algorithm
first             First attempt
fourth            Fourth attempt
second            Second attempt
third             Third attempt
test-set          Test and set instruction
exchange          Exchange instruction

Chapter  4
----------

Chapter  5
----------
bakery            Bakery algorithm
bakery-atomic     Bakery algorithm with atomic assignment statements
bakery-two        Bakery algorithm for two processes
fast              Lamport's fast mutual exclusion algorithm
fast-two          Lamport's fast mutual exclusion algorithm for two processes
fast-two-modified Lamport's algorithm as modified by me

Chapter  6
----------
barz              Barz's simulation of general semaphores
mergesort         Merge sort
pc-sem            Producer-consumer with semaphores
sem               Critical section with busy-wait semaphores
weak-sem          Critical section with weak semaphores

Chapter  7
----------
cs-mon            Monitor for critical section problem
pc-mon            Monitor for producer-consumer problem
rw-mon            Monitor for readers and writers problem
rw-po             Monitor simulating protected object 
sem-mon           Monitor implementation of semaphores

Chapter  8
----------
conway            Conway's problem
