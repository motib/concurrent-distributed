-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Merge sort
with Ada.Text_IO; use Ada.Text_IO;
procedure Mergesort is
   N: constant Positive := 8;
   subtype Array_Index_Ex is Natural range 0..N;
   subtype Array_Index is Array_Index_Ex range 0..N-1;
   type Node_ID is range 1..2;
   A: array(Array_Index) of Integer := (5, 1, 10, 7, 4, 3, 12, 8);
   Result: array(Array_Index) of Integer;

   protected type General_Semaphore(Start_Value: Natural := 0) is
      entry Wait;
      procedure Signal;
   private
      Value: Natural := Start_Value;
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
   S: array(Node_ID) of General_Semaphore;

   task type Sort_Nodes is
      entry Init(ID: Node_ID; Low: Array_Index; High: Array_Index);
   end Sort_Nodes;
   task body Sort_Nodes is
      NI: Node_ID;
      L: Array_Index;
      H: Array_Index;
      Min: Array_Index;
      Temp: Integer;
   begin
      accept Init(ID: Node_ID; Low: Array_Index; High: Array_Index) do
         NI := ID;
         L := Low;
         H := High;
      end Init;
      -- Insertion sort of each half of the array
      for I in L..H-1 loop
         Min := I;
         for J in I+1..H loop
            if A(J) < A(Min) then
               Min := J;
            end if;
         end loop;
         Temp := A(I);
         A(I) := A(Min);
         A(Min) := Temp;
      end loop;
      S(NI).Signal;
   end Sort_Nodes;

   procedure Next(Index: in out Array_Index_Ex; R: in out Array_Index_Ex) is
   begin
      Result(R) := A(Index);
      R := R + 1;
      Index := Index + 1;
   end Next;
   task type Merge_Nodes;
   task body Merge_Nodes is
      First: Array_Index_Ex := 0;
      Second: Array_Index_Ex := N/2;
      R: Array_Index_Ex := 0;
   begin
      for I in Node_ID loop
         S(I).Wait;
      end loop;
      while First < N/2 or Second < N loop
         if First >= N/2 then
            Next(Second, R);
         else
            if Second >= N then
               Next(First, R);
            else
               if A(First) < A(Second) then
                  Next(First, R);
               else
                  Next(Second, R);
               end if;
            end if;
         end if;
      end loop;
      for I in Array_Index loop
         Put_Line(Integer'Image(Result(I)));
      end loop;
   end Merge_Nodes;
   Sort_Node: array(Node_ID) of Sort_Nodes;
   Merge_Node: Merge_Nodes;
begin
   Sort_Node(1).Init(1, 0, (N/2)-1);
   Sort_Node(2).Init(2, (N/2), N-1);
end Mergesort;
