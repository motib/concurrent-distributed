/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
class TestPCMonitor {
	final int Values = 20;
	PCMonitor monitor = new PCMonitor();

	class Producer extends Thread {
		int Name;
		Producer(int ID) { Name = ID; }

		public void run() {
			for (int I = 1; I < Values; I++) {
				int J = Name*100+I;
				System.out.println("Producer " + Name + " producing " + J);
				monitor.Append(J);
			}
		}
	}

	class Consumer extends Thread {
		int Name;
		Consumer(int ID) { Name = ID; }
		
		public void run() {
			for (int I = 1; I < Values; I++)
				System.out.println("Consumer " + Name + " consuming " + 
					monitor.Take());
		}
	}

	TestPCMonitor(int np, int nc) {
		for (int i = 1; i <= np; i++) 
			(new Producer(i)).start();
		for (int i = 1; i <= nc; i++) 
			(new Consumer(i)).start();
	}

	public static void main(String[] args) {
		TestPCMonitor tm = new TestPCMonitor(2,3);
	}
}