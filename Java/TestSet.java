/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

/* Critical section problem with test-and-set  */
class TestSet extends Thread {
    /* Number of processes currently in critical section */
    static volatile int inCS = 0;
    /* Common value */
    static volatile int common = 0;
    /* Local value */
    int local;
    
    synchronized void testAndSet() {
        local = common;
        common = 1;
    }
    
    public void run() {
        while (true) {
            /* Non-critical section */
            do
                testAndSet();
            while (local == 1);
            inCS++;
            Thread.yield();
            /* Critical section */
            System.out.println("Number of processes in critical section: "
                    + inCS);
            inCS--;
            common = 0;
        }
    }
    
    public static void main(String[] args) {
        TestSet p = new TestSet();
        TestSet q = new TestSet();
        p.start();
        q.start();
    }
}