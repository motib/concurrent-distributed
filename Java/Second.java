/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */

/* Second attempt */
class Second {
    /* Number of processes currently in critical section */
    static volatile int inCS = 0;
    /* Process p wants to enter critical section */
    static volatile boolean wantp = false;
    /* Process q wants to enter critical section */    
    static volatile boolean wantq = false;

    class P extends Thread {
        public void run() {
            while (true) {
                /* Non-critical section */
                while (wantq)
                    Thread.yield();
                wantp = true;
                inCS++;
                Thread.yield();
                /* Critical section */
                System.out.println("Number of processes in critical section: "
                        + inCS);
                inCS--;
                wantp = false;
            }
        }
    }
    
    class Q extends Thread {
        public void run() {
            while (true) {
                /* Non-critical section */
                while (wantp)
                    Thread.yield();
                wantq = true;
                inCS++;
                Thread.yield();
                /* Critical section */
                System.out.println("Number of processes in critical section: "
                        + inCS);
                inCS--;
                wantq = false;
            }
        }
    }

    Second() {
        Thread p = new P();
        Thread q = new Q();
        p.start();
        q.start();
    }

    public static void main(String[] args) {
        new Second();
    }
}