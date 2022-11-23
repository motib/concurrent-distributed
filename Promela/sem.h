/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* Definition of busy-wait semaphores */
inline wait( s )  {
        atomic { s > 0 ; s-- }
}

inline signal( s ) { s++ }

