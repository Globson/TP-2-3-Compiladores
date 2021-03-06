%{
#define YYSTYPE char*
#include "tabela_simbolos.h"
#include <stdlib.h>
#include <stdio.h>
//#define YYDEBUG 1


#include <stdbool.h>
#include <string.h>
#include "valor_semantico.h"
//#include "error_messages.h"

#define YYSTYPE ValorSemantico

extern int yylex();
extern int yylineno;

void yyerror(const char* s) {
    printf("Programa sintaticamente incorreto!\n");
	fprintf(stderr,"Erro sintático na linha %d -> %s\n", yylineno,s);
	exit(1);
}

void Erro_N_Dec(const char* s) {
    printf("Programa sintaticamente incorreto!\n");
	fprintf(stderr,"Erro o identificador '%s' na linha %d nao foi declarado!\n", s, yylineno);
	exit(1);
}

void Erro_Redec(const char* s) {
    printf("Programa sintaticamente incorreto!\n");
	fprintf(stderr,"Erro o redeclaração do identificador '%s' na linha %d !\n", s, yylineno);
	exit(1);
}

Tabela_Simbolos TabelaSimbolos;

%}

%token INT
%token FLOAT
%token CHAR
%token STRING
%token BOOLEAN
%token VOID
%token RETURN
%token BREAK
%token CONTINUE
%token NOT
%token OR
%token AND
%token IF
%token ELSIF
%token ELSE
%token WHILE
%token NUM_I
%token NUM_F
%token STR
%token CH
%token TRUE
%token FALSE
%token ID
%token LE
%token GE
%token EQ
%token NE
%token ATRIBUI
%token MOD
%token GRT
%token LESS
%token ADD
%token SUB
%token DIV
%token MUL
%token ABREPARENTESES
%token FECHAPARENTESES
%token ABRECOLCHETES
%token FECHACOLCHETES
%token ABRECHAVES
%token FECHACHAVES 
%token PVIRGULA
%token VIRGULA

%start start
%%
start:
    | lista start


lista: dec_func
    | dec_var
    | ref_var
    | ref_func PVIRGULA
    | condicional

lista_escopo: dec_var lista_escopo
    | ref_var lista_escopo
    | ref_func PVIRGULA lista_escopo
    | condicional lista_escopo
    | comando lista_escopo
    | dec_var
    | ref_var
    | ref_func PVIRGULA
    | comando
    | condicional

dec_func: tipos_ids dec_id ABREPARENTESES dec_parametro FECHAPARENTESES ABRECHAVES lista_escopo FECHACHAVES

dec_parametro: 
    | tipos_ids dec_id   
    | tipos_ids dec_id VIRGULA dec_parametro

ref_parametro:
    | ref_id   
    | ref_id VIRGULA ref_parametro

dec_var: tipos_ids dec_id PVIRGULA
    | tipos_ids dec_id ATRIBUI valor_atrib PVIRGULA
    | tipos_ids dec_id ATRIBUI op PVIRGULA
    | tipos_ids dec_id ABRECOLCHETES NUM_I FECHACOLCHETES PVIRGULA

valor_atrib: valor {Adiciona_conteudo_em_entrada(&TabelaSimbolos, $1, 0);free($1);}


ref_var: ref_id ATRIBUI valor_ou_id PVIRGULA
    | ref_id ATRIBUI op PVIRGULA

ref_func: ref_id ABREPARENTESES ref_parametro FECHAPARENTESES

op: ops_c_parenteses
    | op_s_parenteses

ops_c_parenteses: ABREPARENTESES valor_ou_id op_arit valor_ou_id FECHAPARENTESES
    | ABREPARENTESES valor_ou_id op_arit valor_ou_id FECHAPARENTESES op_arit op
    | ABREPARENTESES valor_ou_id op_arit valor_ou_id FECHAPARENTESES op_arit valor_ou_id
    | ABREPARENTESES valor_ou_id op_arit op FECHAPARENTESES
    | ABREPARENTESES valor_ou_id op_arit op FECHAPARENTESES op_arit op
    | ABREPARENTESES valor_ou_id op_arit op FECHAPARENTESES op_arit valor_ou_id
    | ABREPARENTESES ops_c_parenteses FECHAPARENTESES
    | ABREPARENTESES ops_c_parenteses FECHAPARENTESES op_arit op
    | ABREPARENTESES ops_c_parenteses FECHAPARENTESES op_arit valor_ou_id

