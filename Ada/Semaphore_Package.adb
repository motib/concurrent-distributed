-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
package body Semaphore_Package is

   protected body Semaphore_Object is

      entry Wait when Count > 0 is
      begin
         Count := Count - 1; 
      end Wait; 

      procedure Signal is
      begin 
         Count := Count + 1; 
      end Signal; 

      procedure Init(Initial: Natural; B: Boolean) is
      begin
        Count := Initial;
        Binary := B;
      end Init;
      
   end Semaphore_Object;

   function Init(N: Integer) return Semaphore is
    S: Semaphore;
  begin
    if N < 0 then raise Bad_Semaphore_Initialization;
    else
      S := new Semaphore_Object;
      S.Init(N, False);
      return S;
    end if;
  end Init;

  function Init(N: Integer) return Binary_Semaphore is
    S: Binary_Semaphore;
  begin
    if (N < 0) or (N > 1) then raise Bad_Semaphore_Initialization;
    else
      S := new Semaphore_Object;
      S.Init(N, True);
      return S;
    end if;
  end Init;

  procedure Wait(S: Semaphore) is
  begin
    S.Wait;
  end Wait;

  procedure Signal(S: Semaphore) is
  begin
    S.Signal;
  end Signal;

  procedure Wait(S: Binary_Semaphore) is
  begin
    S.Wait;
  end Wait;

  procedure Signal(S: Binary_Semaphore) is
  begin
    S.Signal;
  end Signal;

end Semaphore_Package;
