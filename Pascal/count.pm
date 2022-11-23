program count;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

var n: integer := 0;

procedure p;
var temp, i: integer;
begin
  for i := 1 to 10 do
    begin
    temp := n;
    n := temp + 1
    end
end;

procedure q;
var temp, i: integer;
begin
  for i := 1 to 10 do
    begin
    temp := n;
    n := temp + 1
    end
end;

begin
  cobegin p; q coend;
  writeln('The value of n is ', n)
end.