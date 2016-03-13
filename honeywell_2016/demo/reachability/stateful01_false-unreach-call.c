#include <assert.h>
#include <pthread.h>

int __VERIFIER_nondet_int();

pthread_mutex_t  ma, mb;
volatile int data1;
volatile int data2;

void * thread1(void * arg)
{  
  pthread_mutex_lock(&ma);
  data1++;
  pthread_mutex_unlock(&ma);

  pthread_mutex_lock(&ma);
  data2++;
  pthread_mutex_unlock(&ma);
}


void * thread2(void * arg)
{  
  data1 += 5;
  
  int diff;
  do {
      diff = __VERIFIER_nondet_int();
  } while(diff <= 0 || diff > 42);
  
  pthread_mutex_lock(&ma);
  data2 += diff;
  pthread_mutex_unlock(&ma);
}
ý

int main()
{
  pthread_t  t1, t2;

  pthread_mutex_init(&ma, 0);
  pthread_mutex_init(&mb, 0);

  data1 = 10;
  data2 = 10;

  pthread_create(&t1, 0, thread1, 0);
  pthread_create(&t2, 0, thread2, 0);
  
  pthread_join(t1, 0);
  pthread_join(t2, 0);
  
  assert(data1 == 16 && data2 >= 0);

  return 0;
}

