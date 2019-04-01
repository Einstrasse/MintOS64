#ifndef __ASM_UTILS_H__
#define __ASM_UTILS_H__


#include "Types.h"

BYTE kInPortByte(WORD wPort);
void kOutPortByte(WORD wPort, BYTE bData);

#endif /*__ASM_UTILS_H__*/