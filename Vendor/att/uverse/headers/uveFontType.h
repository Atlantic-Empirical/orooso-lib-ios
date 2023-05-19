//
//  uveFontType.h
//  DAIS
//
//  Created by Erik Smith on 10/6/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#ifndef DAIS_uveFontType_h
#define DAIS_uveFontType_h

/*! \file uveFontType.h
 */

/*! \enum uveFontType
These are the fonts available. They fall into four categories: Regular, Bold, Italic, and Bold-Italic. The larger the number, the larger the font. Typically use fonts of at least size 18. The available fonts are:
 
 kUveReg16,kUveReg17,kUveReg18,kUveReg19,kUveReg20,kUveReg21,kUveReg22,kUveReg23,kUveReg24,kUveReg26,kUveReg28,kUveReg30,kUveReg32,kUveReg36,kUveReg39,kUveReg42,kUveReg48,kUveReg56,kUveReg64,kUveReg72,
 
 kUveBold16,kUveBold17,kUveBold18,kUveBold19,kUveBold20,kUveBold21,kUveBold22,kUveBold23,kUveBold24,kUveBold26,kUveBold28,kUveBold30,kUveBold32,kUveBold36,kUveBold39,kUveBold42,kUveBold48,kUveBold56,kUveBold64,kUveBold72,
 
 kUveItalic16,kUveItalic17,kUveItalic18,kUveItalic19,kUveItalic20,kUveItalic21,kUveItalic22,kUveItalic23,kUveItalic24,kUveItalic26,kUveItalic28,kUveItalic30,kUveItalic32,kUveItalic36,kUveItalic39,kUveItalic42,kUveItalic48,kUveItalic56,kUveItalic64,kUveItalic72,
 
 kUveBoldItalic16,kUveBoldItalic17,kUveBoldItalic18,kUveBoldItalic19,kUveBoldItalic20,kUveBoldItalic21,kUveBoldItalic22,kUveBoldItalic23,kUveBoldItalic24,kUveBoldItalic26,kUveBoldItalic28,kUveBoldItalic30,kUveBoldItalic32,kUveBoldItalic36,kUveBoldItalic39,kUveBoldItalic42,kUveBoldItalic48,kUveBoldItalic56,kUveBoldItalic64,kUveBoldItalic72

*/
typedef enum
{
    
    kUveReg16,kUveReg17,kUveReg18,kUveReg19,kUveReg20,kUveReg21,kUveReg22,kUveReg23,kUveReg24,kUveReg26,kUveReg28,kUveReg30,kUveReg32,kUveReg36,kUveReg39,kUveReg42,kUveReg48,kUveReg56,kUveReg64,kUveReg72,
    
    kUveBold16,kUveBold17,kUveBold18,kUveBold19,kUveBold20,kUveBold21,kUveBold22,kUveBold23,kUveBold24,kUveBold26,kUveBold28,kUveBold30,kUveBold32,kUveBold36,kUveBold39,kUveBold42,kUveBold48,kUveBold56,kUveBold64,kUveBold72,
    
    kUveItalic16,kUveItalic17,kUveItalic18,kUveItalic19,kUveItalic20,kUveItalic21,kUveItalic22,kUveItalic23,kUveItalic24,kUveItalic26,kUveItalic28,kUveItalic30,kUveItalic32,kUveItalic36,kUveItalic39,kUveItalic42,kUveItalic48,kUveItalic56,kUveItalic64,kUveItalic72,
    
    kUveBoldItalic16,kUveBoldItalic17,kUveBoldItalic18,kUveBoldItalic19,kUveBoldItalic20,kUveBoldItalic21,kUveBoldItalic22,kUveBoldItalic23,kUveBoldItalic24,kUveBoldItalic26,kUveBoldItalic28,kUveBoldItalic30,kUveBoldItalic32,kUveBoldItalic36,kUveBoldItalic39,kUveBoldItalic42,kUveBoldItalic48,kUveBoldItalic56,kUveBoldItalic64,kUveBoldItalic72
    
} uveFontType;


#endif