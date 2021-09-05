//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

#ifndef _AMR_FILE_CODEC_H_
#define _AMR_FILE_CODEC_H_

#define DEF_CHANNELS 1
#define DEF_BITDEPTH 16

#import <UIKit/UIKit.h>

#if __cplusplus
extern "C" {
#endif
    
NSData *AmrToWave(NSData *data);
NSData *CafToAmr(NSData *data);
    
#if __cplusplus
} //Extern C
#endif

#endif
