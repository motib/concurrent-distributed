-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Barz's implementation of general semaphores by binary semaphores
with Ada.Text_IO; use Ada.Text_IO;
procedure Barz is
   pragma Time_Slice(0.01);

   type Bit is range 0..1;
   type Node_Count is range 0..4;
   subtype Node_ID is Node_Count range 1..Node_Count'Last;

   protected type Binary_Semaphore(Start_Value: Bit := 1) is
      entry Wait;
      procedure Signal;
   private
      Value: Bit := Start_Value;
   end Binary_Semaphore;
   protected body Binary_Semaphore is
      entry Wait when Value > 0 is
      begin
         Value := Value - 1;
      end Wait;

      procedure Signal is
      begin
         Value := Value + 1;
      end Signal;
   end Binary_Semaphore;

   type Barz_General_Semaphore(Start_Value: Natural := 0) is record
      S: Binary_Semaphore;
      Gate: Binary_Semaphore;
      Count: Natural := Start_Value;
   end record;

   procedure Wait(B : in out Barz_General_Semaphore) is
   begin
      B.Gate.Wait;
      B.S.Wait;
      B.Count := B.Count - 1;
      if B.Count > 0 then
         B.Gate.Signal;
      end if;
      B.S.Signal;
   end Wait;

   procedure Signal(B : in out Barz_General_Semaphore) is
   begin
      B.S.Wait;
      B.Count := B.Count + 1;
      if B.Count = 1 then
         B.Gate.Signal;
      end if;
      B.S.Signal;
   end Signal;

   Semaphore: Barz_General_Semaphore(1);
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
         Put_Line(" " & Node_ID'Image(I) & " non-critical section" );
         Put_Line(" " & Node_ID'Image(I) & " trying to enter critical section");
         Wait(Semaphore);
         Put_Line(" " & Node_ID'Image(I) & " critical section");
         Put_Line(" " & Node_ID'Image(I) & " leaving critical section");
         Signal(Semaphore);
      end loop;
   end Nodes;

   Node: array(Node_ID) of Nodes;
begin
   for J in Node_ID loop
      Node(J).Init(J);
   end loop;
end Barz;
