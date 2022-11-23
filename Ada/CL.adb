-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Semaphore_Package; use Semaphore_Package;
with Text_IO; use Text_IO; 
procedure CL is

  type Node_Count is range 0..4;
  subtype Node_ID is Node_Count range 1..Node_Count'Last;
  Print: Binary_Semaphore := Init(1);

  task type Nodes is
    entry Init(ID: Node_ID; N_I, N_O: Node_Count);
    entry Configure(C: Node_ID);
    entry Message(M: Integer; ID: Node_ID);
  end Nodes;

  Node: array(Node_ID) of Nodes;

  task body Nodes is

    type Edge is
      record
        Exists:  Boolean := False;
        Last_Message: Integer := 0;
        Recorded_State: Integer := 0;
        Marker_State:   Integer := -1;
      end record;

    Incoming: array(Node_ID) of Edge;
    Outgoing: array(Node_ID) of Edge;
    N_In, N_Out: Node_Count := 0;
    S: Binary_Semaphore := Init(1);
    Received_ID: Node_ID;
    Received_Data: Integer;
    State_Recorded: Boolean := False;
    I: Node_ID;

    pragma Volatile(Incoming);
    pragma Volatile(State_Recorded);

    procedure Send_Messages(Data: Integer) is
    begin
      for J in Node_ID loop
        if Outgoing(J).Exists then
           Wait(S);
           if Data >= 0 then
             Outgoing(J).Last_Message := Data;
           elsif not State_Recorded then
             Outgoing(J).Recorded_State := Outgoing(J).Last_Message;
           end if;
           Signal(S);
           Node(J).Message(Data, I);
        end if;
      end loop;
    end Send_Messages;

    procedure Record_State is
    begin
      if not State_Recorded then
        Wait(S);
        for J in Node_ID loop
          if Incoming(J).Exists then
            Incoming(J).Recorded_State := Incoming(J).Last_Message;
          end if;
        end loop;
        Signal(S);
        Send_Messages(-1);
        State_Recorded := True;
      end if;
    end Record_State;

    function Write_State return Boolean is
    begin
      if not State_Recorded then return False; end if;
      for J in Node_ID loop
        if Incoming(J).Exists and Incoming(J).Marker_State < 0 then
          return False;
        end if;
      end loop;

      Wait(Print);
      Put_Line(" Node " & Node_ID'Image(I) );
      Put_Line("       Outgoing channels");
      for J in Node_ID loop
        if Outgoing(J).Exists then
          Put_Line("         " & Node_ID'Image(J) & " sent 1.." &
                   Integer'Image(Outgoing(J).Recorded_State));
        end if;
      end loop;

      Put_Line("       Incoming  channels");
      for J in Node_ID loop
        if Incoming(J).Exists then
          Put("         " & Node_ID'Image(J) &
            " received 1.." & Integer'Image(Incoming(J).Recorded_State));
          if Incoming(J).Recorded_State /= Incoming(J).Marker_State then
            Put_Line(" stored " & Integer'Image(Incoming(J).Recorded_State+1) &
            " to " & Integer'Image(Incoming(J).Marker_State));
          else
           New_Line;
         end if;
        end if;
      end loop;
      Signal(Print);
      return True;
    end Write_State;

    task Main_Process is
      entry Init;
    end Main_Process;

    task body Main_Process is
    begin
      accept Init;
      for J in 1..9 loop
        Send_Messages(J);
        case I is
          when 2 | 3 => null;
          when 1 => if J = 6 then Record_State; end if;
          when 4 => if J = 3 then Record_State; end if;
        end case;
      end loop;
      loop 
        exit when Write_State; 
        delay 0.01;
      end loop;
    end Main_Process;

  begin
    accept Init(ID: Node_ID; N_I, N_O: Node_Count) do
      I := ID;
      N_In  := N_I;
      N_Out := N_O;
    end Init;
    for J in 1..N_In loop
      accept Configure(C: Node_ID) do
        Incoming(C).Exists := True;
      end Configure;
    end loop;
    for J in 1..N_Out loop
      accept Configure(C: Node_ID) do
        Outgoing(C).Exists := True;
      end Configure;
    end loop;

    Main_Process.Init;

    loop
      select
        accept Message(M: Integer; ID: Node_ID) do
          Received_ID := ID;
          Received_Data := M;
        end Message;
        if Received_Data < 0 then
          if Incoming(Received_ID).Marker_State < 0 then
            Incoming(Received_ID).Marker_State := 
              Incoming(Received_ID).Last_Message;
          if not State_Recorded then Record_State; end if;
          end if;
        else
          Wait(S);
          Incoming(Received_ID).Last_Message := Received_Data;
          Signal(S);
        end if;
      or
        terminate;
      end select;
    end loop;
  end Nodes;

begin
  Node(1).Init(1,0,2);
  Node(1).Configure(2); Node(1).Configure(3);

  Node(2).Init(2,2,2);
  Node(2).Configure(1); Node(2).Configure(3);
  Node(2).Configure(3); Node(2).Configure(4);

  Node(3).Init(3,3,1); 
  Node(3).Configure(1); Node(3).Configure(2);
  Node(3).Configure(4); Node(3).Configure(2);

  Node(4).Init(4,1,1); 
  Node(4).Configure(2); Node(4).Configure(3);
end CL;
