/*
    Implementation of a Linda Tuple Space.
    Author: Moti Ben-Ari, 2004.
    
    A Note consists of a String and an array of zero or more Objects.
    There are separate constructors for 0-3 integer elements.
    Method get(int) returns the i'th integer element.
*/  

public class Note {
    public String id;
    public Object[] p;
    
    public Note (String id, Object[] p) {
        if (id == null) System.exit(1);
        this.id = id;
        if (p != null) this.p = p.clone();
    }

    public Note (String id) { 
        this(id, null); 
    }
    public Note (String id, int p1) { 
        this(id, new Object[]{new Integer(p1)}); 
    }
    public Note (String id, int p1, int p2) {
        this(id, new Object[]{new Integer(p1), new Integer(p2)});
    }
    public Note (String id, int p1, int p2, int p3) {
        this(id, new Object[]{new Integer(p1), new Integer(p2), new Integer(p3)});
    }

	public int get(int i) {
		return ((Integer)p[i]).intValue();
	}

    public String toString() {
        if (p == null) return id;
        String s = id;
        for (int i = 0; i < p.length; i++)
            s = s + " " + ((p[i]==null)?"":p[i].toString());
        return s;
    }
}
