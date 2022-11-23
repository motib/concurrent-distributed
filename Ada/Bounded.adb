-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Ada.Text_IO; use Ada.Text_IO;
procedure Bounded is
  type Index is mod 128;
  type Buffer_Array is array(Index) of Integer;

  task Buffer is
    entry Append(I: in  Integer);
    entry Take  (I: out Integer);
  end Buffer;

  task body Buffer is
    B: Buffer_Array;
    In_Ptr, Out_Ptr, Count:  Index := 0;
  begin
    loop
      select
        when Count < Index'Last =>
          accept Append(I: in Integer) do
            B(In_Ptr) := I;
          end Append;
        Count := Count + 1;
        In_Ptr := In_Ptr + 1;
      or
        when Count > 0 =>
          accept Take(I: out Integer) do
            I := B(Out_Ptr);
          end Take;
        Count := Count - 1;
        Out_Ptr := Out_Ptr + 1;
      or
        terminate;
      end select;
    end loop;
  end Buffer;

  task Producer;
  task body Producer is
  begin
    for N in 1..200 loop
      Put_Line("Producing " & Integer'Image(N));
      Buffer.Append(N);
    end loop;
  end Producer;

  task type Consumer(ID: Integer);
  task body Consumer is
    N: Integer;
  begin
    loop
      Buffer.Take(N);
      Put_Line(Integer'Image(ID) & " consuming " & Integer'Image(N));
    end loop;
  end Consumer;

  C1: Consumer(1);
  C2: Consumer(2);

begin
  null;
end Bounded;