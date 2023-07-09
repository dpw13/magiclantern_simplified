/*
 *  EOS M50 1.1.0 consts
 */

#define CARD_LED_ADDRESS            0xD01300E4     /* maybe also 0xD01301A4 */
#define LEDON                       0xD0002
#define LEDOFF                      0xC0003

#define BR_ICACHE_INV_1     0xE0040072   /* first call to icache_invalidate, before cstart */
#define BR_DCACHE_CLN_1     0xE0040068   /* first call to dcache_clean, before cstart */
#define BR_DCACHE_CLN_2     0xE00400A0   /* second call to dcache_clean, before cstart */
#define BR_ICACHE_INV_2     0xE00400AA   /* second call to icache_invalidate, before cstart */
#define BR_BR_CSTART        0xE00400C0   // indirect branch to cstart; the first branch is
                                         // absolute to original, we must patch.
                                         // This is the pointer to ldr r0,[gStartLoc]
#define BR_BZERO32          0xE0040152   /* called from cstart */
#define BR_CREATE_ITASK     0xE00401B4   /* called from cstart */

/* Everything below still needs to be updated! */

// Used for copying and modifying ROM code before transferring control.
// Approximately: look at BR_ macros for the highest address, subtract ROMBASEADDR,
// align up.  This may not be exactly enough.  See boot-d678.c for longer explanation.
#define FIRMWARE_ENTRY_LEN 0x220

/* "Malloc Information" */
#define MALLOC_STRUCT 0x2d21c
#define MALLOC_FREE_MEMORY (MEM(MALLOC_STRUCT + 8) - MEM(MALLOC_STRUCT + 0x1C)) // "Total Size" - "Allocated Size"

/* high confidence */
#define DRYOS_ASSERT_HANDLER        0x4000               //from debug_asset function, hard to miss

// 00007E64h + 6C
#define CURRENT_GUI_MODE (*(int*)0x7ED0)                 // see SetGUIRequestMode, Compared with param 1 before write to 0x7BC8


#define GUIMODE_PLAY 2
#define GUIMODE_MENU 3
// bindGUIEventFromGUICBR DNE on M50, however by educated guess from older generations:
// In SetGUIRequestMode, look at what code calls NotifyGUIEvent(9, something)
// skip RECORDING variant for now
#define GUIMODE_ML_MENU (lv ? 0x63 : GUIMODE_MENU)
//#define GUIMODE_ML_MENU (RECORDING ? 0 : lv ? 0x63 : GUIMODE_MENU)


#define CANON_SHUTTER_RATING 100000

#define GMT_FUNCTABLE               0xe09a27a0           //from gui_main_task
#define GMT_NFUNCS                  0x7                  //size of table above

#define LVAE_STRUCT                 0x5737c              // First value written in EP_SetInitialBv
#define CONTROL_BV      (*(uint16_t*)(LVAE_STRUCT+0x28)) // via "lvae_setcontrolbv"
#define CONTROL_BV_TV   (*(uint16_t*)(LVAE_STRUCT+0x3e)) // via "lvae_setcontrolaeparam"
#define CONTROL_BV_AV   (*(uint16_t*)(LVAE_STRUCT+0x40)) // via "lvae_setcontrolaeparam"
#define CONTROL_BV_ISO  (*(uint16_t*)(LVAE_STRUCT+0x42)) // via "lvae_setcontrolaeparam"
#define CONTROL_BV_ZERO (*(uint16_t*)(LVAE_STRUCT+0x44)) // via "lvae_setcontrolaccumh": look for accumH, not zero
#define LVAE_DISP_GAIN  (*(uint16_t*)(LVAE_STRUCT+0x70)) // via "lvae_setdispgain"
#define LVAE_MOV_M_CTRL (*(uint8_t* )(LVAE_STRUCT+0x24)) // via "lvae_setmoviemanualcontrol"

/*
 * kitor: ISO related stuff is not in LVAE struct anymore?
 * iso-related stuff calls 0x02275de which returns pointer at 0x02276168 to 0x6b818
 */
#define LVAE_ISO_STRUCT 0x000700e0
#define LVAE_ISO_MIN    (*(uint8_t* )LVAE_ISO_STRUCT + 0x0E ) // via string: ISOMin:%d

