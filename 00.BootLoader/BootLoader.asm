[ORG 0x00]	;
[BITS 16]

SECTION .text

jmp 0x07C0:START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MINT64 OS�� ���õ� ȯ�� ���� ��
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TOTALSECTORCOUNT:	dw	2	; ��Ʈ�δ� ���� MINT64 OS �̹����� ũ��

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �ڵ� ����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
	mov ax, 0x07C0
	mov ds, ax
	mov ax, 0xB800
	mov es, ax

	; ������ 0x0000:0000 ~ 0x0000:FFFF ������ 64KB ũ��� ����
	mov ax, 0x0000
	mov ss, ax ; ���� ���׸�Ʈ�� ���� �ּҸ� 0x0000�� ����
	mov sp, 0xFFFE
	mov bp, 0xFFFE ; ���� �������� 0xFFFE ~ 0xFFFE �� ����

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ȭ���� ��� ����� �Ӽ����� ������� ����
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov si, 0

.SCREENCLEARLOOP:

	mov byte [ es: si ], 0x00
	mov byte [ es: si+1 ], 0x0A

	add si, 2
	cmp si, 80*25*2

	jl .SCREENCLEARLOOP

	mov si, 0
	mov di, 0

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ȭ�� ��ܿ� ���� �޽��� ���
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push MESSAGE1 ; ����� �޽���
	push 0 ; y��ǥ
	push 0 ; x��ǥ
	call PRINTMESSAGE
	add sp, 6 ; �Լ� ȣ�� �� ���� ����

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; OS �̹����� �ε��Ѵٴ� �޽��� ���
	push IMAGELOADINGMESSAGE
	push 1
	push 0
	call PRINTMESSAGE
	add sp, 6; ȣ�� �� ���� ����

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ��ũ���� OS �̹����� �ε�
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ��ũ�� �б� ���� ���� ����
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RESETDISK: ;��ũ�� �����ϴ� �ڵ��� ����
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; BIOS Reset Function ȣ��
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov ax, 0 ; ���� ��ȣ 0
	mov dl, 0 ; ����̺� ��ȣ (0=Floppy)
	int 0x13
	; ���� �߻� �� ���� ó�� �ڵ�� �̵�
	jc HANDLEDISKERROR

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ��ũ���� ���͸� ����
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ��ũ�� ������ �޸𸮷� ������ ��巹��(ES:BX)�� 0x10000���� ����
	mov si, 0x1000
	mov es, si ; ���׸�Ʈ �������� ES�� 0x1000�� ����
	mov bx, 0x0000 ; �ּҸ� 0x1000:0000 (0x10000)���� ���� ����
	; BIOS ���񽺷� ���� �б⸦ �� ��, ES:BX�� ���� ���͸� �����ϰ� �ȴ�.
	mov di, word [ TOTALSECTORCOUNT ]

READDATA:	; ��ũ�� �д� �ڵ��� ����

	cmp di, 0
	je READEND
	sub di, 0x1

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; BIOS READ Function ȣ��
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ah, 0x02
	mov al, 0x1
	mov ch, byte [ TRACKNUMBER ]
	mov cl, byte [ SECTORNUMBER ]
	mov dh, byte [ HEADNUMBER ]
	mov dl, 0x00
	int 0x13
	jc HANDLEDISKERROR

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ������ ��巹���� Ʈ��, ���, ���� ��巹�� ���
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	add si, 0x0020
	mov es, si

	mov al, byte [ SECTORNUMBER ]
	add al, 0x01
	mov byte[ SECTORNUMBER ], al
	cmp al, 19
	jl READDATA

	xor byte [ HEADNUMBER ], 0x01
	mov byte [ SECTORNUMBER ], 0x01

	cmp byte [ HEADNUMBER ], 0x00
	jne READDATA

	add byte [ TRACKNUMBER ], 0x01
	jmp READDATA

READEND:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; OS �̹����� �Ϸ�Ǿ��ٴ� �޽����� ���
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push LOADINGCOMPLETEMESSAGE
	push 2
	push 0
	call PRINTMESSAGE
	add sp, 6

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; �ε��� ���� OS �̹��� ����
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	jmp 0x1000:0x0000

HANDLEDISKERROR:
	push DISKERRORMESSAGE
	push 1
	push 20
	call PRINTMESSAGE
	jmp $

PRINTMESSAGE:
	push bp
	mov bp, sp ; �Լ� ���ѷα�

	push es
	push si
	push di
	push ax
	push cx
	push dx

	mov ax, 0xB800
	mov es, ax ; ������ ���׸�Ʈ ���������� ES�� ���� �޸� ���� ��巹���� ����
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; X, Y ��ǥ�� ������� ���� �޸� ��巹���� ���
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; word[bp+6] -> Y��ǥ
	; word[bp+4] -> X��ǥ
	mov ax, word [ bp + 6 ]
	mov si, 160 ; �� ������ ����Ʈ ��
	mul si
	mov di, ax ; di = y * 160

	mov ax, word [ bp + 4 ]
	mov si, 2
	mul si ; ax = x*2
	add di, ax; di += ax

	mov si, word [ bp + 8 ] ; si = ����� ������ �ּ�


.MESSAGELOOP:
	mov cl, byte [ si ]
	cmp cl, 0
	je .MESSAGEEND

	mov byte [es: di], cl
	add si, 1
	add di, 2

	jmp .MESSAGELOOP

.MESSAGEEND:
	pop dx
	pop cx
	pop ax
	pop di
	pop si
	pop es
	pop bp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ������ ����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ��Ʈ �δ� ���� �޽���
MESSAGE1: db 'MINT64 OS Boot Loader Start~!!', 0
DISKERRORMESSAGE: db 'DISK Error~!!', 0
IMAGELOADINGMESSAGE: db 'OS Image Loading...', 0
LOADINGCOMPLETEMESSAGE: db 'Complete~!!', 0

; ��ũ �б� ���� �޽�����
SECTORNUMBER:		db 0x02
HEADNUMBER:			db 0x00
TRACKNUMBER:		db 0x00

	times 510 - ( $ - $$ )	db	0x00

db 0x55		;
db 0xAA		;
