; engine/FilterRandomMonByBST.asm
SECTION "FilterRandomMonByBST", ROMX

; Input: wcf91 = original mon ID
; Output: A = filtered mon ID within similar BST range
; This is meant to be called from CustomRandomizedCopyData only

FilterRandomMonByBST:
    push bc
    push de
    push hl

    ld a, [wcf91]
    call _CalculateBST
    ld d, a          ; original BST
    ld e, 30         ; tolerance range

    ld c, 40         ; attempt cap
.randomLoop:
    call Random
    cp NUM_POKEMON_RANDOMIZABLE + 1
    jr nc, .randomLoop
    cp 1
    jr c, .randomLoop

    push af
    call _CalculateBST
    ld b, a          ; candidate BST
    ld a, d          ; original BST
    sub b
    jr nc, .absCheck
    neg
.absCheck:
    cp e             ; within tolerance?
    pop af
    jr nc, .retry

    jr .done

.retry:
    dec c
    jr z, .fallback
    jr .randomLoop

.fallback:
    ld a, 25         ; default to Pikachu if all else fails

.done:
    pop hl
    pop de
    pop bc
    ret


; Internal BST calculator (stripped-down version)
_CalculateBST:
    push bc
    push hl

    dec a
    ld hl, BaseStats
    ld bc, BASE_DATA_SIZE
    call _MultiplyAByBC
    add hl, bc

    inc hl           ; skip dex ID
    ld b, 5
    xor a
.bstLoop:
    ld c, [hl]
    add a, c
    inc hl
    dec b
    jr nz, .bstLoop

    pop hl
    pop bc
    ret


; HL = A * BC (naive loop)
_MultiplyAByBC:
    ld hl, 0
.mulLoop:
    and a
    jr z, .mulDone
    add hl, bc
    dec a
    jr .mulLoop
.mulDone:
    ret
