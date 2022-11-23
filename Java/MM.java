/*
    Matrix multiplication in Linda
    Author: Moti Ben-Ari, 2004.
*/

class MM {
    private static final int SIZE = 3;    // Size of matrix
    private static final int WORKERS = 2; // Number of workers
    private Space space = new Space();

    // Workers
    private class Worker extends Thread {
        int n;                            // Number of worker

        public Worker(int n) {
            this.n = n;
        }

        // Create a note to match note (s, rc, formal, formal, ...)
        private Note match(String s, int rc) {
            Object[] p = new Object[SIZE+1];
            p[0] = new Integer(rc);
            return new Note(s, p);
        }

        public void run() {
            Note task = new Note("task");
            while (true) {
                // Get a task and compute row and column numbers
                Note t = space.removenote(task);
                int row = t.get(0);
                int col = t.get(1);
                if (row == 0) break; // Terminate computation
                // Get the row and column notes
                Note r = space.readnote(match("a", row));
                Note c = space.readnote(match("b", col));
                // Computer the inner product of the row and column
                int sum = 0;
                for (int i = 1; i <= SIZE; i++)
                    sum = sum + r.get(i)*c.get(i);
                // Post the result note
                space.postnote(new Note("result", row, col, sum));
                // Print result to track computation
                System.out.println("Worker " + n + " computed (" +
                            row + "," + col + ") = " + ip);
            }
        }
    }

    // Master
    private class Master extends Thread {
        // Create Notes for each row and column vector
        private void initVectors() {
            // Test data
            int[][] a = new int[][]{{1,2,3},{4,5,6},{7,8,9}};
            int[][] b = new int[][]{{1,0,2},{0,1,2},{1,0,0}};
            // Note with row/column and SIZE values
            Object[] p = new Object[SIZE+1];
            for (int i = 1; i <= SIZE; i++) {
                p[0] = new Integer(i);
                for (int j = 1; j <= SIZE; j++)
                    p[j] = new Integer(a[i-1][j-1]);
                space.postnote("a", p);
                for (int j = 1; j <= SIZE; j++)
                    p[j] = new Integer(b[j-1][i-1]);
                space.postnote("b", p);
            }
        }

        public void run() {
            // Create vectors in space
            initVectors();
            // Create Notes with tasks
            for (int i = 0; i < SIZE; i++)
                for (int j = 0; j < SIZE; j++)
                    space.postnote("task", i+1, j+1);
            System.out.print(space);
            // Wait for for all result Notes and collect into a matrix
            int[][] result = new int[SIZE][SIZE];
            for (int i = 0; i < SIZE*SIZE; i++) {
                Note r = space.removenote("result");
                result[r.get(0)-1][r.get(1)-1] = r.get(2);
            }
            // Terminate workers
            for (int i = 0; i < WORKERS; i++)
                space.postnote("task", 0, 0);
            // Print results
            for (int i = 0; i < SIZE; i++) {
                for (int j = 0; j < SIZE; j++)
                    System.out.print(result[i][j] + " ");
                System.out.println();
            }
        }
    }

    private void createProcesses() {
        new Master().start();
        for (int i = 0; i < WORKERS; i++)
            new Worker(i).start();
    }

    public static void main(String [] args) {
        MM mm = new MM();
        mm.createProcesses();
    }
}