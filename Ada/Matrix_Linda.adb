-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Text_IO; use Text_IO;
with Tuple_Defs; use Tuple_Defs;
with Tuple_Package; use Tuple_Package;
procedure Matrix_Linda is

  Result: Tuples;

  task type Workers;
  task body Workers is

  Next, Row_Tuple, Col_Tuple: Tuples;
  Element, I, J, Sum: Integer;

begin
  loop
    Next := In_Tuple(Char('N'), Formal_Int);
    Element := Int(Next, 2);
    Out_Tuple(Char('N'), Int(Element+1));
    exit when Element > 3 * 3;
    I := (Element - 1)  /  3 + 1;
    J := (Element - 1) mod 3 + 1;
    Row_Tuple := Read_Tuple(Char('A'), Int(I), Formal_Vec);
    Col_Tuple := Read_Tuple(Char('B'), Int(J), Formal_Vec);
    
    Sum := 0;
    for N in 1..3 loop
      Sum := Sum + Vec(Row_Tuple,3)(N) * Vec(Col_Tuple,3)(N);
    end loop;

    Out_Tuple(Char('C'), Int(I), Int(J), Int(Sum));
  end loop;
end Workers;   

  Worker: array(1..2) of Workers;

begin
  Out_Tuple(Char('A'), Int(1), Vec((1,2,3)));
  Out_Tuple(Char('A'), Int(2), Vec((4,5,6)));
  Out_Tuple(Char('A'), Int(3), Vec((7,8,9)));
  Out_Tuple(Char('B'), Int(1), Vec((1,0,1)));
  Out_Tuple(Char('B'), Int(2), Vec((0,1,0)));
  Out_Tuple(Char('B'), Int(3), Vec((2,2,0)));

  Out_Tuple(Char('N'), Int(1));

  Put_Line("  Row    Col   Result");
  for I in 1..3 loop
    for J in 1..3 loop
      Result := In_Tuple(Char('C'), Int(I), Int(J), Formal_Int);
      Put_Line(Integer'Image(I) & Integer'Image(J) &
               Integer'Image(Int(Result,4)));
    end loop;
  end loop;
end Matrix_Linda;