//#define LVAE_ISO_HIS    (*(uint8_t* )(LVAE_STRUCT+0xXX)) // no idea, not referenced in ./src?!
//#define LVAE_ISO_SPEED  (*(uint8_t* )(LVAE_STRUCT+0xXX))  //WRONG, not sure how to follow

/*
 * kitor: DIGIC 8 has no PROP_LV_OUTPUT_TYPE (PROP_HOUTPUT_TYPE in ML source)
 * I looked around LiveViewApp and found `LvInfoToggle_Update()` which updates
 * variable to represent currently display overlays. Look at R conts.h for more
 * details.
 */
#define LV_OVERLAYS_MODE MEM(0x15ae8)

/* There's no `DispOperator_PropertyMasterSetDisplayTurnOffOn()` like on EOSR.
 * PropID 80040083 is also not referenced anywhere.
 * GUILockTask does DISP_MuteOnOSDLineVram() and DISP_MuteOnOSDPanelVram()
 * so maybe values stored by those two combined can be used instead. */
#define DISPLAY_IS_ON               1

/*
 * On M50 UYVY Image buffers are hardcoded to be (see VramRead e009ccd6):
 * for EVF   : 1024x768
 * for Panel : 736x480, 720x480 is active image area
 * for HDMI  : 736x480, 1280x720, 1920x1080, 3840x2160 depending on output.
 *             HDMI resolution is selected based on type field from DispDev
 *             structure (8e00 + 0x18)
 * HDMI is referenced as "Line" in Canon functions.
 *
 * Buffers used for regular display are available in smemShowFix output.
 * IMG_VRAM1, IMG_VRAM2, IMG_VRAM3
 *
 * Different to R there's no Clean HDMI output. But DispVram looks similar to
 * R, so who knows...
 *
 * DPW: Had a hell of a time finding this for the M50 mk ii because the jump
 * table at 0xe04b4f16 in srmGetShootMemAreaAddress wasn't properly decoded
 * by ghidra and the jump target wasn't included in the function. Had to
 * manually compute the jump target from the code at switchD_e047514c_caseD_48.
 * 
 * You can also look in smemShowFix and look for the values printed in
 * common_upper. For the M50_2, the start address is set for the first
 * buffer and computed for the second and third by adding the size of
 * the buffer (0x003f4800).
 * 
 * Note that we want the uncached version, so add 0x4000_0000
 */

#define YUV422_LV_BUFFER_1   0x7f421000
// DAT_3f421000+0x003f4800
#define YUV422_LV_BUFFER_2   0x7F815800
// DAT_3f421000+0x007e9000
#define YUV422_LV_BUFFER_3   0x7FC0A000

// Offsets found via DISP_GetImageAddress() helper that prints
// "CurrentImgAddr : %#08x"
#define DISP_VRAM_STRUCT_PTR *(unsigned int *)0xab18            // DispVram structure

/* Doesn't appear to exist */
// #define DV_DISP_TYPE  *((unsigned int *)(DISP_VRAM_STRUCT_PTR + 0xC))   // Display type mask
#define DV_VRAM_LINE  *((unsigned int *)(DISP_VRAM_STRUCT_PTR + 0xA4))  // Pointer to LV buffer for HDMI output
#define DV_VRAM_PANEL *((unsigned int *)(DISP_VRAM_STRUCT_PTR + 0xAC))  // Pointer to LV buffer for Panel output
#define DV_VRAM_EVF   *((unsigned int *)(DISP_VRAM_STRUCT_PTR + 0xB4))  // Pointer to LV buffer for EVF	 output

/* Hardcoded to Panel for now. It would be easier if we can replace this with a
 * function call that would be put into functon_overrides.c. Then we could just
 * define full structs there instead of playing with pointers */
#define YUV422_LV_BUFFER_DISPLAY_ADDR DV_VRAM_PANEL
#define YUV422_LV_PITCH               736       // depends on display type

#define YUV422_HD_BUFFER_DMA_ADDR 0x0 // it expects this to be shamem_read(some_DMA_ADDR)

/* WRONG! */
#define HALFSHUTTER_PRESSED         0
/* kitor: I was unable to find any related stuff from 200D
 * Working theory: since R is LV all-the-time, maybe it's not special anymore
 * and is handled by MPU now?
 */

//Replaced by CONFIG_NO_BFNT in internals.h
//#define BFNT_CHAR_CODES             0x00000000
//#define BFNT_BITMAP_OFFSET          0x00000000
//#define BFNT_BITMAP_DATA            0x00000000

