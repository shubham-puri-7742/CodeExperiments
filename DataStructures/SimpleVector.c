#include<stdio.h>
#include<stdlib.h>

// MACROS
#define VECTOR_INIT_CAPACITY 5
#define UNDEFINED -1
#define SUCCESS 0

#define vector(vec) vector vec;\
__vector_init(&vec)

// tracks stored data
typedef struct sVectorList {
    void** items;
    int capacity;
    int total;
} sVectorList;

// contains the function pointers (because we can't have functions inside structs in C)
typedef struct sVector vector;
struct sVector {
    sVectorList vectorList;

    // function pointers
    int (*Size) (vector*);
    int (*Resize) (vector*, int);
    int (*PushBack) (vector*, void*);
    int (*PopBack) (vector*);
    int (*SetElem) (vector*, int, void*);
    void* (*At) (vector*, int);
    int (*DeleteElem) (vector*, int);
    int (*Clear) (vector*);
};

// internal function (see function pointer initialisations in the init function)
// gets the size of the vector
int __vectorSize(vector* v) {
    // a return value of -1 => error state
    return (v) ? v->vectorList.total : UNDEFINED;
}

// internal function (see function pointer initialisations in the init function)
// resizes the vector to the capacity passed as an argument
int __vectorResize(vector* v, int capacity) {
    // a return value of -1 => error state
    int status = UNDEFINED;
    // if a valid vector
    if (v) {
        // dynamically allocate the required amount of memory
        void** items = realloc(v->vectorList.items, sizeof (void*) * capacity);
        // if the items are valid (the reallocation succeeded)
        if (items) {
            // set the internal variables and capacity
            v->vectorList.items = items;
            v->vectorList.capacity = capacity;
            // set the success state
            status = SUCCESS;
        }
    }
    return status;
}

// internal function (see function pointer initialisations in the init function)
// pushes an element to the back of the vector
int __vectorPushBack(vector* v, void* item) {
    // a return value of -1 => error state
    int status = UNDEFINED;
    // if a valid vector
    if (v) {
        // if the vector is full
        if (v->vectorList.capacity == v->vectorList.total) {
            // try to resize the vector to twice the current capacity (store in a variable because the operation could fail)
            status = __vectorResize(v, v->vectorList.capacity * 2);
            // if the operation succeeded
            if (status != UNDEFINED) {
                // add the item at the end (back) of the vector and increment the total number of elements
                v->vectorList.items[v->vectorList.total++] = item;
            }
        } else {
            // add the item at the end (back) of the vector and increment the total number of elements
            v->vectorList.items[v->vectorList.total++] = item;
            // set the success state
            status = SUCCESS;
        }
    }
    return status;
}

// internal function (see function pointer initialisations in the init function)
// pops the back element (and sets it to NULL)
int __vectorPopBack(vector* v) {
    // a return value of -1 => error state
    int result = UNDEFINED;
    // if a valid vector
    if (v) {
        // set the last element to NULL and decrement the total number of elements
        v->vectorList.items[--v->vectorList.total] = NULL;
        
        // if there are some elements in the vector and the number of elements reduces to 1/4 the capacity
        if ((v->vectorList.total > 0) && ((v->vectorList.total) == (v->vectorList.capacity / 4))) {
            // halve the capacity to save precious memory
            __vectorResize(v, v->vectorList.capacity / 2);
        }
        // set the success state
        result = SUCCESS;
    }
    return result;
}

// internal function (see function pointer initialisations in the init function)
// sets the element at the specified index with a given value
int __vectorSet(vector* v, int idx, void* item) {
    // a return value of -1 => error state
    int status = UNDEFINED;
    // if a valid vector
    if (v) {
        // if a valid index
        if ((idx >= 0) && (idx < v->vectorList.total)) {
            // set the item at the specified index
            v->vectorList.items[idx] = item;
            // set the success state
            status = SUCCESS;
        }
    }
    return status;
}

