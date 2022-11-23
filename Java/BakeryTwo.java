/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

/* Bakery algorithm for two processes */
class BakeryTwo {
    /* Number of processes currently in critical section */
    static volatile int inCS = 0;
    /* Ticket number of process p */
    static volatile int np = 0;
    /* Ticket number of process q */
    static volatile int nq = 0;

    class P extends Thread {
        public void run() {
            while (true) {
                /* Non-critical section */
                np = nq + 1;
                /* await nq = 0 or np <= nq */
                while(nq != 0 && np > nq)
                    Thread.yield();
                inCS++;
                Thread.yield();
                /* Critical section */
                System.out.println("Number of processes in critical section: "
                        + inCS);
                inCS--;
                np = 0;
            }
        }
    }
    
    class Q extends Thread {
        public void run() {
            while (true) {
                /* Non-critical section */
                nq = np + 1;
                while(np != 0 && nq > np)
                    Thread.yield();
                inCS++;
                Thread.yield();
                /* Critical section */
                System.out.println("Number of processes in critical section: "
                        + inCS);
                inCS--;
                nq = 0;
            }
        }
    }

    BakeryTwo() {
        Thread p = new P();
        Thread q = new Q();
        p.start();
        q.start();
    }

    public static void main(String[] args) {
        new BakeryTwo();
    }
}
