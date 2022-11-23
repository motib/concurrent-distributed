/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
class RWMonitor {
	volatile int readercount = 0;
	volatile boolean busy = false;
	
	synchronized void StartRead() {
    while (busy)
      try {
         wait();
      } catch (InterruptedException e) {}
		readercount = readercount + 1;
		notifyAll();
	}

	synchronized void EndRead() {
		readercount = readercount - 1;
		if (readercount == 0) notifyAll();
	}

	synchronized void StartWrite() {
    while (busy || (readercount != 0))
      try {
         wait();
      } catch (InterruptedException e) {}
		busy = true;
	}

	synchronized void EndWrite() {
		busy = false;
		notifyAll();
	}
}
