
%{

open Quad
open Common
open Comp
open Karel


%}

%token BEGIN_PROG
%token BEGIN_EXEC
%token END_EXEC
%token END_PROG

%token MOVE
%token TURN_LEFT
%token TURN_OFF

%token SEMI
%token BEGIN
%token END

%token PICK_BEEPER
%token PUT_BEEPER
%token NEXT_TO_A_BEEPER
%token NOT_NEXT_TO_A_BEEPER

%token FRONT_IS_CLEAR
%token FRONT_IS_BLOCKED
%token LEFT_IS_CLEAR
%token LEFT_IS_BLOCKED
%token RIGHT_IS_CLEAR
%token RIGHT_IS_BLOCKED
%token FACING_NORTH
%token NOT_FACING_NORTH
%token FACING_EAST
%token NOT_FACING_EAST

%token FACING_SOUTH
%token NOT_FACING_SOUTH

%token FACING_WEST
%token NOT_FACING_WEST

%token ANY_BEEPERS_IN_BEEPER_BAG
%token NO_BEEPERS_IN_BEEPER_BAG

%token TIMES
%token ITERATE

%token DO
%token MOVE
%token WHILE

%token IF

%token THEN

%token <int> INT

%token <string> ID
%token ELSE

%token DEFINE_NEW_INSTRUCTION
%token AS

%type <unit> prog
%start prog

%%

prog:	BEGIN_PROG sub_prog_potent BEGIN_EXEC stmts_opt END_EXEC END_PROG
			{ () }

;

stmts_opt:	/* empty */	{ () }
|			stmts			{ () }

;




stmts:		stmt			{ () }
|			stmts SEMI stmt	{ () }
|			stmts SEMI		{ () }


;

stmt:		simple_stmt
				{ () }
|
	ITERATE int_define TIMES stmt  {
			let adr_GOTO_INT = snd $2 in
			let count = fst $2 in
			let decrement = new_temp() in
			let _ = gen(SETI(decrement,1)) in
			let _ = gen(SUB(count,count,decrement)) in
			let _ = gen( GOTO(adr_GOTO_INT) )in (* nous ramene au debut de ITERATE*)
		  backpatch adr_GOTO_INT (nextquad())  
		}

| BEGIN stmts	END {()}

|	WHILE if_test DO stmt { let _ = gen(GOTO(($2)-2)) in backpatch $2 (nextquad())}

| ID{let adr_func = get_define $1 in 
           gen (CALL(adr_func))
		}

|IF if_test THEN stmt {backpatch $2 (nextquad())}

|IF if_test THEN if_complet endif_adr ELSE stmt {let _ = backpatch $2 $5 in backpatch (($5)-1) (nextquad())}


;

if_complet:	simple_stmt{ () }
|
     IF if_test THEN if_complet endif_adr ELSE  if_complet { let _ = backpatch $2 $5 in backpatch (($5)-1) (nextquad())}

|     ITERATE int_define TIMES if_complet {  		
		
		let adr_GOTO_INT = snd $2 in
			let count = fst $2 in
			let decrement = new_temp() in
			let _ = gen(SETI(decrement,1)) in
			let _ = gen(SUB(count,count,decrement)) in
			let _ = gen( GOTO(adr_GOTO_INT) )in (* nous ramene au debut de ITERATE*)
		  backpatch adr_GOTO_INT (nextquad()) 
			 }

| ID{let adr_func = get_define $1 in 
           gen (CALL(adr_func))
		}
|     WHILE if_test DO if_complet  {let _ = gen(GOTO(($2)-2)) in backpatch $2 (nextquad()) }

|     BEGIN stmts END   {}
;



