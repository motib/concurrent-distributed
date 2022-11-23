program fasttwo;
(* Copyright (C) 2006 M. Ben-Ari. See copyright.txt *)

const P = 1; Q = 2;
var gate1: integer := 0;
    gate2: integer := 0;
    wantp: boolean := false;
    wantq: boolean := false;

process pp;
var OK: boolean;
begin
    while true do
      begin
      writeln("Process p non-critical section");
      OK := false;
      while not OK do
          begin
          wantp := true;
          gate1 := P;
          if gate2 <> 0 then
            begin
            wantp := false;
            repeat until gate2 = 0;
            end
          else 
              begin
              gate2 := P;
              if gate1 <> P then
                 begin
                 wantp := false;
                 repeat until wantq = false;
                 if gate2 <> P then
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
      writeln("Process p critical section");
      gate2 := 0;
      wantp := false;
      end
end;

process qq;
var OK: boolean;
begin
    while true do
      begin
      writeln("Process q non-critical section");
      OK := false;
      while not OK do
          begin
          wantq := true;
          gate1 := Q;
          if gate2 <> 0 then
            begin
            wantq := false;
            repeat until gate2 = 0;
            end
          else 
              begin
              gate2 := Q;
              if gate1 <> Q then
                 begin
                 wantq := false;
                 repeat until wantp = false;
                 if gate2 <> Q then
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
      writeln("Process q critical section");
      gate2 := 0;
      wantq := false;
      end
end;

begin
  cobegin
    pp;
    qq
  coend;
end.

