#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mman.h>

// UNIX ONLY
// Compares the running times of reading a file using the C standard library (fopen, fgetc) and memory-mapping (mmap).

// Read 10k random characters from the file using library calls
void libRandomRead(const char* filename) {
  // open the file in read mode
  FILE* f = fopen(filename, "r");
  // for getting the filesize
  struct stat sb;

  // error-checking
  if (stat(filename, &sb) == -1) {
    perror("ERROR: Couldn't get filesize.\n");
    return;
  }

  // seed the random number generator - same seed as below (for a fair comparison)
  srand(50);

  // 10k times
  for (int i = 0; i < 10000; ++i) {
    // get a random, valid index
    int idx = rand() % sb.st_size;
    // go there
    fseek(f, idx, SEEK_SET);
    // read the character there and print it
    printf("%c", fgetc(f));
  }

  // never forget this!!!
  fclose(f);
}

// Read 10K random characters from the file using system calls
void sysRandomRead(const char* filename) {
  // open the file in read mode
  int f = open(filename, O_RDONLY);
  // for getting the filesize
  struct stat sb;

  // error-checking
  if (fstat(f, &sb) == -1) {
    perror("ERROR: Couldn't get filesize.\n");
    return;
  }

  // load the file into memory for reading
  char* fileInMemory = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, f, 0);

  // seed the random number generator - same seed as above (for a fair comparison)
  srand(50);

  // 10k times
  for (int i = 0; i < 10000; ++i) {
    // get a random, valid index
    int idx = rand() % sb.st_size;
    // read the character there and print it
    printf("%c", fileInMemory[idx]);
  }

  // never forget this!!!
  close(f);
}

// used to generate some data (see below)
void populateFile(const char*);

// DRIVER CODE
int main(int argc, char** argv) {
  // filename string
  char* filename;
  // timers
  clock_t start, end;

  // set the filename (or use the default)
  filename = (argc > 1) ? argv[1] : "demofile.txt";
  
  // if the filename is demofile.txt
  if (strcmp(filename, "demofile.txt") == 0) {
    // populate the file with some data
    populateFile(filename);
  }

  // LIBRARY CALL
  // start the timer
  start = clock();
  // do the job (library call)
  libRandomRead(filename);
  // end the timer
  end = clock();
  // get the time taken and display it
  double time_taken = (double)(end - start) / CLOCKS_PER_SEC;
  printf("\n\nlibRandomRead: Time taken: %f\n\n", time_taken);

  // SYSTEM CALL
  // start the timer
  start = clock();
  // do the job (system call)
  sysRandomRead(filename);
  // end the timer
  end = clock();
  // get the time taken and display it
  time_taken = (double)(end - start) / CLOCKS_PER_SEC;
  printf("\n\nsysRandomRead: Time taken: %f\n\n", time_taken);

  return 0;
}

// populates a dummy file (see the string for the developer's note) so that it just works out of the box
void populateFile(const char* filename) {
  // Create file
  int f = open(filename, O_RDWR | O_CREAT, 0666);
  // error-checking
  if (f == -1) {
    perror("ERROR: Couldn't create file.\n");
    return;
  }
  // our demo string... Also doubling as the developer's note
  char* line = "Some really long-winded, random, meaningless line we're going to be writing to the file repeatedly, because we don't have too much real world data we can take in this environment. You can test this program for real by copying some sizeable text from somewhere, putting it in a text file, and running this program on it. For now, we're going to stick to this not-so-substantive test string, because it's the best we've got for now.";
  // write line to the file 25k times
  for (int i = 0; i < 25000; ++i) {
    write(f, line, strlen(line));
  }

  // never forget this!!!
  close(f);
}
