org 100h

basla:

mov ax, 0003h
int 10h

mov ah, 01h
mov ch, 20h
mov cl, 00h
int 10h

call oyuncu_ciz
call tehlike_ciz
call hiz_yaz

ana_dongu:

call bekle_tick

mov al, oyuncu_satir
mov eski_oyuncu_satir, al
mov al, oyuncu_sutun
mov eski_oyuncu_sutun, al

mov al, tehlike_satir
mov eski_tehlike_satir, al
mov al, tehlike_sutun
mov eski_tehlike_sutun, al

; -----------------------
; X HAREKETI

inc hiz_sayac
cmp hiz_sayac, 10
jne hiz_artirma_yok

mov hiz_sayac, 0

mov al, hiz_seviyesi
mov bl, al
inc bl
shr bl, 1
add al, bl

cmp al, 10
jbe hiz_kaydet
mov al, 10

hiz_kaydet:
mov hiz_seviyesi, al

hiz_artirma_yok:

mov cl, hiz_seviyesi
mov ch, 0

tehlike_hareket_tekrar:
push cx
call tehlike_hareket
pop cx
loop tehlike_hareket_tekrar

; -----------------------
; KLAVYE

call klavye_oku

mov cl, oyuncu_hiz
mov ch, 0

oyuncu_hareket_tekrar:

push cx

mov al, tus_ascii

cmp al, 'w'
je yukari
cmp al, 's'
je asagi
cmp al, 'a'
je sola_o
cmp al, 'd'
je saga_o

cmp al, 'W'
je yukari
cmp al, 'S'
je asagi
cmp al, 'A'
je sola_o
cmp al, 'D'
je saga_o

mov ah, tus_scan

cmp ah, 48h
je yukari
cmp ah, 50h
je asagi
cmp ah, 4Bh
je sola_o
cmp ah, 4Dh
je saga_o

jmp oyuncu_hareket_bitti

yukari:
cmp oyuncu_satir, 1
jbe oyuncu_hareket_bitti
dec oyuncu_satir
jmp oyuncu_devam

asagi:
cmp oyuncu_satir, 24
jae oyuncu_hareket_bitti
inc oyuncu_satir
jmp oyuncu_devam

sola_o:
cmp oyuncu_sutun, 0
jbe oyuncu_hareket_bitti
dec oyuncu_sutun
jmp oyuncu_devam

saga_o:
cmp oyuncu_sutun, 79
jae oyuncu_hareket_bitti
inc oyuncu_sutun
jmp oyuncu_devam

oyuncu_devam:
pop cx
loop oyuncu_hareket_tekrar
jmp oyuncu_hareket_son

oyuncu_hareket_bitti:
pop cx

oyuncu_hareket_son:

; -----------------------
; CARPISMA

mov tus_ascii, 0
mov tus_scan, 0

mov al, oyuncu_satir
cmp al, tehlike_satir
jne devam

mov al, oyuncu_sutun
cmp al, tehlike_sutun
jne devam

jmp oyun_bitti

devam:

mov al, oyuncu_satir
cmp al, eski_oyuncu_satir
jne oyuncu_sil

mov al, oyuncu_sutun
cmp al, eski_oyuncu_sutun
jne oyuncu_sil

jmp oyuncu_sil_gec

oyuncu_sil:
call oyuncu_eski_sil

oyuncu_sil_gec:

mov al, tehlike_satir
cmp al, eski_tehlike_satir
jne tehlike_sil

mov al, tehlike_sutun
cmp al, eski_tehlike_sutun
jne tehlike_sil

jmp tehlike_sil_gec

tehlike_sil:
call tehlike_eski_sil

tehlike_sil_gec:

call oyuncu_ciz
call tehlike_ciz
call hiz_yaz

jmp ana_dongu

; -----------------------
; X OYUNCUYU TAKIP EDER

tehlike_hareket:

mov al, tehlike_satir
cmp al, oyuncu_satir
jb asagi_t
ja yukari_t

mov al, tehlike_sutun
cmp al, oyuncu_sutun
jb saga_t
ja sola_t

ret

asagi_t:
cmp tehlike_satir, 24
jae tehlike_bitti
inc tehlike_satir
ret

yukari_t:
cmp tehlike_satir, 1
jbe tehlike_bitti
dec tehlike_satir
ret

saga_t:
cmp tehlike_sutun, 79
jae tehlike_bitti
inc tehlike_sutun
ret

sola_t:
cmp tehlike_sutun, 0
jbe tehlike_bitti
dec tehlike_sutun
ret

tehlike_bitti:
ret

; -----------------------
; BEKLE

bekle_tick:

mov ah, 00h
int 1Ah
mov son_tick, dl

bekle_devam:

call klavye_oku

mov ah, 00h
int 1Ah
cmp dl, son_tick
je bekle_devam

ret

; -----------------------
; KLAVYE

klavye_oku:

mov ah, 01h
int 16h
jz yok

mov ah, 00h
int 16h
mov tus_ascii, al
mov tus_scan, ah

yok:
ret

; -----------------------
; CAN SISTEMI

oyun_bitti:

dec can
cmp can, 0
je tamamen_bitti

cmp can, 2
je hiz3

cmp can, 1
je hiz5

jmp devam_mesaj

hiz3:
mov oyuncu_hiz, 3
jmp devam_mesaj

hiz5:
mov oyuncu_hiz, 5

devam_mesaj:

mov ax, 0600h
mov bh, 07h
mov cx, 0000h
mov dx, 184Fh
int 10h

mov ah, 02h
mov bh, 00h
mov dh, 12
mov dl, 20
int 10h

mov ah, 09h
lea dx, can_mesaj
int 21h

