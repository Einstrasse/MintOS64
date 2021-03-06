/*
 * ModeSwitch.h
 *
 *  Created on: 2018. 2. 2.
 *      Author: hg958
 */

#ifndef __MODESWITCH_H__
#define __MODESWITCH_H__

#include "Types.h"

void kReadCPUID( DWORD dwEAX, DWORD* pdwEAX, DWORD* pdwEBX, DWORD* pdwECX, DWORD* pdwEDX );
void kSwitchAndExecute64bitKernel(void);

#endif /* 01_KERNEL32_SOURCE_MODESWITCH_H_ */
