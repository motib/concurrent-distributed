/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

/* Lamport's fast mutual exclusion algorithm for two processes */
class WaitFreeTwo {
    /* Number of processes currently in critical section */
    static volatile int inCS = 0;
    /* First gate */
    static volatile int gate1 = 0;
    /* Second gate */
    static volatile int gate2 = 0;
    /* Process p wants to enter critical section */
    static volatile boolean wantp = false;
    /* Process q wants to enter critical section */
    static volatile boolean wantq = false;
    /* Process ids for p and q */
    static final int p = 1;
    static final int q = 2;
    
    
    class P extends Thread {
        public void run() {
            while (true) {
                /* Non critical section */
                gate1 = p;
                wantp = true;
                if (gate2 != 0) {
                    wantp = false;
                    continue;
                }
                gate2 = p;
                if (gate1 != p) {
                    wantp = false;
                    /* await wantq = false */
                    while (wantq == true)
                        Thread.yield();
                    if (gate2 != p)
                        continue;
                    else
                        wantp = true;
                }
                inCS++;
                Thread.yield();
                /* Critical section */
                System.out.println("Number of processes in critical section: "
                        + inCS);
                inCS--;
                gate2 = 0;
                wantp = false;
            }
        }
    }

    class Q extends Thread {
        public void run() {
            while (true) {
                /* Non critical section */
                gate1 = q;
                wantq = true;
                if (gate2 != 0) {
                    wantq = false;
                    continue;
                }
                gate2 = q;
                if (gate1 != q) {
                    wantq = false;
                    /* await wantq = false */
                    while (wantq == true)
                        Thread.yield();
                    if (gate2 != q)
                        continue;
                    else
                        wantq = true;
                }
                    inCS++;
                    Thread.yield();
                    /* Critical section */
                    System.out.println("Number of processes in critical section: "
                            + inCS);
                    inCS--;
                    gate2 = 0;
                    wantq = false;
            }
        }
    }
    
    WaitFreeTwo() {
        Thread p = new P();
        Thread q = new Q();
        p.start();
        q.start();
    }

    public static void main(String[] args) {
        new WaitFreeTwo();
    }
}
