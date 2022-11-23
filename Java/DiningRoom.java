/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

import java.util.concurrent.Semaphore;

/* Dining philosophers with limited room entry */
class DiningRoom extends Thread {
    /* Semaphore for each fork */
    static Semaphore[] fork = new Semaphore[5];
    /* Semaphore for entering the dining room */
    static Semaphore room = new Semaphore(4);
    /* Philosopher id */
    int i;
    
    DiningRoom(int i) {
        this.i = i;
    }

    public void run() {
        while (true) {
            /* Think */
            try {
                room.acquire();
                fork[i].acquire();
                fork[(i + 1) % 5].acquire();
            } catch (InterruptedException e) {
            }
            /* Eat */
            System.out.println("Philosopher " + i + " is eating.");
            Thread.yield();
            fork[i].release();
            fork[(i + 1) % 5].release();
            room.release();
        }
    }
    
    public static void main(String[] args) {
        for (int i=0; i < 5; i++) {
            fork[i] = new Semaphore(1);
        }
        
        for (int i=0; i < 5; i++)
            new DiningRoom(i).start();
    }
}
