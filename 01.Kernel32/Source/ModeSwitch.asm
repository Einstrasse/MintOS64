;
; ModeSwitch.asm
;
;  Created on: 2018. 2. 2.
;      Author: hg958
;

 [BITS 32]
 ; C언어에서 호출할 수 있도록 이름을 노출함(Export)
 global kReadCPUID, kSwitchAndExecute64bitKernel

 SECTION .text

 ; CPUID를 반환하는 함수
 ; Param: DWORD dwEAX, DWORD* pdwEAX, *pdwEBX, *pdwECX, *pdwEDX
 kReadCPUID:
 	push ebp
 	mov ebp, esp
 	push eax
 	push ebx
 	push ecx
 	push edx
 	push esi

 	;; ebp -> saved ebp
 	;; ebp+4 -> return address
 	;; ebp+8 -> 1st param
 	;; ebp+12 -> 2nd param..

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; EAX 레지스터 값으로 CPUID 명령어 실행
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov eax, dword [ ebp + 8 ]
 	cpuid

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; 반환값을 파라메터에 저장
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov esi, dword [ ebp + 12 ] ; 1,2,3,4 파라메터가 포인터이므로 간접참조하기 위해 esi를 사용함
 	mov dword [ esi ], eax

 	mov esi, dword [ ebp + 16 ]
 	mov dword [ esi ], ebx

 	mov esi, dword [ ebp + 20 ]
 	mov dword [ esi ], ecx

 	mov esi, dword [ ebp + 24 ]
 	mov dword [ esi ], edx

 	pop esi
 	pop edx
 	pop ecx
 	pop ebx
 	pop eax
 	pop ebp
 	ret

 ; IA-32e 모드로 전환하고 64비트 커널을 수행하는 함수
 ; PARAM: (void)
 kSwitchAndExecute64bitKernel:
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; CR4 컨트롤 레지스터의 PAE(Physical Address Extension) 비트를 1로 설정
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov eax, cr4
 	or eax, 0x20
 	mov cr4, eax

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; CR3 컨트롤 레지스터에 PML4 테이블의 어드레스와 캐시 활성화
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov eax, 0x100000
 	mov cr3, eax

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; IA32_EFER.LME를 1로 설정하여 IA-32e 모드를 활성화
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov ecx, 0xC0000080
 	rdmsr

 	or eax, 0x0100

 	wrmsr

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; CR0 컨트롤 레지스터를 설정하여 캐시 기능과 페이징 기능을 활성화
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov eax, cr0
 	or eax, 0xE0000000
 	xor eax, 0x60000000
 	;and eax, 0x1fffffff ; 29, 30, 31비트를 모두 0으로 설정함
 	;or eax, 0x80000000; 31비트를 1로 설정함
 	mov cr0, eax

 	jmp 0x08:0x200000

	; Unreachable code
 	jmp $
