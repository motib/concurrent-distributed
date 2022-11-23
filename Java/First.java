/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */

/* First attempt */
class First {
    /* Number of processes currently in critical section */
    static volatile int inCS = 0;
    /* Which processes turn is it */
    static volatile int turn = 1;

    class P extends Thread {
        public void run() {
            while (true) {
                /* Non-critical section */
                while (turn != 1)
                    Thread.yield();
                inCS++;
                Thread.yield();
                /* Critical section */
                System.out.println("Number of processes in critical section: "
                        + inCS);
                inCS--;
                turn = 2;
            }
        }
    }
    
    class Q extends Thread {
        public void run() {
            while (true) {
                /* Non-critical section */
                while (turn != 2)
                    Thread.yield();
                inCS++;
                Thread.yield();
                /* Critical section */
                System.out.println("Number of processes in critical section: "
                        + inCS);
                inCS--;
                turn = 1;
            }
        }
    }

    First() {
        Thread p = new P();
        Thread q = new Q();
        p.start();
        q.start();
    }

    public static void main(String[] args) {
        new First();
    }
}