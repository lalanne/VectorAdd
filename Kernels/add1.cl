
#ifdef __INT__
    #define TYPE int
#elif __FLOAT__
    #define TYPE float
#else
    #define TYPE float
#endif

__kernel
void add(__global TYPE* a, __global TYPE* b, __global TYPE* c){

    const uint gid = get_global_id(0);
    const uint id = gid*ELEMENTS_PER_WI;

    uint i;
    for(i=0; i<ELEMENTS_PER_WI; ++i){
        c[id+i] = a[id+i] + b[id+i];
    }
}
