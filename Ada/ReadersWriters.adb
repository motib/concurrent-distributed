-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Ada.Text_Io; with Ada.Integer_Text_IO;
procedure ReadersWriters is
   
   protected RW is
      entry StartRead;
      procedure EndRead;
      entry Startwrite;
      procedure EndWrite;
      function NumberReaders return Natural; 
   private
      Readers: Natural :=0;
      Writing: Boolean := false;
   end RW; 

   protected body RW is

      entry StartRead when not Writing is
      begin
         Readers := Readers + 1;
      end StartRead;
      
      procedure EndRead is
      begin
         Readers := Readers - 1;
      end EndRead;
      
      entry StartWrite when not Writing and Readers = 0 is
      begin
         Writing := true;
      end StartWrite;
      
      procedure EndWrite is
      begin
         Writing := false;
      end EndWrite;
      
      function NumberReaders return Natural is
      begin
         return Readers;
      end NumberReaders;
   end RW;
   
   task type Reader(N: integer) is
   end Reader;
   
   task body Reader is
   begin
      for I in 1..10 loop
         RW.StartRead;
         Ada.Text_Io.Put("Reader ");
         Ada.Integer_Text_Io.Put(N);
         Ada.Text_Io.New_Line;
         RW.EndRead;
       end loop;
   end Reader;

   task type Writer(N: integer) is
   end Writer;
   
   task body Writer is
   begin
      for I in 1..10 loop
         RW.StartWrite;
         Ada.Text_Io.Put("Writer ");
         Ada.Integer_Text_Io.Put(N);
         Ada.Text_Io.New_Line;
         RW.EndWrite;
       end loop;
   end Writer;

   R1: Reader(1); R2: Reader(2); R3: Reader(3);
   W1: Writer(1); W2: Writer(2);

begin
   null;
end ReadersWriters;
