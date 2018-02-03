;
; ModeSwitch.asm
;
;  Created on: 2018. 2. 2.
;      Author: hg958
;

 [BITS 32]
 ; C���� ȣ���� �� �ֵ��� �̸��� ������(Export)
 global kReadCPUID, kSwitchAndExecute64bitKernel

 SECTION .text

 ; CPUID�� ��ȯ�ϴ� �Լ�
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
 	; EAX �������� ������ CPUID ��ɾ� ����
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov eax, dword [ ebp + 8 ]
 	cpuid

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; ��ȯ���� �Ķ���Ϳ� ����
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov esi, dword [ ebp + 12 ] ; 1,2,3,4 �Ķ���Ͱ� �������̹Ƿ� ���������ϱ� ���� esi�� �����
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

 ; IA-32e ���� ��ȯ�ϰ� 64��Ʈ Ŀ���� �����ϴ� �Լ�
 ; PARAM: (void)
 kSwitchAndExecute64bitKernel:
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; CR4 ��Ʈ�� ���������� PAE(Physical Address Extension) ��Ʈ�� 1�� ����
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov eax, cr4
 	or eax, 0x20
 	mov cr4, eax

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; CR3 ��Ʈ�� �������Ϳ� PML4 ���̺��� ��巹���� ĳ�� Ȱ��ȭ
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov eax, 0x10000
 	mov cr3, eax

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; IA32_EFER.LME�� 1�� �����Ͽ� IA-32e ��带 Ȱ��ȭ
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov ecx, 0xC0000080
 	rdmsr

 	or eax, 0x0100

 	wrmsr

 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; CR0 ��Ʈ�� �������͸� �����Ͽ� ĳ�� ��ɰ� ����¡ ����� Ȱ��ȭ
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	mov eax, cr0
 	;or eax, 0xE0000000
 	;xor eax, 0x60000000
 	and eax, 0x1fffffff ; 29, 30, 31��Ʈ�� ��� 0���� ������
 	or eax, 0x80000000; 31��Ʈ�� 1�� ������
 	mov cr0, eax

 	jmp 0x08:0x200000

	; Unreachable code
 	jmp $
