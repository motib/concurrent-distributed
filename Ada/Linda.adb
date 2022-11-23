-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Characters.Latin_1;
package body Linda is
    Empty: Note := Note'(Formal, Formal, Formal);
    Board: array(0..100) of Note;
    NoRoomOnBoard: exception;
    Last: Integer range Board'Range := 0;

    protected Space is
    	entry Wait;
        procedure Notify;
    private
    	entry Wait1;
    	Posted: Boolean := False;
    end Space;
    
    protected body Space is
    	entry Wait when not Posted is
	begin
		requeue Wait1;
	end Wait;
	
	procedure Notify is
	begin
		if Wait1'Count > 0 then
			Posted := True;
		end if;
	end Notify;

    	entry Wait1 when Posted is
	begin
		if Wait1'Count = 0 then
			Posted := False;
		end if;
	end Wait1;
    end Space;
    
   function ToString(N: Note) return String is
   	S: Unbounded_String := To_Unbounded_String("");
   begin
   	if N.ID /= Formal then
		S := S & Character'Val(N.ID) & " ";
		if (N.P1 /= Formal) then S := S & Integer'Image(N.P1) & " "; end if;
		if (N.P2 /= Formal) then S := S & Integer'Image(N.P2) & " "; end if;
	end if;
	return To_String(S);
   end ToString;

   procedure ClearBoard is
   begin
   	Last := 0;
   end ClearBoard;
   
   function GetBoard return String is
   	S: Unbounded_String := To_Unbounded_String("");
   begin
        for I in 0..Last-1 loop
              S := S & ToString(Board(I)) & Ada.Characters.Latin_1.LF;
	end loop;
	return To_String(S);
   end GetBoard;

   procedure Post(T: Note) is
   begin
   	if Last > Board'Last then raise NoRoomOnBoard; end if;
	Board(Last) := T;
	Last := Last + 1;
        Space.Notify;
   end Post;
	
   procedure PostNote(C: Character; I1: Integer; I2: Integer) is
   begin
   	Post(Note'(Character'Pos(C), I1, I2));
   end PostNote;
   
   procedure PostNote(C: Character; I1: Integer) is
   begin
   	Post(Note'(Character'Pos(C), I1, Formal));
   end PostNote;

   procedure PostNote(C: Character) is
   begin
   	Post(Note'(Character'Pos(C), Formal, Formal));
   end PostNote;

   -----------------------------------------------------

   function SearchNote(T: Note) return Integer is
   	I: Integer := Board'First;
	Found: Boolean := False;
	N: Note;
   begin
        while not Found and (I < Last) loop
            N := Board(I);
            Found := (T.ID = N.ID) and then
	        ( (T.P1 = Formal) or (N.P1 = Formal) or (T.P1 = N.P1) ) and then
	        ( (T.P2 = Formal) or (N.P2 = Formal) or (T.P2 = N.P2) );
	    if not Found then I := I + 1; end if;
	 end loop;
      return I;
   end SearchNote;
   
   function GetNote(T: Note; Remove: Boolean) return Note is
   	I: Integer;
	Temp: Note;
   begin
   	I := SearchNote(T);
	if I = Last then return Empty; end if;
	Temp := Board(I);
	if Remove then
		for J in I..Last-1 loop
			Board(J) := Board(J+1);
		end loop;
		Last := Last - 1;
	end if;
	return Temp;
   end GetNote;
   
   procedure ReadRemove(C: Character; 
   	I1: in out Integer; I2: in out Integer; Remove: Boolean) is
	T: Note := Note'(Character'Pos(C), I1, I2);
	N: Note;
   begin
   	loop
		N := GetNote(T, Remove);
		exit when N /= Empty; 
		Space.Wait;
		end loop;
	I1 := N.P1;
	I2 := N.P2;
   end ReadRemove;

   procedure ReadNote(C: Character; I1: out Integer; I2: out Integer) is
   begin
   	I1 := Formal; I2 := Formal;
   	ReadRemove(C, I1, I2, False);
   end ReadNote;
   
   procedure ReadNote(C: Character; I1: out Integer) is
   	I2: Integer;
   begin
   	I1 := Formal; I2 := Formal;
   	ReadRemove(C, I1, I2, False);
   end ReadNote;
   
   procedure ReadNote(C: Character) is
   	I1, I2: Integer;
   begin
   	I1 := Formal; I2 := Formal;
   	ReadRemove(C, I1, I2, False);
   end ReadNote;

   procedure RemoveNote(C: Character; I1: out Integer; I2: out Integer) is
   begin
   	I1 := Formal; I2 := Formal;
   	ReadRemove(C, I1, I2, True);
   end RemoveNote;
   
   procedure RemoveNote(C: Character; I1: out Integer) is
   	I2: Integer := Formal;
   begin
   	I1 := Formal;
   	ReadRemove(C, I1, I2, True);
   end RemoveNote;
   
   procedure RemoveNote(C: Character) is
   	I1, I2: Integer := Formal;
   begin
   	ReadRemove(C, I1, I2, True);
   end RemoveNote;

   procedure ReadNoteEq(C: Character; I1: in out Integer; I2: in out Integer) is
   begin
   	ReadRemove(C, I1, I2, False);
   end ReadNoteEq;
   
   procedure ReadNoteEq(C: Character; I1: in out Integer) is
   	I2: Integer := Formal;
   begin
   	ReadRemove(C, I1, I2, False);
   end ReadNoteEq;
   
   procedure RemoveNoteEq(C: Character; I1: in out Integer; I2: in out Integer) is
   begin
   	ReadRemove(C, I1, I2, True);
   end RemoveNoteEq;
   
   procedure RemoveNoteEq(C: Character; I1: in out Integer) is
   	I2: Integer := Formal;
   begin
   	ReadRemove(C, I1, I2, True);
   end RemoveNoteEq;
   
end Linda;
