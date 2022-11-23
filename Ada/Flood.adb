-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Distributed consensus by flooding
-- Uses FIFO buffers to emulate channels
with FIFO_Buffers;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
procedure Flood is
   pragma Time_Slice(0.01);

   type Node_Count is range 0..4;
   subtype Node_ID is Node_Count range 1..Node_Count'Last;
   Traitors: constant Node_ID := 2;
   subtype Round is Node_Count range 0..Traitors;

   type Buffer_Index is mod 20;

   Crash_Probability: constant Integer := 4;
   type Crash_Die is range 1..Crash_Probability;

   type Plan is (C, A, R);
   subtype Non_Crashed_Plan is Plan range A..R;

   type PlanTable is array(Node_ID) of Plan;

   package Message_Buffers is new FIFO_Buffers(Buffer_Index, PlanTable);
   type Message_Buffer_Array is array(Node_ID) of Message_Buffers.Buffer;
   Message_Buffer: array(Round) of Message_Buffer_Array;

   package Random_Plan is new Ada.Numerics.Discrete_Random(Non_Crashed_Plan);
   Gen: Random_Plan.Generator;

   package Random_Crash is new Ada.Numerics.Discrete_Random(Crash_Die);
   CGen: Random_Crash.Generator;

   task type Nodes is
      entry Init(ID: Node_ID; Traitor: Boolean);
   end Nodes;
   task body Nodes is
      Plans: PlanTable := (others => C);
      Zero: PlanTable := (others => C);
      ReceivedPlan: PlanTable;
      Lie: Boolean;
      Crashed: Boolean := False;
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
      end if;
      if Plans(MyID) = A then
         Put_Line(" " & Node_ID'Image(MyID) & " wants to attack");
      else if Plans(MyID) = R then
         Put_Line(" " & Node_ID'Image(MyID) & " wants to retreat");
      end if;
      end if;

      for Iter in Round loop
         for G in Node_ID loop
            if G /= MyID then
               if Lie then
                  if Random_Crash.Random(CGen) = 1 then
                     if not Crashed then
                        Put_Line(" " & Node_ID'Image(MyID) & " crashes!");
                     end if;
                     Crashed := True;
                  end if;
               end if;

               if Crashed then
                  Message_Buffer(Iter)(G).Put(Zero);
               else
                  Message_Buffer(Iter)(G).Put(Plans);
               end if;
            end if;
         end loop;

         for G in Node_ID loop
            if G /= MyID then
               Message_Buffer(Iter)(MyID).Get(ReceivedPlan);
               for G1 in Node_ID loop
                  if Plans(G1) = C then
                     Plans(G1) := ReceivedPlan(G1);
                  end if;
               end loop;
            end if;
         end loop;
      end loop;

      As := 0;
      Rs := 0;
      for G1 in Node_ID loop
         if Plans(G1) = A then
            Put_Line(" " & Node_ID'Image(MyID) & " thinks " & Node_ID'Image(G1) & " attacks");
            As := As + 1;
         else if Plans(G1) = R then
            Put_Line(" " & Node_ID'Image(MyID) & " thinks " & Node_ID'Image(G1) & " retreats");
            Rs := Rs + 1;
         end if;
      end if;
      end loop;
      Put_Line(" " & Node_ID'Image(MyID) & " has attack: " &
               Integer'Image(As) & " and retreat: " & Integer'Image(Rs));

      if (As > Rs) then
         Put_Line(" " & Node_ID'Image(MyID) & " finally attacks");
      else
         Put_Line(" " & Node_ID'Image(MyID) & " finally retreats");
      end if;

   end Nodes;

   Node: array(Node_ID) of Nodes;
begin
   Random_Plan.Reset(Gen);
   Random_Crash.Reset(CGen);
   for J in Node_ID loop
      Node(J).Init(J, J<=Traitors);
   end loop;
end Flood;
