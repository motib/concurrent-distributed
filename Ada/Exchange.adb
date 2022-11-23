-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Text_IO; use Text_IO;
with Hardware_Primitives; use Hardware_Primitives;
procedure Exchange is

  task T1;
  task body T1 is
    L: Integer := 0;
  begin
    loop
      Put_Line("Task 1 is idling");
      loop
        Exchange(L);
        exit when L = 0;
      end loop;
      Put_Line("Task 1 critical section");
      Exchange(L);
    end loop;
  end T1;

  task T2;
  task body T2 is
    L: Integer := 0;
  begin
    loop
      Put_Line("Task 2 is idling");
      loop
        Exchange(L);
        exit when L = 0;
      end loop;
      Put_Line("Task 2 critical section");
      Exchange(L);
    end loop;
  end T2;

  task T3;
  task body T3 is
    L: Integer := 0;
  begin
    loop
      Put_Line("Task 3 is idling");
      loop
        Exchange(L);
        exit when L = 0;
      end loop;
      Put_Line("Task 3 critical section");
      Exchange(L);
    end loop;
  end T3;

begin
  null;
end Exchange;
