-- Copyright (C) 2006 M. Ben-Ari. See copyright.txt
with Ada.Text_IO;
procedure Matrix is

   Size: constant Integer := 3;
   type Vector is array(1..Size) of Integer;
   Matrix1: array(1..Size) of Vector :=
      ((1,2,3),(4,5,6),(7,8,9));
   Matrix2: array(1..Size) of Vector :=
      ((1,0,2),(0,1,2),(1,0,0));

   type Multiplier_Task;
   type Multiplier_Pointer is access all Multiplier_Task;


   task type Source_Task is
      entry Init(V: Vector; South: Multiplier_Pointer);
   end Source_Task;

   task type Sink_Task is
      entry North;
   end Sink_Task;

   type Sink_Pointer is access all Sink_Task;

   task type Zero_Task is
      entry Init(West: Multiplier_Pointer);
   end Zero_Task;

   task type Result_Task is
      entry Init(ID: Integer);
      entry East(I: in  Integer);
   end Result_Task;

   type Result_Pointer is access all Result_Task;

   task type Multiplier_Task is
      entry Init(Coeff: Integer;
         South1: Multiplier_Pointer; South2: Sink_Pointer;
         West1: Multiplier_Pointer; West2: Result_Pointer);
      entry North(I: in  Integer);
      entry East(I: in  Integer);
   end Multiplier_Task;

   M: array(1..Size, 1..Size) of aliased Multiplier_Task;
   S: array(1..Size) of aliased Source_Task;
   T: array(1..Size) of aliased Sink_Task;
   Z: array(1..Size) of aliased Zero_Task;
   R: array(1..Size) of aliased Result_Task;

   task body Multiplier_Task is
      S1: Multiplier_Pointer := null;
      S2: Sink_Pointer := null;
      W1: Multiplier_Pointer := null;
      W2: Result_Pointer := null;
      Sum, X, A: Integer;
      Need_North, Need_East: Boolean := True;
   begin
      accept Init(Coeff: Integer;
            South1: Multiplier_Pointer; South2: Sink_Pointer;
            West1: Multiplier_Pointer; West2: Result_Pointer) do
         A := Coeff; S1 := South1; S2 := South2;
         W1 := West1; W2 := West2;
      end Init;
      for N in 1..Size loop
         loop
            select
               when Need_North =>
                  accept North(I: in Integer) do
                     X := I;
                  end North;
                  if S1 = null then S2.North; else S1.North(X); end if;
                  Need_North := False;
            or
               when Need_East =>
                  accept East (I: in Integer) do
                     Sum := I;
                  end East;
                  Need_East := False;
            end select;


            exit when (not Need_North) and (not Need_East);
         
end loop;
         Sum := Sum + A*X;
         if W1 = null then W2.East(Sum); else W1.East(Sum); end if;
         Need_North := True;
         Need_East := True;
      end loop;
   end Multiplier_Task;

   task body Source_Task is
      S: Multiplier_Pointer;
      Vec: Vector;
   begin
      accept Init(V: Vector; South: Multiplier_Pointer) do
         Vec := V;
         S := South;
      end Init;
      for N in 1..Size loop
         S.North(Vec(N));
      end loop;
   end Source_Task;

   task body Sink_Task is
   begin
      for N in 1..Size loop
         accept North;
      end loop;
   end Sink_Task;

   task body Zero_Task is
      W: Multiplier_Pointer;
   begin
      accept Init(West: Multiplier_Pointer) do
         W := West;
      end Init;
      for N in 1..Size loop
         W.East(0);
      end loop;
   end Zero_Task;

   task body Result_Task is
      use Ada.Text_IO;
      Ident: Integer;
   begin
      accept Init(ID: Integer) do
         Ident := ID;
      end Init;
      for N in 1..Size loop
         accept East(I: in Integer) do
            Put_Line(Integer'Image(Ident) & Integer'Image(N) &
               Integer'Image(I));
         end East;
      end loop;
   end Result_Task;

   procedure Init is
   begin
      for I in 1..Size loop
         Z(I).Init(M(I,Size)'access);
         S(I).Init(Matrix2(I), M(1,I)'access);
         R(I).Init(I);
      end loop;

      for I in 1..Size-1 loop
         for J in 2..Size loop
            M(I,J).Init(Matrix1(I)(J),
               M(I+1,J)'access, null, M(I,J-1)'access, null);
         end loop;
      end loop;

      for I in 1..Size-1 loop
         M(I,1).Init(Matrix1(I)(1),
            M(I+1,1)'access, null, null, R(I)'access);
      end loop;
      
      for J in 2..Size loop
         M(Size,J).Init(Matrix1(Size)(J),
            null, T(J)'access, M(Size,J-1)'access, null);
      end loop;
      
      M(Size,1).Init(Matrix1(Size)(1),
         null, T(1)'access, null, R(Size)'access);
   end Init;

begin
   Init;
end Matrix;