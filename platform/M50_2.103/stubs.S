/** \file
 * Entry points into the firmware image.
 *
 * These are the functions that we can call from our tasks
 * in the Canon 1.1.0 firmware for the EOS M50.
 *
 */
/*
 * Copyright (C) 2021 Magic Lantern Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 */

#include <stub.h>

/* All functions are Thumb. */


/** Startup **/
NSTUB( ROMBASEADDR, firmware_entry )
THUMB_FN(0xe0040104,  cstart)                               /* calls bzero32 and create_init_task(..., init_task, ...) */
THUMB_FN(0xe05d5cb8,  bzero32)                              /* zeros out a data structure */
THUMB_FN(0xe02ed9d8,  create_init_task)                     /* low-level DryOS initialization */
THUMB_FN(0xe05d466c,  dcache_clean)                         /* loop with MCR p15 c7,c10,1; DSB */
THUMB_FN(0xe05d4740,  icache_invalidate)                    /* loop with MCR p15 c7,c5,1; c7,c1,6; c7,c1,0; ISB */
THUMB_FN(0xe0040236,  init_task)                            /* USER_MEM size checking, dmSetup, termDriverInit, stdlibSetup etc */

/** Tasks **/
DATA_PTR(    0x1010,  current_interrupt)                    /* from interrupt handler (VBAR + 0x18); where the interrupt ID is stored */
DATA_PTR(    0x1028,  current_task)                         /* from task_create; pointer to the current task structure */
THUMB_FN(0xe05be0f2,  msleep)                               /* argument is always multiple of 10 */
THUMB_FN(0xe059400e,  task_create)                          /* used to start TaskMain, GuiMainTask etc. AKA CreateTaskClass */
NSTUB( 0x4108, task_max)

/** File I/O **/
THUMB_FN(0xe05b53b6, _FIO_CreateFile)                       /* All of these are now Storage::(name) */
THUMB_FN(0xe05b511c, _FIO_OpenFile)
THUMB_FN(0xe05b5992,  FIO_CloseFile)
THUMB_FN(0xe05b55c0, _FIO_ReadFile)
THUMB_FN(0xe05b5778, _FIO_WriteFile)
THUMB_FN(0xe05b56ba,  FIO_SeekSkipFile)                     // This is now Storage::Search and has the same semantics
THUMB_FN(0xe05b5528, _FIO_RemoveFile)
THUMB_FN(0xe05b6566, _FIO_RenameFile)
THUMB_FN(0xe05b697c, _FIO_CreateDirectory)
THUMB_FN(0xe05b6e5e, _FIO_FindFirstEx)                      // FirstEnt
THUMB_FN(0xe05b6f5e,  FIO_FindNextEx)                       // NextEnt
THUMB_FN(0xe05b70c0,  FIO_FindClose)                        // CloseEnt
THUMB_FN(0xe05b6cb2,  FIO_Flush)
THUMB_FN(0xe05b5b2c, _FIO_GetFileSize64)                    // AcqSize; different in D8 cameras - returns 64 bit size in struct of lower/upper 32bit part.

/** Bitmap **/
/* bmp_vram_info not needed for D6+ */

/** Debug messages **/
THUMB_FN(0xe05d4e3c,  DryosDebugMsg)                        /* lots of debug messages; format string is third argument */

/** Dumper **/
THUMB_FN(0xe06c4b4e,  dump_file)                            // shouldn't be used, gone from newer models

/** Eventprocs (call by name) **/
THUMB_FN(0xe05cfcfa ,  call)                                 /* many functions called by name (lv_start, lv_stop etc) */

/** GUI timers **/
THUMB_FN(0xe060eb3e,  SetHPTimerNextTick)                   /* same "worker" function as SetHPTimerAfterNow */
THUMB_FN(0xe060eab8,  SetHPTimerAfterNow)                   /* from error message */
THUMB_FN(0xe04b9984,  SetTimerAfter)                        /* from error message */
THUMB_FN(0xe05c43e2,  CancelTimer)                          /* CancelRefreshTimer, CancelPlayTimer */

