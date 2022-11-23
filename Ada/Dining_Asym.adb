-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Text_IO; use Text_IO;
with Semaphore_Package; use Semaphore_Package;
procedure Dining_Asym is

  type Node_ID is range 0..4;

  Fork: array(Node_ID) of Binary_Semaphore := (others => Init(1));

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
      if I = 4 then Wait(Fork(0)); else Wait(Fork(I)); end if;
      Put_Line(" " & Node_ID'Image(I) & " first fork taken");
      if I = 4 then Wait(Fork(4)); else Wait(Fork((I+1) mod 5)); end if;
      Put_Line(" " & Node_ID'Image(I) & " critical section");
      Signal(Fork(I));
      Put_Line(" " & Node_ID'Image(I) & " first fork released");
      Signal(Fork((I+1) mod 5));
      Put_Line(" " & Node_ID'Image(I) & " second fork released");
    end loop;
  end Nodes;

begin
  for J in Node_ID loop
    Node(J).Init(J);
  end loop;
end Dining_Asym;