op_s_parenteses: valor_ou_id op_arit valor_ou_id
    | valor_ou_id op_arit op

op_arit: ADD
    | SUB
    | MUL
    | DIV
    | MOD

valor: NUM_F
    | NUM_I
    | STR
    | TRUE
    | FALSE
    | CH

valor_ou_id: valor
    | ABREPARENTESES SUB ref_id FECHAPARENTESES
    | SUB ref_id
    | ref_id
    | ABREPARENTESES SUB ref_func FECHAPARENTESES
    | SUB ref_func
    | ref_func

tipos_ids:INT {
        Adiciona_tipo_tabela(&TabelaSimbolos,"int");
        }
    | FLOAT {
        Adiciona_tipo_tabela(&TabelaSimbolos,"float");
        }
    | STRING {
        Adiciona_tipo_tabela(&TabelaSimbolos,"string");
        }
    | CHAR {
        Adiciona_tipo_tabela(&TabelaSimbolos,"char");
        }
    | BOOLEAN {
        Adiciona_tipo_tabela(&TabelaSimbolos,"boolean");
        }
    | VOID {
        Adiciona_tipo_tabela(&TabelaSimbolos,"void");
        } 

dec_id: ID {
        if(!Entrada_Existente_Tabela(&TabelaSimbolos,$1)){
            Adiciona_Entrada_Tabela_Simbolos(&TabelaSimbolos,$1);
        }
        else{
            Erro_Redec($1);
        }
        free($1);
    }

ref_id: ID {
	if(!Entrada_Existente_Tabela(&TabelaSimbolos,$1)){
		Erro_N_Dec($1);
    }
	free($1);	
}
    | ID ABRECOLCHETES NUM_I FECHACOLCHETES {
        if(!Entrada_Existente_Tabela(&TabelaSimbolos,$1)){
		Erro_N_Dec($1);
    }
	free($1);
    }

comando: RETURN valor_ou_id PVIRGULA
    | RETURN op PVIRGULA
    | RETURN PVIRGULA
    | CONTINUE PVIRGULA
    | BREAK PVIRGULA

expressao_logica: valor_ou_id op_logica valor_ou_id

expressao_relacional: expressao_relacional_s_parenteses
    | expressao_relacional_c_parenteses

expressao_relacional_c_parenteses:  ABREPARENTESES expressao_logica FECHAPARENTESES op_relacional expressao_relacional 
    | ABREPARENTESES expressao_relacional_c_parenteses FECHAPARENTESES
    | ABREPARENTESES expressao_relacional_c_parenteses FECHAPARENTESES op_relacional expressao_relacional 
    | ABREPARENTESES expressao_logica FECHAPARENTESES
    | NOT ABREPARENTESES expressao_logica FECHAPARENTESES op_relacional expressao_relacional 
    | NOT ABREPARENTESES expressao_relacional_c_parenteses FECHAPARENTESES
    | NOT ABREPARENTESES expressao_relacional_c_parenteses FECHAPARENTESES op_relacional expressao_relacional 
    | NOT ABREPARENTESES expressao_logica FECHAPARENTESES

expressao_relacional_s_parenteses: expressao_logica op_relacional expressao_relacional
    | expressao_logica
    | NOT expressao_logica op_relacional expressao_relacional
    | NOT expressao_logica 

op_relacional: OR
    | AND

op_logica: GRT
    | LESS
    | LE
    | GE
    | EQ
    | NE

condicional: op_condicao ABREPARENTESES expressao_relacional FECHAPARENTESES ABRECHAVES lista_escopo FECHACHAVES
    | ELSE ABRECHAVES lista_escopo FECHACHAVES

op_condicao: IF
    | ELSIF
    | WHILE

%%

int main() {
	Nova_Tabela(&TabelaSimbolos);
	yyparse();
	printf("Programa sintaticamente correto!\n");
	Printa_Tabela_Simbolos(&TabelaSimbolos);

	return 0;
}
