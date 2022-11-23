/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

import java.util.concurrent.Semaphore;

/* Barz's algorithm for simulating general semaphores */
public class Barz extends Thread {
    /* Number of processes */
    static final int N = 4;
    /* Number of processes currently in critical section */
    static volatile int inCS = 0;
    /* Mutual exclusion for accessing count */
    static Semaphore S = new Semaphore(1);
    /* Gate for blocking and unblocking of processes */
    static Semaphore gate = new Semaphore(1);
    /* Integer component of the simulated semaphore */
    static volatile int count = 2;
    /* Process ID */
    int PID;
    
    public Barz(int pid) {
        PID = pid;
    }

    public void run() {
        while (true) {
            try {
                gate.acquire();
                S.acquire();
            } catch (InterruptedException e) {
            }
            count--;
            if (count > 0)
                gate.release();
            S.release();
            inCS++;
            /* Critical section */
            System.out.println(
                "Process " + PID + " in CS, number in CS " + inCS);
            try {
                sleep((int) (100 * Math.random()));
            } catch (InterruptedException e) {
            }
            inCS--;
            try {
                S.acquire();
            } catch (InterruptedException e) {
            }
            count++;
            if (count == 1)
                gate.release();
            S.release();
        }
    }

    public static void main(String[] args) {
        for (int i=0; i < N; i++)
            new Barz(i).start();
    }
}
