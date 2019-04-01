#include "Types.h"
#include "Keyboard.h"

void kPrintString( int iX, int iY, const char* pcString );
int Main(void) {
	char vcTemp[2] = {0,};
	BYTE bFlags;
	BYTE bTemp;
	int i = 0;
	kPrintString(0, 11, "This is the IA-32e Mode");
	kPrintString(0, 12, "Keyboard Activate...........................[    ]");

	if (kActivateKeyboard()) {
		kPrintString(45, 12, "Pass");
		kChangeKeyboardLED(FALSE, FALSE, FALSE);
	} else {
		kPrintString(45, 12, "Fail");
		while(1);
	}
	while(TRUE) {
		if (kIsOutputBufferFull()) {
			bTemp = kGetKeyboardScanCode();

			if (kConvertScanCodeToASCIICode(bTemp, &vcTemp[0], &bFlags)) {
				if (bFlags & KEY_FLAGS_DOWN)
					kPrintString(i++, 13, vcTemp);
			}
		}
	}
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
