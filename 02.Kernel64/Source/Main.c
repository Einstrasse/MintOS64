#include "Types.h"

void kPrintString( int iX, int iY, const char* pcString );
int Main(void) {
	kPrintString(0, 11, "This is the IA-32e Mode");
	while(TRUE);
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
