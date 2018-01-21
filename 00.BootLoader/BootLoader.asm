[ORG 0x00]	;
[BITS 16]

SECTION .text

jmp 0x07C0:START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MINT64 OS에 관련된 환경 설정 값
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TOTALSECTORCOUNT:	dw	2	; 부트로더 제외 MINT64 OS 이미지의 크기

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 코드 영역
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
	mov ax, 0x07C0
	mov ds, ax
	mov ax, 0xB800
	mov es, ax

	; 스택을 0x0000:0000 ~ 0x0000:FFFF 영역에 64KB 크기로 생성
	mov ax, 0x0000
	mov ss, ax ; 스택 세그먼트의 시작 주소를 0x0000로 설정
	mov sp, 0xFFFE
	mov bp, 0xFFFE ; 스택 프레임을 0xFFFE ~ 0xFFFE 로 설정

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; 화면을 모두 지우고 속성값을 녹색으로 설정
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
	; 화면 상단에 시작 메시지 출력
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push MESSAGE1 ; 출력할 메시지
	push 0 ; y좌표
	push 0 ; x좌표
	call PRINTMESSAGE
	add sp, 6 ; 함수 호출 후 스택 정리

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; OS 이미지를 로딩한다는 메시지 출력
	push IMAGELOADINGMESSAGE
	push 1
	push 0
	call PRINTMESSAGE
	add sp, 6; 호출 후 스택 정리

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; 디스크에서 OS 이미지를 로딩
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; 디스크를 읽기 전에 먼저 리셋
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RESETDISK: ;디스크를 리셋하는 코드의 시작
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; BIOS Reset Function 호출
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov ax, 0 ; 서비스 번호 0
	mov dl, 0 ; 드라이브 번호 (0=Floppy)
	int 0x13
	; 에러 발생 시 에러 처리 코드로 이동
	jc HANDLEDISKERROR

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; 디스크에서 섹터를 읽음
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; 디스크의 내용을 메모리로 복사할 어드레스(ES:BX)를 0x10000으로 설정
	mov si, 0x1000
	mov es, si ; 세그먼트 레지스터 ES를 0x1000로 설정
	mov bx, 0x0000 ; 주소를 0x1000:0000 (0x10000)으로 최종 설정
	; BIOS 서비스로 섹터 읽기를 쓸 시, ES:BX에 읽은 섹터를 저장하게 된다.
	mov di, word [ TOTALSECTORCOUNT ]

READDATA:	; 디스크를 읽는 코드의 시작

	cmp di, 0
	je READEND
	sub di, 0x1

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; BIOS READ Function 호출
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
	; 복사할 어드레스와 트랙, 헤드, 섹터 어드레스 계산
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
	; OS 이미지가 완료되었다는 메시지를 출력
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push LOADINGCOMPLETEMESSAGE
	push 2
	push 0
	call PRINTMESSAGE
	add sp, 6

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; 로딩한 가상 OS 이미지 실행
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
	mov bp, sp ; 함수 프롤로그

	push es
	push si
	push di
	push ax
	push cx
	push dx

	mov ax, 0xB800
	mov es, ax ; 데이터 세그먼트 레지스터인 ES에 비디오 메모리 시작 어드레스를 삽입
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; X, Y 좌표를 기반으로 비디오 메모리 어드레스를 계산
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; word[bp+6] -> Y좌표
	; word[bp+4] -> X좌표
	mov ax, word [ bp + 6 ]
	mov si, 160 ; 한 라인의 바이트 수
	mul si
	mov di, ax ; di = y * 160

	mov ax, word [ bp + 4 ]
	mov si, 2
	mul si ; ax = x*2
	add di, ax; di += ax

	mov si, word [ bp + 8 ] ; si = 출력할 문자의 주소


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
; 데이터 영역
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 부트 로더 시작 메시지
MESSAGE1: db 'MINT64 OS Boot Loader Start~!!', 0
DISKERRORMESSAGE: db 'DISK Error~!!', 0
IMAGELOADINGMESSAGE: db 'OS Image Loading...', 0
LOADINGCOMPLETEMESSAGE: db 'Complete~!!', 0

; 디스크 읽기 관련 메시지들
SECTORNUMBER:		db 0x02
HEADNUMBER:			db 0x00
TRACKNUMBER:		db 0x00

	times 510 - ( $ - $$ )	db	0x00

db 0x55		;
db 0xAA		;
