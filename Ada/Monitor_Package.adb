-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
package body Monitor_Package is

  task body Monitor is
  begin
    loop
      accept Enter;
      accept Leave;
    end loop;
  end Monitor;

  task body Condition is
  begin
    loop
      select
        when Wait'Count = 0 =>
          accept Signal do
            Monitor.Leave;
          end Signal;
      or
        accept Wait do
          loop
            select
              accept Signal;
              exit;
            or
              accept Waiting(B: out Boolean) do
                B := True;
              end Waiting;
            end select;
          end loop;
        end Wait;
      or
        accept Waiting(B: out Boolean) do
          B := Wait'Count /= 0;
        end Waiting;
      end select;
    end loop;
  end Condition;

  function Non_Empty(C: Condition) return Boolean is
    B: Boolean;
  begin
    C.Waiting(B);
    return B;
  end Non_Empty;

end Monitor_Package;
