-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Monitor_Package; use Monitor_Package;
package body Phil_Monitor is

  Fork: array(0..4) of Integer := (others => 2);
  OK_to_Eat: array(0..4) of Condition;

  procedure Take_Fork(I: Integer) is
  begin
    Monitor.Enter;
    if Fork(I) /= 2 then
      Monitor.Leave;
      Ok_to_Eat(I).Wait;
    end if;
    Fork((I+1) mod 5) := Fork((I+1) mod 5) - 1;
    Fork((I-1) mod 5) := Fork((I-1) mod 5) - 1;
    Monitor.Leave;
  end Take_Fork;

  procedure Release_Fork(I: Integer) is
  begin
    Monitor.Enter;
    Fork((I+1) mod 5) := Fork((I+1) mod 5) + 1;
    Fork((I-1) mod 5) := Fork((I-1) mod 5) + 1;
    if Fork((I+1) mod 5) = 2 then
      OK_to_Eat((I+1) mod 5).Signal;
    end if;
    if Fork((I-1) mod 5) = 2 then
      OK_to_Eat((I-1) mod 5).Signal;
    end if;
  end Release_Fork;

end Phil_Monitor;
