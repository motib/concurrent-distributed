/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
class TestRWMonitor {
	final int Values = 20;
	RWMonitor monitor = new RWMonitor();

	class Reader extends Thread {
		int Name;
		Reader(int ID) { Name = ID; }

		public void run() {
			for (int I = 1; I < Values; I++) {
				monitor.StartRead();
				System.out.println("Reader " + Name + "reading ");
				monitor.EndRead();
			}
		}
	}

	class Writer extends Thread {
		int Name;
		Writer(int ID) { Name = ID; }

		public void run() {
			for (int I = 1; I < Values; I++) {
				monitor.StartWrite();
				System.out.println("Writer " + Name + "writing ");
				monitor.EndWrite();
			}
		}
	}

	TestRWMonitor(int nr, int nw) {
		for (int i = 1; i <= nr; i++) 
			(new Reader(i)).start();
		for (int i = 1; i <= nw; i++) 
			(new Writer(i)).start();
	}

	public static void main(String[] args) {
		TestRWMonitor tm = new TestRWMonitor(2,3);
	}
}

