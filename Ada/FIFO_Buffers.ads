-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
generic
   type Index is mod <>;
   type Element is private;

package FIFO_Buffers is
   type Buffer_Data is array(Index) of Element;
   protected type Buffer is
      entry Get(C: out Element);
      entry Put(C: in Element);
   private
      Data: Buffer_Data;
      Count: Natural := 0;
      In_Index, Out_Index: Index := 0;
   end Buffer;
end FIFO_Buffers;
