-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Conway's problem
with FIFO_Buffers;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
procedure Conway is
   pragma Time_Slice(0.01);

   type Symbol is ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b',
                   'c', 'd', NL);
   subtype Char is Symbol range 'a' .. 'd';

   type Buffer_Index is mod 2;

   package Input_Buffers is new FIFO_Buffers(Buffer_Index, Char);
   Input_Buffer: Input_Buffers.Buffer;
   package Pipe_Buffers is new FIFO_Buffers(Buffer_Index, Symbol);
   Pipe: Pipe_Buffers.Buffer;
   package Output_Buffers is new FIFO_Buffers(Buffer_Index, Symbol);
   Output_Buffer: Output_Buffers.Buffer;

   package Random_Char is new Ada.Numerics.Discrete_Random(Char);
   task Generator;
   task body Generator is
     G: Random_Char.Generator;
   begin
      Random_Char.Reset(G);
      for I in 1..50 loop
         Input_Buffer.Put(Random_Char.Random(G));
      end loop;
   end Generator;

   task Compress;
   task body Compress is
      Previous: Symbol := '0';
      Count: Natural := 0;
      C: Char;
      S: Symbol;
   begin
      loop
         Input_Buffer.Get(C);
         if C = Previous and Count < 8 then
            Count := Count + 1;
         else
            if (Previous /= '0') then
               if Count > 0 then
                  S := Symbol'Val(Count + 1);
                  Pipe.Put(S);
                  Count := 0;
               end if;
               Pipe.Put(Previous);
            end if;
            Previous := C;
         end if;
      end loop;
   end Compress;

   task Output;
   task body Output is
      S: Symbol;
      Count: Natural := 0;
   begin
      loop
         Pipe.Get(S);
         Output_Buffer.Put(S);
         Count := Count + 1;
         if Count >= 4 then
            Output_Buffer.Put(NL);
            Count := 0;
         end if;
      end loop;
   end Output;

   task Printer;
   task body Printer is
      S: Symbol;
   begin
      loop
         Output_Buffer.Get(S);
         if S = NL then
            New_Line;
         else
            if S in '0' .. '9' then
               Put(Character'Val(48+Symbol'Pos(S)));
            else
               Put(Character'Val(87+Symbol'Pos(S)));
            end if;
         end if;
      end loop;
   end Printer;
begin
   null;
end Conway;
