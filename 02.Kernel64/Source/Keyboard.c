#include "Types.h"
#include "Keyboard.h"
#include "AsmUtils.h"

BOOL kIsOutputBufferFull(void) {
	if (kInPortByte(0x64) & 0x01) return TRUE;
	return FALSE;
}
BOOL kIsInputBufferFull(void) {
	if (kInPortByte(0x64) & 0x02) return TRUE;
	return FALSE;
}

void kWaitUntilInputBufferEmpty(void) {
	for (int i=0; i < 0xFFFF; i++) {
		if (kIsInputBufferFull() == FALSE) return;
	}
}
void kWaitUntilInputBufferFull(void) {
	for (int i=0; i < 0xFFFF; i++) {
		if (kIsInputBufferFull()) return;
	}
}

//Return true if ack data receive / else return false
BOOL kWaitForAckData(void) {
	kWaitUntilInputBufferFull();
	if (kInPortByte(0x60) == 0xFA) return TRUE;
	return FALSE;
}

BOOL kActivateKeyboard(void) {
	//Keyboard Device Activate on Keyboard Controller
	kOutPortByte(0x64, 0xAE);
	kWaitUntilInputBufferEmpty();

	//Keyboard Activate on Keyboard device itself
	kOutPortByte(0x60, 0xF4);
	return kWaitForAckData();
}

BYTE kGetKeyboardScanCode(void) {
	while(kIsOutputBufferFull() == FALSE);
	return kInPortByte(0x60);
}

//Keyboard Led Change is omitted
BOOL kChangeKeyboardLED(BOOL bCapsLockOn, BOOL bNumLockOn, BOOL bScrollLockOn) {
	return TRUE;
}
///Enable A20 Gate is also omitted

void kReboot(void) {
	kWaitUntilInputBufferEmpty();
	kOutPortByte(0x64, 0xD1);
	kOutPortByte(0x60, 0x00);
	while(TRUE);
}

