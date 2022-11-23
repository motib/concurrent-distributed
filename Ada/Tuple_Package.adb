-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
package body Tuple_Package is

  Tuple_Space: array(0..50) of Tuples := (others => Null_Tuple);
  Out_of_Tuple_Space: exception;

  task Space_Lock is
    entry Lock;
    entry Unlock;
  end Space_Lock;

    task body Space_Lock is
    begin
      loop
        select
          accept Lock;
          accept Unlock;
        or 
          terminate;
        end select;
      end loop;
    end Space_Lock;

  task Suspend is
    entry Release;
    entry Notify;
    entry Request;
  end Suspend;

task body Suspend is
  Suspended: Integer := 0;
begin
  loop
    select
      accept Release;
      for I in 1..Suspended loop
        accept Request;
      end loop;
      Suspended := 0;
    or
      accept Notify;
      Suspended := Suspended + 1;
    or
      terminate;
    end select;
    Space_Lock.Unlock;
  end loop;
end Suspend;

  function Find_Tuple(T: in Tuples) return Integer is
  begin
    Tuple_Space(0) := T;
    for I in reverse Tuple_Space'Range loop
      if Match(T, Tuple_Space(I)) then return I; end if;
    end loop;
  end Find_Tuple;

  procedure Out_Tuple(T: Tuples) is
    I: Integer;
  begin
    Space_Lock.Lock;
    I := Find_Tuple(Null_Tuple);
    if I = 0 then raise Out_of_Tuple_Space; end if;
    Tuple_Space(I) := T;
    Suspend.Release;
  end Out_Tuple;

  procedure Out_Tuple (T1, T2, T3, T4: Tuple_Element := Null_Element) is
  begin
    Out_Tuple(Create_Tuple(T1, T2, T3, T4));
  end Out_Tuple;

  function Find_Tuple_or_Suspend(T: Tuples; Must_Remove: Boolean) 
             return Tuples is
    T1: Tuples;
    I: Integer;
  begin
    loop
      Space_Lock.Lock;
      I := Find_Tuple(T);
      if I /= 0 then
        T1 := Tuple_Space(I);
        if Must_Remove then Tuple_Space(I) := Null_Tuple; end if;
        Space_Lock.Unlock;
        return T1;
      else
        Suspend.Notify;
        Suspend.Request;
      end if;
    end loop;
  end Find_Tuple_or_Suspend;

  function In_Tuple(T: Tuples) return Tuples is
  begin
    return Find_Tuple_or_Suspend(T, Must_Remove => True);
  end In_Tuple;

  function  In_Tuple  (T1, T2, T3, T4: Tuple_Element := Null_Element) 
     return Tuples is
  begin
     return In_Tuple(Create_Tuple(T1, T2, T3, T4));
  end In_Tuple;

  function Read_Tuple(T: Tuples) return Tuples is
  begin
    return Find_Tuple_or_Suspend(T, Must_Remove => False);
  end Read_Tuple;

  function  Read_Tuple(T1, T2, T3, T4: Tuple_Element := Null_Element) 
     return Tuples is
  begin
     return Read_Tuple(Create_Tuple(T1, T2, T3, T4));
  end Read_Tuple;

end Tuple_Package;
