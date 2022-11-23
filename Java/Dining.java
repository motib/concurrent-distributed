/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

import java.util.concurrent.Semaphore;

/* Dining philosophers solution */
class Dining extends Thread {
    /* Semaphore for each fork */
    static Semaphore[] fork = new Semaphore[5];

    class Philosopher extends Thread {
        /* Philosopher id */
        int i;
        Philosopher(int i) { this.i = i; }

        public void run() {
            while (true) {
                /* Think */
                try {
                    fork[i].acquire();
                    fork[(i + 1) % 5].acquire();
                } catch (InterruptedException e) {
                }
                /* Eat */
                System.out.println("Philosopher " + i + " is eating.");
                Thread.yield();
                fork[i].release();
                fork[(i + 1) % 5].release();
            }
        }
    }
    
    Dining() {
        for (int i=0; i < 5; i++) {
            fork[i] = new Semaphore(1);
        }
        new Philosopher(0).start();
        new Philosopher(1).start();
        new Philosopher(2).start();
        new Philosopher(3).start();
        new Philosopher(4).start();
    }
    
    public static void main(String[] args) {
        new Dining();
    }
}
