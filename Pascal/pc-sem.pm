program prodcon;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

const K = 20;
      N = 10;
      NMinusOne = 9;
var   B: array[0..NMinusOne] of integer;
      inptr, outptr: integer := 0;
      count: integer := 0;
      S: binarysem := 1;
      notfull: binarysem := 1;
      notempty: binarysem := 0;

process Producer;
var I: Integer := 0;
begin
    for I := 0 to K do
      begin
      writeln("Produce ", I);
      if count = N then wait(notfull);
      wait(S);
      B[inptr] := I;
      inptr := (inptr + 1) mod N;
      count := count + 1;
      signal(S);
      if count = 1 then signal(notempty);
      end;
end;

process Consumer;
var I: Integer := 0;
    V: Integer;
begin
    for I := 0 to K do
      begin
      if count = 0 then wait(notempty);
      wait(S);
      V := B[outptr];
      outptr := (outptr + 1) mod N;
      count := count - 1;
      signal(S);
      if count = NMinusOne then signal(notfull);
      writeln("Consume ", V);
      end;
end;

begin
  cobegin Producer; Consumer coend;
end.
