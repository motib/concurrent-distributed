-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
with Semaphore_Package; use Semaphore_Package;
with Text_IO; use Text_IO;
procedure RA is

  type Node_Count is range 0..4;
  subtype Node_ID is Node_Count range 1..Node_Count'Last;

  task type Nodes is
    entry Init(ID: Node_ID);
    entry Request_Message(Num: Integer; ID: Node_ID);
    entry Reply_Message;
  end Nodes;

  Node: array(Node_ID) of Nodes;

  task body Nodes is

    Number:      Integer          := 0;
    High_Number: Integer          := 0;
    Requesting:  Boolean          := False;
    Reply_Count: Node_Count       := 0;
    S:           Binary_Semaphore := Init(1);
    Wake_Up:     Binary_Semaphore := Init(0);
    Deferred:    array(Node_ID) of Boolean := (others => False);
    I:           Node_ID;
    Received_Number: Integer;
    Received_ID:     Node_ID;

    pragma Volatile(Number);
    pragma Volatile(High_Number);
    pragma Volatile(Requesting);
    pragma Volatile(Reply_Count);
    pragma Volatile(Deferred);

    task Main_Process is
      entry Init;
    end Main_Process;

    task body Main_Process is

      procedure Choose_Number is
      begin
        Wait(S);
        Requesting := True;
        Number := High_Number + 1;
        Signal(S);
      end Choose_Number;

      procedure Send_Request is
        begin
        Reply_Count := 0;
        for J in Node_ID loop
          if J /= I then
            Node(J).Request_Message(Number, I);
            Put_Line(" " & Node_ID'Image(I) & " sending request to " &
                Node_ID'Image(J) & " with number " &
                Integer'Image(Number));
          end if;
        end loop;
      end Send_Request;

      procedure Reply_to_Deferred_Nodes is
      begin
        Wait(S);
        Requesting := False;
        Signal(S);
        for J in Node_ID loop
          if Deferred(J) then
            Put_Line(" " & Node_ID'Image(I) & " sending deferred reply to " &
                     Node_ID'Image(J));
            Deferred(J) := False;
            Node(J).Reply_Message;
          end if;
        end loop;
      end Reply_to_Deferred_Nodes;

    begin
      accept Init;
      for M in 1..3 loop
        Put_Line(" " & Node_ID'Image(I) & " non-critical section" );
        Choose_Number;
        Send_Request;
        Wait(Wake_Up);
        Put_Line(" " & Node_ID'Image(I) & " critical section");
        Reply_to_Deferred_Nodes;
        Put_Line(" " & Node_ID'Image(I) & " replied to deferred nodes");
      end loop;
    end Main_Process;

    procedure Received_Request is
      Decide_to_Defer: Boolean;
    begin
        Put_Line(" " & Node_ID'Image(I) & " with number " &
           Integer'Image(Number) & " received request from " &
           Node_ID'Image(Received_ID) & " with number " &
           Integer'Image(Received_Number));
        if Received_Number > High_Number then
          High_Number := Received_Number;
        end if;
        Wait(S);
        Decide_to_Defer := Requesting and
             ( Number < Received_Number or
              (Number = Received_Number and
               I < Received_ID) );
        if Decide_to_Defer then
          Deferred(Received_ID) := True;
          Put_Line(" " & Node_ID'Image(I) & " decides to defer " &
                   Node_ID'Image(Received_ID));
          Signal(S);
        else
          Put_Line(" " & Node_ID'Image(I) & " sending reply to " &
                Node_ID'Image(Received_ID));
          Signal(S);
          Node(Received_ID).Reply_Message;
        end if;
    end Received_Request;

  begin
    accept Init(ID: Node_ID) do
      I := ID;
      Main_Process.Init;
    end Init;
    loop
      select
        accept Request_Message(Num: Integer; ID: Node_ID) do
          Received_Number := Num;
          Received_ID     := ID;
        end Request_Message;
        Received_Request;
      or
        accept Reply_Message;
        Reply_Count := Reply_Count + 1;
        if Reply_Count = Node_ID'Last - 1 then Signal(Wake_Up); end if;
      or
        terminate;
      end select;
    end loop;
  end Nodes;

begin
  for J in Node_ID loop
    Node(J).Init(J);
  end loop;
end RA;
