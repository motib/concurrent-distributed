/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

/* Lamport's fast mutual exclusion algorithm */
class WaitFree extends Thread {
    /* Number of threads */
    static final int N = 10;
    /* Number of threads currently in critical section */
    static volatile int inCS = 0;
    /* First gate */
    static volatile int gate1 = 0;
    /* Second gate */
    static volatile int gate2 = 0;
    /* Threads wanting to enter critical section, indexed by id */
    static volatile boolean want[];
    /* Thread id */
    int id;
    
    public void run() {
        while (true) {
            /* Non critical section */
            gate1 = id;
            want[id] = true;
            if (gate2 != 0) {
                want[id] = false;
                continue;
            }
            gate2 = id;
            if (gate1 != id) {
                want[id] = false;
                /* await all other wants = false */
                for (int i=1; i <= N; i++) {
                    if (i == id)
                        continue;
                    while (want[i] == true)
                        Thread.yield();
                }
                if (gate2 != id)
                    continue;
                else
                    want[id] = true;
            }
            inCS++;
            Thread.yield();
            /* Critical section */
            System.out.println("Number of processes in critical section: "
                    + inCS);
            inCS--;
            gate2 = 0;
            want[id] = false;
        }
    }
    
    WaitFree(int id) {
        this.id = id;
    }
    
    public static void main(String[] args) {
        want = new boolean[N+1];
        for (int i=1; i <= N; i++)
            new WaitFree(i).start();
    }
}
