[ORG 0x00]
[BITS 16]

SECTION .text

;;;;;;;;;;;;;;;;;;;;;;;;
; 코드영역
;;;;;;;;;;;;;;;;;;;;;;;;

START:
	mov ax, 0x1000
	mov ds, ax ; DS segment register set to 0x1000
	mov es, ax ; ES segment register set to 0x1000

	cli ; Inactivate interrupt
	lgdt [ GDTR ] ; GDT table load

;;;;;;;;;;;;;;;;;;;;;;;;
; Enter to Protected Mode
;;;;;;;;;;;;;;;;;;;;;;;;
	mov eax, 0x4000003B
	mov cr0, eax

	; CS Segment selector : 0x00
	; 보호모드에서 세그먼트 디스크립터를 GDTR에서 오프셋 0x08에 있는놈을 가르키게 하기 위해서 dword 0x08: 가 들어감
	; 리얼모드에서 코드 세그먼트 레지스터에 0x1000이 들어있었으므로 Base address가 0x10000이었다. 따라서 이 값을 더해줘야
	; 리얼모드->보호모드 로 변경되더라도 같은 주소를 가르키게 된다.
	jmp dword 0x08: (PROTECTEDMODE - $$ + 0x10000)

;;;;;;;;;;;;;;;;;;;;;;;;
; Enter to protected mode
;;;;;;;;;;;;;;;;;;;;;;;;

[BITS 32]
PROTECTEDMODE:
	mov ax, 0x10
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

	jmp dword 0x08: 0x10200 ; Jump to C kernel

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
align 8, db 0

dw 0x0000
GDTR:
	dw GDTEND - GDT - 1
	dd ( GDT - $$ + 0x10000 )

GDT:
	NULLDescriptor:
		dw 0x0000
		dw 0x0000
		db 0x00
		db 0x00
		db 0x00
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
