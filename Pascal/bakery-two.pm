program bakerytwo;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

var np: integer := 0;
    nq: integer := 0;

process p;
begin
    while true do
      begin
      writeln("Process p non-critical section");
      np := nq + 1;
      repeat until (nq = 0) or (np <= nq);
      writeln("Process p critical section");
      np := 0;
      end
end;

process q;
begin
    while true do
      begin
      writeln("Process q non-critical section");
      nq := np + 1;
      repeat until (np = 0) or (nq < np);
      writeln("Process q critical section");
      nq := 0;
      end;
end;

begin
  cobegin
    p;
    q
  coend;
end.

