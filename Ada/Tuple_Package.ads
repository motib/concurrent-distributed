-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Tuple_Defs; use Tuple_Defs;
package Tuple_Package is

  function  In_Tuple  (T: Tuples) return Tuples;
  function  Read_Tuple(T: Tuples) return Tuples;
  procedure Out_Tuple (T: Tuples);

  function  In_Tuple  (T1, T2, T3, T4: Tuple_Element := Null_Element) 
     return Tuples;
  function  Read_Tuple(T1, T2, T3, T4: Tuple_Element := Null_Element) 
     return Tuples;
  procedure Out_Tuple (T1, T2, T3, T4: Tuple_Element := Null_Element);

end Tuple_Package;
