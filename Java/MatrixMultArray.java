/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Programmed by Panu Pitkämäki */

import java.util.ArrayList;
import java.util.concurrent.Exchanger;

/* Matrix multiplication-array with channels */
class MatrixMultArray {
    /* East - West channels */
    ArrayList<Channel<Integer>> eastWest = new ArrayList<Channel<Integer>>();
    /* North - South channels */
    ArrayList<Channel<Integer>> northSouth = new ArrayList<Channel<Integer>>();

    class Multiplier extends Thread {
        Channel<Integer> north, east, south, west;
        Integer value;

        Multiplier(int value, Channel<Integer> north, Channel<Integer> east,
                   Channel<Integer> south, Channel<Integer> west) {
            this.value = value;
            this.north = north;
            this.east = east;
            this.south = south;
            this.west = west;
        }
 
        public void run() {
            int in;
            int sum;
            for (int i=0; i < 3; i++) {
                in = north.receive().intValue();
                sum = east.receive().intValue();
                sum += value * in;
                south.send(in);
                west.send(sum);
            }
        }
    }

    class Zero extends Thread {
        Channel<Integer> west;
        Zero(Channel<Integer> west) { this.west = west; }
        public void run() {
            west.send(0);
            west.send(0);
            west.send(0);
        }
    }

    class Sink extends Thread {
        Channel<Integer> north;
        Sink(Channel<Integer> north) { this.north = north; }
        public void run() {
            north.receive();
            north.receive();
            north.receive();
        }
    }

    class Result extends Thread {
        Channel<Integer> east;
        Integer a, b, c;
        Result(Channel<Integer> east) { this.east = east; }
        public void run() {
            a = east.receive();
            b = east.receive();
            c = east.receive();
        }

        void print() {
            System.out.println("\t" + a + "\t" + b + "\t" + c);
        }
    }

    class Source extends Thread {
        Channel<Integer> south;
        Integer a, b, c;
        Source(Channel<Integer> south, Integer a, Integer b, Integer c) {
            this.south = south;
            this.a = a;
            this.b = b;
            this.c = c;
        }
        public void run() {
            south.send(a);
            south.send(b);
            south.send(c);
        }
    }

    MatrixMultArray() {
        for (int i=0; i < 12; i++) {
            eastWest.add(new Channel<Integer>());
            northSouth.add(new Channel<Integer>());
        }
        /* Store Result objects for printing at the end */
        Result result1 = new Result(eastWest.get(0));
        Result result2 = new Result(eastWest.get(4));
        Result result3 = new Result(eastWest.get(8));
        result1.start();
        result2.start();
        result3.start();

        /* Form multiplication array */
        new Zero(eastWest.get(3)).start();
        new Zero(eastWest.get(7)).start();
        new Zero(eastWest.get(11)).start();
        new Sink(northSouth.get(3)).start();
        new Sink(northSouth.get(7)).start();
        new Sink(northSouth.get(11)).start();
        new Source(northSouth.get(0), 1, 0, 2).start();
        new Source(northSouth.get(4), 0, 1, 2).start();
        new Source(northSouth.get(8), 1, 0, 0).start();
        new Multiplier(1, northSouth.get(0),  eastWest.get(1),  northSouth.get(1),  eastWest.get(0)).start();
        new Multiplier(2, northSouth.get(4),  eastWest.get(2),  northSouth.get(5),  eastWest.get(1)).start();
        new Multiplier(3, northSouth.get(8),  eastWest.get(3),  northSouth.get(9),  eastWest.get(2)).start();
        new Multiplier(4, northSouth.get(1),  eastWest.get(5),  northSouth.get(2),  eastWest.get(4)).start();
        new Multiplier(5, northSouth.get(5),  eastWest.get(6),  northSouth.get(6),  eastWest.get(5)).start();
        new Multiplier(6, northSouth.get(9),  eastWest.get(7),  northSouth.get(10), eastWest.get(6)).start();
        new Multiplier(7, northSouth.get(2),  eastWest.get(9),  northSouth.get(3),  eastWest.get(8)).start();
        new Multiplier(8, northSouth.get(6),  eastWest.get(10), northSouth.get(7),  eastWest.get(9)).start();
        new Multiplier(9, northSouth.get(10), eastWest.get(11), northSouth.get(11), eastWest.get(10)).start();
        try {
            result1.join();
            result2.join();
            result3.join();
        } catch (InterruptedException e) {
        }
        result1.print();
        result2.print();
        result3.print();
    }

    public static void main(String[] args) {
        new MatrixMultArray();
    }
}

/* Simulate channel with Exchanger */
class Channel<T> {
    Exchanger<T> ex = new Exchanger<T>();
    /* Blocks until other end is sending() */
    T receive() {
        T item = null;
        try {
            item = ex.exchange(null);
        } catch (InterruptedException e) {
        }
        return item;
    }

    /* Blocks until other end is receiving() */
    void send(T obj) {
        try {
            ex.exchange(obj);
        } catch (InterruptedException e) {
        }
    }
}

