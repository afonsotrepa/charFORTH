# charFORTH
A character based FORTH where every word is one char long. Core implemented in less than 500 lines of x86-64 assembly.

# Example code

```forth
:L 91+ 91+ * 91+ *; \ length
cA L8*a \ array of qwords

:t sdrdrs ; \ 2dup

\ do sieve for given number
:S 0 1W 1+   t* d L1->I DDDX T   8*A+ 1s!   1R;

\ print out all primes from 2 to L
:P 2 1W   d 8*A+@ 1~=I d. dS T   1+d L-R;

Pb
```
