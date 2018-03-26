#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* say_hello(char* name) {
  char* greeting = calloc(100, 1);
  strcpy(greeting, "Hello, ");

  strcat(greeting, name);

  return greeting;
}
