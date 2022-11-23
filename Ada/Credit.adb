-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Mattern's credit-recovery algorithm for distributed termination
-- Uses FIFO buffers to emulate channels
with FIFO_Buffers;
with Ada.Text_IO; use Ada.Text_IO;
procedure Credit is
   pragma Time_Slice(0.01);

   Procs: Integer := 0;
   pragma Atomic(Procs);

   Messages: Integer := 10;

   type Node_Count is range 0..3;
   subtype Node_ID is Node_Count range 1..Node_Count'Last;

   type Buffer_Index is mod 5;

   package Buffers is new FIFO_Buffers(Buffer_Index, Float);

   Message_Buffer: array(Node_Count) of Buffers.Buffer;
   Signal_Buffer: Buffers.Buffer;

   protected type Node_Lock is
      entry Lock;
      procedure Unlock;
   private
      Locked: Boolean := False;
   end Node_Lock;

   protected body Node_Lock is
      entry Lock when Locked = False is
      begin
         Locked := True;
      end Lock;

      procedure Unlock is
      begin
         Locked := False;
      end Unlock;
   end Node_Lock;

   type Node_Data is
     record
        Parent: Node_Count := 0;
        Weight: Float := 0.0;
        Active: Boolean := False;
        Terminated: Boolean := False;
     end record;

   Data: array(Node_ID) of Node_Data;
   Lock: array(Node_ID) of Node_Lock;

   type Edge_List is array(Integer range 0..1) of Node_Count;

   task Env is
      entry Init(Edges: Edge_List);
   end Env;
   task body Env is
      E: Edge_List;
      W: Float;
      Weight: Float := 1.0;
   begin
      accept Init(Edges: Edge_List) do
         E := Edges;
      end Init;
      for J in E'Range loop
         Weight := Weight / 2.0;
         Put_Line("Env sending " & Float'Image(Weight) & " to " &
                  Node_ID'Image(E(J)));
         Message_Buffer(E(J)).Put(Weight);
      end loop;
      while Weight < 1.0 loop
         Signal_Buffer.Get(W);
         Put_Line("Env got " & Float'Image(W));
         Weight := Weight + W;
         Put_Line("Env has " & Float'Image(Weight));
      end loop;
      Put_Line("System terminated");
   end Env;

   task type Send_Nodes is
      entry Init(ID: Node_ID; Edges: Edge_List);
      entry Activate;
   end Send_Nodes;
   task body Send_Nodes is
      MyID: Node_ID;
      Next_Send: Integer := 0;
      E: Edge_List;
   begin
      accept Init(ID: Node_ID; Edges: Edge_List) do
         MyID := ID;
         E := Edges;
      end Init;
      accept Activate;
      for M in 1..Messages loop
         Lock(MyID).Lock;
         Data(MyID).Weight := Data(MyID).Weight / 2.0;
         Put_Line(" " & Node_ID'Image(MyID) & " sending " &
                  Float'Image(Data(MyID).Weight) & " to " &
                  Node_ID'Image(E(Next_Send)));
         Lock(MyID).Unlock;
         Message_Buffer(E(Next_Send)).Put(Data(MyID).Weight);
         Put_Line(" " & Node_ID'Image(MyID) & " sent");
         Next_Send := Next_Send + 1;

         if Next_Send > E'Last then
            Next_Send := 0;
         end if;

         if E(Next_Send) = 0 then
            Next_Send := 0;
         end if;
         Put_Line(" " & Node_ID'Image(MyID) & " send done ");
      end loop;

      Lock(MyID).Lock;
      Put_Line(" " & Node_ID'Image(MyID) & " sending " &
               Float'Image(Data(MyID).Weight) & " to env");
      Signal_Buffer.Put(Data(MyID).Weight);
      Data(MyID).Weight := 0.0;
      Data(MyID).Active := False;
      Data(MyID).Terminated := True;
      Lock(MyID).Unlock;
      Put_Line(" " & Node_ID'Image(MyID) & " done sending");
   end Send_Nodes;

   Send: array(Node_ID) of Send_Nodes;

   task type Receive_Nodes is
      entry Init(ID: Node_ID);
   end Receive_Nodes;
   task body Receive_Nodes is
      MyID: Node_ID;
      W: Float;
   begin
      accept Init(ID: Node_ID) do
         MyID := ID;
      end Init;
      loop
         Put_Line(" " & Node_ID'Image(MyID) & " waiting for message");
         Message_Buffer(MyID).Get(W);
         Put_Line(" " & Node_ID'Image(MyID) & " got " & Float'Image(W));
         Lock(MyID).Lock;
         if Data(MyID).Terminated or Data(MyID).Active then
            Put_Line(" " & Node_ID'Image(MyID) & " passing " &
                     Float'Image(W) & " to env");
            Signal_Buffer.Put(W);
         else
            Put_Line(" " & Node_ID'Image(MyID) & " activating ");
            Send(MyID).Activate;
            Data(MyID).Active := True;
            Data(MyID).Weight := W;
            Put_Line(" " & Node_ID'Image(MyID) & " has " &
                     Float'Image(Data(MyID).Weight));
         end if;
         Lock(MyID).Unlock;
      end loop;
   end Receive_Nodes;

   Receive: array(Node_ID) of Receive_Nodes;

begin
   Env.Init((1, 2));
   Send(1).Init(1, (2, 3));
   Send(2).Init(2, (1, 0));
   Send(3).Init(3, (2, 0));
   for J in Node_ID loop
      Receive(J).Init(J);
   end loop;
end Credit;
