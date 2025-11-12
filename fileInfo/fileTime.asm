;============================================================================
; fileTime.asm
; John Schwartzman, Forte Systems, Inc.
; 06/15/2024
; Linux x86_64
;============================================================================
%include	"macro.inc"

; %define	NUM_VAR		2		; round up to next even value

;================== DEFINE LOCAL VARIABLES for printFileSize ================ =================
%define	mTime		qword [rsp + VAR_SIZE * (NUM_VAR - 4)]	; rsp +  0

global	    main
global		printFileTime

extern		mtime

;============================== CODE SECTION ================================
section	.text

printFileTime:						; rdi contains the file modification time
	prologue

	; mov		rdi, 0x6663a58b			; TEMP work around
	lea		edi, [mtime]
	localtime
	mov		[tm], rax

	lea		rdi, [buffer]
	mov		rsi, 40				; size of buffer
	lea		rdx, [tdFmt]
	mov		rcx, [tm]
	strftime

	lea		rdi, [buffer]
	print
	
	epilogue

;============================================================================

%ifdef __MAIN__	;============================================================

main:
	prologue
	; mov     rdi, [mTime]
	call	printFileTime

.fin:
	epilogue

%endif	;===================== __MAIN__ =====================================

;============================================================================
section		.bss

	struc	tm_type					; structure declaration
		tm_sec		resd	1
		tm_min		resd	1
		tm_hour		resd	1
		tm_mday		resd	1
		tm_mon		resd	1
		tm_year		resd	1
		tm_wday		resd	1
		tm_yday		resd	1
		tm_isdst	resd	1
	endstruc

buffer		resb	40

section     .data

tdFmt		db		"%b %d %H:%M ", EOL

tm		istruc	tm_type
		iend

;============================================================================