/** Memory allocation **/
THUMB_FN(0xe05c2b98, _AllocateMemory)                       /* System::Memory::_AllocateMemory, look for "[MEM] NG AllocateMemory" */
THUMB_FN(0xe05c2d50, _FreeMemory)                           /* Make sure to get the wrapper with 1 param */
THUMB_FN(0xe05c2a22,  GetMemoryInformation)
THUMB_FN(0xe05c29f6,  GetSizeOfMaxRegion)
THUMB_FN(0xe05c3358, _alloc_dma_memory)
THUMB_FN(0xe05c334c, _free_dma_memory)
THUMB_FN(0xe03c8ed0, _malloc)                               /* PackHeap::malloc? */
THUMB_FN(0xe03c8f08, _free)

/** Memory info **/
THUMB_FN(0xe039e030,  memmap_info)                          /* Exception vector, DRYOS system memory etc */
THUMB_FN(0xe013e6a4,  smemShowFix)                          /* Common Lower, Common Upper etc */
THUMB_FN(0xe03cea90,  malloc_info)                          /* Malloc Information */
THUMB_FN(0xe03ceb28,  sysmem_info)                          /* System Memory Information */

/** Misc **/
THUMB_FN(0xe05bfc80,  uart_printf)
THUMB_FN(0xe005dba0,  vsnprintf)                            /* called by LogFile_printf(..., "*Data Lost*\n", ...); the one called by DebugMsg only knows %s */

/** Startup **/
DATA_PTR(    0xF0B9,  additional_version)
/* kitor: Please note that this points at '\n' char in char* with FW version */

/** Tasks **/
DATA_PTR(    0x4144,  task_dispatch_hook)
THUMB_FN(0xe00a6c7c,  task_trampoline)
/*
 * kitor: task_create calls internal function (e05f5fb4) which set up basic
 * task structure, and part of that is call to task_trampoline_caller (e00e96ac)
 * (it is followed by check of caller return value).
 * task_trampoline_caller will pass task_trampoline+1 as parameter to another
 * function.
 */
THUMB_FN(0xe01db088, _get_task_info_by_id)
/*
 * kitor: via extask function. While on 5D3 it was called directly, now helper
 * is used. Find extask via string formats. Trace variables holding task id,
 * you will quickly find where it is verified (this is the mentioned helper).
 * In the helper code you will find call to our stub.
 */

/** Recursive locks **/
THUMB_FN(0xe05d03c4,  CreateRecursiveLock)                  /* SystemIF::KerMisc::CreateRecursiveLockStrictly, KerMisc.c line 100  */
THUMB_FN(0xe058ada8,  AcquireRecursiveLock)                 /* SystemIF::KerRLock.c line 0xc6 */
THUMB_FN(0xe058ae72,  ReleaseRecursiveLock)                 /* SystemIF::KerRLock.c line 0x131 */

/** Semaphores **/
THUMB_FN(0xe05d4a24,  create_named_semaphore)               /* SystemIF::KerSem.c line 0x5e  */
THUMB_FN(0xe05d4b9a,  give_semaphore)                       /* SystemIF::KerSem.c line 0x167 */
THUMB_FN(0xe05d4b20,  take_semaphore)                       /* SystemIF::KerSem.c line 0x133 */

/** GUI **/
DATA_PTR(   0x1110c,  gui_task_list)                        // Couldn't find ref to "CtrlMan: Use RecursiveLock", found with CtrlMan.c line 0xd7
THUMB_FN(0xe059dd2e,  SetGUIRequestMode)                    // by debug message
THUMB_FN(0xe0221440,  gui_main_task)                        // parameter to task_create("GuiMainTask"...
THUMB_FN(0xe05a31dc,  dialog_redraw)                        // "pDialog->pSignature == pcSignature" no longer present, look for Dialog.c line 0x2d1
THUMB_FN(0xe03ff02a,  gui_massive_event_loop)               // various "GUICMD_"* strings
THUMB_FN(0xe004efcc,  gui_enqueue_message)                  // via string "warning! QueueLength=" and "GUI::GUI.c" in one function

