-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
package body Tuple_Defs is

  function Int(I: Integer) return Tuple_Element is
  begin
    return (Ints, new Integer'(I));
  end Int;

  function Char(C: Character) return Tuple_Element is
  begin
    return (Chars, new Character'(C));
  end Char;

  function Bool(B: Boolean) return Tuple_Element is
  begin
    return (Bools, new Boolean'(B));
  end Bool;

  function Str(S: String) return Tuple_Element is
  begin
    return (Strs, new String'(S));
  end Str;

  function Vec(V: Vector) return Tuple_Element is
  begin
    return (Vecs, new Vector'(V));
  end Vec;

  function Int(T: Tuples; Index: Integer) return Integer is
  begin
    return T(Index).I.all;
  end Int;

  function Char(T: Tuples; Index: Integer) return Character is
  begin
    return T(Index).C.all;
  end Char;

  function Bool(T: Tuples; Index: Integer) return Boolean is
  begin
    return T(Index).B.all;
  end Bool;

  function Str(T: Tuples; Index: Integer) return String is
  begin
    return T(Index).S.all;
  end Str;

  function Vec(T: Tuples; Index: Integer) return Vector is
  begin
    return T(Index).V.all;
  end Vec;

  function Create_Tuple(T1, T2, T3, T4: Tuple_Element :=
      (Null_Element)) return Tuples is
  begin
    return (T1, T2, T3, T4);
  end Create_Tuple;

  function Element_Match(E1, E2: Tuple_Element) return Boolean is
  begin
    case E1.Tuple_Type is
      when None => return True;
      when Ints => 
        return E1 = Formal_Int or else 
               E2 = Formal_Int or else 
               E1.I.all = E2.I.all;
      when Chars =>
        return E1 = Formal_Char or else 
               E2 = Formal_Char or else 
               E1.C.all = E2.C.all;
      when Bools =>
        return E1 = Formal_Bool or else 
               E2 = Formal_Bool or else 
               E1.B.all = E2.B.all;
      when Strs =>
        return E1 = Formal_Str or else
               E2 = Formal_Str or else 
               E1.S.all = E2.S.all;
      when Vecs =>
        return E1 = Formal_Vec or else 
               E2 = Formal_Vec or else 
               E1.V.all = E2.V.all;
    end case;
  end Element_Match;

  function Match(T1, T2: Tuples) return Boolean is
  begin
    for J in Tuples'Range loop
      if T1(J).Tuple_Type /= T2(J).Tuple_Type 
                or else
         not Element_Match(T1(J), T2(J)) then
           return False;
      end if;
    end loop;
    return True;
  end Match;

end Tuple_Defs;
