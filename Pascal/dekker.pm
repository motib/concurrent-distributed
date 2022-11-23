program dekker;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

var wantp: boolean := false;
    wantq: boolean := false;
    turn:  integer := 1;

process p;
begin
    while true do
      begin
      writeln("Process p non-critical section");
      wantp := true;
      while wantq do
        if turn = 2 then
          begin
          wantp := false;
          repeat until turn = 1;
          wantp := true
          end;
      writeln("Process p critical section");
      turn := 2;
      wantp := false;
      end
end;

process q;
begin
    while true do
      begin
      writeln("Process q non-critical section");
      wantq := true;
      while wantp do
        if turn = 1 then
          begin
          wantq := false;
          repeat until turn = 2;
          wantq := true
          end;
      writeln("Process q critical section");
      turn := 1;
      wantq := false;
      end;
end;

begin
  cobegin
    p;
    q
  coend;
end.
