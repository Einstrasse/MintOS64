[ORG 0x00]
[BITS 16]

SECTION .text

;;;;;;;;;;;;;;;;;;;;;;;;
; �ڵ念��
;;;;;;;;;;;;;;;;;;;;;;;;

START:
	mov ax, 0x1000
	mov ds, ax ; DS segment register set to 0x1000
	mov es, ax ; ES segment register set to 0x1000

;;;;;;;;;;;;;;;;;;;;;;;;
; A20 ����Ʈ Ȱ��ȭ
;;;;;;;;;;;;;;;;;;;;;;;;
; BIOS ���񽺸� ���� Ȱ��ȭ
mov ax, 0x2401
int 0x15

jc .A20GATEERROR
jmp .A20GATESUCCESS

.A20GATEERROR:
	;���� �߻� ��, �ý��� ��Ʈ�� ��Ʈ�� ���� ��ȯ �õ�
	in al, 0x92
	or al, 0x02
	and al, 0xFE
	out 0x92, al

.A20GATESUCCESS:

	cli ; Inactivate interrupt to avoid side effect
	lgdt [ GDTR ] ; GDT table load

;;;;;;;;;;;;;;;;;;;;;;;;
; Enter to Protected Mode
;;;;;;;;;;;;;;;;;;;;;;;;
	mov eax, 0x4000003B
	mov cr0, eax

	; CS Segment selector : 0x00
	; ��ȣ��忡�� ���׸�Ʈ ��ũ���͸� GDTR���� ������ 0x08�� �ִ³��� ����Ű�� �ϱ� ���ؼ� dword 0x08: �� ��
	; �����忡�� �ڵ� ���׸�Ʈ �������Ϳ� 0x1000�� ����־����Ƿ� Base address�� 0x10000�̾���. ���� �� ���� �������
	; ������->��ȣ��� �� ����Ǵ��� ���� �ּҸ� ����Ű�� �ȴ�.
	jmp dword 0x18: (PROTECTEDMODE - $$ + 0x10000)

;;;;;;;;;;;;;;;;;;;;;;;;
; Enter to protected mode
;;;;;;;;;;;;;;;;;;;;;;;;

[BITS 32]
PROTECTEDMODE:
	mov ax, 0x20	; ��ȣ ��� Ŀ�ο� ������ ���׸�Ʈ ��ũ���͸� AX �������Ϳ� ����
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ss, ax
	mov esp, 0xFFFE
	mov ebp, 0xFFFE

	push ( SWITCHSUCCESSMESSAGE - $$ + 0x10000 )
	push 2
	push 0
	call PRINTMESSAGE
	add esp, 12

	jmp dword 0x18: 0x10200 ; Jump to C kernel

;;;;;;;;;;;;;;;;;;;;;;;;
; function code area
;;;;;;;;;;;;;;;;;;;;;;;;

PRINTMESSAGE:
	push ebp
	mov ebp, esp
	push esi
	push edi
	push eax
	push ecx
	push edx

	;;;;;;;;;;;;;;;;;;;;;;;;
	; Calc video memory addr based on (X, Y) cord
	;;;;;;;;;;;;;;;;;;;;;;;;
	mov eax, dword [ ebp + 12 ]
	mov esi, 160
	mul esi
	mov edi, eax

	mov eax, dword [ ebp + 8 ]
	mov esi, 2
	mul esi
	add edi, eax

	mov esi, dword [ ebp + 16 ]

.MESSAGELOOP:
	mov cl, byte [ esi ]
	cmp cl, 0
	je .MESSAGEEND

	mov byte [ edi + 0xB8000 ], cl
	add esi, 1
	add edi, 2
	jmp .MESSAGELOOP

.MESSAGEEND:
	pop edx
	pop ecx
	pop eax
	pop edi
	pop esi
	pop ebp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;
; data area
;;;;;;;;;;;;;;;;;;;;;;;;
; �Ʒ� �����͵��� 8����Ʈ�� ���߾� �����ϱ� ����
align 8, db 0

;GDTR�� ���� 8����Ʈ�� ���߾� �����ϱ� ���� �߰�
dw 0x0000
;GDTR �ڷᱸ�� ����
GDTR:
	dw GDTEND - GDT - 1
	dd ( GDT - $$ + 0x10000 )

;GDT ���̺� ����
GDT:
	; ��(NULL) ��ũ����, �ݵ�� 0���� �ʱ�ȭ�ؾ� ��
	NULLDescriptor:
		dw 0x0000
		dw 0x0000
		db 0x00
		db 0x00
		db 0x00
		db 0x00

	; IA-32e ��� Ŀ�ο� �ڵ� ���׸�Ʈ ��ũ����
	IA_32eCODEDESCRIPTOR:
		dw 0xFFFF
		dw 0x0000
		db 0x00
		db 0x9A
		db 0xAF
		db 0x00

	IA_32eDATADESCRIPTOR:
		dw 0xFFFF
		dw 0x0000
		db 0x00
		db 0x92
		db 0xAF
		db 0x00

	CODEDESCRIPTOR:
		dw 0xFFFF
		dw 0x0000
		db 0x00
		db 0x9A
		db 0xCF
		db 0x00

	DATADESCRIPTOR:
		dw 0xFFFF
		dw 0x0000
		db 0x00
		db 0x92
		db 0xCF
		db 0x00

GDTEND:

SWITCHSUCCESSMESSAGE: db 'Switched To Protected Mode Success~!!', 0

times 512 - ( $ - $$ ) db 0x00
