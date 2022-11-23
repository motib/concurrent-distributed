-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Ada.Text_IO; use Ada.Text_IO;
with Linda; use Linda;
procedure TestLinda is
	procedure WriteBoard is
	begin
		Put_Line("Board");
		Put(GetBoard);
		Put_Line("********************************");
	end WriteBoard;
	
	procedure Print(C: Character; I1: integer; I2: Integer) is
	begin
		Put_Line("Note = " & ToString(Note'(Character'Pos(C), I1, I2)));
		Put_Line("--------------------------------");
		WriteBoard;
	end Print;

	protected Scheduler is
		entry WaitTurn(I: Integer);
		procedure SetTurn(I: Integer);
	private
		entry WaitTurn1;
		entry WaitTurn2;
		Release1, Release2: Boolean := False;
	end Scheduler;

	protected body Scheduler is
		entry WaitTurn(I: Integer) when True is
		begin
			if I = 1 then requeue WaitTurn1;
			elsif I = 2 then requeue WaitTurn2;
			end if;
		end WaitTurn;

		procedure SetTurn(I: Integer) is
		begin
			if I = 1 then Release1 := True;
			elsif I = 2 then Release2 := True;
			end if;
		end SetTurn;

		entry WaitTurn1 when Release1 is
		begin
			Release1 := False;
		end WaitTurn1;

		entry WaitTurn2 when Release2 is
		begin
			Release2 := False;
		end WaitTurn2;
	end Scheduler;
	
	procedure WaitTurn(I: Integer) is
	begin
		Scheduler.WaitTurn(I);
	end WaitTurn;

	task T1;
	task body T1 is
            C: Character;
	    I1, I2: Integer := 0;
	begin
        -- Check post, read and remove
            PostNote('m', 10, 20);		-- Posts note
            WriteBoard;
            WaitTurn(1);
            ReadNote('m', I1, I2);
            print('m', I1, I2);	  	            -- Prints m 10 20
            WaitTurn(1);
            RemoveNote('m', I1, I2);
            print('m', I1, I2);	  	            -- Prints m 10 20
            WriteBoard;
            WaitTurn(1);
            
        -- Check different size nodes
            PostNote('a');
            WriteBoard;
            WaitTurn(1);
            ReadNote('a');
            print('a', Formal, Formal);		          -- Prints a
            WaitTurn(1);
            ReadNote('a', I1, I2);  -- OK, parameters are not counted
            print('a', Formal, Formal);		          -- Prints a
            WaitTurn(1);
            RemoveNote('a');
            print('a', Formal, Formal);		          -- Prints a
            WaitTurn(1);
            PostNote('b', 7, Formal);
            WriteBoard;
            WaitTurn(1);
            RemoveNote('b', I1);
            print('b', I1, I2);		          -- Prints b 7
            WriteBoard;
            WaitTurn(1);

        -- Check alues vs. variables
            PostNote('c', 1, 2);
	    WriteBoard;
            C := 'c'; I1 := 8; I2 := 9;
            PostNote(C, I1, I2);
            WriteBoard;
            WaitTurn(1);
            ReadNote('c', I1, I2);
            print('c', I1, I2);		          -- Prints c 1 2
            WaitTurn(1);
            ReadNote(c, I1, I2);
            print('c', I1, I2);		          -- Prints c 1 2 
            WaitTurn(1);
            I1 := 1; I2 := 2;
            ReadNoteEq(c, I1, I2);
            print('c', I1, I2);		          -- Prints c 1 2 
            WaitTurn(1);
            I1 := 8; I2 := 9;
            RemoveNoteEq(c, I1, I2);
            print('c', I1, I2);		          -- Prints c 8 9 
            WaitTurn(1);
            I1 := 1; I2 := 2;
            RemoveNoteEq(c, I1, I2);
            print('c', I1, I2);		          -- Prints c 1 2 
            WaitTurn(1);

        --  Check blocking, unblocking
            RemoveNote('a', I1, I2); -- Blocks, step t2
            print('a', I1, I2);		          -- Prints a 77 88 
            WaitTurn(1);
            RemoveNote('b', I1, I2); 
            print('b', I1, I2);		          -- Prints b 55 66 
            WaitTurn(1);
    end T1;
    
    task T2;
    task body T2 is
    begin
            WaitTurn(2);
            PostNote('b', 55, 66);   -- Doesn't unblock
            WriteBoard;
            WaitTurn(2);
            PostNote('a', 77, 88);   -- Unblock
            WriteBoard;
    end T2;

begin
	declare
		T: Character := '0';
	begin
		loop
			Get(T);
			if T = '-' then exit;
			elsif T = '1' then Scheduler.SetTurn(1);
			elsif T = '2' then Scheduler.SetTurn(2);
			end if;
		end loop;
		abort T1;
		abort T2;
	end;
end TestLinda;
