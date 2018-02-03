#include "Types.h"
#include "Page.h"
#include "ModeSwitch.h"

void kPrintString( int iX, int iY, const char* pcString );
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);
// Main �Լ�
void Main(void) {
	DWORD dwEAX, dwEBX, dwECX, dwEDX;
	char vcVendorString[13] = { 0, };

	kPrintString( 0, 3, "C Language Kernel Started...................[Pass]" );

	//�ּ� �޸� ũ���� 64MB�� �Ѵ��� �˻�
	kPrintString(0, 4, "Minimum Memory Size Check...................[    ]");
	if ( kIsMemoryEnough() == FALSE ) {
		kPrintString(45, 4, "Fail");
		kPrintString(0, 5, "Not Enough Memory. MING64 OS Requires at least 64MB Memory");
		while(TRUE);
	} else {
		kPrintString(45, 4, "Pass");
	}

	// IA-32e ����� Ŀ�� ������ �ʱ�ȭ
	kPrintString(0, 5, "IA-32e Kernel Area Initialization...........[    ]");
	if (kInitializeKernel64Area() == FALSE) {
		kPrintString(45, 5, "Fail");
		kPrintString(0, 6, "Kernel Area Initialization Failed. Cannot Boot MIN64 OS");
		while(TRUE);
	} else {
		kPrintString(45, 5, "Pass");
	}

	// IA-32e ����� Ŀ���� ���� ������ ���̺� ����
	kPrintString(0, 6, "Page Tables Initialize......................[    ]");
	kInitializePageTables();
	kPrintString( 45, 6, "Pass" );

	// ���μ��� ���� ���� �б�
	kReadCPUID( 0x00, &dwEAX, &dwEBX, &dwECX, &dwEDX );
	*(DWORD*) vcVendorString = dwEBX;
	*( (DWORD*) vcVendorString + 1 ) = dwEDX;
	*( (DWORD*) vcVendorString + 2 ) = dwECX;
	kPrintString(0, 7, "Processor Vendor String.....................[            ]");
	kPrintString(45, 7, vcVendorString);

	//64��Ʈ ���� ���� Ȯ��
	kReadCPUID(0x80000001, &dwEAX, &dwEBX, &dwECX, &dwEDX);
	kPrintString(0, 8, "64bit Mode Support Check....................[    ]");
	if ( dwEDX & (1 << 29 )) {
		kPrintString(45, 8, "Pass");
	} else {
		kPrintString(45, 8, "Fail");
		kPrintString(0, 9, "This processor does not support 64bit mode!");
		while( TRUE );
	}

	//IA-32e ���� ��ȯ
	kPrintString(0, 9, "Switch To IA-32e Mode");
	// kSwitchAndExecute64bitKernel();


	while ( TRUE ) ;

}

//���ڿ� ��� �Լ�
void kPrintString( int iX, int iY, const char* pcString ) {
	CHARACTER* pstScreen = ( CHARACTER* ) 0xB8000;
	int i;

	pstScreen += ( iY * 80 ) + iX;
	for ( i = 0 ; pcString[i] != 0 ; i++ ) {
		pstScreen[i].bCharactor = pcString[i];
	}
}
//IA-32e ���� Ŀ�� ������ 0���� �ʱ�ȭ. ������ True, ���н� False ��ȯ
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

	pdwCurrentAddress = (DWORD*) 0x100000; // 1MB���� �˻� ����

	while ( (DWORD)pdwCurrentAddress < 0x4000000 ) {
		*pdwCurrentAddress = 0x12345678;
		if ( *pdwCurrentAddress != 0x12345678 ) {
			return FALSE;
		}
		pdwCurrentAddress += ( 0x100000 / sizeof(DWORD) );
	}
	return TRUE;
}
