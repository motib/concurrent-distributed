program fast;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

const N = 3;
var gate1: integer := 0;
    gate2: integer := 0;
    want:  array[1..N] of boolean;

process p(I: integer);
var OK: boolean;
    J: integer;
begin
    while true do
      begin
      writeln("Process ", I, " non-critical section");
      OK := false;
      while not OK do
          begin
          want[I] := true;
          gate1 := I;
          if gate2 <> 0 then
            begin
            want[I] := false;
            repeat until gate2 = 0;
            end
          else 
              begin
              gate2 := I;
              if gate1 <> I then
                 begin
                 want[I] := false;
                 for J := 1 to N do
                   repeat until want[J] = false;
                 if gate2 <> I then
                   begin
                   repeat until gate2 = 0; 
                   end
                 else
                   OK := true;
                 end
              else 
                OK := true;
              end
          end;
      writeln("Process ", I, " critical section");
      gate2 := 0;
      want[I] := false;
      end
end;

var J: integer;
begin
  for J := 1 to N do want[J] := false;
  cobegin
    p(1); p(2); p(3);
  coend;
end.

