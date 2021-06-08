#include "stdio.h"
#include "stdlib.h"

#define MEM_SIZE 256
#define SEED 10
#define RAND_LIMIT 1000000

void put_4bytes(FILE *data_mem, char *word)
{
  for(int i = 7; i > 0; i = i - 2)
    fprintf(data_mem,"%c%c\n", word[i-1], word[i]);
}

int main()
{
  int array_size_i;
  char array_size_s[8];
  FILE *data_mem;

  data_mem = fopen("data_mem.h", "w");
  
  printf("Tamanho da array: ");
  scanf("%d", &array_size_i);
  int teste = array_size_i; // BOTEI PQ NÃO FUNCIONA SEM
  sprintf(array_size_s, "%08x", teste);
  put_4bytes(data_mem, array_size_s);

  srand(SEED);
  for(int i = 1; i < MEM_SIZE; i++){
    if(i <= array_size_i){
      char word[8];
      int rand_word = rand() % RAND_LIMIT;
      sprintf(word, "%08x", rand_word);
      put_4bytes(data_mem, word);
    }
    else
      fprintf(data_mem, "00\n00\n00\n00\n");
  }

  fclose(data_mem);
  return 0;
}