-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
package Semaphore_Package is

  type Semaphore is private;
  type Binary_Semaphore is private;

  function Init(N: Integer) return Semaphore;
  procedure Wait  (S: Semaphore);
  procedure Signal(S: Semaphore);

  function Init(N: Integer) return Binary_Semaphore;
  procedure Wait  (S: Binary_Semaphore);
  procedure Signal(S: Binary_Semaphore);

  Bad_Semaphore_Initialization: exception;

private

   protected type Semaphore_Object is
      entry Wait; 
      procedure Signal;
      procedure Init(Initial: Natural; B: Boolean);
   private
      Count: Natural;
      Binary: Boolean;
   end Semaphore_Object; 

  type Semaphore is access Semaphore_Object;
  type Binary_Semaphore is access Semaphore_Object;

end Semaphore_Package;
