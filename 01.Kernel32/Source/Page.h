#ifndef __PAGE_H__
#define __PAGE_H__

#include "Types.h"

// 매크로
#define PAGE_FLAGS_P		0x00000001	// Present
#define PAGE_FLAGS_RW		0x00000002	// Read/Write
#define PAGE_FLAGS_US		0x00000004 	// User/Supervisor(설정 시 유저레벨)
#define PAGE_FLAGS_PWT		0x00000008	// Page Level Write-Through
#define PAGE_FLAGS_PCD		0x00000010	// Page level Cache Disable
#define PAGE_FLAGS_A		0x00000020	// Accessed
#define PAGE_FLAGS_D		0x00000040	// Dirty
#define PAGE_FLAGS_PS		0x00000080	// Page Size
#define PAGE_FLAGS_G		0x00000100	// Global
#define PAGE_FLAGS_PAT		0x00001000	// Page Attribute Table Index
#define PAGE_FLAGS_EXB		0x80000000	// Execute Disable 비트
#define PAGE_FLAGS_DEFAULT	( PAGE_FLAGS_P | PAGE_FLAGS_RW )
#define PAGE_TABLESIZE		0x1000
#define PAGE_MAXENTRYCOUNT	512
#define PAGE_DEFAULTSIZE	0x200000 // 2MB

//structure alignment
#pragma pack( push, 1 )

//페이지 엔트리에 대한 자료구조
typedef struct kPageTableEntryStruct {
	// PML4T와 PDPTE의 경우 - 1bit P, RW, US, PWT, PCD, A, D, PSb, G, 3bit Avail, 1bit PAT, 8bit Reserved
	// 20bit Base Address

	// PDE의 경우 - 1bit P, RW, US, PWT, PCD, A, D, PS, G, 3bit Avail, 1bit PAT, 8bit Avail
	// 11bit Base Address
	DWORD dwAttributeAndLowerBaseAddress;
	// 8bit Upper Base Address, 12bit Reserved, 11bit Avail, 1bit EXB
	DWORD dwUpperBaseAddressAnxEXB;
} PML4TENTRY, PDPTENTRY, PDENTRY, PTENTRY; //PML4 Table Entry, Page Directory Pointer Table Entry, Page Directory Entry, Page Table Entry
#pragma pack( pop )

//함수
void kInitializePageTables(void);
void kSetPageEntryData(PTENTRY* pstEntry, DWORD dwUpperBaseAddress, DWORD dwLowerBaseAddress, DWORD dwLowerFlags, DWORD dwUpperFlags);

#endif /*__PAGE_H__*/
