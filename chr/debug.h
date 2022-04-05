#ifndef DEBUG_H
#define DEBUG_H

namespace debug {
inline bool myassert(bool b) {
    assert(b);
    return b;
}
}

#endif // DEBUG_H
