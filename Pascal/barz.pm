program barz;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

var gate: binarysem := 1;
    S: binarysem := 1;
    count: integer := 3;

process p(N: integer);
begin
    while true do
      begin
      writeln("Process ", N, " non-critical section");
      wait(gate);
      wait(S);
      count := count - 1;
      if count > 0 then signal(gate);
      signal(S);
      writeln("Process ", N, " critical section");
      wait(S);
      count := count + 1;
      if count = 1 then signal(gate);
      signal(S);
      end
end;

begin
  cobegin
    p(0); p(1); p(2);
  coend;
end.

