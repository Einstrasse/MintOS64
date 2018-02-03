[BITS 64]

SECTION .text

;외부에서 정의한 함수를 쓸 수 있도록 정의함(Import)
extern Main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 코드영역
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
START:
	mov ax, 0x10 ; IA-32e 커널용 데이터 세그먼트 디스크립터 오프셋을 ax에 저장
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; 스택을 0x600000 ~ 0x6FFFFF에 1MB 크기로 생성
	mov ss, ax
	mov rsp, 0x6FFFF8
	mov rbp, 0x6FFFF8

	call Main; C언어 엔트리 포인트 함수 호출

	jmp $
