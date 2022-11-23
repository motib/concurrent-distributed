-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Bakery algorithm for two processes
with Ada.Text_IO; use Ada.Text_IO;
procedure BakeryTwo is
   pragma Time_Slice(0.01);

   protected Numbers is
      procedure SetNP;
      procedure SetNQ;
      procedure ResetNP;
      procedure ResetNQ;
      function GetNP return Natural;
      function GetNQ return Natural;
   private
      NP: Natural := 0;
      NQ: Natural := 0;
   end Numbers;
   protected body Numbers is
      procedure SetNP is
      begin
         NP := NQ + 1;
      end SetNP;
      procedure SetNQ is
      begin
         NQ := NP + 1;
      end SetNQ;
      procedure ResetNP is
      begin
         NP := 0;
      end ResetNP;
      procedure ResetNQ is
      begin
         NQ := 0;
      end ResetNQ;
      function GetNP return Natural is
      begin
         return NP;
      end GetNP;
      function GetNQ return Natural is
      begin
         return NQ;
      end GetNQ;
   end Numbers;

   task P;
   task body P is
   begin
      loop
         Put_Line("P non-critical section");
         Numbers.SetNP;
         Put_Line("P trying to enter critical section");
         loop exit when (Numbers.GetNQ = 0) or
           (Numbers.GetNP <= Numbers.GetNQ); end loop;
         Put_Line("P critical section");

         Put_Line("P leaving critical section");
         Numbers.ResetNP;
      end loop;
   end P;

   task Q;
   task body Q is
   begin
      loop
         Put_Line("Q non-critical section");
         Numbers.SetNQ;
         Put_Line("Q trying to enter critical section");
         loop exit when (Numbers.GetNP = 0) or
           (Numbers.GetNQ < Numbers.GetNP); end loop;
         Put_Line("Q critical section");

         Put_Line("Q leaving critical section");
         Numbers.ResetNQ;
      end loop;
   end Q;

begin
   null;
end BakeryTwo;
