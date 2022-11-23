-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Text_IO; use Text_IO;
procedure First is
  pragma Time_Slice(0.01);

  Turn: Integer := 1;
  pragma Volatile(Turn);

  task T1;
  task body T1 is
  begin
    loop
      Put_Line("Task 1 idling");
      loop exit when Turn = 1; end loop;
      Put_Line("Task 1 critial section");
      Turn := 2;
    end loop;
  end T1;

  task T2;
  task body T2 is
  begin
    loop
      Put_Line("Task 2 idling");
      loop exit when Turn = 2; end loop;
      Put_Line("Task 2 critial section");
      Turn := 1;
    end loop;
  end T2;

begin
  null;
end First;
