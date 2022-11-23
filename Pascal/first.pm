program first;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

var turn: integer := 1;

procedure p;
begin
    while true do
      begin
      writeln("Process p non-critical section");
      repeat until turn = 1;
      writeln("Process p critical section");
      turn := 2;
      end;
end;

procedure q;
begin
    while true do
      begin
      writeln("Process q non-critical section");
      repeat until turn = 2;
      writeln("Process q critical section");
      turn := 1;
      end;
end;

begin
  cobegin
    p;
    q
  coend;
end.

