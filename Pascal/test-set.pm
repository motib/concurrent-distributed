program ts;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

ATOMIC FUNCTION test_and_set(VAR target : INTEGER ): INTEGER;
    VAR u : INTEGER;
BEGIN
    u := target;
    target := 1;
    test_and_set := u;
END;

var common: integer := 0;

procedure p;
begin
    while true do
      begin
      writeln("Process p non-critical section");
      while (test_and_set(common)) do;
      writeln("Process p critical section");
      common := 0;
      end;
end;

procedure q;
begin
    while true do
      begin
      writeln("Process q non-critical section");
      while (test_and_set(common)) do;
      writeln("Process q critical section");
      common := 0;
      end;
end;

begin
  cobegin
    p;
    q
  coend;
end.

