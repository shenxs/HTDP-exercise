#include<stdio.h>
#include <stdlib.h>
#include "mpc.h"

#ifdef _WIN32
#include <string.h>
static char buffer[2048]

/* 自定义readline函数 */
char* readline(char* prompt){
  fputs(prompt, stdout);
  fgets(buffer, 2048, stdin);
  char* cpy = malloc(strlen(buffer)+1);
  strcpy(cpy, buffer);
  cpy[strlen(cpy)-1] = '\0';
  return cpy;
}

/*  自定义add_history function */
void add_history(char* unused) {}

#else
#include <editline/readline.h>
#endif

long eval(mpc_ast_t* t);
long eval_op(long x,char* op ,long y);

int main(int argc,char** argv){


  /* 创建parsers */
  mpc_parser_t* Number = mpc_new("number");
  mpc_parser_t* Operator = mpc_new("operator");
  mpc_parser_t* Expr= mpc_new("expr");
  mpc_parser_t* Lispy=mpc_new("lispy");

  mpca_lang(MPCA_LANG_DEFAULT,
            "                                                     \
    number   : /-?[0-9]+/ ;                                       \
    operator : '+' | '-' | '*' | '/' | '%' | \"add\" | \"sub\" | \"mul\" | \"div\";                  \
    expr     : <number> | '(' <operator> <expr>+ ')' ;  \
    lispy    : /^/ <operator> <expr>+ /$/ ;             \
  ",
            Number,Operator,Expr,Lispy);

  puts("MyLisp Version 0.0.0.0.1");
  puts("Press Ctrl+c to exit");

  while(1){
    char *input= readline("lispy>");

    add_history(input);

    mpc_result_t r;
    if(mpc_parse("<stdin>", input, Lispy, &r)){
      long result= eval(r.output);
      printf("%li\n", result);
      mpc_ast_delete(r.output);
    }else{
      mpc_err_print(r.error);
      mpc_err_delete(r.error);
    }
    free(input);
  }

  mpc_cleanup(4, Number,Operator,Expr,Lispy);
  return 0;
}
long eval(mpc_ast_t* t){
  /* 数字直接返回值 */
  if(strstr(t->tag, "number")){
    return  atoi(t->contents);
  }

  /* 表达式，计算其值 */
  char* op=t->children[1]->contents;

  long x =eval(t->children[2]);

  int i=3;
  while(strstr(t->children[i]->tag, "expr")){
    x=eval_op(x, op, eval(t->children[i]));
    i++;
  }
  return x;

}
long eval_op(long x, char* op, long y) {
  if (strcmp(op, "+") == 0 || strcmp(op, "add") == 0) { return x + y; }
  if (strcmp(op, "-") == 0 || strcmp(op, "sub") == 0) { return x - y; }
  if (strcmp(op, "*") == 0 || strcmp(op, "mul") == 0) { return x * y; }
  if (strcmp(op, "/") == 0 || strcmp(op, "div") == 0) { return x / y; }
  if (strcmp(op, "%") == 0) { return x % y; }
  return 0;
}