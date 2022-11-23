program second;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

var wantp: boolean := false;
    wantq: boolean := false;

procedure p;
begin
    while true do
      begin
      writeln("Process p non-critical section");
      repeat until wantq = false;
      wantp := true;
      writeln("Process p critical section");
      wantp := false;
      end;
end;

procedure q;
begin
    while true do
      begin
      writeln("Process q non-critical section");
      repeat until wantp = false;
      wantq := true;
      writeln("Process q critical section");
      wantq := true;
      end;
end;

begin
  cobegin
    p;
    q
  coend;
end.

