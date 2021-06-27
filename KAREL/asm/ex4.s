@
@ Question 5.2
@
@ Ecrivez un programme qui fait un parcours vertical depuis
@ sa position courante jusqu’à ce qu’il trouve un beeper.
@ Il partira vers le nord puis, quand il trouvera un mur,
@ il tournera à gauche et avancera avant de repartir vers
@ le sud et ainsi de suite.
@
_start:
		seti r0,#0
		seti r1,#0
		seti r2, #2
		seti r3,#3
		seti r4,#4
		seti r5,#0
		seti r6, #2

		
		loop:
			invoke 6,1,5
			goto_ne debut ,r5, r0
			invoke 1,0,0
			invoke 11,1,0
			goto_ne end,r1,r0
			


			goto loop

			debut:

			goto_eq nord, r6, r4
			goto_eq sud, r6, r2
			nord:	
				invoke 2,0,0
				
				invoke 2,0,0
				invoke 2,0,0
				invoke 1,0,0
				invoke 2,0,0
				invoke 2,0,0
				invoke 2,0,0
				seti r6,#2
				goto loop

			
				sud:
				invoke 2,0,0
				invoke 1,0,0
				invoke 2,0,0
				seti r6,#4

				goto loop
		end:
	stop
