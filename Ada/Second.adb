-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Text_IO; use Text_IO;
procedure Second is
  pragma Time_Slice(0.01);

  C1, C2: Integer := 1;
  pragma Volatile(C1);
  pragma Volatile(C2);

  task T1;
  task body T1 is
  begin
    loop
      Put_Line("Task 1 idling");
      loop exit when C2 /= 0; end loop;
      Put_Line("Task 1 entering critical section");
      C1 := 0;
      Put_Line("Task 1 in critical section");
      C1 := 1;
    end loop;
  end T1;

  task T2;
  task body T2 is
  begin
    loop
      Put_Line("Task 2 idling");
      loop exit when C1 /= 0; end loop;
      Put_Line("Task 2 entering critical section");
      C2 := 0;
      Put_Line("Task 2 in critical section");
      C2 := 1;
    end loop;
  end T2;

begin
  null;
end Second;
