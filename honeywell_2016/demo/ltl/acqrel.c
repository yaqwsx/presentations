// ****************************************************
//
//     Making Prophecies with Decision Predicates
//
//              Byron Cook * Eric Koskinen
//                     July 2010
//
// ****************************************************

// Benchmark: acqrel.c
// Property: G(a => F r)

volatile int A, R;
void init() { A = R = 0; }
int __VERIFIER_nondet_int();

int main() {
  init();
  volatile int n = 0;
  while(__VERIFIER_nondet_int()) {
    A = 1;
    A = 0;
    n = __VERIFIER_nondet_int();
    while(n>0) {
      n--;
    }
    R = 1;
    R = 0;
  }
  while(1) { volatile int x; x=x; }
  return 0;
}
