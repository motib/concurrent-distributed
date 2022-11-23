/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */

/* Third attempt */
class Third {
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
                wantp = true;
                while (wantq)
                    Thread.yield();
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
                wantq = true;
                while (wantp)
                    Thread.yield();
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

    Third() {
        Thread p = new P();
        Thread q = new Q();
        p.start();
        q.start();
    }

    public static void main(String[] args) {
        new Third();
    }
}