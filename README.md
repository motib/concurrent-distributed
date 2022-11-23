# Principle of Concurrent and Distributed Programming (Second Edition)	

Addison-Wesley, 2006. [ISBN 0-321-31283-X](https://www.pearson.com/en-us/subject-catalog/p/principles-of-concurrent-and-distributed-programming/P200000003698/9780321312839).

[Mordechai (Moti) Ben-Ari](https://www.weizmann.ac.il/sci-tea/benari/home)
	
An introduction to concurrent and distributed algorithms that use the synchronization primitives: semaphores, monitors, channels, rendezvous, spaces and token passing.  Another major topic is verification using deductive methods, temporal logic and model checking. 

This program archive is divided into directories containing programs in five languages.

## Promela

There are three types of files: h-files are include files, pml-files are Promela language files and prp-files contain LTL expressions for proving programs.

There is a separate directory for versions of the programs that can be processed by my [Erigone model checker](https://github.com/motib/erigone).

h-files         Contents    

    critical        Critical section declarations (read comments on how to use)    
    for             Macro for a for-statement    
    monitor         Implementation of monitors    
    sem             Implementation of semaphores    
    weak-sem-N      Implementation of weak semaphores    
    weak-sem-3      (as above) specialized for three processes    

prp-files       Contents

    barz-bin        Barz - gate is a binary semaphore
    barz-cg         Barz - count = 0 -> gate = 0
    barz-gc         Barz - gate = 0 && not in Test -> count = 0
    ds              Dijkstra-Scholten - liveness
    nostarve        No starvation for critical section problem
    rw-mon          Monitor for readers and writers - liveness
    token           At most one token in RA and NM token-passing

pml-files       Contents

Each pml file contains comments on verification. The words "Verify Safety" or "Verify Acceptance" mean you select "Verify" with one of those modes. If "with XXX" is included, "Load" the associated prp with that LTL claim and "Translate" before verifying.

### Chapter  2

    count           Counter

### Chapter  3

    dekker          Dekker's algorithm
    first           First attempt
    fourth          Fourth attempt
    second          Second attempt
    third           Third attempt
    test-set        Test and set instruction
    exchange        Exchange instruction

### Chapter  4

### Chapter  5

    bakery          Bakery algorithm
    bakery-atomic   Bakery algorithm with atomic assignment statements
    bakery-two      Bakery algorithm for two processes
    fast            Lamport's fast mutual exclusion algorithm
    fast-two        Lamport's fast mutual exclusion algorithm for two processes
    fast-two-modified (as above) modified by me for this book

### Chapter  6

    barz            Barz's simulation of general semaphores
    mergesort       Merge sort
    pc-sem          Producer-consumer with semaphores
    sem             Critical section with busy-wait semaphores
    udding          Udding's starvation-free algorithm
    weak-sem        Critical section with weak semaphores

### Chapter  7

    cs-mon          Monitor for critical section problem
    pc-mon          Monitor for producer-consumer problem
    rw-mon          Monitor for readers and writers problem
    rw-po           Monitor simulating protected object 
    sem-mon         Monitor implementation of semaphores

### Chapter  8

    conway          Conway's problem
    matrix          Matrix multiplication in an array of processors

### Chapter  9

    dining          Dining philosophers
    dining-room     Dining philosophers with four in a room
    linda           Master-worker matrix multiplication

### Chapter 10

    nm              Neilsen-Mizuno algorithm
    ra              Ricart-Agrawala algorithm
    ra-token        Ricart-Agrawala token-passing algorithm

### Chapter 11

    cl              Chandy-Lamport algorithm
    credit          Mattern's credit-recovery algorithm
    ds              Dijkstra-Scholten algorithm

### Chapter 12

    bg              Byzantine Generals algorithm
    bg-verif        Byzantine Generals  algorithm - specialized for verification
    cr              Crash failure
    flood           Flooding algorithm
    flood-verif1    Flooding algorithm - specialized for verification
    flood-verif2    Flooding algorithm - specialized for verification with bits
    king            King algorithm
    king-verif      King algorithm - specialized for verification

### Chapter 13

    inversion       Priority inversion
    simpson         Simpson's algorithm

## BACI - Pascal and C

The following programs have been implemented.
The extension is .pm for Pascal and .cm for C.

### Chapter  2

    count           Counter

### Chapter  3

    dekker          Dekker's algorithm
    first           First attempt
    fourth          Fourth attempt
    second          Second attempt
    third           Third attempt
    test-set        Test and set instruction
    exchange        Exchange instruction

### Chapter  4

### Chapter  5

    bakery          Bakery algorithm
    bakery-atomic   Bakery algorithm with atomic assignment statements
    bakery-two      Bakery algorithm for two processes
    fast            Lamport's fast mutual exclusion algorithm
    fast-two        Lamport's algorithm for two processes (modified)

### Chapter  6

    barz            Barz's simulation of general semaphores
    mergesort       Merge sort
    pc-sem          Producer-consumer with semaphores
    sem             Critical section with busy-wait semaphores
    udding          Udding's starvation-free algorithm

### Chapter  7

    pc-mon          Monitor for producer-consumer problem
    rw-mon          Monitor for readers and writers problem
    rw-po           Monitor simulating protected object 
    sem-mon         Monitor implementation of semaphores

## Java

Java source code is given for the concurrent programs.
The distributed algorithms are implemented in Java in the DAJ tool.


### Chapter  2

    Count           Counter

### Chapter  3

    Dekker          Dekker's algorithm
    First           First attempt
    Fourth          Second attempt
    Second          Third attempt
    Third           Fourth attempt
    TestSet         Test and set instruction
    Exchange        Exchange instruction

### Chapter  4

### Chapter  5

    BakeryOriginal  Bakery algorithm
    BakeryAtomic    Bakery algorithm with atomic assignment statements
    BakeryTwo       Bakery algorithm for two processes
    WaitFree        Lamport's fast mutual exclusion algorithm
    WaitFreeTwo     Lamport's algorithm for two processes (modified)

### Chapter  6

    Barz             Barz's simulation of general semaphores
    Mergesort        Merge sort
    ProducerConsumer Producer-consumer with semaphores
    CountSem         Critical section with busy-wait semaphores
    Udding           Udding's starvation-free algorithm

### Chapter  7

    PCMonitor, TestPCMonitor Monitor for producer-consumer problem
    RWMonitor, TestRWMonitor Monitor for readers and writers problem
    
### Chapter  8

    MatrixMultArray Matrix multiplication in an array of processors

### Chapter  9

    Dining           Dining philosophers
    DiningAsymmetric Asymmetric solution to dining philosophers
    DiningRoom       Dining philosophers with four in a room
    Note, Space, TestLinda
                     Implementation of Linda primitives
    MM               Master-worker matrix multiplication
    
## Ada

### Chapter  2

    Count           Counter

### Chapter  3

    Dekker          Dekker's algorithm
    First           First attempt
    Fourth          Fourth attempt
    Second          Second attempt
    Third           Third attempt
    Test_and_Set    Test and set instruction
    Exchange        Exchange instruction
    Hardware_Primitives Implementations of above instructions

### Chapter  4

### Chapter  5

    Bakery          Bakery algorithm
    Bakery_Atomic   Bakery algorithm with atomic assignment statements
    Bakery_Two      Bakery algorithm for two processes
    Fast            Lamport's fast mutual exclusion algorithm
    Fast_Two        Lamport's algorithm for two processes

### Chapter  6

    Barz            Barz's simulation of general semaphores
    Mergesort       Merge sort
    Semaphore_Package Implementation of semaphores
    PCS             Producer-consumer with semaphores
    Sem             Critical section with busy-wait semaphores
    Udding          Udding's starvation-free algorithm

### Chapter  7

    FIFO_Buffers    Protected type for FIFO buffer
    Monitor_Package Implementation of monitor
    PC_Monitor      Monitor for producer-consumer
    PCM             Monitor solution for producer-consumer
    RW_Monitor      Monitor for readers and writers
    RW              Monitor solution for readers and writers
    ReadersWriters  Protected objects for readers and writers

### Chapter  8

    Conway          Conway's problem
    Matrix          Matrix multiplication in an array of processors
    Bounded         Bounded buffer with rendezvous

### Chapter  9

    Dining_Semaphore Dining philosophers with semaphore
    Dining_Asym      Dining philosophers - asymmetric solution
    Dining_Room      Dining philosophers with room
    Dining_Monitor   Dining philosophers with monitor
    Phil_Monitor     Monitor for dining philosophers
    Tuple_Defs, Tuple_Package, TestLinda, Linda:
                     Linda implementation
    Matrix_Linda     Master-worker matrix multiplication

### Chapter 10

    NM              Neilsen-Mizuno algorithm
    RA              Ricart-Agrawala algorithm
    RA_Token        Ricart-Agrawala token-passing algorithm

### Chapter 11

    CL              Chandy-Lamport algorithm
    Credit          Mattern's credit-recovery algorithm
    DS              Dijkstra-Scholten algorithm

### Chapter 12

    BG              Byzantine Generals algorithm
    CR              Crash failure
    Flood           Flooding algorithm
    King            King algorithm

Appendix
    
    Divide          Division algorithm for SPARK
