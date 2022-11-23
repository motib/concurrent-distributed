/*
    Implementation of a Linda Tuple Space.
    Author: Moti Ben-Ari, 2004.

    Space is implemented as a Vector of Notes.
    A read/remove that does not find a tuple is blocked.
    A post wakes up all blocked processes who retry the matches.
*/  

import java.util.Vector;
public class Space {
        
    public static final Object formal = null;    // Formal parameter is null
    private Vector space = new Vector();        // The space of Notes
        
    public Space() {
        clearSpace();
    }

    // public method to clear space
    synchronized public void clearSpace() {
        space.clear();
    }
    
    // Return space as a string
    synchronized public String toString() {
        String s = "";
        for (int i = 0; i < space.size(); i++) 
              s = s + ((Note) space.get(i)).toString() + "\n";
        return s;
    }

    // Various signatures for postnote
    synchronized public void postnote(Note n) {
        post(n);
    }
    synchronized public void postnote(String id, Object[] p) {
        post(new Note(id, p));
    }
    synchronized public void postnote(String id) {
        post(new Note(id));
    }
    synchronized public void postnote(String id, int p1) {
        post(new Note(id, p1));
    }
    synchronized public void postnote(String id, int p1, int p2) {
        post(new Note(id, p1, p2));
    }
    synchronized public void postnote(String id, int p1, int p2, int p3) {
        post(new Note(id, p1, p2, p3));
    }

    // Post - add note to space and notify all blocked processes
    synchronized void post(Note t) {
        space.add(t);
        notifyAll();
    }

    // Read/remove note: perform match
    synchronized public Note removenote(Note n) {
        return readRemove(n, true);
    }
    
     synchronized public Note readnote(Note n) {
        return readRemove(n, false);
    }
    
    // Read/remove note with null element array matches anything with id
    synchronized public Note removenote(String id) {
        return readRemove(new Note(id), true);
    }
    synchronized public Note readnote(String id) {
        return readRemove(new Note(id), false);
    }

    // Read/remove note - search for note until found or wait
    synchronized private Note readRemove(Note t, boolean remove) {
        while (true) {
            int i = searchNote(t);
            if (i < space.size()) { 
                Note n = (Note) space.get(i);
                if (remove) space.remove(i);
                return n;
            }
            try { wait(); } catch (InterruptedException e) { }
        }
    }
    
    // Search for a match on the space; formal matches anything
    // Return index of element found or size() to indicate not found
    synchronized private int searchNote(Note t) {
        int i = 0; 
        boolean found = false;
        while (!found && (i < space.size())) {
            Note n = (Note) space.get(i);
            // Note id's must match
            found = (n.id.equals(t.id));
            // Null element arrays match anything
            if (found && (t.p != null) && (n.p != null)) {
                // Lengths of element arrays must match
                found = found && (t.p.length == n.p.length);
                for (int j = 0; j < t.p.length && found; j++)
                    // Elements must be null or equal
                    found = found && (
                        (t.p[j] == formal) || (n.p[j] == formal) || 
                        (t.p[j].equals(n.p[j])) );
                }
            if (!found) i++;
         }
         return (found ? i : space.size());
    }
}
