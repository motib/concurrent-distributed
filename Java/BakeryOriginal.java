/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

/* Original bakery algorithm without atomic max() function */
class BakeryOriginal extends Thread {
    /* Number of threads */
    static final int N = 100;
    /* Number of threads currently in critical section */
    static volatile int inCS = 0;
    /* Ticket numbers of all threads, indexed by id */
    static volatile int number[];
    /* Threads that are choosing their ticket number, indexed by id */
    static volatile boolean choosing[];
    /* Thread id */
    int id;
    
    BakeryOriginal(int id) {
        this.id = id;
    }
    
    int max() {
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
            choosing[id] = true;
            number[id] = 1 + max();
            choosing[id] = false;
            for (int j = 0; j < N; j++) {
                if (j == id)
                    continue;
                while (choosing[j] == true)
                    Thread.yield();
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
        choosing = new boolean[N];
        for (int i=0; i < N; i++)
            new BakeryOriginal(i).start();
    }
}