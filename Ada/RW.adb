-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Text_IO; use Text_IO;
with RW_Monitor; use RW_Monitor;
procedure RW is

  task type Reader is
    entry Init(I: in Integer);
  end Reader;

  task type Writer is
    entry Init(I: in Integer);
  end Writer;

  R: array (1..6) of Reader;
  W: array (1..3) of Writer;

  task body Reader is
    ID: Integer;
  begin
    accept Init(I: in Integer) do
      ID := I;
    end Init;
    loop
      Start_Read;
      Put_Line(Integer'Image(ID) & "  Reading ");
      Stop_Read;
      Put_Line(Integer'Image(ID) & "  Not Reading ");
    end loop;
  end Reader;

  task body Writer is
    ID:  Integer;
  begin
    accept Init(I: in Integer) do
      ID := I;
    end Init;
    loop
      Start_Write;
      Put_Line(Integer'Image(ID) & "  Writing ");
      Stop_Write;
      Put_Line(Integer'Image(ID) & "  Not Writing ");
    end loop;
  end Writer;

begin
  for I in R'Range loop R(I).Init(I); end loop;
  for I in W'Range loop W(I).Init(I); end loop;
end RW;
