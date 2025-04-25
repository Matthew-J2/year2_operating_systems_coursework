section	.data 
welcome db "Welcome to my guessing game!", 10 ;Welcome message for game 

welcomeLen equ $-welcome ;Calculate the welcome message length 
samemsg db "You guessed correctly.", 10 ;Message that the guess is correct 
samelen equ $-samemsg ;Calculate the length of the message 

notsamemsg db "Your guess is incorrect.", 10 ;Message that the guess is incorrect  
notsamelen equ $-notsamemsg ;Calculate the length of the message 

question1 db "Guess a 5 letter capital city, player 1.", 10 ; Message asking question for player 1 
question1Len equ $-question1 ; Calculate the length of the message 

question2 db "Guess a 5 letter capital city, player 2.", 10 ; Message asking question for player 2 
question2Len equ $-question2 ; Calculate the length of the message 

cityMessage db "The city I was thinking of is: " ; Message explaining the letter that was selected 
cityMessageLen equ $-cityMessage ; calculate the length of the message 

yourScore1 db "Player 1, your score is: " ; Message telling player 1 their score 
yourScore1Len equ $-yourScore1 ; Calulate the length of the message 

yourScore2 db "Player 2, your score is: " ; Message telling player 2 their score 
yourScore2Len equ $-yourScore2 ; Calculate the length of the message 

cr db 10 ;for creating a new line same as endl in C++ 

correctCount1 db 0 ; Byte value that counts how many questions player 1 has answered correctly 
correctCount1Len equ $-correctCount1 ; Length of the value 

correctCount2 db 0 ; Byte value that counts how many questions player 2 has answered correctly 
correctCount2Len equ $-correctCount2 ; Length of the value 

;the array we are using to store the correct answers for the guessing game 
global listAnswers 
listAnswers:     
  dq  'Hanoi' ; the answer cities are stores in 8 bytes to aid the comparison that is why we are using the data type dq 
  dq  'Paris' 
  dq  'Cairo' 
  dq 'Tokyo' 
  dq 'Minsk' 
city:  
dq  0 ; where we store each of the answers one at a time 

section .bss 
guess1 resq 5  ; Variable to store player 1's guess 
guess2 resq 5  ; Variable to store player 2's guess 
printCountValue1 resb 1 ; Variable to store the ASCII value of player 1's score 
printCountValue2 resb 1 ; Variable to store the ASCII value of player 2's score 

section	.text 
   global _start   ;must be declared for linker (ld) 
_start:	 
call displayWelcome ; Displays welcome messsge 
call newLine    ;Prints newline 
mov  rax,5      ;number of answers and so possible questions 
mov  rbx,0      ;RBX will store the city currently being guessed 
mov  rcx, listAnswers     ;RCX will point to the current element in array to be guessed 

call top ; Calls main function which calls other functions. 

;Main function that calls other functions 
top:   
  mov  rbx, [rcx] ; put the current city being guessed in rbx 
  mov [city],rbx ; move rbx into a variable city that stores the current correct answer 
  push rax ; push rax on stack 
  push rcx ; push rax on stack 
  call displayQuestion1 ; call subroutine to display the question to player 1 
  call reading1 ; call subroutine to get player 1's guess and compare the guess with the correct answer 
  call displayQuestion2 ; call subroutine to display the question to player 2 
  call reading2 ; call subroutine to get player 2's guess and compare the guess with the correct answer 
  call displayCityMessage ; call subroutine to display the message for the correct answer 
  call display ; call subroutine to print the correct answer 
  call newLine ; new line like endl in C++ 
  pop rcx ; get back from stack 
  pop rax ; get back from stack 
  add  rcx,8     ;move pointer to next element in the array.  As 8 bits for each letter move on by 8 
  dec  rax        ;decrement counter by one so going down  
  jnz  top        ;if counter not 0, then loop again 
  call displayScore1 ; Displays the message for player 1's score 
  call score1 ; Displays player 1's score 
  call newLine ; Prints newline 
  call displayScore2 ; Displays the message for player 2's score 
  call score2 ; Displays player 2's score 
  call newLine ; Prints newline 
  call done ; call subroutine to end program 

