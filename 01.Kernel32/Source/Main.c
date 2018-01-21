#include "Types.h"

void kPrintString( int iX, int iY, const char* pcString );
BOOL kInitializeKernel64Area(void);
// Main 함수
void Main(void) {
	kPrintString( 0, 3, "C Language Kernel Started~!!!!!" );

	// IA-32e 모드의 커널 영역을 초기화
	kInitializeKernel64Area();
	kPrintString( 0, 4, "IA-32e Kernel Area Initialization Complete");


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
