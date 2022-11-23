-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Berman-Garay king algorithm for distributed consensus
-- Uses FIFO buffers to emulate channels
with FIFO_Buffers;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
procedure King is
   pragma Time_Slice(0.01);

   type Node_Count is range 0..5;
   subtype Node_ID is Node_Count range 1..Node_Count'Last;
   subtype Loyal_ID is Node_ID range 2..Node_ID'Last;

   Overwhelming: constant Integer := 3;

   type Buffer_Index is mod 20;

   type Plan is (A, R);

   package Message_Buffers is new FIFO_Buffers(Buffer_Index, Plan);
   type Message_Buffer_Array is array(Node_ID) of Message_Buffers.Buffer;
   Message_Buffer: array(Node_ID) of Message_Buffer_Array;

   type PlanTable is array(Node_ID) of Plan;

   package Random_Plan is new Ada.Numerics.Discrete_Random(Plan);
   Gen: Random_Plan.Generator;

   package Random_King is new Ada.Numerics.Discrete_Random(Loyal_ID);
   KGen: Random_King.Generator;

   King_ID: array(1..2) of Node_ID;

   task type Nodes is
      entry Init(ID: Node_ID; Traitor: Boolean);
   end Nodes;
   task body Nodes is
      MyMajority: Plan;
      Plans: PlanTable;
      MajoritySize: Integer;
      M: Plan;
      Lie: Boolean;
      MyID: Node_ID;
      As: Integer;
      Rs: Integer;
   begin
      accept Init(ID: Node_ID; Traitor: Boolean) do
         MyID := ID;
         Lie := Traitor;
      end Init;
      Plans(MyID) := Random_Plan.Random(Gen);
      if Lie then
         Put_Line(" " & Node_ID'Image(MyID) & " is a traitor!");
      else
         if Plans(MyID) = A then
            Put_Line(" " & Node_ID'Image(MyID) & " wants to attack");
         else
            Put_Line(" " & Node_ID'Image(MyID) & " wants to retreat");
         end if;
      end if;

      for Iter in 1..2 loop
         for G in Node_ID loop
            if G /= MyID then
               if Lie then
                  Message_Buffer(G)(MyID).Put(Random_Plan.Random(Gen));
               else
                  Message_Buffer(G)(MyID).Put(Plans(MyID));
               end if;
            end if;
         end loop;

         for G in Node_ID loop
            if G /= MyID then
               Message_Buffer(MyID)(G).Get(M);
               if (M = A) then
                  Put_Line(" " & Node_ID'Image(MyID) & " got " &
                           Node_ID'Image(G) & " says he attacks");
               else
                  Put_Line(" " & Node_ID'Image(MyID) & " got " &
                           Node_ID'Image(G) & " says he retreats");
               end if;
               Plans(G) := M;
            end if;
         end loop;

         As := 0;
         Rs := 0;
         for G1 in Node_ID loop
            if Plans(G1) = A then
               As := As + 1;
            else
               Rs := Rs + 1;
            end if;
         end loop;
         if As > Rs then
            MyMajority := A;
            MajoritySize := As;
            Put_Line(" " & Node_ID'Image(MyID) & " think majority attacks");
         else
            MyMajority := R;
            MajoritySize := Rs;
            Put_Line(" " & Node_ID'Image(MyID) & " think majority retreats");
         end if;

         if King_ID(Iter) = MyID then
            for G in Node_ID loop
               if G /= MyID then
                  if Lie then
                     Message_Buffer(G)(MyID).Put(Random_Plan.Random(Gen));
                  else
                     Message_Buffer(G)(MyID).Put(MyMajority);
                  end if;
               end if;
            end loop;
            Plans(MyID) := MyMajority;
         else
            Message_Buffer(MyID)(King_ID(Iter)).Get(M);
            if (M = A) then
               Put_Line(" " & Node_ID'Image(MyID) & " got " &
                        " king says we attack");
            else
               Put_Line(" " & Node_ID'Image(MyID) & " got " &
                        " king says we retreat");
            end if;
            if MajoritySize > Overwhelming then
               Plans(MyID) := MyMajority;
            else
               Plans(MyID) := M;
            end if;
         end if;
      end loop;

      if Plans(MyID) = A then
         Put_Line(" " & Node_ID'Image(MyID) & " finally attacks");
      else
         Put_Line(" " & Node_ID'Image(MyID) & " finally retreats");
      end if;

   end Nodes;

   Node: array(Node_ID) of Nodes;
begin
   Random_Plan.Reset(Gen);
   Random_King.Reset(KGen);

   if Random_Plan.Random(Gen) = A then
      King_ID(1) := 1;
      King_ID(2) := Random_King.Random(KGen);
   else
      King_ID(2) := 1;
      King_ID(1) := Random_King.Random(KGen);
   end if;

   Put_Line("King 1 is " & Node_ID'Image(King_ID(1)));
   Put_Line("King 2 is " & Node_ID'Image(King_ID(2)));

   for J in Node_ID loop
      Node(J).Init(J, J=1);
   end loop;
end King;