static KEYBOARD_MANAGER gs_stKeyboardManager = {0, };
static KEY_MAPPING_ENTRY gs_vstKeyMappingTable[ KEY_MAPPING_TABLE_MAXCOUNT ] =
{
    /*  0   */  {   KEY_NONE        ,   KEY_NONE        },
    /*  1   */  {   KEY_ESC         ,   KEY_ESC         },
    /*  2   */  {   '1'             ,   '!'             },
    /*  3   */  {   '2'             ,   '@'             },
    /*  4   */  {   '3'             ,   '#'             },
    /*  5   */  {   '4'             ,   '$'             },
    /*  6   */  {   '5'             ,   '%'             },
    /*  7   */  {   '6'             ,   '^'             },
    /*  8   */  {   '7'             ,   '&'             },
    /*  9   */  {   '8'             ,   '*'             },
    /*  10  */  {   '9'             ,   '('             },
    /*  11  */  {   '0'             ,   ')'             },
    /*  12  */  {   '-'             ,   '_'             },
    /*  13  */  {   '='             ,   '+'             },
    /*  14  */  {   KEY_BACKSPACE   ,   KEY_BACKSPACE   },
    /*  15  */  {   KEY_TAB         ,   KEY_TAB         },
    /*  16  */  {   'q'             ,   'Q'             },
    /*  17  */  {   'w'             ,   'W'             },
    /*  18  */  {   'e'             ,   'E'             },
    /*  19  */  {   'r'             ,   'R'             },
    /*  20  */  {   't'             ,   'T'             },
    /*  21  */  {   'y'             ,   'Y'             },
    /*  22  */  {   'u'             ,   'U'             },
    /*  23  */  {   'i'             ,   'I'             },
    /*  24  */  {   'o'             ,   'O'             },
    /*  25  */  {   'p'             ,   'P'             },
    /*  26  */  {   '['             ,   '{'             },
    /*  27  */  {   ']'             ,   '}'             },
    /*  28  */  {   '\n'            ,   '\n'            },
    /*  29  */  {   KEY_CTRL        ,   KEY_CTRL        },
    /*  30  */  {   'a'             ,   'A'             },
    /*  31  */  {   's'             ,   'S'             },
    /*  32  */  {   'd'             ,   'D'             },
    /*  33  */  {   'f'             ,   'F'             },
    /*  34  */  {   'g'             ,   'G'             },
    /*  35  */  {   'h'             ,   'H'             },
    /*  36  */  {   'j'             ,   'J'             },
    /*  37  */  {   'k'             ,   'K'             },
    /*  38  */  {   'l'             ,   'L'             },
    /*  39  */  {   ';'             ,   ':'             },
    /*  40  */  {   '\''            ,   '\"'            },
    /*  41  */  {   '`'             ,   '~'             },
    /*  42  */  {   KEY_LSHIFT      ,   KEY_LSHIFT      },
    /*  43  */  {   '\\'            ,   '|'             },
    /*  44  */  {   'z'             ,   'Z'             },
    /*  45  */  {   'x'             ,   'X'             },
    /*  46  */  {   'c'             ,   'C'             },
    /*  47  */  {   'v'             ,   'V'             },
    /*  48  */  {   'b'             ,   'B'             },
    /*  49  */  {   'n'             ,   'N'             },
    /*  50  */  {   'm'             ,   'M'             },
    /*  51  */  {   ','             ,   '<'             },
    /*  52  */  {   '.'             ,   '>'             },
    /*  53  */  {   '/'             ,   '?'             },
    /*  54  */  {   KEY_RSHIFT      ,   KEY_RSHIFT      },
    /*  55  */  {   '*'             ,   '*'             },
    /*  56  */  {   KEY_LALT        ,   KEY_LALT        },
    /*  57  */  {   ' '             ,   ' '             },
    /*  58  */  {   KEY_CAPSLOCK    ,   KEY_CAPSLOCK    },
    /*  59  */  {   KEY_F1          ,   KEY_F1          },
    /*  60  */  {   KEY_F2          ,   KEY_F2          },
    /*  61  */  {   KEY_F3          ,   KEY_F3          },
    /*  62  */  {   KEY_F4          ,   KEY_F4          },
    /*  63  */  {   KEY_F5          ,   KEY_F5          },
    /*  64  */  {   KEY_F6          ,   KEY_F6          },
    /*  65  */  {   KEY_F7          ,   KEY_F7          },
    /*  66  */  {   KEY_F8          ,   KEY_F8          },
    /*  67  */  {   KEY_F9          ,   KEY_F9          },
    /*  68  */  {   KEY_F10         ,   KEY_F10         },
    /*  69  */  {   KEY_NUMLOCK     ,   KEY_NUMLOCK     },
    /*  70  */  {   KEY_SCROLLLOCK  ,   KEY_SCROLLLOCK  },

    /*  71  */  {   KEY_HOME        ,   '7'             },
    /*  72  */  {   KEY_UP          ,   '8'             },
    /*  73  */  {   KEY_PAGEUP      ,   '9'             },
    /*  74  */  {   '-'             ,   '-'             },
    /*  75  */  {   KEY_LEFT        ,   '4'             },
    /*  76  */  {   KEY_CENTER      ,   '5'             },
    /*  77  */  {   KEY_RIGHT       ,   '6'             },
    /*  78  */  {   '+'             ,   '+'             },
    /*  79  */  {   KEY_END         ,   '1'             },
    /*  80  */  {   KEY_DOWN        ,   '2'             },
    /*  81  */  {   KEY_PAGEDOWN    ,   '3'             },
    /*  82  */  {   KEY_INS         ,   '0'             },
    /*  83  */  {   KEY_DEL         ,   '.'             },
    /*  84  */  {   KEY_NONE        ,   KEY_NONE        },
    /*  85  */  {   KEY_NONE        ,   KEY_NONE        },
    /*  86  */  {   KEY_NONE        ,   KEY_NONE        },
    /*  87  */  {   KEY_F11         ,   KEY_F11         },
    /*  88  */  {   KEY_F12         ,   KEY_F12         }
};

BOOL kIsAlphabetScanCode(BYTE bScanCode) {
	if ( 'a' <= gs_vstKeyMappingTable[bScanCode].bNormalCode &&
		gs_vstKeyMappingTable[bScanCode].bNormalCode <= 'z') 
		return TRUE;
	return FALSE; 
}

BOOL kIsNumberOrSymbolScanCode(BYTE bScanCode) {
	if (2 <= bScanCode && bScanCode <= 53 && !kIsAlphabetScanCode(bScanCode))
		return TRUE;
	return FALSE;
}

