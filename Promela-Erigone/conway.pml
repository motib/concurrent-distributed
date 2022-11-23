/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Conway's problem
   Process Generator generates random input data
   Do not run in jSpin because of incremental print statements
*/

chan inC  = [2] of { byte };
chan pipe = [2] of { byte };
chan outC = [2] of { byte };

active proctype Generator() {
  byte I = 1;
  do
  :: I > 50 -> break
  :: else ->
      if
      :: inC ! 'a'
      :: inC ! 'b'
      :: inC ! 'c'
      :: inC ! 'd'
      fi;
      I++
   od
}

active proctype Compress() {
    byte previous;
    byte count = 0;
    byte c;
    inC ? previous;
end:do
    :: inC ? c ->
        if
        :: (c == previous) && (count < 9-1) -> count++
        :: else ->
            if
            :: count > 0 ->
                pipe ! count+1;
                count = 0
            :: else
            fi;
            pipe ! previous;
            previous = c;
        fi
    od
}

active proctype Output() {
    byte c;
    byte count = 0;
end:do
    :: pipe ? c;
       outC ! c;
       count++;
       if
       :: count >= 4 ->
        outC ! 0;
        count = 0
       :: else
       fi
    od
}

active proctype Printer() {
    byte c;
end:do
    :: outC ? c;
       if
       :: c == 0 -> printf("\n")
       :: (c >= 2) && (c <= 9) -> printf("%d ", c)
       :: else -> printf("%c ", c)
       fi;
    od
}
