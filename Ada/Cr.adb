-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Distributed consensus with crash failure (Byzantine Generals algorithm)
-- Uses FIFO buffers to emulate channels
with FIFO_Buffers;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
procedure BG is
   pragma Time_Slice(0.01);

   type Node_Count is range 0..4;
   subtype Node_ID is Node_Count range 1..Node_Count'Last;

   type Buffer_Index is mod 20;

   Crash_Probability: constant Integer := 4;
   type Crash_Die is range 1..Crash_Probability;

   type Plan is (C, A, R);
   subtype Non_Crashed_Plan is Plan range A..R;

   type Message is
      record
         From: Node_ID;
         Whose: Node_ID;
         What: Plan;
      end record;

   package Message_Buffers is new FIFO_Buffers(Buffer_Index, Message);
   Message_Buffer: array(Node_ID) of Message_Buffers.Buffer;
   Message_Buffer2: array(Node_ID) of Message_Buffers.Buffer;

   type PlanTable is array(Node_ID) of Plan;
   type PlanMatrix is array(Node_ID) of PlanTable;

   package Random_Plan is new Ada.Numerics.Discrete_Random(Non_Crashed_Plan);
   Gen: Random_Plan.Generator;

   package Random_Crash is new Ada.Numerics.Discrete_Random(Crash_Die);
   CGen: Random_Crash.Generator;

   task type Nodes is
      entry Init(ID: Node_ID; Traitor: Boolean);
   end Nodes;
   task body Nodes is
      Plans: PlanTable;
      ReportedPlan: PlanMatrix;
      MajorityPlan: PlanTable;
      M: Message;
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
      else
         if Plans(MyID) = A then
            Put_Line(" " & Node_ID'Image(MyID) & " wants to attack");
         else if Plans(MyID) = R then
            Put_Line(" " & Node_ID'Image(MyID) & " wants to retreat");
         end if;
         end if;
      end if;

      M.From := MyID;
      M.Whose := MyID;
      M.What := Plans(MyID);
      for G in Node_ID loop
         if G /= MyID then
            if Lie then
               if Random_Crash.Random(CGen) = 1 then
                  Crashed := True;
               end if;
            end if;

            if Crashed then
               M.What := C;
            end if;
            Message_Buffer(G).Put(M);
         end if;
      end loop;

      for G in Node_ID loop
         if G /= MyID then
            Message_Buffer(MyID).Get(M);
            Plans(M.Whose) := M.What;
            if (M.What = A) then
               Put_Line(" " & Node_ID'Image(MyID) & " got " &
                        Node_ID'Image(M.Whose) & " says he attacks");
            else if M.What = R then
               Put_Line(" " & Node_ID'Image(MyID) & " got " &
                        Node_ID'Image(M.Whose) & " says he retreats");
            end if;
            end if;
         end if;
      end loop;

      M.From := MyID;
      for G in Node_ID loop
         if G /= MyID then
            for G1 in Node_ID loop
               if G1 /= G and G1 /= MyID then
                  M.Whose := G;
                  M.What := Plans(G);
                  if Lie then
                     if Random_Crash.Random(CGen) = 1 then
                        Crashed := True;
                     end if;
                  end if;
                  if Crashed then
                     M.What := C;
                  end if;

                  Message_Buffer2(G1).Put(M);
               end if;
            end loop;
         end if;
      end loop;

      for G in Node_ID loop
         if G /= MyID then
            for G1 in Node_ID loop
               if G1 /= G and G1 /= MyID then
                  Message_Buffer2(MyID).Get(M);
                  ReportedPlan(M.From)(M.Whose) := M.What;
                  if (M.What = A) then
                     Put_Line(" " & Node_ID'Image(MyID) & " got " &
                              Node_ID'Image(M.From) & " says " &
                              Node_ID'Image(M.Whose) & " attacks");
                  else if M.What = R then
                     Put_Line(" " & Node_ID'Image(MyID) & " got " &
                              Node_ID'Image(M.From) & " says " &
                              Node_ID'Image(M.Whose) & " retreats");
                  end if;
                  end if;
               end if;
            end loop;
         end if;
      end loop;

      for G in Node_ID loop
         if G /= MyID then
            As := 0;
            Rs := 0;
            for G1 in Node_ID loop
               if G /= G1 and G1 /= MyID then
                  if ReportedPlan(G1)(G) = A then
                     As := As + 1;
                  else if ReportedPlan(G1)(G) = R then
                     Rs := Rs + 1;
                  end if;
                  end if;
               else
                  if Plans(G) = A then
                     As := As + 1;
                  else if Plans(G) = R then
                     Rs := Rs + 1;
                  end if;
                  end if;
               end if;
            end loop;
            if (As > Rs) then
               MajorityPlan(G) := A;
               Put_Line(" " & Node_ID'Image(MyID) & " thinks " &
                        Node_ID'Image(G) & " attacks");
            else
               MajorityPlan(G) := R;
               Put_Line(" " & Node_ID'Image(MyID) & " thinks " &
                        Node_ID'Image(G) & " retreats");
            end if;
         end if;
      end loop;

      As := 0;
      Rs := 0;
      MajorityPlan(MyID) := Plans(MyID);
      for G1 in Node_ID loop
         if MajorityPlan(G1) = A then
            As := As + 1;
         else
            Rs := Rs + 1;
         end if;
      end loop;
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
      Node(J).Init(J, J=1);
   end loop;
end BG;
