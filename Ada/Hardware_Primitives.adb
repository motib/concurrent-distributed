-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
package body Hardware_Primitives is

  task TS_Task is
    entry Test_and_Set(L: out Integer);
    entry Zero;
  end TS_Task;

  task EX_Task is
    entry Exchange(L: in out Integer);
  end EX_Task;

  task body TS_Task is
    C: Integer := 0;
  begin
    loop
      select
        accept Test_and_Set(L: out Integer) do
          L := C;
          C := 1;
        end Test_and_Set;
      or 
        accept Zero do
          C := 0;
        end Zero;
      or
        terminate;
      end select;
    end loop;
  end TS_Task;

  task body EX_Task is
    C: Integer := 1;
    Temp: Integer;
  begin
    loop
      select
        accept Exchange(L: in out Integer) do
          Temp := L;
          L := C;
          C := Temp;
        end Exchange;
      or
        terminate;
      end select;
    end loop;
  end EX_Task;

  procedure Test_and_Set(L: out Integer) is
  begin
    TS_Task.Test_and_Set(L);
  end Test_and_Set;

  procedure Zero is
  begin
    TS_Task.Zero;
  end Zero;

  procedure Exchange(L: in out Integer) is
  begin
    EX_Task.Exchange(L);
  end Exchange;

end Hardware_Primitives;
