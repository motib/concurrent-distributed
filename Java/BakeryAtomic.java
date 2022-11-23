/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

/* Bakery algorithm with atomic max() function */
class BakeryAtomic extends Thread {
    /* Number of threads */
    static final int N = 100;
    /* Number of threads currently in critical section */
    static volatile int inCS = 0;
    /* Ticket numbers of all threads, indexed by id */
    static volatile int number[];
    /* Thread id */
    int id;
    
    BakeryAtomic(int id) {
        this.id = id;
    }
    
    synchronized int max() {
        int max = 0;
        for (int i=0; i < N; i++) {
            if (i == id)
                continue;
            if (max < number[i])
                max = number[i];
        }
        return max;
    }
    
    public void run() {
        while (true) {
            /* Non critical section */
            number[id] = 1 + max();
            for (int j = 0; j < N; j++) {
                if (j == id)
                    continue;
                while (!(number[j] == 0 || 
                        ((number[id] < number[j]) || 
                                (number[id] == number[j] && id < j))))
                    Thread.yield();
            }
            inCS++;
            Thread.yield();
            /* Critical section */
            System.out.println("Number of processes in critical section: "
                    + inCS);
            inCS--;
            number[id] = 0;
        }
    }
    
    public static void main(String[] args) {
        number = new int[N];
        for (int i=0; i < N; i++)
            new BakeryAtomic(i).start();
    }
}