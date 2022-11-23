-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Uddings's implementation of starvation-free mutual exclusion using
-- weak semaphores.
with Ada.Text_IO; use Ada.Text_IO;
procedure Udding is
   pragma Time_Slice(0.01);

   type Node_ID is range 1..3;
   Num_Gate1: Integer := 0;
   Num_Gate2: Integer := 0;

   protected type General_Semaphore(Start_Value: Integer := 0) is
      entry Wait;
      procedure Signal;
   private
      Value: Integer := Start_Value;
   end General_Semaphore;
   protected body General_Semaphore is
      entry Wait when Value > 0 is
      begin
         Value := Value - 1;
      end Wait;
      procedure Signal is
      begin
         Value := Value + 1;
      end Signal;
   end General_Semaphore;
   Gate1: General_Semaphore(1);
   Gate2: General_Semaphore(0);
   Only_One: General_Semaphore(1);

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
         Put_Line(" " & Node_ID'Image(I) & " trying to enter critical section");
         Gate1.Wait;
         Num_Gate1 := Num_Gate1 + 1;
         Gate1.Signal;
         Only_One.Wait;
         Gate1.Wait;
         Num_Gate1 := Num_Gate1 - 1;
         Num_Gate2 := Num_Gate2 + 1;
         if Num_Gate1 > 0 then
            Gate1.Signal;
         else
            Gate2.Signal;
         end if;
         Only_One.Signal;
         Gate2.Wait;
         Num_Gate2 := Num_Gate2 - 1;
         Put_Line(" " & Node_ID'Image(I) & " critical section");

         Put_Line(" " & Node_ID'Image(I) & " left critical section");
         if Num_Gate2 > 0 then
            Gate2.Signal;
         else
            Gate1.Signal;
         end if;
      end loop;
   end Nodes;
   Node: array(Node_ID) of Nodes;
begin
   for J in Node_ID loop
      Node(J).Init(J);
   end loop;
end Udding;
