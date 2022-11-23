-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
-- Programmed by Jan Lönnberg
-- Lamport's fast mutual exclusion algorithm for two processes
with Ada.Text_IO; use Ada.Text_IO;
procedure Fast_Two is
   pragma Time_Slice(0.01);

   type Node_Name is (No_Node, P_Node, Q_Node);
   Gate1, Gate2: Node_Name := No_Node;
   pragma Atomic(Gate1);
   pragma Atomic(Gate2);
   WantP, WantQ: Boolean := False;

   task P;
   task body P is
   begin
      loop
         Put_Line("P non-critical section");
         <<StartP>>
         WantP := True;
         Put_Line("P trying to enter critical section");
         Gate1 := P_Node;
         if Gate2 /= No_Node then
            WantP := False;
            loop exit when Gate2 = No_Node; end loop;
            goto StartP;
         end if;
         Gate2 := P_Node;
         if Gate1 /= P_Node then
            WantP := False;
            loop exit when WantQ = False; end loop;
            if Gate2 /= P_Node then
               loop exit when Gate2 = No_Node; end loop;
               goto StartP;
            end if;
         end if;

         Put_Line("P critical section");

         Gate2 := No_Node;
         WantP := False;
      end loop;
   end P;

   task Q;
   task body Q is
   begin
      loop
         Put_Line("Q non-critical section");
         <<StartQ>>
         WantQ := True;
         Put_Line("Q trying to enter critical section");
         Gate1 := Q_Node;
         if Gate2 /= No_Node then
            WantQ := False;
            loop exit when Gate2 = No_Node; end loop;
            goto StartQ;
         end if;
         Gate2 := Q_Node;
         if Gate1 /= Q_Node then
            WantQ := False;
            loop exit when WantP = False; end loop;
            if Gate2 /= Q_Node then
               loop exit when Gate2 = No_Node; end loop;
               goto StartQ;
            end if;
         end if;

         Put_Line("Q critical section");

         Gate2 := No_Node;
         WantQ := False;
      end loop;
   end Q;

begin
   null;
end Fast_Two;
