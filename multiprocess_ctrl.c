// libraries for code 
#include <sys/ipc.h> 
#include <sys/sem.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <sys/shm.h> 
#include <stdint.h> 
#include "ops_sems.h" 
//Pointer to the file used to write the voter information to. 
FILE *fptr; 

//Size of the buffer - Changed to 10 
int bufferlength=10; 

int main(int argc, char argv[]){ 
    //The slot in the shared memory we are storing the  
    //store values, 11 and 12 store the index the producer  
    //and consumer are looking at). 
    int posprod=bufferlength+1; 
    //The slot in the shared memory we are storing the position of P2 along the shared memory 
    int poscon=bufferlength+2; 
    //Create shared memory segment 
    int shm_id=shmget(ftok("task3_.c",2),bufferlength, 0666|IPC_CREAT); 
    //Use our source file as the "key"             
    int id=ops_semget("task3_.c",1); 
    int* data; //For our pointer to shared memory... 
    shm_id=shmget(ftok("task3_.c",2),0,006); 
    //Attach the shared buffer 
    data = shmat(shm_id, (void *)0, 0); 
    //Allocate slot in shared memory to store position of P1 
    //Allocate slot in shared memory to store position of P2 
    data[posprod]=0; 
    data[poscon]=0; 
    //Initialize each cell of memory to 0. 
    for (int cell=0; cell <bufferlength; cell++){ 
        data[cell] = 0; 
    } 
    int booth_count = 0; 
    // Fork to create 2 processes 
    int pid=fork();   
    if(pid){ 
        //P1 - voting entry 
        int voterID; 
        while(1){ 
            //Call semaphore to block consumer 
            ops_wait(id); 
            //Print in producer critical section 
            printf("In critical section P1 ... \n"); 
            //When the producer is not at the max index, adds a voter. 
            if (data[posprod]!=bufferlength){ 
                //Checks if the current booth is empty 
                if (data[data[posprod]] == 0){ 
                    printf("Add your voter ID.\n"); 
                    scanf("%d", &voterID); 
                    //Put a value in the slot producer is pointing at 
                    data[data[posprod]]=voterID; 
                    //Keep track of number of booths, add one to number of booths if a voter enters a booth. 
                    if (booth_count < 10){ 
                        booth_count += 1; 
                    } 
                    printf("%d Voter(s) in the booth.\n", booth_count); 
                    //Sleep for 1 second 
                    sleep(1); 
                } 
                //Move position of producer on one along the shared memory 
                data[posprod]=data[posprod]+1; 
            } 
            else{ 
                printf("Booths are full. Please wait.\n"); 
            } 
            printf("Ending critical section P1 ... \n"); 
            ops_signal(id);   
        } 
    } 

    else{ 
        //P2 -vote chooser 
        while(1){ 
            //Initializes smallest variable, the booth with the smallest value inside it, the index used to find the smallest voterID, 
            //and the current position of the consumer. 
            int smallest = data[data[poscon]]; 
            int booth_smallest; 
            int i; 
            int prev_position = data[poscon]; 
            //Call Semaphore to block P1 
            ops_wait(id); 
       
            //Print in the critical section for P2 
            printf("In critical section P2 ... \n"); 

            //Finds the smallest voterID. 
            if (data[posprod] == bufferlength){ 
                printf("Reading shared memory for list of voters.\n"); 
                for (i = 0; i < data[posprod]; i++){ 
                    data[poscon] = i; 
                    if (smallest > data[data[poscon]]){ 
                        smallest = data[data[poscon]]; 
                        booth_smallest = data[poscon]; 
                    } 
                } 
                //Set P2 position to the smallest booth. 
                data[poscon] = booth_smallest; 
                printf("Voter %d, with voterID %d is now voting\n", booth_smallest, data[data[poscon]]); 

        //Sleep for 5 seconds 
        sleep(5); 
        printf("Voter has voted.\n"); 
        //print where P2 is along shared memory and print value that P2 is pointing at 
        printf("Print where consumer is along shared memory %d : Print value that consumer is pointing at %d \n", data[poscon],data[data[poscon]]); 

        //Creates pointer to the text file, checks if the file path is valid, prints the voterID to the file, and closes the file. 
        fptr = fopen("./VoterInfo.txt", "a"); 
        if (fptr == NULL){ 
          printf("Error recieving voter in booth %d's information. Please try again.\n", booth_smallest); 
        } 
        else{ 
          fprintf(fptr, "Voter with ID %d has voted.\n", smallest); 
          printf("Printing to file."); 
        } 
        fclose(fptr); 
        //Voter leaves the polling station, the booth count is decremented, and the value in the cell used to store the voter's ID is set to 0. 
        sleep(2); 
        printf("Voter is leaving.\n"); 
        data[poscon] = booth_smallest; 
        data[data[poscon]] = 0; 
        booth_count -= 1; 

        //Sets the producers position to where the cell which has been reset to 0, and returns the consumer's position to its previous value. 
        data[posprod] = data[poscon]; 
        data[poscon]= prev_position; 

      } 
      //If booths are not full, do not remove any more voters from the polling station. 
      else{ 
        printf("Checking cell %d.\n", data[posprod]); 
      } 
      //Print end critical section P2 
      printf("Ending critical section P2 ... \n"); 
      //End the semaphore and release P1 
      ops_signal(id); 
    } 
  }   
} 