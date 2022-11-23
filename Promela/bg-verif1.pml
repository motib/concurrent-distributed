/* Copyright (C) 2006 M. Ben-Ari. See copyright.txt */
/* 
	Byzantine Generals algorithm for verification
	Don't actually send or receive any messages
*/

/* Macros for for-loop without declaration of variable ... */
#define for(I,low,high) I = low ; do :: ( I > high ) -> break :: else ->
#define rof(I) ; I++ od

mtype = { A, R } ;
typedef vector {
	mtype p[4]
};
typedef matrix {
    vector v[4]
};

matrix plans[3];
/*
   plans[I].v[J].p[K] is:
     In General I, K thinks that this is J's plan
*/

mtype  choice[3];
#define T 3

inline ComputeMajority(I) {
	byte choseR, choseA, Rs, As;
    d_step {
		choseR = 0; choseA = 0;
		for (M, 0, 3)
            Rs = 0; As = 0;
            for (N, 0, 3)
                if
                :: (plans[I].v[M].p[N] == A) -> As++;
                :: (plans[I].v[M].p[N] == R) -> Rs++;
                :: else
                fi;
            rof (N);
            if
            :: (Rs >= As) -> choseR++
            :: (As > Rs) -> choseA++
            fi
        rof (M);
        choice[I] = ((choseR >= choseA) -> R : A);
	}
}

inline Display() {
    for (L, 0, 2)
        d_step {
            printf("MSC: At %d:\n", L);
            for (M, 0, 3)
                printf("MSC: %e %e %e %e\n", 
                    plans[L].v[M].p[0], plans[L].v[M].p[1], 
                    plans[L].v[M].p[2], plans[L].v[M].p[3])
            rof(M)
        }
    rof (L)
}

init {
    byte I, J, K, L, M, N;
    /* Choose one set of plans - should be nondeterministic */
    if :: plans[0].v[0].p[0] = A :: plans[0].v[0].p[0] = R fi; 
    if :: plans[1].v[1].p[1] = A :: plans[1].v[1].p[1] = R fi;
    if :: plans[2].v[2].p[2] = A :: plans[2].v[2].p[2] = R fi;
/*
    plans[0].v[0].p[0] = A;
    plans[1].v[1].p[1] = R;
    plans[2].v[2].p[2] = A;
*/

    /* First round */
    for (I, 0, 2)
        for (J, 0, 2)
            if :: I != J -> 
                plans[I].v[J].p[J] = plans[J].v[J].p[J];
               :: else
            fi;
        rof (J);
        if :: plans[I].v[T].p[T] = A :: plans[I].v[T].p[T] = R fi; 
    rof(I);
    Display();

    /* Second round */
    for (I, 0, 2)
        for (J, 0, 2)
            if :: J != I ->
                for (K, 0, 2) 
                    if :: K != I && K != J -> 
                        plans[I].v[J].p[K] = plans[K].v[J].p[J];
                       :: else
                    fi;
                rof (K);
                plans[I].v[T].p[J] = plans[J].v[T].p[T]; 
                if :: plans[I].v[J].p[T] = A :: plans[I].v[J].p[T] = R fi; 
               :: else
            fi;
        rof (J);
    rof(I);
    Display();

    for (I, 0, 2)
        ComputeMajority(I);
    rof(I);
    printf("MSC: Choices are %e %e %e\n", choice[0], choice[1], choice[2]);
    assert( (choice[0] == choice[1]) && (choice[1] == choice[2]))
}

