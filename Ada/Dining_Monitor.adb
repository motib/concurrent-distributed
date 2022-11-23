-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Text_IO; use Text_IO;
with Phil_Monitor; use Phil_Monitor; 
procedure Dining_Monitor is

  type Node_ID is range 0..4;

  task type Nodes is
    entry Init(ID: Node_ID);
  end Nodes;

  Node: array(Node_ID) of Nodes;

  task body Nodes is
    I:           Node_ID;
  begin
    accept Init(ID: Node_ID) do
      I := ID;
    end Init;
    for M in 1..5 loop
      Put_Line(" " & Node_ID'Image(I) & " thinking");
      Take_Fork(Integer(I));
      Put_Line(" " & Node_ID'Image(I) & " critical section");
      Release_Fork(Integer(I));
      Put_Line(" " & Node_ID'Image(I) & " forks released");
    end loop;
  end Nodes;

begin
  for J in Node_ID loop
    Node(J).Init(J);
  end loop;
end Dining_Monitor;
