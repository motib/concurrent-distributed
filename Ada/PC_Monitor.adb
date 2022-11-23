-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Monitor_Package; use Monitor_Package;
package body PC_Monitor is

  Not_Empty, Not_Full: Condition;

  N:        constant Integer := 10;

  Buffer:   array(0..N-1) of Integer;
  In_Ptr,Out_Ptr:   Integer := 0;
  Count:  Integer := 0;

  procedure Append(V: in Integer) is
  begin
    Monitor.Enter;
    if Count = Buffer'Length then
       Monitor.Leave;
       Not_Full.Wait;
    end if;
    Buffer(In_Ptr) := V;
    In_Ptr := (In_Ptr + 1) mod N;
    Count := Count + 1;
    Not_Empty.Signal;
  end Append;

  procedure Take(V: out Integer) is
  begin
    Monitor.Enter;
    if Count = 0 then
      Monitor.Leave;
      Not_Empty.Wait;
    end if;
    V := Buffer(Out_Ptr);
    Out_Ptr := (Out_Ptr + 1) mod N;
    Count := Count - 1;
    Not_Full.Signal;
  end Take;

end PC_Monitor;
