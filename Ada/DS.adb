-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Semaphore_Package; use Semaphore_Package;
with Text_IO; use Text_IO; 
procedure DS is

  type Node_Count is range 0..4;
  subtype Node_ID is Node_Count range 1..Node_Count'Last;

  task type Nodes is
    entry Init(ID: Node_ID; N_I, N_O: Node_Count);
    entry Configure(C: Node_ID);
    entry Message(M: Integer; ID: Node_ID);
    entry Signal(ID: Node_ID);
  end Nodes;

  Node: array(Node_ID) of Nodes;

  task body Nodes is

    type Edge is
      record
        Exists:  Boolean := False;
        Deficit: Natural := 0;
      end record;

    Incoming: array(Node_ID) of Edge;
    Outgoing: array(Node_ID) of Edge;
    First_Edge:  Node_Count := 0;
    N_In, N_Out: Node_Count := 0;
    N_Signals:   Natural := 0;

    pragma Volatile(N_Signals);
    pragma Volatile(First_Edge);
    pragma Volatile(Incoming);

    I: Node_ID;
    S: Binary_Semaphore := Init(1);
    Received_ID: Node_ID;

    task Main_Process is
      entry Init;
    end Main_Process;

    task body Main_Process is
      Count: Integer := 0;

      procedure Send_Messages is
      begin
        for J in Node_ID loop
          if Outgoing(J).Exists then
             Put_Line("  " & Node_ID'Image(I) & " sending  " &
                     Integer'Image(Count) & " to   " &
                     Node_ID'Image(J));
             Wait(S);
             N_Signals := N_Signals + 1;
             Signal(S);
             Node(J).Message(Count, I);
          end if;
        end loop;
      end Send_Messages;

      function Decide_to_Terminate return Boolean is

        procedure Send_Signals(ID: Node_ID) is
        begin
          while Incoming(ID).Deficit > 0 loop
            Incoming(ID).Deficit := Incoming(ID).Deficit - 1;
            Put_Line("  " & Node_ID'Image(I) & " sending signal to " &
                     Node_ID'Image(ID));
            Signal(S);
            Node(ID).Signal(I);
            Wait(S);
          end loop;
        end Send_Signals;

      begin
        for J in Node_ID loop
          if  J /= First_Edge then
            Wait(S);
            Send_Signals(J);
            Signal(S);
          end if;
        end loop;

        Wait(S);
        if N_Signals = 0 then
          if I = 1 then
            Put_Line("  " & Node_ID'Image(I) & " program terminated ");
          elsif First_Edge /= 0 then
            Send_Signals(First_Edge);
            First_Edge := 0;
          end if;
          Signal(S);
          return True;
        else 
          Signal(S);
          return False;
        end if;
      end Decide_to_Terminate;

    begin
      accept Init;
      if I = 1 then 
        Send_Messages;
        Send_Messages;
        loop
          exit when Decide_to_Terminate;
          delay 0.01;
        end loop;
      else
        loop
          loop 
            exit when First_Edge /= 0;
            delay 0.01;
          end loop;
          if Count < 5 then
            Count := Count + 1;
            Send_Messages;
          end if;
          loop
            exit when not Decide_to_Terminate or First_Edge /= 0;
            delay 0.01;
          end loop;
        end loop;
      end if;
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
          Put_Line("  " & Node_ID'Image(I) & " received " &
                   Integer'Image(M) & " from " &
                   Node_ID'Image(ID));
          Received_ID := ID;
        end Message;
        if First_Edge = 0 then
          First_Edge := Received_ID;
        end if;
        Wait(S);
        Incoming(Received_ID).Deficit := Incoming(Received_ID).Deficit + 1;
        Signal(S);
      or
        accept Signal(ID: Node_ID) do
          Put_Line("  " & Node_ID'Image(I) & " received signal from " &
                   Node_ID'Image(ID));
          Received_ID := ID;
        end Signal;
        Wait(S);
        N_Signals := N_Signals - 1;
        Signal(S);
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
end DS;