//THUMB_FN(0xe065a4f4,  gui_init_end)                         // "EndGuiInit" string does not exist in M50 mk ii and no function is called before gui event loop
DATA_PTR(    0x5428,  gui_main_struct)                      // global referenced by function with string "QueueClearFlg Clear"

/*
 * kitor Similar to R180 I was unable to find GUI_Control either. If you compare
 * 200D.101 surrounding functions, it just seems to DNE on R and M50.
 */

/** GUI timers **/
THUMB_FN(0xe032da0a,  StartDateTimer)                       // by debug message
THUMB_FN(0xe032dabc,  CancelDateTimer)                      // by debug message

/** MPU communication **/
/*
 * kitor: skipped for now. InitializeIntercom looks identical to R180?!
 * I thought M50 has no MPU, yet at least buffers are initialized.
 */

/** Queue **/
THUMB_FN(0xe05b9144,  msg_queue_create)                     // easy to spot in create_gui_main_task, KerQueue.c line 0x5f
THUMB_FN(0xe05b9208,  msg_queue_receive)                    // used on gui queue in gui_main_task
THUMB_FN(0xe05b9366,  msg_queue_post)                       // used in gui_enqueue_message
THUMB_FN(0xe05b939c,  msg_queue_count)                      // NOT called before string "warning! QueueLength", look for KerQueue line 0x231

/** Memory **/

/* 
 * Tracking InitializeResourceManager:
 * First 6 functions are the same, though we don't have names for them all
 * Should mean that the first 6 entries are functionally the same. The functions differ starting with VRAM.
 *
 *  gAllocateMemoryResourceCBR = AllocateMemoryResourceCBR;
 *  gContAllocMemoryCBR = ContAllocMemoryCBR;
 *  gFreeMemoryCBR = FreeMemoryCBR;
 *  gShrinkMemoryCBR = ShrinkMemoryCBR;
 *  gAllocStorageCBR = AllocStorageCBR;
 *
 *  The 6th argument isn't documented, but also doesn't appear to be used below. Based on the 200D code, this is:
 *
 *  gDecideSizeCBR = DecideSizeCBR;
 *
 *                        Resource::RscMgr::DecideSize + 1,Resource::RscMgr::AllocMovStorage + 1,
 *                        Resource::RscMgr::DecideMovStorage + 1,Resource::RscMgr::TryFileStorage + 1,
 *                        Resource::RscMgr::AllocDcfFileStorage + 1);
 *
 * The RSC version of these functions were difficult to track down as the number of globals for
 * these callbacks changed between the M50 mk ii and the 200d was changed and the assertion lines
 * have been scrubbed.
 */

THUMB_FN(0xe060e288,  AllocateMemoryResource)               // m_pfAllocMemoryCBR, this function takes 4 params in 200D/EOSR, 3 for 50D
THUMB_FN(0xe060e2b6,  AllocateContinuousMemoryResource)     // m_pfContAllocMemoryCBR, takes 4 params now, 3 for 50D
THUMB_FN(0xe060e2e4,  FreeMemoryResource)                   // m_pfFreeMemoryCBR
THUMB_FN(0xe05c1484,  AddMemoryChunk)                       // Same as in 200D (matched by offsets), may be wrong as multiple variants exists.
                                                            // Other options: e054c3da e054cf5a
THUMB_FN(0xe05c1508,  GetFirstChunkFromSuite)               // "IsSuiteSignature( hSuite )" + PackMem
THUMB_FN(0xe05c1d28,  GetNextMemoryChunk)                   // "IsSuiteSignature( hSuite )" + PackMem
                                                            // Similar function is at e05547a0, but with just a few xrefs and different offset used
