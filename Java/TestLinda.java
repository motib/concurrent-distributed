/*
    Implementation of a Linda Tuple Space.
    Author: Moti Ben-Ari, 2004.
    Note: Uses java.util.Scanner from Java 5.
*/  

class TestLinda {
    private Space ts = new Space();
    private int turn = 0;           // To schedule threads

    // Print a Note
    synchronized void print(Note n) {
            System.out.println("Note = " + n);
            System.out.println("--------------------------------");
            writeSpace();
    }            

    // Print the space
    synchronized void writeSpace() {
        System.out.println("Space");
        System.out.print(ts);
        System.out.println("********************************");
    }

    // Wait for input of i
    void waitTurn(int i) {
        while (turn != i)
            try { Thread.sleep(200); } catch (InterruptedException e) {};
        turn = 0;
    }

    private class T1 extends Thread {
        public void run() {
            Note note;
            String c; 
            int i1 = 0, i2 = 0; 

            // Check post, read and remove
            ts.postnote("m", 10, 20);		// Posts note
            writeSpace();
            waitTurn(1);
            note = ts.readnote("m");
            print(note);	  	            // Prints m 10 20
            waitTurn(1);
            note = ts.removenote("m");
            print(note);	  	            // Prints m 10 20
            waitTurn(1);
            
            // Check values vs. variables
            ts.postnote("c", 1, 2);
            c = "c"; i1 = 8; i2 = 9;
            ts.postnote(c, i1, i2);
            writeSpace();
            waitTurn(1);
            note = ts.readnote(new Note(c, i1, i2));
            print(note);		          // Prints c 8 9 
            waitTurn(1);
            i1 = 1; i2 = 2;
            note = ts.readnote(new Note(c, i1, i2));
            print(note);		          // Prints c 1 2 
            waitTurn(1);
            i1 = 8; i2 = 9;
            note = ts.removenote(new Note(c, i1, i2));
            print(note);		          // Prints c 8 9 
            waitTurn(1);
            i1 = 1; i2 = 2;
            note = ts.removenote(new Note(c, i1, i2));
            print(note);		          // Prints c 1 2 
            waitTurn(1);

            System.out.println("Next instruction should block");
            
            //  Check blocking, unblocking
            note = ts.removenote("a"); // Blocks, step t2
            print(note);		       // Prints a 77 88 
            waitTurn(1);
            note = ts.removenote("b");
            print(note);		       // Prints b 55 66 
            waitTurn(1);
        }
    }

    private class T2 extends Thread {
        public void run() {
            waitTurn(2);
            ts.postnote("b", 55, 66);   // Doesn"t unblock
            writeSpace();
            waitTurn(2);
            ts.postnote("a", 77, 88);   // Unblock
            writeSpace();
        }
    }

    // Read input to get whose turn 1 or 2 it is to execute
    // Enter 0 to terminate
    private class Scheduler extends Thread {
        java.util.Scanner scanner = new java.util.Scanner(System.in);
        public void run() {
            while (true) {
                turn = scanner.nextInt();
                if (turn == 0) System.exit(0);
                try { Thread.sleep(200); } catch (InterruptedException e) {}
            }
        }
    }

    private void init() {
        new T1().start();
        new T2().start();
        new Scheduler().start();
    }

    public static void main(String [] args) {
        TestLinda test = new TestLinda();
        test.init();
    }
}