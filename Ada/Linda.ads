-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
package Linda is
   Formal: constant Integer := -32767;

   type Note is 
      record
         ID: Integer; -- Note id
         P1: Integer; -- First parameter
         P2: Integer; -- Second parameter
      end record;

   procedure ClearBoard;
   function GetBoard return String;
   function ToString(N: Note) return String;
   procedure PostNote(C: Character; I1: Integer; I2: Integer);
   procedure PostNote(C: Character; I1: Integer);
   procedure PostNote(C: Character);
   procedure ReadNote(C: Character; I1: out Integer; I2: out Integer);
   procedure ReadNote(C: Character; I1: out Integer);
   procedure ReadNote(C: Character);
   procedure RemoveNote(C: Character; I1: out Integer; I2: out Integer);
   procedure RemoveNote(C: Character; I1: out Integer);
   procedure RemoveNote(C: Character);
   procedure ReadNoteEq(C: Character; I1: in out Integer; I2: in out Integer);
   procedure ReadNoteEq(C: Character; I1: in out Integer);
   procedure RemoveNoteEq(C: Character; I1: in out Integer; I2: in out Integer);
   procedure RemoveNoteEq(C: Character; I1: in out Integer);
end Linda;
