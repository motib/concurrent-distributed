-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
package Tuple_Defs is

  type Vector   is array(Positive range <>) of Integer;
  type Int_Ptr  is access Integer;
  type Char_Ptr is access Character;
  type Bool_Ptr is access Boolean;
  type Str_Ptr  is access String;
  type Vec_Ptr  is access Vector;

  type Tuple_Types is (None, Ints, Chars, Bools, Strs, Vecs);
  type Tuple_Element(Tuple_Type: Tuple_Types := None) is
    record
      case Tuple_Type is
        when None => null;
        when Ints  => I: Int_Ptr;
        when Chars => C: Char_Ptr;
        when Bools => B: Bool_Ptr;
        when Strs  => S: Str_Ptr;
        when Vecs  => V: Vec_Ptr;
      end case;
    end record;

  Null_Element: constant Tuple_Element := (Tuple_Type => None);
  Formal_Int:   constant Tuple_Element := (Ints,  null);
  Formal_Char:  constant Tuple_Element := (Chars, null);
  Formal_Bool:  constant Tuple_Element := (Bools, null);
  Formal_Str:   constant Tuple_Element := (Strs,  null);
  Formal_Vec:   constant Tuple_Element := (Vecs,  null);

  type Tuples is array(1..4) of Tuple_Element;

  Null_Tuple: constant Tuples := (others => (Tuple_Type => None));

  function Int(I:  Integer)   return Tuple_Element;
  function Char(C: Character) return Tuple_Element;
  function Bool(B: Boolean)   return Tuple_Element;
  function Str(S:  String)    return Tuple_Element;
  function Vec(V:  Vector)    return Tuple_Element;

  function Int(T:  Tuples; Index: Integer) return Integer;
  function Char(T: Tuples; Index: Integer) return Character;
  function Bool(T: Tuples; Index: Integer) return Boolean;
  function Str(T:  Tuples; Index: Integer) return String;
  function Vec(T:  Tuples; Index: Integer) return Vector;

  function Create_Tuple(T1, T2, T3, T4: Tuple_Element := 
       (Null_Element)) return Tuples;
  function Match(T1, T2: Tuples) return Boolean;

end Tuple_Defs;
