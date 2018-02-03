#include "Types.h"
#include "Page.h"
#include "ModeSwitch.h"

void kPrintString( int iX, int iY, const char* pcString );
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);
void kCopyKernel64ImageTo2Mbyte(void);

// Main 함수
void Main(void) {
	DWORD dwEAX, dwEBX, dwECX, dwEDX;
	char vcVendorString[13] = { 0, };

	kPrintString(0, 3, "Protected Mode C Language Kernel Start......[Pass]" );

	//최소 메모리 크기인 64MB를 넘는지 검사
	kPrintString(0, 4, "Minimum Memory Size Check...................[    ]");
	if ( kIsMemoryEnough() == FALSE ) {
		kPrintString(45, 4, "Fail");
		kPrintString(0, 5, "Not Enough Memory. MING64 OS Requires at least 64MB Memory");
		while(TRUE);
	} else {
		kPrintString(45, 4, "Pass");
	}

	// IA-32e 모드의 커널 영역을 초기화
	kPrintString(0, 5, "IA-32e Kernel Area Initialization...........[    ]");
	if (kInitializeKernel64Area() == FALSE) {
		kPrintString(45, 5, "Fail");
		kPrintString(0, 6, "Kernel Area Initialization Failed. Cannot Boot MIN64 OS");
		while(TRUE);
	} else {
		kPrintString(45, 5, "Pass");
	}

	// IA-32e 모드의 커널을 위한 페이지 테이블 생성
	kPrintString(0, 6, "Page Tables Initialize......................[    ]");
	kInitializePageTables();
	kPrintString( 45, 6, "Pass" );

	// 프로세서 벤더 정보 읽기
	kReadCPUID( 0x00, &dwEAX, &dwEBX, &dwECX, &dwEDX );
	*(DWORD*) vcVendorString = dwEBX;
	*( (DWORD*) vcVendorString + 1 ) = dwEDX;
	*( (DWORD*) vcVendorString + 2 ) = dwECX;
	kPrintString(0, 7, "Processor Vendor String.....................[            ]");
	kPrintString(45, 7, vcVendorString);

	//64비트 지원 유무 확인
	kReadCPUID(0x80000001, &dwEAX, &dwEBX, &dwECX, &dwEDX);
	kPrintString(0, 8, "64bit Mode Support Check....................[    ]");
	if ( dwEDX & (1 << 29 )) {
		kPrintString(45, 8, "Pass");
	} else {
		kPrintString(45, 8, "Fail");
		kPrintString(0, 9, "This processor does not support 64bit mode!");
		while( TRUE );
	}

	//IA-32e 모드 커널을 0x200000(2MByte) 어드레스로 이동
	kPrintString(0, 9, "Copy IA-32e Kernel to 2M Address............[    ]");
	kCopyKernel64ImageTo2Mbyte();
	kPrintString(45, 9, "Pass");
	//IA-32e 모드로 전환
	kPrintString(0, 10, "Switch To IA-32e Mode");
	kSwitchAndExecute64bitKernel();


	while ( TRUE ) ;

}

//문자열 출력 함수
void kPrintString( int iX, int iY, const char* pcString ) {
	CHARACTER* pstScreen = ( CHARACTER* ) 0xB8000;
	int i;

	pstScreen += ( iY * 80 ) + iX;
	for ( i = 0 ; pcString[i] != 0 ; i++ ) {
		pstScreen[i].bCharactor = pcString[i];
	}
}
//IA-32e 모드용 커널 영역을 0으로 초기화. 성공시 True, 실패시 False 반환
BOOL kInitializeKernel64Area(void) {
	DWORD* pdwCurrentAddress;
	pdwCurrentAddress = (DWORD*) 0x100000;

	while ( (DWORD)pdwCurrentAddress < 0x600000) {
		*pdwCurrentAddress = (DWORD)0x0;

		if (*pdwCurrentAddress != (DWORD)0x0) return FALSE;
		pdwCurrentAddress += 1;

	}
	return TRUE;

}
BOOL kIsMemoryEnough(void) {
	DWORD* pdwCurrentAddress;

	pdwCurrentAddress = (DWORD*) 0x100000; // 1MB부터 검사 시작

	while ( (DWORD)pdwCurrentAddress < 0x4000000 ) {
		*pdwCurrentAddress = 0x12345678;
		if ( *pdwCurrentAddress != 0x12345678 ) {
			return FALSE;
		}
		pdwCurrentAddress += ( 0x100000 / sizeof(DWORD) );
	}
	return TRUE;
}

void kCopyKernel64ImageTo2Mbyte(void) {
	WORD wKernel32SectorCount, wTotalKernelSectorCount, wKernel64SectorCount;
	DWORD* pdwSourceAddress, *pdwDestinationAddress;
	int i;
	wTotalKernelSectorCount = *( (WORD*) 0x7C05 );
	wKernel32SectorCount = *( (WORD*) 0x7C07 );
	wKernel64SectorCount = wTotalKernelSectorCount - wKernel32SectorCount;
	pdwSourceAddress = (DWORD*)(0x10000 + wKernel32SectorCount * 512);
	pdwDestinationAddress = (DWORD*) 0x200000;

	for (i=0; i < 512 * wKernel64SectorCount / sizeof(DWORD); i++) {
		*pdwDestinationAddress = *pdwSourceAddress;
		pdwDestinationAddress++;
		pdwSourceAddress++;
	}
}
