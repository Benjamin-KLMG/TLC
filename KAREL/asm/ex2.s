@
@ Question 3.2.2
@
@ En utilisant une boucle, réalisez un programme permettant
@ au robot de se déplacer 5 fois vers le sud.
@
@
@ Question 3.2.2
@
@ En utilisant une boucle, réalisez un programme permettant
@ au robot de se déplacer 5 fois vers le sud.
@
_start:
		seti   r0, #1
		seti r1, #1
		seti r2,#5
		invoke	2, 0, 0
		invoke	2, 0, 0
		@invoke	1, 0, 0

	loop:
		
		goto_gt	end, r0, r2
		invoke	1, 0, 0
		add r0,r1,r0
		goto	loop	
		
	end:
	    stop
