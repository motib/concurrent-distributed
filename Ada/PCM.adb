-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Text_IO; use Text_IO;
with PC_Monitor; use PC_Monitor; 
procedure PCM is

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
    N: Integer := 0;
  begin
    loop
      N := N + 1;
      Put_Line("Produce   " & Integer'Image(N));
      if N mod 40 = 0 then delay 1.0; end if;
      Append(N);
    end loop;
  end Producer;

  task body Consumer1 is
    N: Integer;
  begin
    loop
      Take(N);
      Put_Line("Consume 1 " & Integer'Image(N));
    end loop;
  end Consumer1;

  task body Consumer2 is
    N: Integer;
  begin
    loop
      Take(N);
      Put_Line("Consume 2 " & Integer'Image(N));
    end loop;
  end Consumer2;

begin
  null;
end PCM;
