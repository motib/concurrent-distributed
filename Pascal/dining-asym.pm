program Philosophers;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

{ Dining philosophers: demonstrate array of semaphores. }

var	Fork: array[0 .. 4] of binarysem;
	K: integer;

procedure Phil(N: integer);
var I: Integer;
begin
  for I := 1 to 10 do
    begin
    wait(Fork[N]);
    wait(Fork[N+1]);
    writeln('P', N, ' is eating');
    signal(Fork[N+1]);
    signal(Fork[N]);
    end;
end;

procedure Phil5;
var I: Integer;
begin
  for I := 1 to 10 do
    begin
    wait(Fork[0]);
    wait(Fork[4]);
    writeln('P 4 is eating');
    signal(Fork[4]);
    signal(Fork[0]);
    end;
end;

begin
  for K := 0 to 4 do initialsem(Fork[K], 1);
  cobegin
    Phil(0); Phil(1); Phil(2); Phil(3); Phil5;  
  coend;
end.

