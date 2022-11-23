/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
   Monitor for readers and writers 
   Verify Safety
   Verify Acceptance with <>isReading && <>isWriting
*/

bool lock = false;
byte Readers = 0 ;
bool Writing = false ;
/*
bool isReading;
bool isWriting;
*/
bool RG;
byte RW;
bool WG;
byte WW;

active [2] proctype r() {
    /* StartRead */
   atomic {
      !lock;
      lock = true;
   }
    if 
    :: (Writing || !(WW == 0)) ->
         atomic {  
            RW++;
            lock = false;          
            RG;          
            lock = true;           
            RG = false;  
            RW--;
         }
    :: else 
    fi;
    Readers++ ;
    assert (!Writing);
    atomic {  
       if 
       :: (RW > 0) -> 
           RG = true;
           !lock;                  
           lock = true;            
       :: else
       fi;
    }
    lock = false;
    /*
    if
    :: (_pid == 0) -> isReading = true 
    :: else
    fi;
    */
    printf("process %d reading %d\n", _pid, 1);
            
    /* EndRead */
   atomic {
      !lock;
      lock = true;
   }
    Readers--;
    if 
    :: (Readers == 0) ->
        atomic {  
           if 
           :: (WW > 0) -> 
               WG = true;
               !lock;                  
               lock = true;            
           :: else -> skip
           fi;
        }
    :: else ->
    fi;
   lock = false;
}

active [2] proctype w() {
	  /* StartWrite */
   atomic {
      !lock;
      lock = true;
   }
    if 
    :: ((Readers != 0) || Writing) ->
         atomic {  
            WW++;
            lock = false;          
            WG;          
            lock = true;           
            WG = false;  
            WW--;
         }
    :: else 
    fi;
    Writing = true ;
    assert (Readers == 0);
   lock = false;
    /*
    if
    :: (_pid == 3) -> isWriting = true
    :: else
    fi;
    */
    printf("process %d writing %d\n", _pid, 1);

    /* EndWrite */
   atomic {
      !lock;
      lock = true;
   }
    Writing = false;
    if 
    :: (RW == 0) ->
        atomic {  
           if 
           :: (WW > 0) -> 
               WG = true;
               !lock;                  
               lock = true;            
           :: else ->
           fi;
        }
    :: else ->
        atomic {  
           if 
           :: (RW > 0) -> 
               RG = true;
               !lock;                  
               lock = true;            
           :: else ->
           fi;
        }
    fi;
    lock = false;
}
