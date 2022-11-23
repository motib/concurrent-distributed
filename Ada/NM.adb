-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Neilsen-Mizuno token algorithm for distributed mutual exclusion
-- Uses FIFO buffers to emulate channels
with FIFO_Buffers;
with Ada.Text_IO; use Ada.Text_IO;
procedure NM is
   pragma Time_Slice(0.01);

   Procs: Integer := 0;
   pragma Atomic(Procs);

   type Node_Count is range 0..5;
   subtype Node_ID is Node_Count range 1..Node_Count'Last;

   type Buffer_Index is mod 5;

   type Request is
      record
         From: Node_ID;
         Origin: Node_ID;
      end record;

   type Token is (Token_Value);

   package Request_Buffers is new FIFO_Buffers(Buffer_Index, Request);
   package Token_Buffers is new FIFO_Buffers(Buffer_Index, Token);

   Request_Buffer: array(Node_ID) of Request_Buffers.Buffer;
   Token_Buffer: array(Node_ID) of Token_Buffers.Buffer;

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
        Parent: Node_Count;
        Deferred: Node_Count := 0;
        Holding: Boolean := False;
     end record;

   Data: array(Node_ID) of Node_Data;
   Lock: array(Node_ID) of Node_Lock;

   task type Nodes is
      entry Init(ID: Node_ID);
   end Nodes;
   task body Nodes is
      MyID: Node_ID;
      R: Request;
      T: Token := Token_Value;
   begin
      accept Init(ID: Node_ID) do
         MyID := ID;
      end Init;
      loop
         Put_Line(" " & Node_ID'Image(MyID) & " non-critical section" );

         Lock(MyID).Lock;
         Put_Line(" " & Node_ID'Image(MyID) & " trying to enter critical section");
         if not Data(MyID).Holding then
            R.From := MyID;
            R.Origin := MyID;
            Put_Line(" " & Node_ID'Image(MyID) & " requesting" );
            Request_Buffer(Data(MyID).Parent).Put(R);
            Put_Line(" " & Node_ID'Image(MyID) & " requested" );
            Data(MyID).Parent := 0;
            Token_Buffer(MyID).Get(T);
            Put_Line(" " & Node_ID'Image(MyID) & " got token");
         end if;

         Data(MyID).Holding := False;
         Lock(MyID).Unlock;

         Put_Line(" " & Node_ID'Image(MyID) & " critical section");
         Procs := Procs + 1;

         if (Procs > 1) then
            Put_Line("MUTEX FAIL");
         end if;

         Procs := Procs - 1;

         Lock(MyID).Lock;
         Put_Line(" " & Node_ID'Image(MyID) & " leaving critical section");
         if Data(MyID).Deferred /=0 then
            Put_Line(" " & Node_ID'Image(MyID) & " done, sending token to" &
                     Node_ID'Image(Data(MyID).Deferred));
            Token_Buffer(Data(MyID).Deferred).Put(T);
            Put_Line(" " & Node_ID'Image(MyID) & " sent token");
            Data(MyID).Deferred := 0;
         else
            Data(MyID).Holding := True;
         end if;

         Lock(MyID).Unlock;
      end loop;
   end Nodes;

   task type Receive_Nodes is
      entry Init(ID: Node_ID);
   end Receive_Nodes;
   task body Receive_Nodes is
      MyID: Node_ID;
      R: Request;
      T: Token := Token_Value;
      Source: Node_ID;
   begin
      accept Init(ID: Node_ID) do
         MyID := ID;
      end Init;
      loop
         Request_Buffer(MyID).Get(R);
         Source := R.From;
         Lock(MyID).Lock;
         if Data(MyID).Parent = 0 then
            if Data(MyID).Holding then
               Put_Line(" " & Node_ID'Image(MyID) & " sending token to" &
                     Node_ID'Image(R.Origin) & " (rec)");
               Token_Buffer(R.Origin).Put(T);
               Put_Line(" " & Node_ID'Image(MyID) & " sent token (rec)");
               Data(MyID).Holding := False;
            else
               Data(MyID).Deferred := R.Origin;
            end if;
         else
            R.From := MyID;
            Request_Buffer(Data(MyID).Parent).Put(R);
         end if;
         Data(MyID).Parent := Source;
         Lock(MyID).Unlock;
      end loop;
   end Receive_Nodes;

   Node: array(Node_ID) of Nodes;
   Receive: array(Node_ID) of Receive_Nodes;

begin
   Data(1).Holding := True;
   for J in Node_ID loop
      Data(J).Parent := J/2;
      Node(J).Init(J);
      Receive(J).Init(J);
   end loop;
end NM;
