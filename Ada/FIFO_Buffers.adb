-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
package body FIFO_Buffers is
   protected body Buffer is
      entry Put(C: in Element) when Count < Data'Length is
      begin
         Data(In_Index) := C;
         In_Index := In_Index + 1;
         Count := Count + 1;
      end Put;
      entry Get(C : out Element) when Count > 0 is
      begin
         C := Data(Out_Index);
         Out_Index := Out_Index + 1;
         Count := Count - 1;
      end Get;
   end Buffer;
end FIFO_Buffers;
