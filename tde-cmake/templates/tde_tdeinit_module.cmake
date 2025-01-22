#include <tdemacros.h>
extern "C" int kdemain(int argc, char* argv[]);
extern "C" TDE_EXPORT int tdeinitmain(int argc, char* argv[]) { return kdemain(argc,argv); }
