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

;;;;;;;;;;;;;;;;;;;;;;;;
; A20 게이트 활성화
;;;;;;;;;;;;;;;;;;;;;;;;
; BIOS 서비스를 통한 활성화
mov ax, 0x2401
int 0x15

jc .A20GATEERROR
jmp .A20GATESUCCESS

.A20GATEERROR:
	;에러 발생 시, 시스템 컨트롤 포트를 통한 전환 시도
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
	; 보호모드에서 세그먼트 디스크립터를 GDTR에서 오프셋 0x08에 있는놈을 가르키게 하기 위해서 dword 0x08: 가 들어감
	; 리얼모드에서 코드 세그먼트 레지스터에 0x1000이 들어있었으므로 Base address가 0x10000이었다. 따라서 이 값을 더해줘야
	; 리얼모드->보호모드 로 변경되더라도 같은 주소를 가르키게 된다.
	jmp dword 0x18: (PROTECTEDMODE - $$ + 0x10000)

;;;;;;;;;;;;;;;;;;;;;;;;
; Enter to protected mode
;;;;;;;;;;;;;;;;;;;;;;;;

[BITS 32]
PROTECTEDMODE:
	mov ax, 0x20	; 보호 모드 커널용 데이터 세그먼트 디스크립터를 AX 레지스터에 저장
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
; 아래 데이터들을 8바이트에 맞추어 정렬하기 위함
align 8, db 0

;GDTR의 끝을 8바이트에 맞추어 정렬하기 위해 추가
dw 0x0000
;GDTR 자료구조 정의
GDTR:
	dw GDTEND - GDT - 1
	dd ( GDT - $$ + 0x10000 )

;GDT 테이블 정의
GDT:
	; 널(NULL) 디스크립터, 반드시 0으로 초기화해야 함
	NULLDescriptor:
		dw 0x0000
		dw 0x0000
		db 0x00
		db 0x00
		db 0x00
		db 0x00

	; IA-32e 모드 커널용 코드 세그먼트 디스크립터
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
