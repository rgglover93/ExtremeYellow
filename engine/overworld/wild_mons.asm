LoadWildData::
	ResetEvent EVENT_RANDOM_WILD_BOTH_GRASS_AND_WATER ; new, for randomization
	ld hl, WildDataPointers
	ld a, [wCurMap]

; get wild data for current map
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a       ; hl now points to wild data for current map
	ld a, [hli]
	ld [wGrassRate], a
	and a
	jr z, .NoGrassData ; if no grass data, skip to surfing data
; new, to handle wild encounter randomization
	ld a, [wRandomizationWildEncounters]
	cp RANDOM_NONE
	jr z, .noRandomization
; we do indeed randomize
	push hl
	ld de, wGrassMons
	call CustomRandomizedCopyData
	SetEvent EVENT_RANDOM_WILD_BOTH_GRASS_AND_WATER ; new, for randomization
	pop hl
	jr .continueWithWaterEncounters
.noRandomization
; back to vanilla
	push hl
	ld de, wGrassMons ; otherwise, load grass data
	ld bc, $1C ; = 28 = 14x2, edited, it was $14=20=10x2, needed to be increased by 8=4x2 as I modified the encounter maps and probabilities
	call CopyData ; Copy bc bytes from hl to de.
	pop hl
.continueWithWaterEncounters ; new label
	ld bc, $1C ; new, it was $14, needed to be increased by 4 as I modified the encounter maps and probabilities
	add hl, bc
.NoGrassData
	ld a, [hli]
	ld [wWaterRate], a
	and a
	ret z        ; if no water data, we're done
; new, to handle wild encounter randomization
	ld a, [wRandomizationWildEncounters]
	cp RANDOM_NONE
	jr z, .noRandomization
; we do indeed randomize
	ld de, wWaterMons
	jp CustomRandomizedCopyData
.noRandomization2
; back to vanilla
	ld de, wWaterMons ; load surfing data
	ld bc, $1C ; = 28 = 14x2, edited, it was $14=20=10x2, needed to be increased by 8=4x2 as I modified the encounter maps and probabilities
	jp CopyData ; Copy bc bytes from hl to de.

INCLUDE "data/wild/grass_water.asm"

; new, for wild encounter randomization ----------------------------------------

; target copy is de = wGrassMons or wWaterMons
; we need hl too as it points to the table and we use that for the levels
CustomRandomizedCopyData:
	ld c, 0 ; we need 14x2 info: level and randomly read pokemon species
	        ; the levels are read from the hard-coded tables
			; the species are read from a random point in (this? a?) ROM bank

	push de
	push hl
	push bc
	; Instead of pulling from HL + counter, just get a random mon
	.callRandomSpecies
	call Random
	and 0x7F       ; get values from 0–127
	add 1          ; make sure 1–128
	ld [wcf91], a
.loopRandom
	call Random
	cp NUM_POKEMON_RANDOMIZABLE + 1
	jr nc, .loopRandom
	cp 1
	jr c, .loopRandom
	ld [de], a

	CheckEvent EVENT_RANDOM_WILD_BOTH_GRASS_AND_WATER
	; if we load data for water TOO, we use a different offset, prime to the first one
	jr nz, .waterToo
; first encounter type we load (only grass or only water map)
	ld bc, 41 ; arbitrary number, bare minimum is 14, but bigger to allow for higher-than-threshold values, also better be a prime for the reason above
	ld a, [wCurMap]
	call AddNTimes ; add bc to hl a times
	jr .continueWithReading
.waterToo
	ld c, 61 ; arbitrary number, bigger than 14, and preferably prime
	ld b, 0
	ld a, [wCurMap]
	call AddNTimes ; add bc to hl a times
.continueWithReading
	; now hl is the randomized starting address for the current map
	ld a, h
	ld [wRandomMemoryAddressForWildRandomization_Current], a
	ld a, l
	ld [wRandomMemoryAddressForWildRandomization_Current+1], a
	pop bc
	pop hl
	pop de

.loopEntry
	push bc
	ld a, [hli] ; a = level; hl now points to the not-to-be-used species
	ld [de], a
	inc de

; read ROM data and load it in [de]
	push hl
	push de
	ld a, [wRandomMemoryAddressForWildRandomization_Current]
	ld h, a
	ld a, [wRandomMemoryAddressForWildRandomization_Current+1]
	ld l, a
	pop bc
	; now c has again the counter, [0,13]
	ld a, c ; now it's a the register with the counter
	push bc
	ld bc, 1
	call AddNTimes ; add bc=1 to hl a=counter times
	; now hl is the randomized address for the current map and the current mon index
	dec hl ; necessary becase we do the inc hl in the next step for the loop
.sanityLoop
	inc hl
	ld a, [hl] ; a is the content of the random address
; now we need to check if it's in [1,203] (we exclude anomalies, MissingNo, humans, fossils...)
	cp 0
	jr z, .sanityLoop ; we don't allow the non-pokemon with index 0
	cp NUM_POKEMON_RANDOMIZABLE+1 ; =203+1 until I add new mons
	jr nc, .sanityLoop ; if it's >=204, not good
	; when we arrive here, A is a valid Pokémon ID in range
	ld [wcf91], a
	ld b, a
	ld a, [wRandomizationWildEncounters]
	cp RANDOM_SIMSTRENGTH
	jr nz, .useOriginal

	ld a, b
	call FilterRandomMonByBST
	jr .storeFiltered

	.useOriginal
	ld a, b

	.storeFiltered
	ld [de], a ; write species to wild data

	inc hl ; we go to the next address memory for next loop
	ld a, h
	ld [wRandomMemoryAddressForWildRandomization_Current], a
	ld a, l
	ld [wRandomMemoryAddressForWildRandomization_Current+1], a ; update the temporary wram variable for next loop
	pop de
	pop hl

	inc de
	inc hl
	pop bc
	inc c ; increase the counter, c, initialized at 0
	ld a, c
	cp 14
	jr nz, .loopEntry
	ret

;	call FarCopyData ; copy bc bytes from a:hl to de

INCLUDE "engine/FilterRandomMonByBST.asm"
