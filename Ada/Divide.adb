-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
--# main_program;
procedure Divide(X1, X2: in Integer; Q, R : out Integer)
--# derives Q, R from X1,X2;
--# pre (X1 >= 0) and (X2 > 0);
--# post (X1 = Q * X2 + R) and (R < X2) and (R >= 0);
is
    N: Integer;
begin
   Q := 0; R := 0; N := X1;
   while N /= 0 
   --# assert (X1 = X2 * Q + R + N) and (X2 > R) and (R >= 0);
   loop
      if R+1 = X2 then
         Q := Q + 1; R := 0;
      else
         R := R + 1;
      end if;
      N := N - 1;
   end loop;
end Divide;