BOOL kIsNumberPadScanCode(BYTE bScanCode) {
	if (71 <= bScanCode && bScanCode <= 83)
		return TRUE;
	return FALSE;
}

//Determine wheter should use Combined Key Code
BOOL kIsUseCombinedCode(BYTE bScanCode) {
	BYTE bDownScanCode;
	BOOL bUseCombinedKey = FALSE;

	bDownScanCode = bScanCode & 0x7F;

	if (kIsAlphabetScanCode(bDownScanCode)) {
		if (gs_stKeyboardManager.bShiftDown ^ gs_stKeyboardManager.bCapsLockOn)
			bUseCombinedKey = TRUE;
		else 
			bUseCombinedKey = FALSE;
	} else if (kIsNumberOrSymbolScanCode(bDownScanCode)) {
		if (gs_stKeyboardManager.bShiftDown) 
			bUseCombinedKey = TRUE;
		else
			bUseCombinedKey = FALSE;
	} else if (kIsNumberPadScanCode(bDownScanCode) && 
		!gs_stKeyboardManager.bExtendedCodeIn) {
		if (gs_stKeyboardManager.bNumLockOn)
			bUseCombinedKey = TRUE;
		else 
			bUseCombinedKey = FALSE;
	}
	return bUseCombinedKey;
}

void UpdateCombinationKeyStatusAndLED(BYTE bScanCode) {
	BOOL bDown; //indicates if key is pressed now.
	BYTE bDownScanCode;
	BOOL bLEDStatusChanged = FALSE;

	if (bScanCode & 0x80) {
		bDown = FALSE;
		bDownScanCode = bScanCode & 0x7F;
	} else {
		bDown = TRUE;
		bDownScanCode = bScanCode;
	}

	if (bDownScanCode == 0x36 || bDownScanCode == 0x2A) {
		gs_stKeyboardManager.bShiftDown = bDown;
	} else if (bDownScanCode == 0x3A && bDown) {
		gs_stKeyboardManager.bCapsLockOn ^= TRUE;
		bLEDStatusChanged = TRUE;
	} else if (bDownScanCode == 0x45 && bDown) {
		gs_stKeyboardManager.bNumLockOn ^= TRUE;
		bLEDStatusChanged = TRUE;
	} else if (bDownScanCode == 0x46 && bDown) {
		gs_stKeyboardManager.bScrollLockOn ^= TRUE;
		bLEDStatusChanged = TRUE;
	}

	if (bLEDStatusChanged) {
		kChangeKeyboardLED(gs_stKeyboardManager.bCapsLockOn,
			gs_stKeyboardManager.bNumLockOn, gs_stKeyboardManager.bScrollLockOn);
	}
}

BOOL kConvertScanCodeToASCIICode(BYTE bScanCode, BYTE* pbASCIICode, BOOL* pbFlags) {

	if (gs_stKeyboardManager.iSkipCountForPause > 0) {
		gs_stKeyboardManager.iSkipCountForPause--;
		return FALSE;
	}

	if (bScanCode == 0xE1) {
		*pbASCIICode = KEY_PAUSE;
		*pbFlags = KEY_FLAGS_DOWN;
		gs_stKeyboardManager.iSkipCountForPause = KEY_SKIP_COUNT_FOR_PAUSE;
		return TRUE;
	} else if (bScanCode == 0xE0) {
		gs_stKeyboardManager.bExtendedCodeIn = TRUE;
		return FALSE;
	}

	if (kIsUseCombinedCode(bScanCode)) {
		*pbASCIICode = gs_vstKeyMappingTable[bScanCode & 0x7F].bCombinedCode;
	} else {
		*pbASCIICode = gs_vstKeyMappingTable[bScanCode & 0x7F].bNormalCode;
	}

	if (gs_stKeyboardManager.bExtendedCodeIn == TRUE) {
		*pbFlags = KEY_FLAGS_EXTENDEDKEY;
		gs_stKeyboardManager.bExtendedCodeIn = FALSE;
	} else {
		*pbFlags = 0;
	}

	if ((bScanCode & 0x80) == 0) {
		*pbFlags |= KEY_FLAGS_DOWN;
	}

	UpdateCombinationKeyStatusAndLED(bScanCode);
	return TRUE;
}