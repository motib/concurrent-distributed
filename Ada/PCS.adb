-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Text_IO; use Text_IO;
with Semaphore_Package; use Semaphore_Package;
procedure PCS is

  N: constant Integer := 10;
  B: array(0..N-1) of Integer;
  In_Ptr, Out_Ptr: Integer := 0;

  Elements: Semaphore := Init(0);
  Spaces:   Semaphore := Init(N);

  task Producer is
    pragma Priority(10);
  end Producer;
  task Consumer1 is
    pragma Priority(7);
  end Consumer1;
  task Consumer2 is
    pragma Priority(7);
  end Consumer2;

  task body Producer is
    I: Integer := 0;
  begin
    loop
      I := I + 1;
      Put_Line("Produce   " & Integer'Image(I));
      if I mod 40 = 0 then delay 1.0; end if;
      Wait(Spaces);
      B(In_Ptr) := I;
      In_Ptr := (In_Ptr + 1) mod N;
      Signal(Elements);
    end loop;
  end Producer;

  task body Consumer1 is
    I: Integer;
  begin
    loop
      Wait(Elements);
      I := B(Out_Ptr);
      Out_Ptr := (Out_Ptr + 1) mod N;
      Signal(Spaces);
      Put_Line("Consume 1 " & Integer'Image(I));
    end loop;
  end Consumer1;

  task body Consumer2 is
    I: Integer;
  begin
    loop
      Wait(Elements);
      I := B(Out_Ptr);
      Out_Ptr := (Out_Ptr + 1) mod N;
      Signal(Spaces);
      Put_Line("Consume 2 " & Integer'Image(I));
    end loop;
  end Consumer2;

begin
  null;
end PCS;
