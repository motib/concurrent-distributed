program udding;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

var gate1: semaphore := 1;
    gate2: semaphore := 0;
    onlyOne: semaphore := 1;
    numgate1, numgate2: integer := 0;

process p(N: integer);
begin
    while true do
      begin
      writeln("Process ", N, " non-critical section");
      wait(gate1);
      numGate1 := numGate1 + 1;
      signal(gate1);
      wait(onlyOne);
      wait(gate1);
      numGate1 := numGate1 - 1;
      numGate2 := numGate2 + 1;
      if numGate1 > 0 then signal(gate1)
      else signal(gate2);
      signal(onlyOne);
      wait(gate2);
      numGate2 := numGate2 - 1;
      writeln("Process ", N, " critical section");
      if numGate2 > 0 then signal(gate2)
      else signal(gate1);
      end
end;

begin
  cobegin
    p(0); p(1); p(2);
  coend;
end.

