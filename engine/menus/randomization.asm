DisplayRandomizationMenu::
	call InitRandomizationMenu
.randomizationMenuLoop
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	and START | B_BUTTON
	jr nz, .exitRandomizationMenu
	call RandomizationControl
	jr c, .dpadDelay
	call GetRandomizationPointer
	jr c, .exitRandomizationMenu
.dpadDelay
	call RandomizationMenu_UpdateCursorPosition
	call DelayFrame
	call DelayFrame
	call DelayFrame
	jr .randomizationMenuLoop
.exitRandomizationMenu
	ldh a, [hRandomAdd]
	ld [wRandomMemoryAddressForTypeChartRandomization+1], a
	call Random
	ld [wRandomMemoryAddressForWildRandomization+1], a
	ret

GetRandomizationPointer:
	ld a, [wOptionsCursorLocation]
	ld e, a
	ld d, $0
	ld hl, RandomizationMenuJumpTable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

RandomizationMenuJumpTable:
	dw RandomizationMenu_WildEncounters
	dw RandomizationMenu_TrainersTeam
	dw RandomizationMenu_TypeChart
	dw RandomizationMenu_Items
	dw RandomizationMenu_Evolutions
	dw RandomizationMenu_Dummy
	dw RandomizationMenu_Cancel

; ---------------------------------------------

RandomizationMenu_WildEncounters:
	ld a, [wRandomizationWildEncounters]
	ld c, a
	ldh a, [hJoy5]
	bit 4, a
	jr nz, .pressedRight
	bit 5, a
	jr nz, .pressedLeft
	jr .nonePressed
.pressedRight
	ld a, c
	cp 2
	jr c, .increase
	ld c, $ff
.increase
	inc c
	jr .save
.pressedLeft
	ld a, c
	and a
	jr nz, .decrease
	ld c, 3
.decrease
	dec c
.save
	ld a, c
	ld [wRandomizationWildEncounters], a
.nonePressed
	ld b, $0
	ld hl, RandomizationStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 15, 4
	call PlaceString
	and a
	ret

; ---------------------------------------------

RandomizationMenu_TrainersTeam:
	ld a, [wRandomizationTrainersTeams]
	ld c, a
	ldh a, [hJoy5]
	bit 4, a
	jr nz, .pressedRight
	bit 5, a
	jr nz, .pressedLeft
	jr .nonePressed
.pressedRight
	ld a, c
	cp 2
	jr c, .increase
	ld c, $ff
.increase
	inc c
	jr .save
.pressedLeft
	ld a, c
	and a
	jr nz, .decrease
	ld c, 3
.decrease
	dec c
.save
	ld a, c
	ld [wRandomizationTrainersTeams], a
.nonePressed
	ld b, $0
	ld hl, RandomizationStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 15, 6
	call PlaceString
	and a
	ret

; ---------------------------------------------

RandomizationMenu_Items:
	ld a, [wRandomizationItems]
	ld c, a
	ldh a, [hJoy5]
	bit 4, a
	jr nz, .pressedRight
	bit 5, a
	jr nz, .pressedLeft
	jr .nonePressed
.pressedRight
	ld a, c
	cp 1
	jr c, .increase
	ld c, $ff
.increase
	inc c
	ld a, e
	jr .save
.pressedLeft
	ld a, c
	and a
	jr nz, .decrease
	ld c, $2
.decrease
	dec c
	ld a, d
.save
	ld a, c
	ld [wRandomizationItems], a
.nonePressed
	ld b, $0
	ld hl, RandomizationStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 8, 10
	call PlaceString
	and a
	ret

; ---------------------------------------------

RandomizationMenu_TypeChart:
	ld a, [wRandomizationTypeChart]
	ld c, a
	ldh a, [hJoy5]
	bit 4, a
	jr nz, .pressedRight
	bit 5, a
	jr nz, .pressedLeft
	jr .nonePressed
.pressedRight
	ld a, c
	cp 1
	jr c, .increase
	ld c, $ff
.increase
	inc c
	ld a, e
	jr .save
.pressedLeft
	ld a, c
	and a
	jr nz, .decrease
	ld c, $2
.decrease
	dec c
	ld a, d
.save
	ld a, c
	ld [wRandomizationTypeChart], a
.nonePressed
	ld b, $0
	ld hl, RandomizationStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 15, 8
	call PlaceString
	and a
	ret

; ---------------------------------------------

RandomizationMenu_Evolutions:
	ld a, [wRandomizationEvolutions]
	ld c, a
	ldh a, [hJoy5]
	bit 4, a
	jr nz, .pressedRight
	bit 5, a
	jr nz, .pressedLeft
	jr .nonePressed
.pressedRight
	ld a, c
	cp 1
	jr c, .increase
	ld c, $ff
.increase
	inc c
	ld a, e
	jr .save
.pressedLeft
	ld a, c
	and a
	jr nz, .decrease
	ld c, $2
.decrease
	dec c
	ld a, d
.save
	ld a, c
	ld [wRandomizationEvolutions], a
.nonePressed
	ld b, $0
	ld hl, RandomizationStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 13, 12
	call PlaceString
	and a
	ret

; ---------------------------------------------

RandomizationStringsPointerTable:
	dw RandomOffText
	dw RandomFullText
	dw RandomSMLRText

RandomOffText:    db "OFF@",0
RandomFullText:   db "FULL@",0
RandomSMLRText:   db "SMLR@",0
