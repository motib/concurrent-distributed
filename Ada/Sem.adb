-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Ada.Text_Io; with Ada.Integer_Text_IO;
with Semaphore_Package; use Semaphore_Package;
procedure Sem is
   N: Integer := 0;
   S: Binary_Semaphore := Init(1);
   
   task type Count_Task is
   end Count_Task;
   
   task body Count_Task is
      Temp: Integer;
   begin
      for I in 1..10 loop
         Wait(S);
         Temp := N;
         delay(0.0);
         N := Temp + 1;
         Signal(S);
       end loop;
   end Count_Task;

begin
   declare
      P, Q: Count_Task;
   begin
      null;
   end;
   Ada.Text_Io.Put("The value of N is ");
   Ada.Integer_Text_Io.Put(N);
   Ada.Text_Io.New_Line;
end Sem;