bekle_space:
mov ah, 00h
int 16h
cmp al, ' '
jne bekle_space

mov oyuncu_satir, 10
mov oyuncu_sutun, 20
mov tehlike_satir, 10
mov tehlike_sutun, 50

mov hiz_seviyesi, 1
mov hiz_sayac, 0

mov tus_ascii, 0
mov tus_scan, 0

mov ax, 0003h
int 10h

mov ah, 01h
mov ch, 20h
mov cl, 00h
int 10h

call oyuncu_ciz
call tehlike_ciz
call hiz_yaz

jmp ana_dongu

tamamen_bitti:

mov ax, 0600h
mov bh, 07h
mov cx, 0000h
mov dx, 184Fh
int 10h

mov ah, 02h
mov bh, 00h
mov dh, 12
mov dl, 30
int 10h

mov ah, 09h
lea dx, mesaj
int 21h

mov ah, 00h
int 16h

mov ah, 4Ch
int 21h

; -----------------------
; CIZIM

oyuncu_ciz:
mov ah, 02h
mov bh, 00h
mov dh, oyuncu_satir
mov dl, oyuncu_sutun
int 10h

mov ah, 09h
mov al, 'A'
mov bh, 00h
mov bl, 07h
mov cx, 1
int 10h
ret

tehlike_ciz:
mov ah, 02h
mov bh, 00h
mov dh, tehlike_satir
mov dl, tehlike_sutun
int 10h

mov ah, 09h
mov al, 'X'
mov bh, 00h
mov bl, 07h
mov cx, 1
int 10h
ret

oyuncu_eski_sil:
mov ah, 02h
mov bh, 00h
mov dh, eski_oyuncu_satir
mov dl, eski_oyuncu_sutun
int 10h

mov ah, 09h
mov al, ' '
mov bh, 00h
mov bl, 07h
mov cx, 1
int 10h
ret

tehlike_eski_sil:
mov ah, 02h
mov bh, 00h
mov dh, eski_tehlike_satir
mov dl, eski_tehlike_sutun
int 10h

mov ah, 09h
mov al, ' '
mov bh, 00h
mov bl, 07h
mov cx, 1
int 10h
ret

; -----------------------
; UST YAZI

hiz_yaz:

; CAN yaz
mov ah, 02h
mov bh, 00h
mov dh, 0
mov dl, 0
int 10h

mov ah, 09h
mov al, 'C'
mov bh, 00h
mov bl, 07h
mov cx, 1
int 10h

mov ah, 02h
mov dl, 1
int 10h

mov ah, 09h
mov al, 'A'
mov cx, 1
int 10h

mov ah, 02h
mov dl, 2
int 10h

mov ah, 09h
mov al, 'N'
mov cx, 1
int 10h

mov ah, 02h
mov dl, 3
int 10h

mov ah, 09h
mov al, ':'
mov cx, 1
int 10h

mov ah, 02h
mov dl, 4
int 10h

mov ah, 09h
mov al, ' '
mov cx, 1
int 10h

mov ah, 02h
mov dl, 5
int 10h

mov al, can
add al, '0'
mov ah, 09h
mov cx, 1
int 10h

; HIZ yaz
mov ah, 02h
mov dl, 15
int 10h

mov ah, 09h
mov al, 'H'
mov cx, 1
int 10h

mov ah, 02h
mov dl, 16
int 10h

mov ah, 09h
mov al, 'I'
mov cx, 1
int 10h

mov ah, 02h
mov dl, 17
int 10h

mov ah, 09h
mov al, 'Z'
mov cx, 1
int 10h

mov ah, 02h
mov dl, 18
int 10h

mov ah, 09h
mov al, ':'
mov cx, 1
int 10h

mov ah, 02h
mov dl, 19
int 10h

mov ah, 09h
mov al, ' '
mov cx, 1
int 10h

mov ah, 02h
mov dl, 20
int 10h

mov al, oyuncu_hiz
add al, '0'
mov ah, 09h
mov cx, 1
int 10h

; X HIZI yaz
mov ah, 02h
mov dl, 30
int 10h

mov ah, 09h
mov al, 'X'
mov cx, 1
int 10h

mov ah, 02h
mov dl, 31
int 10h

mov ah, 09h
mov al, ':'
mov cx, 1
int 10h

mov ah, 02h
mov dl, 32
int 10h

mov ah, 09h
mov al, ' '
mov cx, 1
int 10h

cmp hiz_seviyesi, 10
jne x_hiz_tek

mov ah, 02h
mov dl, 33
int 10h

mov ah, 09h
mov al, '1'
mov cx, 1
int 10h

mov ah, 02h
mov dl, 34
int 10h

mov ah, 09h
mov al, '0'
mov cx, 1
int 10h
ret

x_hiz_tek:
mov ah, 02h
mov dl, 33
int 10h

mov al, hiz_seviyesi
add al, '0'
mov ah, 09h
mov cx, 1
int 10h

mov ah, 02h
mov dl, 34
int 10h

mov ah, 09h
mov al, ' '
mov cx, 1
int 10h

ret

; -----------------------
; DATA

oyuncu_satir db 10
oyuncu_sutun db 20

tehlike_satir db 10
tehlike_sutun db 50

eski_oyuncu_satir db 10
eski_oyuncu_sutun db 20

eski_tehlike_satir db 10
eski_tehlike_sutun db 50

hiz_sayac db 0
hiz_seviyesi db 1

can db 3
oyuncu_hiz db 1

tus_ascii db 0
tus_scan db 0

son_tick db 0

mesaj db 'OYUN BITTI!$'
can_mesaj db 'CAN GITTI! SPACE BAS$'