-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg

-- Ricart-Agrawala token algorithm for distributed mutual exclusion
-- Uses FIFO buffers to emulate channels
with FIFO_Buffers;
with Ada.Text_IO; use Ada.Text_IO;
procedure RA_Token is
   pragma Time_Slice(0.01);

   Procs: Integer := 0;
   pragma Atomic(Procs);

   type Node_Count is range 0..4;
   subtype Node_ID is Node_Count range 1..Node_Count'Last;

   type Buffer_Index is mod 4;

   type Request is
      record
         From: Node_ID;
         Num: Integer;
      end record;

   type IntForNode is array(Node_ID) of Integer;

   package Request_Buffers is new FIFO_Buffers(Buffer_Index, Request);
   package Token_Buffers is new FIFO_Buffers(Buffer_Index, IntForNode);

   Request_Buffer: array(Node_ID) of Request_Buffers.Buffer;
   Token_Buffer: array(Node_ID) of Token_Buffers.Buffer;

   protected type Node_Data is
      procedure SetGranted(G: in IntForNode);
      procedure SetInGranted(N: Node_ID; V: Integer);
      procedure SetRequested(R: in IntForNode);
      procedure SetInRequested(N: Node_ID; V: Integer);
      procedure GetTokenToSend(Dest: out Node_Count; Grant: out IntForNode);
      procedure SetHaveToken(T: Boolean);
      function GetHaveToken return Boolean;
      procedure SetInCS(T: Boolean);
      function GetInCS return Boolean;
      entry Lock;
      procedure Unlock;
   private
      Requested: IntForNode := (others => 0);
      Granted: IntForNode := (others => 0);
      Have_Token: Boolean := False;
      InCS: Boolean := False;
      Locked: Boolean := False;
   end Node_Data;

   protected body Node_Data is
      procedure SetGranted(G: in IntForNode) is
      begin
         Granted := G;
      end SetGranted;

      procedure SetInGranted(N: Node_ID; V: Integer) is
      begin
         Granted(N) := V;
      end SetInGranted;

      procedure SetRequested(R: in IntForNode) is
      begin
         Requested := R;
      end SetRequested;

      procedure SetInRequested(N: Node_ID; V: Integer) is
      begin
         if (Requested(N)<V) then
           Requested(N) := V;
         end if;
      end SetInRequested;

      procedure GetTokenToSend(Dest: out Node_Count; Grant: out IntForNode) is
      begin
         for N in Node_ID loop
            if Requested(N) > Granted(N) then
               Grant := Granted;
               Dest := N;
               Have_Token := False;
               return;
            end if;
         end loop;
         Dest := 0;
      end GetTokenToSend;

      procedure SetHaveToken(T: Boolean) is
      begin
         Have_Token := T;
      end SetHaveToken;

      function GetHaveToken return Boolean is
      begin
         return Have_Token;
      end GetHaveToken;

      procedure SetInCS(T: Boolean) is
      begin
         InCS := T;
      end SetInCS;

      function GetInCS return Boolean is
      begin
         return InCS;
      end GetInCS;

      entry Lock when Locked = False is
      begin
         Locked := True;
      end Lock;

      procedure Unlock is
      begin
         Locked := False;
      end Unlock;
   end Node_Data;

   Data: array(Node_ID) of Node_Data;

   task type Nodes is
      entry Init(ID: Node_ID);
   end Nodes;
   task body Nodes is
      MyID: Node_ID;
      MyNum: Integer := 0;
      G: IntForNode;
      R: Request;
      D: Node_Count;
   begin
      accept Init(ID: Node_ID) do
         MyID := ID;
      end Init;
      loop
         Put_Line(" " & Node_ID'Image(MyID) & " non-critical section" );
         Data(MyID).Lock;
         Put_Line(" " & Node_ID'Image(MyID) & " trying to enter critical section");

         if not Data(MyID).GetHaveToken then
            MyNum := MyNum + 1;
            R.From := MyID;
            R.Num := MyNum;
            Data(MyID).Unlock;
            Put_Line(" " & Node_ID'Image(MyID) & " requesting" );
            for N in Node_ID loop
               if N /= MyID then
                  Request_Buffer(N).Put(R);
               end if;
            end loop;
            Put_Line(" " & Node_ID'Image(MyID) & " requested" );
            Token_Buffer(MyID).Get(G);
            Data(MyID).Lock;
            Data(MyID).SetGranted(G);
            Data(MyID).SetHaveToken(True);
            Put_Line(" " & Node_ID'Image(MyID) & " got token");
         end if;
         Data(MyID).SetInCS(True);
         Data(MyID).Unlock;
         Put_Line(" " & Node_ID'Image(MyID) & " critical section");
         Procs := Procs + 1;

         if (Procs > 1) then
            Put_Line("MUTEX FAIL");
         end if;

         Procs := Procs - 1;
         Data(MyID).Lock;
         Put_Line(" " & Node_ID'Image(MyID) & " leaving critical section");
         Data(MyID).SetInGranted(MyID, MyNum);
         Data(MyID).SetInCS(False);

         Data(MyID).GetTokenToSend(D, G);
         Data(MyID).Unlock;
         if D > 0 then
            Put_Line(" " & Node_ID'Image(MyID) & " done, sending token to" &
                     Node_ID'Image(D));
            Token_Buffer(D).Put(G);
            Put_Line(" " & Node_ID'Image(MyID) & " sent token");
         end if;
      end loop;
   end Nodes;

   task type Receive_Nodes is
      entry Init(ID: Node_ID);
   end Receive_Nodes;
   task body Receive_Nodes is
      MyID: Node_ID;
      G: IntForNode;
      R: Request;
      D: Node_Count;
   begin
      accept Init(ID: Node_ID) do
         MyID := ID;
      end Init;
      loop
         Request_Buffer(MyID).Get(R);
         Data(MyID).Lock;
         Data(MyID).SetInRequested(R.From, R.Num);
         Put_Line(" " & Node_ID'Image(MyID) & " got request from " &
                  Node_ID'Image(R.From));
         if Data(MyID).GetHaveToken and not Data(MyID).GetInCS then
            Data(MyID).GetTokenToSend(D, G);
            if D > 0 then
               Put_Line(" " & Node_ID'Image(MyID) & " sending token to" &
                        Node_ID'Image(D) & " rec ");
               Token_Buffer(D).Put(G);
               Put_Line(" " & Node_ID'Image(MyID) & " sent token (rec)");
            end if;
         else
            Put_Line(" " & Node_ID'Image(MyID) & " can't send token");
         end if;
         Data(MyID).Unlock;
      end loop;
   end Receive_Nodes;

   Node: array(Node_ID) of Nodes;
   Receive: array(Node_ID) of Receive_Nodes;

begin
   Data(1).SetHaveToken(True);
   for J in Node_ID loop
      Node(J).Init(J);
      Receive(J).Init(J);
   end loop;
end RA_Token;