#define NUM_PICSTYLES 10 // guess, but seems to be always 9 for old cams, 10 for new

#define AUDIO_MONITORING_HEADPHONES_CONNECTED 0
#define INFO_BTN_NAME               "INFO"
#define Q_BTN_NAME                  "Q/SET"
#define ARROW_MODE_TOGGLE_KEY       "FUNC"

#define MIN_MSLEEP 11
#define PLAY_MODE (gui_state == GUISTATE_PLAYMENU && CURRENT_GUI_MODE == GUIMODE_PLAY)
#define MENU_MODE (gui_state == GUISTATE_PLAYMENU && CURRENT_GUI_MODE == GUIMODE_MENU)

/* WRONG: copied straight from 200d/50d */
// Definitely wrong / hacks / no testing at all:
    #define LV_STRUCT_PTR 0xaf2d0

    #define IMGPLAY_ZOOM_LEVEL_ADDR (0x2CBC) //wrong

    #define WINSYS_BMP_DIRTY_BIT_NEG MEM(0x4444+0x30) // wrong, no idea
    #define FOCUS_CONFIRMATION (*(int*)0x4444) // wrong, focusinfo looks really different 50D -> 200D
    #define LV_BOTTOM_BAR_DISPLAYED 0x0 // wrong, fake bool
// below definitely wrong, just copied from 50D
    #define FRAME_SHUTTER *(uint8_t*)(MEM(LV_STRUCT_PTR) + 0x56)
    #define FRAME_APERTURE *(uint8_t*)(MEM(LV_STRUCT_PTR) + 0x57)
    #define FRAME_ISO *(uint16_t*)(MEM(LV_STRUCT_PTR) + 0x58)
    #define FRAME_SHUTTER_TIMER *(uint16_t*)(MEM(LV_STRUCT_PTR) + 0x5c)
    #define FRAME_BV ((int)FRAME_SHUTTER + (int)FRAME_APERTURE - (int)FRAME_ISO)
// this block all copied from 50D, and probably wrong, though likely safe
    #define FASTEST_SHUTTER_SPEED_RAW 160
    #define MAX_AE_EV 2
    #define FLASH_MAX_EV 3
    #define FLASH_MIN_EV -10
    #define COLOR_FG_NONLV 80
    #define AF_BTN_HALFSHUTTER 0
    #define AF_BTN_STAR 2
// another block copied from 50D
    #define GUIMODE_WB 5
    #define GUIMODE_FOCUS_MODE 9
    #define GUIMODE_DRIVE_MODE 8
    #define GUIMODE_PICTURE_STYLE 4
    #define GUIMODE_Q_UNAVI 0x18
    #define GUIMODE_FLASH_AE 0x22
    #define GUIMODE_PICQ 6

// all these MVR ones are junk, don't try and record video and they probably don't get used?
    #define MVR_190_STRUCT (*(void**)0x1ed8) // look in MVR_Initialize for AllocateMemory call;
                                         // decompile it and see where ret_AllocateMemory is stored.
#define div_maybe(a,b) ((a)/(b))
    // see mvrGetBufferUsage, which is not really safe to call => err70
    // macros copied from arm-console
    #define MVR_BUFFER_USAGE 70 /* obviously wrong, don't try and record video
           // div_maybe(-100*MEM(236 + MVR_190_STRUCT) - \
           // 100*MEM(244 + MVR_190_STRUCT) - 100*MEM(384 + MVR_190_STRUCT) - \
           // 100*MEM(392 + MVR_190_STRUCT) + 100*MEM(240 + MVR_190_STRUCT) + \
           // 100*MEM(248 + MVR_190_STRUCT), \
           // - MEM(236 + MVR_190_STRUCT) - MEM(244 + MVR_190_STRUCT) + \
           // MEM(240 + MVR_190_STRUCT) +  MEM(248 + MVR_190_STRUCT)) */
    #define MVR_FRAME_NUMBER (*(int*)(220 + MVR_190_STRUCT))
    //#define MVR_LAST_FRAME_SIZE (*(int*)(512 + MVR_752_STRUCT))
    #define MVR_BYTES_WRITTEN MEM((212 + MVR_190_STRUCT))

//address of XimrContext structure to redraw in FEATURE_VRAM_RGBA
#define XIMR_CONTEXT 0x9329C
