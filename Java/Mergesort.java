/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

import java.util.List;
import java.util.Collections;
import java.util.Vector;
import java.util.concurrent.Semaphore;

/* Mergesort using semaphores */
class Mergesort {
    public static void main(String[] args) {
        Semaphore sem1 = new Semaphore(0);
        Semaphore sem2 = new Semaphore(0);
        Vector<Integer> v = new Vector<Integer>();
        v.add(3); /* Add vector contents */ 
        v.add(5);
        v.add(6);
        v.add(8);
        v.add(1);
        v.add(3);
        v.add(5);
        v.add(7);
        new Sort(sem1, v.subList(0, v.size()/2)).start();
        new Sort(sem2, v.subList(v.size()/2, v.size())).start();
        new Merge(sem1, sem2, v).start();
    }
}

class Merge extends Thread {
    Semaphore sem1, sem2;
    Vector<Integer> vec;
    
    Merge(Semaphore s1, Semaphore s2, Vector<Integer> v) { 
        sem1 = s1; sem2 = s2; vec = v; 
    }
    
    public void run() {
        /* Wait for sorts to complete */
        try {
            sem1.acquire();
            sem2.acquire();
        } catch (InterruptedException e) {
        }
        /* Merge results */
        Vector<Integer> result = new Vector<Integer>();
        int i = 0, j = vec.size()/2;
        while (i < vec.size()/2 || j < vec.size()) {
            if (i == vec.size()/2)
                result.add(vec.get(j++));
            else if (j == vec.size())
                result.add(vec.get(i++));
            else if (vec.get(i).compareTo(vec.get(j)) < 0)
                result.add(vec.get(i++));
            else
                result.add(vec.get(j++));
        }
        System.out.println(result);
    }
}

class Sort extends Thread {
    Semaphore sem;
    List<Integer> vec;
        
    Sort(Semaphore s, List<Integer> v) { 
        sem = s; vec = v;
    }

    public void run() {
        /* Sort list and release semaphore */
        Collections.sort(vec);
        sem.release();
    }
}
