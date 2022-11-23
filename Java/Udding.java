/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

import java.util.concurrent.Semaphore;

/* Udding's starvation free algorithm */
public class Udding extends Thread {
    /* Number of processes */
    static final int N = 100;
    /* Number of processes currently in critical section */
    static volatile int inCS = 0;
    /* First gate */
    static Semaphore gate1 = new Semaphore(1);
    static volatile int ngate1 = 0;
    /* Second gate */
    static Semaphore gate2 = new Semaphore(0);
    static volatile int ngate2 = 0;
    /* Only one */
    static Semaphore onlyOne = new Semaphore(1);
    

    public void run() {
        while (true) {
            try {
                gate1.acquire();
            } catch (InterruptedException e) {
            }
            ngate1++;
            gate1.release();
            /* First gate */
            try {
                onlyOne.acquire();
                gate1.acquire();
            } catch (InterruptedException e) {
            }
            ngate1--;
            ngate2++;
            if (ngate1 > 0)
                gate1.release();
            else
                gate2.release();
            onlyOne.release(); 
            
            /* Second gate */
            try {
                gate2.acquire();
            } catch (InterruptedException e) {
            }
            ngate2--;
            /* Critical section */
            inCS++;
            Thread.yield();
            System.out.println("Number of processes in critical section: "
                    + inCS);
            inCS--;
            if (ngate2 > 0)
                gate2.release();
            else
                gate1.release();
        }
    }

    public static void main(String[] args) {
        for (int i=0; i < N; i++)
            new Udding().start();
    }
}