if_test: test 	{
			let testif = new_temp() in
			let _ = gen (SETI(testif,0) ) in
			let adr_GOTO = nextquad () in  (* l'adresse de la prochaine instruction du gGOTO_EQ *)
			let _ = gen (GOTO_EQ(0,$1,testif)) in
			adr_GOTO
		}
;

while_test: test  {
			let testif = new_temp() in
			let _ = gen (SETI(testif,0) ) in
			let adr_GOTO = nextquad () in  (* l'adresse de la prochaine instruction du gGOTO_EQ *)
			let _ = gen (GOTO_EQ(0,$1,testif)) in
			adr_GOTO
    }
;



endif_adr : /* empty*/{
											let _= gen( GOTO(0)) in 
											nextquad()

											  }

int_define:
	INT{
			let count=new_temp() in (* le nombre d'iteration a faitre*)
			let _ = gen(SETI(count,$1)) in
			let endTest = new_temp() in 
			let _ =gen(SETI(endTest,0)) in
			let adr_GOTO=nextquad() in
			let _ = gen (GOTO_EQ(0,count,endTest)) in
			count,adr_GOTO
	}
;



simple_stmt: TURN_LEFT
				{ gen (INVOKE (turn_left, 0, 0)) }
|			TURN_OFF
				{ gen STOP  }
|			MOVE
				{ gen (INVOKE (move, 0, 0)) }

|			PICK_BEEPER {  gen ( INVOKE (pick_beeper, 0, 0)) }

|			PUT_BEEPER { gen ( INVOKE (put_beeper, 0, 0)) }

|			NEXT_TO_A_BEEPER { print_string " NEXT_TO_A_BEEPER " }


;


define_Id:ID{
			if(is_defined $1)then (raise (SyntaxError "Sous programme deja defini")) 
			else
			let adr = nextquad() in
			let _ = gen (GOTO(0)) in
			let _ = define $1 (nextquad()) in
			adr 

}

define_new: 
		DEFINE_NEW_INSTRUCTION define_Id AS   stmts{ let _ = gen (RETURN) in backpatch $2 (nextquad())}   

 ;


sub_prog_potent: /* potentielement vide */ {()}

| sub_prog_potent define_new {()}


;



test: 

		FRONT_IS_CLEAR { let b =new_temp() in gen( INVOKE(is_clear,front,b)); b }
|
 		FRONT_IS_BLOCKED {let b =new_temp() in gen ( INVOKE(is_blocked,front,b)); b}
|	
		LEFT_IS_CLEAR { let b =new_temp() in gen ( INVOKE(is_clear,left,b)) ;b}
|	
		LEFT_IS_BLOCKED { let b =new_temp() in gen (INVOKE(is_blocked,left,b)) ;b}
|	
		RIGHT_IS_CLEAR { let b =new_temp() in gen ( INVOKE(is_clear,right,b));b }
|	
		RIGHT_IS_BLOCKED { let b =new_temp() in gen ( INVOKE(is_blocked,right,b));b }
|	
		FACING_NORTH { let b =new_temp() in gen (INVOKE(facing,north,b) ) ;b}
|	
		NOT_FACING_NORTH { let b =new_temp() in gen (INVOKE(not_facing,north,b)) ;b}
|	
		FACING_EAST { let b =new_temp() in gen  (INVOKE(facing,east,b)) ;b}
|	
		NOT_FACING_EAST { let b =new_temp() in gen  (INVOKE(not_facing,east,b)) ;b}
|
		FACING_SOUTH { let b =new_temp() in gen  ( INVOKE(facing,south,b)) ;b}
|
		NOT_FACING_SOUTH { let b =new_temp() in gen  ( INVOKE(not_facing,south,b));b }
|
		FACING_WEST { let b =new_temp() in gen  (INVOKE(facing,west,b)); b}
|
		NOT_FACING_WEST { let b =new_temp() in gen  ( INVOKE(not_facing,west,b)) ;b}
|
		ANY_BEEPERS_IN_BEEPER_BAG { let a =new_temp() in gen  ( INVOKE(any_beeper,a,0)) ;a}
|
		NO_BEEPERS_IN_BEEPER_BAG { let a =new_temp() in gen  (INVOKE(no_beeper,a,0)) ;a}

|		NOT_NEXT_TO_A_BEEPER { let a = new_temp() in gen  (INVOKE(no_next_beeper,a,0)) ;a}

|		NEXT_TO_A_BEEPER { let a = new_temp() in gen  (INVOKE(next_beeper,a,0)) ;a}

; 
