program ex;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

ATOMIC PROCEDURE exchange(VAR x: integer; VAR y: integer);
    VAR temp: INTEGER;
BEGIN
    temp := x;
    x := y;
    y := temp;
END;

var common: integer := 1;

procedure p;
var local: integer;
begin
    while true do
      begin
      writeln("Process p non-critical section");
      repeat
        exchange(common, local)
      until local = 1;
      writeln("Process p critical section");
      exchange(common, local)
      end;
end;

procedure q;
var local: integer;
begin
    while true do
      begin
      writeln("Process q non-critical section");
      repeat
        exchange(common, local)
      until local = 1;
      writeln("Process q critical section");
      exchange(common, local)
      end;
end;

begin
  cobegin
    p;
    q
  coend;
end.