THUMB_FN(0xe05c12ca,  GetMemoryAddressOfMemoryChunk)        // "IsChunkSignature( hChunk )" + PackMem - 200D uses "MemChunk" directly
THUMB_FN(0xe05c16d4,  DeleteMemorySuite)                    // String "DeleteMemorySuite 0x%x"
THUMB_FN(0xe05c1960,  CreateMemorySuite)                    // Calls CreateMemoryChunk
THUMB_FN(0xe05c0fa6,  CreateMemoryChunk)                    // String "PackMem.c", calls malloc(0x18)
//kitor: disabled using CONFIG_MEMORY_SRM_NOT_WORKING
//THUMB_FN(0xe056a5c6,  SRM_AllocateMemoryResourceFor1stJob)  // "pMessage" and "pPriorMessage" with "RscMgr.c". Unsure - there seems to be multiple identical functions
                                                            // Matched like in R by structure params to 200D stub 
//THUMB_FN(0xe056da22,  SRM_FreeMemoryResourceFor1stJob)      // find refs to "pMessage", there are several similar looking functions using it,
                                                            // Matched to 200D stub, just buffer size differs (0x34 vs 0x30)

/** Uncategorized **/
DATA_PTR(   0x14190,  sd_device)                            // From function that references "SD_DeviceCreate:"
THUMB_FN(0xe0863600,  LoadCalendarFromRTC)                  // Calls RTCSyncCall. Called from "SetStopMovieRecDate"
THUMB_FN(0xe01e11c0,  ErrForCamera_handler)                 // ERR70, ERR80 etc (DlgErrForCamera.c)

/** Properties **/
THUMB_FN(0xe05c3af6, _prop_cleanup)                         // "PropertyMgr.c", strings changed, found based on 200D
THUMB_FN(0xe05c3516,  prop_register_slave)                  // "PropertyMgr.c", "pRegisterSlave"
THUMB_FN(0xe05c35e4, _prop_request_change)                  // "PropertyMgr.c", "pRequestChange"

/**
 * RGBA / Compositor functions and structures
 */

/** General FEATURE_VRAM_RGBA stubs **/
THUMB_FN(0xe018e040, XimrExe);                              //In RefreshVrmsSurface, just before "XimrExe" debug message
DATA_PTR(   0x11260, winsys_sem);                           //Used in RefreshVrmsSurface around XimrExe call

/*
 * Pointer to first Canon RGBA buffer (GUI). On M50 mk ii this is set up by
 * RENDERER_SetDrawVram
 */
DATA_PTR(   0x1122c, _rgb_vram_info);

/** Wrong on purpose **/
DATA_PTR(       0x0,  LCD_Palette)                          // D8 has no indexed RGB buffers.


/** App handlers **/
/**
 * Those can usually be found by looking at function address passed to
 * WINSYS_CreateDialogBox_wrapper / WINSYS_CreateDialogBox, just after some
 * debug message */
THUMB_FN(0xe056b450,  PlayMain_handler)                     // msg: "StartPlayMain"
THUMB_FN(0xe06c0ba4,  ShootOlcApp_handler)                  // msg: "StartShootOlcApp PopPalette(%d)"
THUMB_FN(0xe0445f00,  LiveViewApp_handler)                  // msg: "StartLiveViewApp(%#x)"
THUMB_FN(0xe07c5da8,  LiveViewShutterApp_handler)           // msg: "StartLiveViewShutterApp"
THUMB_FN(0xe08fd784,  PlayMovieGuideApp_handler)            // msg: "StartPlayMovieGuideApp"

// See R180 stubs.s for details.
DATA_PTR(0x0f500,  PlayMain_dialog)                      // in StartPlayMain()
DATA_PTR(0x15d7c,  ShootOlcApp_dialog)                   // in StartShootOlcApp()
DATA_PTR(0x0e9b8,  LiveViewApp_dialog)                   // in StartLiveViewApp()
DATA_PTR(0x1532c,  LiveViewShutterApp_dialog)            // in StartLiveViewShutterApp(), not sure if needed
DATA_PTR(0x17360,  PlayMovieGuideApp_dialog)             // in StartPlayMovieGuideApp()



/**
 * STUFF BELOW IS WRONG!
 **/

THUMB_FN(0xdf00d365,  fsuDecodePartitionTable)             // inlined like in EOS R. See R180 function_overrides.c for WIP alternative