// internal function (see function pointer initialisations in the init function)
// gets the element at the specified index
void* __vectorGet(vector* v, int idx) {
    // a return value of NULL => error state
    void* readData = NULL;
    // if a valid vector
    if (v) {
        // if a valid index
        if ((idx >= 0) && (idx < v->vectorList.total)) {
            // read the data at the index (which becomes the success state)
            readData = v->vectorList.items[idx];
        }
    }
    return readData;
}

// internal function (see function pointer initialisations in the init function)
// deletes the element at the specified index
int __vectorDelete(vector* v, int idx) {
    // a return value of -1 => error state
    int status = UNDEFINED;
    // if a valid vector
    if (v) {
        // if an invalid index
        if ((idx < 0) && (idx >= v->vectorList.total)) {
            // return the failure state
            return status;
        }
        
        // set the element at the specified index to NULL
        v->vectorList.items[idx] = NULL;

        // for every element after it
        for (int i = idx; i < (v->vectorList.total - 1); ++i) {
            // move it one index behind
            v->vectorList.items[i] = v->vectorList.items[i + 1];
            // and set the element ahead to NULL
            v->vectorList.items[i + 1] = NULL;
        }
        
        // decrement the total number of elements
        --v->vectorList.total;

        // if there are some elements in the vector and the number of elements reduces to 1/4 the capacity
        if ((v->vectorList.total > 0) && ((v->vectorList.total) == (v->vectorList.capacity / 4))) {
            // halve the capacity to save precious memory
            __vectorResize(v, v->vectorList.capacity / 2);
        }
        // set the success state
        status = SUCCESS;
    }
    return status;
}

// internal function (see function pointer initialisations in the init function)
// clears the vector
int __vectorFree(vector* v) {
    // a return value of -1 => error state
    int status = UNDEFINED;
    // if a valid vector
    if (v) {
        // free the allocated memory
        free(v->vectorList.items);
        // set the items pointer to NULL
        v->vectorList.items = NULL;
        // set the success state
        status = SUCCESS;
    }
    return status;
}

// vector initialisation
// binds the function pointers and assigns initial values to variables
// allocates memory for VECTOR_INIT_CAPACITY items by default
void __vector_init(vector* v) {
    // initialise function pointers
    v->Size = __vectorSize;
    v->Resize = __vectorResize;
    v->PushBack = __vectorPushBack;
    v->PopBack = __vectorPopBack;
    v->SetElem = __vectorSet;
    v->At = __vectorGet;
    v->DeleteElem = __vectorDelete;
    v->Clear = __vectorFree;
    // initialise the capacity and allocate the requisite memory
    v->vectorList.capacity = VECTOR_INIT_CAPACITY;
    v->vectorList.total = 0; // no items yet
    v->vectorList.items = malloc(sizeof(void*) * v->vectorList.capacity);
}

// Example driver code
int main() {
    // initialise the vector with some example data
    vector(vec);
    vec.PushBack(&vec, "some string");
    vec.PushBack(&vec, "another string");
    vec.PushBack(&vec, "a third string");
    vec.PushBack(&vec, "a crazy fourth string");
    vec.PushBack(&vec, "a fifth string!?!?");
    vec.PushBack(&vec, "are you even serious?");

    // display the vector
    printf("PRINTING THE ORIGINAL VECTOR\nFirst element: %s\n", (char*)vec.At(&vec, 0));
    for (int i = 0; i < vec.Size(&vec); ++i) {
        printf("%s\n", (char*)vec.At(&vec, i));
    }

    // make some changes - change the third (index 2) element, pop the back element, delete the first (index 0) element
    printf("\nNOW MAKING SOME CHANGES...\n");
    vec.SetElem(&vec, 2, "new third (index 2) string");
    vec.PopBack(&vec);
    vec.DeleteElem(&vec, 0);

    // display the modified vector
    printf("PRINTING THE ORIGINAL VECTOR\nFirst element: %s\n", (char*)vec.At(&vec, 0));
    for (int i = 0; i < vec.Size(&vec); ++i) {
        printf("%s\n", (char*)vec.At(&vec, i));
    }
    
    // clear the vector
    vec.Clear(&vec);
    
    return 0;
}