-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Lamport's fast mutual exclusion algorithm
with Ada.Text_IO; use Ada.Text_IO;
procedure Fast is
   pragma Time_Slice(0.01);

   type Node_Count is range 0..4;
   subtype Node_ID is Node_Count range 1..Node_Count'Last;
   Gate1, Gate2: Node_Count := 0;
   pragma Atomic(Gate1);
   pragma Atomic(Gate2);
   Want: array(Node_ID) of Boolean := (others => False);

   task type Nodes is
      entry Init(ID: Node_ID);
   end Nodes;
   task body Nodes is
      I:           Node_ID;
   begin
      accept Init(ID: Node_ID) do
         I := ID;
      end Init;
      loop
         Put_Line(" " & Node_ID'Image(I) & " non-critical section");
         <<Start>>
         Put_Line(" " & Node_ID'Image(I) & " trying to enter critical section");
         Want(I) := True;
         Gate1 := I;
         if Gate2 /= 0 then
            Want(I) := False;
            loop exit when Gate2 = 0; end loop;
            goto Start;
         end if;
         Gate2 := I;
         if Gate1 /= I then
            Want(I) := False;
            for J in Node_ID loop
               loop exit when Want(J) = False; end loop;
            end loop;
            if Gate2 /= I then
               loop exit when Gate2 = 0; end loop;
               goto Start;
            end if;
         end if;
         Put_Line(" " & Node_ID'Image(I) & " critical section");
         Gate2 := 0;
         Put_Line(" " & Node_ID'Image(I) & " left critical section");
         Want(I) := False;
         end loop;
   end Nodes;
   Node: array(Node_ID) of Nodes;
begin
   for J in Node_ID loop
      Node(J).Init(J);
   end loop;
end Fast;
