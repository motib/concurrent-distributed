program Bakery;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

const NODES = 3;
var   Choosing: array[1..NODES] of boolean;
      Number:   array[1..NODES] of integer;

  function Max: integer;
  var Current: Integer := 0;
      I: Integer;
  begin
    for I := 1 to NODES do
      if Number[I] > Current then
        Current := Number[I];
    Max := Current;
  end;

    procedure p(i: integer);
    var j: integer;
    begin
        while true do
          begin
          writeln("Process ", i, " non-critical section");
          choosing[i] := true;
          number[i] := 1 + Max;
          choosing[i] := false;
          for j := 1 to NODES do
            if j <> i then
              begin
              repeat until choosing[j] = false;
              repeat until 
                 (number[j] = 0) or (number[i] < number[j]) or
                 ((number[i] = number[j]) and (i < j));
              end;
          writeln("Process ", i, " critical section");
          number[i] := 0;
          end;
    end;

var j: integer;
begin
  for j := 1 to NODES do choosing[j] := false;
  for j := 1 to NODES do number[j] := 0;
  cobegin
    p(1); p(2); p(3);
  coend;
end.
