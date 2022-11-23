-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Ada.Text_IO;
procedure Count is

   N: Integer := 0;

   task type Count_Task;

   task body Count_Task is
      Temp: Integer;
   begin
      for I in 1..10 loop
         Temp := N;
         delay(0.0);
         N := Temp + 1;
       end loop;
   end Count_Task;

begin
   declare
      P, Q: Count_Task;
   begin
      null;
   end;
   Ada.Text_Io.Put_Line("The value of N is " & Integer'Image(N));
end Count;