;Display function 
display: 
  mov  edx,8      ;message length 
  mov  ecx, city   ;message to write the correct city 
  mov  ebx, 1     ;file descriptor (stdout) 
  mov  eax, 4     ;system call number (sys_write) 
  int  0x80       ;call kernel 
ret 

 ;function to read the user guess and do comparison with the answer 
 reading1: 
  mov eax, 3 ; read from keyboard 
  mov ebx, 2 ; stdin 
  mov ecx, guess1 ; move user guess into ecx 
  mov edx, 5 ;  As single city using 1 byte 
  int 80h	; invoke the kernel to get the user's guess 
  mov   rax, [guess1] ; move guess by player 1 into rax 
  cmp   rax, [city]  ; compare correct answer with what in rax 
  je    same1 ; if guess was correct jump to same function for player 1 
  call Notsame1 ; if the guess is incorrect then go to Notsame function for player 1 
  ret ; return to the main section 

 reading2: 
  mov eax, 3 ; read from keyboard 
  mov ebx, 2 ; stdin 
  mov ecx, guess2 ; move user guess into ecx 
  mov edx, 5 ;  As single city using 1 byte 
  int 80h	; invoke the kernel to get the user's guess 
  mov   rax, [guess2] ; move guess by player 2 into rax 
  cmp   rax, [city]  ; compare correct answer with what in rax 
  je    same2 ; if guess was correct jump to same function for player 2 
  call Notsame2 ; if the guess is incorrect then go to Notsame function for player 2 
  ret ; return to the main section  

; function to show message that answer was not correct answer 
 Notsame1: 
  mov   ecx,notsamemsg ; Not same message 
  mov   edx, notsamelen ; length of same message 
  mov   ebx,1	;file descriptor (stdout) 
  mov   eax,4	;system call number (sys_write) 
  int 80h ; invoke the kernel to display message 

  mov eax, 3 ; read to clear the keyboard buffer 
  mov ebx, 2 ;  stdin 
  mov ecx, guess1 ; Clear the key press from the user input so it does not mess up loop 
  mov edx, 1 ;  As single character using 1 byte 
  int 80h	; invoke the kernel to take the enter key press to clear the keyboard buffer 
   ret ; return to main code 

Notsame2: 
  mov   ecx,notsamemsg ; Not same message 
  mov   edx, notsamelen ; length of same message 
  mov   ebx,1	;file descriptor (stdout) 
  mov   eax,4	;system call number (sys_write) 
  int 80h ; invoke the kernel to display message 

  mov eax, 3 ; read to clear the keyboard buffer 
  mov ebx, 2 ;  stdin 
  mov ecx, guess2 ; Clear the key press from the user input so it does not mess up loop 
  mov edx, 1 ;  As single character using 1 byte 
  int 80h	; invoke the kernel to take the enter key press to clear the keyboard buffer 
   ret ; return to main code 

; function to show message answer was correct 
same1: 
  mov   ecx,samemsg ; same message 
  mov   edx, samelen ; length of same message 
  mov   ebx,1	;file descriptor (stdout) 
  mov   eax,4	;system call number (sys_write) 
  int 80h ; invoke the kernel to display message 
  mov eax, 3 ; read to clear the keyboard buffer 
  mov ebx, 2 ;  stdin 
  mov ecx, guess1 ; Clear the key press from the user input so it does not mess up loop 
  mov edx, 1 ;  As single character using 1 byte 
  int 80h	; invoke the kernel to take the enter key press to clear the keyboard buffer 
  inc byte [correctCount1] 
   ret ; return to main code 

; function to show message answer was correct 
same2: 
  mov   ecx,samemsg ; same message 
  mov   edx, samelen ; length of same message 
  mov   ebx,1	;file descriptor (stdout) 
  mov   eax,4	;system call number (sys_write) 
  int 80h ; invoke the kernel to display message 

  mov eax, 3 ; read to clear the keyboard buffer 
  mov ebx, 2 ;  stdin 
  mov ecx, guess2 ; Clear the key press from the user input so it does not mess up loop 
  mov edx, 1 ;  As single character using 1 byte 
  int 80h	; invoke the kernel to take the enter key press to clear the keyboard buffer 
  inc byte [correctCount2] 
   ret ; return to main code 

