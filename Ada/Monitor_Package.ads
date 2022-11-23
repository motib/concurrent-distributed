-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
package Monitor_Package is

  task Monitor is
    entry Enter;
    entry Leave;
  end Monitor;

  task type Condition is
    entry Signal;
    entry Wait;
    entry Waiting(B: out Boolean);
  end Condition;

  function Non_Empty(C: Condition) return Boolean;

end Monitor_Package;
