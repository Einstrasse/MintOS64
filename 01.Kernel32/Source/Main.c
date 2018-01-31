#include "Types.h"
#include "Page.h"

void kPrintString( int iX, int iY, const char* pcString );
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);
// Main �Լ�
void Main(void) {
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