; Function to create a new line like endl in C++ 
 newLine: 
  mov eax,4 	; Put 4 in eax register into which is system  
               ;call for write (sys_write)	 
  mov ebx,1 	; Put 1 in ebx register which is the standard  
; output to the screen  
  mov ecx, cr	; Put the newline value into ecx register 
  mov edx, 1	; Put the length of the newline value into edx  
; register 
  int 80h 	; Call the kernel with interrupt to check the  
; registers and perform the action of moving to  
; the next line like endl in c++ 
   ret	; return to previous position in code  

;Function to display welcome to game message 
displayWelcome: 
   mov  edx,welcomeLen      ;message length 
   mov  ecx, welcome   ;message to write 
   mov  ebx, 1     ;file descriptor (stdout) 
   mov  eax, 4     ;system call number (sys_write) 
   int  0x80       ;invoke the kernel to print the message 
   ret ; return to the main section 

;Function to display question for player 1 
displayQuestion1: 
   mov  edx,question1Len      ;message length 
   mov  ecx, question1  ;message to write 
   mov  ebx, 1     ;file descriptor (stdout) 
   mov  eax, 4     ;invoke the kernel to print the message 
   int  0x80       ;call kernel 
   ret ; return to the main section 

;Function to display question for player 2 
displayQuestion2: 
   mov  edx,question2Len      ;message length 
   mov  ecx, question2  ;message to write 
   mov  ebx, 1     ;file descriptor (stdout) 
   mov  eax, 4     ;invoke the kernel to print the message 
   int  0x80       ;call kernel 
   ret ; return to the main section 

; Function to display the correct answer sentence 
displayCityMessage: 
   mov  edx,cityMessageLen      ;message length 
   mov  ecx, cityMessage  ;message to write 
   mov  ebx, 1     ;file descriptor (stdout) 
   mov  eax, 4     ;system call number (sys_write) 
   int  0x80       ;invoke the kernel to print the message 
   ret ; return to the main section 

; Function to display the score message for player 1 
displayScore1: 
   mov  edx, yourScore1Len      ;message length 
   mov  ecx, yourScore1  ;message to write 
   mov  ebx, 1     ;file descriptor (stdout) 
   mov  eax, 4     ;system call number (sys_write) 
   int  0x80       ;invoke the kernel to print the message 
   ret ; return to the main section 

; Function to display the score message for player 2 
displayScore2: 
   mov  edx, yourScore2Len      ;message length 
   mov  ecx, yourScore2  ;message to write 
   mov  ebx, 1     ;file descriptor (stdout) 
   mov  eax, 4     ;system call number (sys_write) 
   int  0x80       ;invoke the kernel to print the message 
   ret ; return to the main section 

; Function to display the score for player 1 
score1: 
  mov ecx, [correctCount1] ; Move player 1's current count into ecx 
  add ecx, 48 ; Add 48 to the value to convert it into its ASCII value 
  mov [printCountValue1], ecx ; Move ecx into printCountValue1 so that player 1's value can be printed 
  mov  edx, correctCount1Len   ;message length 
  mov  ecx, printCountValue1   ;Message to write the correct score 
  mov  ebx, 1     ;file descriptor (stdout) 
  mov  eax, 4     ;system call number (sys_write) 
  int  0x80       ;call kernel 
ret 

; Function to display the score for player 2 
score2: 
  mov ecx, [correctCount2] ; Move player 1's current count into ecx 
  add ecx, 48 ; Add 48 to the value to convert it into its ASCII value 
  mov [printCountValue2], ecx ; Move ecx into printCountValue2 so that player 2's value can be printed 
  mov  edx, correctCount2Len   ;message length 
  mov  ecx, printCountValue2   ;Message to write the correct score 
  mov  ebx, 1     ;file descriptor (stdout) 
  mov  eax, 4     ;system call number (sys_write) 
  int  0x80       ;call kernel 
ret 
; Function to end the program 
 done: 
   mov  eax, 1     ;system call number (sys_exit) 
   int  0x80       ;invoke the kernel to end the program 