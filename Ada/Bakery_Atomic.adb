-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Bakery algorithm with atomic operations implemented in a protected object
with Ada.Text_IO; use Ada.Text_IO;
procedure Bakery_Atomic is
   pragma Time_Slice(0.01);

   type Node_Count is range 0..4;
   subtype Node_ID is Node_Count range 1..Node_Count'Last;
   type Number_Array is array(Node_ID) of Integer;

   protected Numbers is
      procedure SetToMax(Current: in Node_ID);
      procedure Reset(Current: in Node_ID);
      function Compare(Current: in Node_ID; Other: in Node_ID) return Boolean;
   private
      Number: Number_Array := (others => 0);
   end Numbers;

   protected body Numbers is
      procedure SetToMax(Current: in Node_ID) is
         Max : Integer := 0;
      begin
         for N in Number'Range loop
            if Number(N) > Max then
               Max := Number(N);
            end if;
         end loop;
         Number(Current) := Max + 1;
         Put_Line(" " & Node_ID'Image(Current) & " number is " &
                  Integer'Image(Number(Current)));
      end SetToMax;

      procedure Reset(Current: in Node_ID) is
      begin
         Number(Current) := 0;
      end Reset;

      function Compare(Current: in Node_ID; Other: in Node_ID)
                      return Boolean is
      begin
         return Number(Other) = 0 or Number(Current) < Number(Other) or
           (Number(Current) = Number(Other) and Current < Other);
      end Compare;
   end Numbers;

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
         Numbers.SetToMax(I);
         for J in Node_ID loop
            if J /= I then
               loop exit when Numbers.Compare(I, J); end loop;
            end if;
         end loop;
         Put_Line(" " & Node_ID'Image(I) & " critical section");
         Numbers.Reset(I);
         Put_Line(" " & Node_ID'Image(I) & " left critical section");
      end loop;
   end Nodes;

   Node: array(Node_ID) of Nodes;
begin
   for J in Node_ID loop
      Node(J).Init(J);
   end loop;
end Bakery_Atomic;
