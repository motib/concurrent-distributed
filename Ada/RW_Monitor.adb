-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Monitor_Package; use Monitor_Package;
package body RW_Monitor is

  OK_to_Read, OK_to_Write: Condition;

  Readers: Integer := 0;
  Writing: Boolean := False;

  procedure Start_Read is
  begin
    Monitor.Enter;
    if Writing or Non_Empty(OK_to_Write) then
       Monitor.Leave;
       OK_to_Read.Wait;
    end if;
    Readers := Readers + 1;
    OK_to_Read.Signal;
  end Start_Read;

  procedure Stop_Read is
  begin
    Monitor.Enter;
    Readers := Readers - 1;
    if Readers = 0 then
       OK_to_Write.Signal;
    else
       Monitor.Leave;
    end if;
  end Stop_Read;

  procedure Start_Write is
  begin
    Monitor.Enter;
    if Readers /= 0 or Writing then
       Monitor.Leave;
       OK_to_Write.Wait;
    end if;
    Writing := True;
    Monitor.Leave;
  end Start_Write;

  procedure Stop_Write is
  begin
    Monitor.Enter;
    if Non_Empty(OK_to_Read) then
       OK_to_Read.Signal;
    else
       OK_to_Write.Signal;
    end if;
  end Stop_Write;

end RW_Monitor;
