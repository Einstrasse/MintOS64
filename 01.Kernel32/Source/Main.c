#include "Types.h"

void kPrintString( int iX, int iY, const char* pcString );
BOOL kInitializeKernel64Area(void);
// Main �Լ�
void Main(void) {
	kPrintString( 0, 3, "C Language Kernel Started~!!!!!" );

	// IA-32e ����� Ŀ�� ������ �ʱ�ȭ
	kInitializeKernel64Area();
	kPrintString( 0, 4, "IA-32e Kernel Area Initialization Complete");


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
