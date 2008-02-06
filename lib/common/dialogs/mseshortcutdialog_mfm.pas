unit mseshortcutdialog_mfm;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

implementation
uses
 mseclasses,mseshortcutdialog;

const
 objdata: record size: integer; data: array[0..6129] of byte end =
      (size: 6130; data: (
  84,80,70,48,20,116,109,115,101,115,104,111,114,116,99,117,116,100,105,97,
  108,111,103,102,111,19,109,115,101,115,104,111,114,116,99,117,116,100,105,97,
  108,111,103,102,111,8,98,111,117,110,100,115,95,120,2,87,8,98,111,117,
  110,100,115,95,121,3,222,0,9,98,111,117,110,100,115,95,99,120,3,66,
  2,9,98,111,117,110,100,115,95,99,121,3,84,1,8,116,97,98,111,114,
  100,101,114,2,1,7,118,105,115,105,98,108,101,8,23,99,111,110,116,97,
  105,110,101,114,46,111,112,116,105,111,110,115,119,105,100,103,101,116,11,13,
  111,119,95,109,111,117,115,101,102,111,99,117,115,11,111,119,95,116,97,98,
  102,111,99,117,115,13,111,119,95,97,114,114,111,119,102,111,99,117,115,11,
  111,119,95,115,117,98,102,111,99,117,115,19,111,119,95,109,111,117,115,101,
  116,114,97,110,115,112,97,114,101,110,116,13,111,119,95,109,111,117,115,101,
  119,104,101,101,108,17,111,119,95,100,101,115,116,114,111,121,119,105,100,103,
  101,116,115,12,111,119,95,97,117,116,111,115,99,97,108,101,0,18,99,111,
  110,116,97,105,110,101,114,46,98,111,117,110,100,115,95,120,2,0,18,99,
  111,110,116,97,105,110,101,114,46,98,111,117,110,100,115,95,121,2,0,19,
  99,111,110,116,97,105,110,101,114,46,98,111,117,110,100,115,95,99,120,3,
  66,2,19,99,111,110,116,97,105,110,101,114,46,98,111,117,110,100,115,95,
  99,121,3,84,1,21,99,111,110,116,97,105,110,101,114,46,102,114,97,109,
  101,46,100,117,109,109,121,2,0,7,111,112,116,105,111,110,115,11,17,102,
  111,95,115,99,114,101,101,110,99,101,110,116,101,114,101,100,17,102,111,95,
  108,111,99,97,108,115,104,111,114,116,99,117,116,115,15,102,111,95,97,117,
  116,111,114,101,97,100,115,116,97,116,16,102,111,95,97,117,116,111,119,114,
  105,116,101,115,116,97,116,10,102,111,95,115,97,118,101,112,111,115,12,102,
  111,95,115,97,118,101,115,116,97,116,101,0,7,99,97,112,116,105,111,110,
  6,9,83,104,111,114,116,99,117,116,115,15,109,111,100,117,108,101,99,108,
  97,115,115,110,97,109,101,6,8,116,109,115,101,102,111,114,109,0,11,116,
  119,105,100,103,101,116,103,114,105,100,4,103,114,105,100,13,111,112,116,105,
  111,110,115,119,105,100,103,101,116,11,13,111,119,95,109,111,117,115,101,102,
  111,99,117,115,11,111,119,95,116,97,98,102,111,99,117,115,13,111,119,95,
  97,114,114,111,119,102,111,99,117,115,17,111,119,95,102,111,99,117,115,98,
  97,99,107,111,110,101,115,99,13,111,119,95,109,111,117,115,101,119,104,101,
  101,108,17,111,119,95,100,101,115,116,114,111,121,119,105,100,103,101,116,115,
  18,111,119,95,102,111,110,116,103,108,121,112,104,104,101,105,103,104,116,12,
  111,119,95,97,117,116,111,115,99,97,108,101,0,8,98,111,117,110,100,115,
  95,120,2,0,8,98,111,117,110,100,115,95,121,2,0,9,98,111,117,110,
  100,115,95,99,120,3,66,2,9,98,111,117,110,100,115,95,99,121,3,30,
  1,11,102,114,97,109,101,46,100,117,109,109,121,2,0,7,97,110,99,104,
  111,114,115,11,6,97,110,95,116,111,112,9,97,110,95,98,111,116,116,111,
  109,0,9,112,111,112,117,112,109,101,110,117,7,11,116,112,111,112,117,112,
  109,101,110,117,49,11,111,112,116,105,111,110,115,103,114,105,100,11,12,111,
  103,95,99,111,108,115,105,122,105,110,103,19,111,103,95,102,111,99,117,115,
  99,101,108,108,111,110,101,110,116,101,114,20,111,103,95,99,111,108,99,104,
  97,110,103,101,111,110,116,97,98,107,101,121,12,111,103,95,97,117,116,111,
  112,111,112,117,112,17,111,103,95,109,111,117,115,101,115,99,114,111,108,108,
  99,111,108,0,13,102,105,120,114,111,119,115,46,99,111,117,110,116,2,1,
  13,102,105,120,114,111,119,115,46,105,116,101,109,115,14,1,6,104,101,105,
  103,104,116,2,16,14,99,97,112,116,105,111,110,115,46,99,111,117,110,116,
  2,3,14,99,97,112,116,105,111,110,115,46,105,116,101,109,115,14,1,7,
  99,97,112,116,105,111,110,6,6,65,99,116,105,111,110,9,102,111,110,116,
  46,110,97,109,101,6,11,115,116,102,95,100,101,102,97,117,108,116,11,102,
  111,110,116,46,120,115,99,97,108,101,5,0,0,0,0,0,0,0,128,255,
  63,10,102,111,110,116,46,100,117,109,109,121,2,0,0,1,7,99,97,112,
  116,105,111,110,6,8,83,104,111,114,116,99,117,116,9,102,111,110,116,46,
  110,97,109,101,6,11,115,116,102,95,100,101,102,97,117,108,116,11,102,111,
  110,116,46,120,115,99,97,108,101,5,0,0,0,0,0,0,0,128,255,63,
  10,102,111,110,116,46,100,117,109,109,121,2,0,0,1,7,99,97,112,116,
  105,111,110,6,9,65,108,116,101,114,110,97,116,101,9,102,111,110,116,46,
  110,97,109,101,6,11,115,116,102,95,100,101,102,97,117,108,116,11,102,111,
  110,116,46,120,115,99,97,108,101,5,0,0,0,0,0,0,0,128,255,63,
  10,102,111,110,116,46,100,117,109,109,121,2,0,0,0,0,0,14,100,97,
  116,97,99,111,108,115,46,99,111,117,110,116,2,3,16,100,97,116,97,99,
  111,108,115,46,111,112,116,105,111,110,115,11,14,99,111,95,102,111,99,117,
  115,115,101,108,101,99,116,12,99,111,95,114,111,119,115,101,108,101,99,116,
  12,99,111,95,115,97,118,101,118,97,108,117,101,12,99,111,95,115,97,118,
  101,115,116,97,116,101,10,99,111,95,114,111,119,102,111,110,116,11,99,111,
  95,114,111,119,99,111,108,111,114,13,99,111,95,122,101,98,114,97,99,111,
  108,111,114,17,99,111,95,109,111,117,115,101,115,99,114,111,108,108,114,111,
  119,0,14,100,97,116,97,99,111,108,115,46,105,116,101,109,115,14,1,5,
  119,105,100,116,104,3,65,1,16,111,110,98,101,102,111,114,101,100,114,97,
  119,99,101,108,108,7,14,98,101,102,111,114,101,100,114,97,119,110,111,100,
  101,7,111,112,116,105,111,110,115,11,11,99,111,95,114,101,97,100,111,110,
  108,121,12,99,111,95,100,114,97,119,102,111,99,117,115,14,99,111,95,102,
  111,99,117,115,115,101,108,101,99,116,12,99,111,95,114,111,119,115,101,108,
  101,99,116,7,99,111,95,102,105,108,108,12,99,111,95,115,97,118,101,118,
  97,108,117,101,12,99,111,95,115,97,118,101,115,116,97,116,101,10,99,111,
  95,114,111,119,102,111,110,116,11,99,111,95,114,111,119,99,111,108,111,114,
  13,99,111,95,122,101,98,114,97,99,111,108,111,114,17,99,111,95,109,111,
  117,115,101,115,99,114,111,108,108,114,111,119,0,10,119,105,100,103,101,116,
  110,97,109,101,6,2,115,99,0,1,5,119,105,100,116,104,2,125,16,111,
  110,98,101,102,111,114,101,100,114,97,119,99,101,108,108,7,10,98,101,102,
  111,114,101,100,114,97,119,7,111,112,116,105,111,110,115,11,11,99,111,95,
  114,101,97,100,111,110,108,121,10,99,111,95,110,111,102,111,99,117,115,14,
  99,111,95,102,111,99,117,115,115,101,108,101,99,116,12,99,111,95,114,111,
  119,115,101,108,101,99,116,12,99,111,95,115,97,118,101,118,97,108,117,101,
  12,99,111,95,115,97,118,101,115,116,97,116,101,10,99,111,95,114,111,119,
  102,111,110,116,11,99,111,95,114,111,119,99,111,108,111,114,13,99,111,95,
  122,101,98,114,97,99,111,108,111,114,17,99,111,95,109,111,117,115,101,115,
  99,114,111,108,108,114,111,119,0,10,119,105,100,103,101,116,110,97,109,101,
  6,4,115,99,100,105,0,1,5,119,105,100,116,104,2,125,16,111,110,98,
  101,102,111,114,101,100,114,97,119,99,101,108,108,7,11,98,101,102,111,114,
  101,100,114,97,119,49,7,111,112,116,105,111,110,115,11,11,99,111,95,114,
  101,97,100,111,110,108,121,10,99,111,95,110,111,102,111,99,117,115,14,99,
  111,95,102,111,99,117,115,115,101,108,101,99,116,12,99,111,95,114,111,119,
  115,101,108,101,99,116,12,99,111,95,115,97,118,101,118,97,108,117,101,12,
  99,111,95,115,97,118,101,115,116,97,116,101,10,99,111,95,114,111,119,102,
  111,110,116,11,99,111,95,114,111,119,99,111,108,111,114,13,99,111,95,122,
  101,98,114,97,99,111,108,111,114,17,99,111,95,109,111,117,115,101,115,99,
  114,111,108,108,114,111,119,0,10,119,105,100,103,101,116,110,97,109,101,6,
  5,115,99,49,100,105,0,0,13,100,97,116,97,114,111,119,104,101,105,103,
  104,116,2,16,11,111,110,99,101,108,108,101,118,101,110,116,7,13,103,114,
  105,100,99,101,108,108,101,118,101,110,116,13,114,101,102,102,111,110,116,104,
  101,105,103,104,116,2,14,0,13,116,116,114,101,101,105,116,101,109,101,100,
  105,116,2,115,99,13,111,112,116,105,111,110,115,119,105,100,103,101,116,11,
  13,111,119,95,109,111,117,115,101,102,111,99,117,115,11,111,119,95,116,97,
  98,102,111,99,117,115,13,111,119,95,97,114,114,111,119,102,111,99,117,115,
  17,111,119,95,100,101,115,116,114,111,121,119,105,100,103,101,116,115,18,111,
  119,95,102,111,110,116,103,108,121,112,104,104,101,105,103,104,116,12,111,119,
  95,97,117,116,111,115,99,97,108,101,0,11,111,112,116,105,111,110,115,115,
  107,105,110,11,19,111,115,107,95,102,114,97,109,101,98,117,116,116,111,110,
  111,110,108,121,0,8,98,111,117,110,100,115,95,120,2,0,8,98,111,117,
  110,100,115,95,121,2,0,9,98,111,117,110,100,115,95,99,120,3,65,1,
  9,98,111,117,110,100,115,95,99,121,2,16,12,102,114,97,109,101,46,108,
  101,118,101,108,111,2,0,17,102,114,97,109,101,46,99,111,108,111,114,99,
  108,105,101,110,116,4,3,0,0,128,16,102,114,97,109,101,46,108,111,99,
  97,108,112,114,111,112,115,11,10,102,114,108,95,108,101,118,101,108,111,10,
  102,114,108,95,108,101,118,101,108,105,15,102,114,108,95,99,111,108,111,114,
  99,108,105,101,110,116,0,11,102,114,97,109,101,46,100,117,109,109,121,2,
  0,8,116,97,98,111,114,100,101,114,2,1,7,118,105,115,105,98,108,101,
  8,11,111,112,116,105,111,110,115,101,100,105,116,11,11,111,101,95,114,101,
  97,100,111,110,108,121,12,111,101,95,117,110,100,111,111,110,101,115,99,13,
  111,101,95,99,108,111,115,101,113,117,101,114,121,16,111,101,95,99,104,101,
  99,107,109,114,99,97,110,99,101,108,15,111,101,95,101,120,105,116,111,110,
  99,117,114,115,111,114,14,111,101,95,115,104,105,102,116,114,101,116,117,114,
  110,12,111,101,95,101,97,116,114,101,116,117,114,110,20,111,101,95,114,101,
  115,101,116,115,101,108,101,99,116,111,110,101,120,105,116,13,111,101,95,101,
  110,100,111,110,101,110,116,101,114,13,111,101,95,97,117,116,111,115,101,108,
  101,99,116,9,111,101,95,108,111,99,97,116,101,13,111,101,95,107,101,121,
  101,120,101,99,117,116,101,12,111,101,95,115,97,118,101,118,97,108,117,101,
  12,111,101,95,115,97,118,101,115,116,97,116,101,0,17,111,110,117,112,100,
  97,116,101,114,111,119,118,97,108,117,101,115,7,15,117,112,100,97,116,101,
  114,111,119,118,97,108,117,101,115,7,111,112,116,105,111,110,115,11,16,116,
  101,111,95,116,114,101,101,99,111,108,110,97,118,105,103,0,13,114,101,102,
  102,111,110,116,104,101,105,103,104,116,2,14,0,0,11,116,115,116,114,105,
  110,103,101,100,105,116,4,115,99,100,105,13,111,112,116,105,111,110,115,119,
  105,100,103,101,116,11,13,111,119,95,109,111,117,115,101,102,111,99,117,115,
  11,111,119,95,116,97,98,102,111,99,117,115,13,111,119,95,97,114,114,111,
  119,102,111,99,117,115,17,111,119,95,100,101,115,116,114,111,121,119,105,100,
  103,101,116,115,18,111,119,95,102,111,110,116,103,108,121,112,104,104,101,105,
  103,104,116,0,11,111,112,116,105,111,110,115,115,107,105,110,11,19,111,115,
  107,95,102,114,97,109,101,98,117,116,116,111,110,111,110,108,121,0,8,98,
  111,117,110,100,115,95,120,3,66,1,8,98,111,117,110,100,115,95,121,2,
  0,9,98,111,117,110,100,115,95,99,120,2,125,9,98,111,117,110,100,115,
  95,99,121,2,16,12,102,114,97,109,101,46,108,101,118,101,108,111,2,0,
  17,102,114,97,109,101,46,99,111,108,111,114,99,108,105,101,110,116,4,3,
  0,0,128,16,102,114,97,109,101,46,108,111,99,97,108,112,114,111,112,115,
  11,10,102,114,108,95,108,101,118,101,108,111,10,102,114,108,95,108,101,118,
  101,108,105,15,102,114,108,95,99,111,108,111,114,99,108,105,101,110,116,0,
  11,102,114,97,109,101,46,100,117,109,109,121,2,0,8,116,97,98,111,114,
  100,101,114,2,2,7,118,105,115,105,98,108,101,8,11,111,112,116,105,111,
  110,115,101,100,105,116,11,11,111,101,95,114,101,97,100,111,110,108,121,12,
  111,101,95,117,110,100,111,111,110,101,115,99,13,111,101,95,99,108,111,115,
  101,113,117,101,114,121,16,111,101,95,99,104,101,99,107,109,114,99,97,110,
  99,101,108,15,111,101,95,101,120,105,116,111,110,99,117,114,115,111,114,14,
  111,101,95,115,104,105,102,116,114,101,116,117,114,110,12,111,101,95,101,97,
  116,114,101,116,117,114,110,20,111,101,95,114,101,115,101,116,115,101,108,101,
  99,116,111,110,101,120,105,116,13,111,101,95,101,110,100,111,110,101,110,116,
  101,114,13,111,101,95,97,117,116,111,115,101,108,101,99,116,25,111,101,95,
  97,117,116,111,115,101,108,101,99,116,111,110,102,105,114,115,116,99,108,105,
  99,107,16,111,101,95,97,117,116,111,112,111,112,117,112,109,101,110,117,13,
  111,101,95,107,101,121,101,120,101,99,117,116,101,12,111,101,95,115,97,118,
  101,118,97,108,117,101,12,111,101,95,115,97,118,101,115,116,97,116,101,0,
  13,114,101,102,102,111,110,116,104,101,105,103,104,116,2,14,0,0,11,116,
  115,116,114,105,110,103,101,100,105,116,5,115,99,49,100,105,3,84,97,103,
  2,1,13,111,112,116,105,111,110,115,119,105,100,103,101,116,11,13,111,119,
  95,109,111,117,115,101,102,111,99,117,115,11,111,119,95,116,97,98,102,111,
  99,117,115,13,111,119,95,97,114,114,111,119,102,111,99,117,115,17,111,119,
  95,100,101,115,116,114,111,121,119,105,100,103,101,116,115,18,111,119,95,102,
  111,110,116,103,108,121,112,104,104,101,105,103,104,116,0,11,111,112,116,105,
  111,110,115,115,107,105,110,11,19,111,115,107,95,102,114,97,109,101,98,117,
  116,116,111,110,111,110,108,121,0,8,98,111,117,110,100,115,95,120,3,192,
  1,8,98,111,117,110,100,115,95,121,2,0,9,98,111,117,110,100,115,95,
  99,120,2,125,9,98,111,117,110,100,115,95,99,121,2,16,12,102,114,97,
  109,101,46,108,101,118,101,108,111,2,0,17,102,114,97,109,101,46,99,111,
  108,111,114,99,108,105,101,110,116,4,3,0,0,128,16,102,114,97,109,101,
  46,108,111,99,97,108,112,114,111,112,115,11,10,102,114,108,95,108,101,118,
  101,108,111,10,102,114,108,95,108,101,118,101,108,105,15,102,114,108,95,99,
  111,108,111,114,99,108,105,101,110,116,0,11,102,114,97,109,101,46,100,117,
  109,109,121,2,0,8,116,97,98,111,114,100,101,114,2,3,7,118,105,115,
  105,98,108,101,8,11,111,112,116,105,111,110,115,101,100,105,116,11,11,111,
  101,95,114,101,97,100,111,110,108,121,12,111,101,95,117,110,100,111,111,110,
  101,115,99,13,111,101,95,99,108,111,115,101,113,117,101,114,121,16,111,101,
  95,99,104,101,99,107,109,114,99,97,110,99,101,108,15,111,101,95,101,120,
  105,116,111,110,99,117,114,115,111,114,14,111,101,95,115,104,105,102,116,114,
  101,116,117,114,110,12,111,101,95,101,97,116,114,101,116,117,114,110,20,111,
  101,95,114,101,115,101,116,115,101,108,101,99,116,111,110,101,120,105,116,13,
  111,101,95,101,110,100,111,110,101,110,116,101,114,13,111,101,95,97,117,116,
  111,115,101,108,101,99,116,25,111,101,95,97,117,116,111,115,101,108,101,99,
  116,111,110,102,105,114,115,116,99,108,105,99,107,16,111,101,95,97,117,116,
  111,112,111,112,117,112,109,101,110,117,13,111,101,95,107,101,121,101,120,101,
  99,117,116,101,12,111,101,95,115,97,118,101,118,97,108,117,101,12,111,101,
  95,115,97,118,101,115,116,97,116,101,0,13,114,101,102,102,111,110,116,104,
  101,105,103,104,116,2,14,0,0,0,7,116,98,117,116,116,111,110,8,116,
  98,117,116,116,111,110,49,8,98,111,117,110,100,115,95,120,3,205,1,8,
  98,111,117,110,100,115,95,121,3,50,1,9,98,111,117,110,100,115,95,99,
  120,2,50,9,98,111,117,110,100,115,95,99,121,2,20,7,97,110,99,104,
  111,114,115,11,7,97,110,95,108,101,102,116,9,97,110,95,98,111,116,116,
  111,109,0,8,116,97,98,111,114,100,101,114,2,1,5,115,116,97,116,101,
  11,15,97,115,95,108,111,99,97,108,99,97,112,116,105,111,110,0,7,99,
  97,112,116,105,111,110,6,2,79,75,11,109,111,100,97,108,114,101,115,117,
  108,116,7,5,109,114,95,111,107,0,0,7,116,98,117,116,116,111,110,8,
  116,98,117,116,116,111,110,50,8,98,111,117,110,100,115,95,120,3,5,2,
  8,98,111,117,110,100,115,95,121,3,50,1,9,98,111,117,110,100,115,95,
  99,120,2,50,9,98,111,117,110,100,115,95,99,121,2,20,7,97,110,99,
  104,111,114,115,11,7,97,110,95,108,101,102,116,9,97,110,95,98,111,116,
  116,111,109,0,8,116,97,98,111,114,100,101,114,2,2,5,115,116,97,116,
  101,11,15,97,115,95,108,111,99,97,108,99,97,112,116,105,111,110,0,7,
  99,97,112,116,105,111,110,6,6,67,97,110,99,101,108,11,109,111,100,97,
  108,114,101,115,117,108,116,7,9,109,114,95,99,97,110,99,101,108,0,0,
  11,116,115,116,114,105,110,103,101,100,105,116,5,115,99,49,101,100,3,84,
  97,103,2,1,13,111,112,116,105,111,110,115,119,105,100,103,101,116,11,13,
  111,119,95,109,111,117,115,101,102,111,99,117,115,11,111,119,95,116,97,98,
  102,111,99,117,115,13,111,119,95,97,114,114,111,119,102,111,99,117,115,17,
  111,119,95,100,101,115,116,114,111,121,119,105,100,103,101,116,115,18,111,119,
  95,102,111,110,116,103,108,121,112,104,104,101,105,103,104,116,12,111,119,95,
  97,117,116,111,115,99,97,108,101,0,8,98,111,117,110,100,115,95,120,3,
  16,1,8,98,111,117,110,100,115,95,121,3,33,1,9,98,111,117,110,100,
  115,95,99,120,3,180,0,9,98,111,117,110,100,115,95,99,121,2,37,12,
  102,114,97,109,101,46,108,101,118,101,108,111,2,0,16,102,114,97,109,101,
  46,102,114,97,109,101,119,105,100,116,104,2,1,16,102,114,97,109,101,46,
  99,111,108,111,114,102,114,97,109,101,4,2,0,0,160,13,102,114,97,109,
  101,46,99,97,112,116,105,111,110,6,10,38,65,108,116,101,114,110,97,116,
  101,16,102,114,97,109,101,46,108,111,99,97,108,112,114,111,112,115,11,10,
  102,114,108,95,108,101,118,101,108,111,14,102,114,108,95,102,114,97,109,101,
  119,105,100,116,104,14,102,114,108,95,99,111,108,111,114,102,114,97,109,101,
  10,102,114,108,95,102,105,108,101,102,116,0,11,102,114,97,109,101,46,100,
  117,109,109,121,2,0,16,102,114,97,109,101,46,111,117,116,101,114,102,114,
  97,109,101,1,2,0,2,17,2,0,2,0,0,7,97,110,99,104,111,114,
  115,11,7,97,110,95,108,101,102,116,9,97,110,95,98,111,116,116,111,109,
  0,8,116,97,98,111,114,100,101,114,2,3,10,111,110,97,99,116,105,118,
  97,116,101,7,10,101,100,97,99,116,105,118,97,116,101,12,111,110,100,101,
  97,99,116,105,118,97,116,101,7,12,101,100,100,101,97,99,116,105,118,97,
  116,101,11,111,112,116,105,111,110,115,101,100,105,116,11,11,111,101,95,114,
  101,97,100,111,110,108,121,12,111,101,95,117,110,100,111,111,110,101,115,99,
  13,111,101,95,99,108,111,115,101,113,117,101,114,121,16,111,101,95,99,104,
  101,99,107,109,114,99,97,110,99,101,108,15,111,101,95,101,120,105,116,111,
  110,99,117,114,115,111,114,14,111,101,95,115,104,105,102,116,114,101,116,117,
  114,110,12,111,101,95,101,97,116,114,101,116,117,114,110,20,111,101,95,114,
  101,115,101,116,115,101,108,101,99,116,111,110,101,120,105,116,13,111,101,95,
  101,110,100,111,110,101,110,116,101,114,13,111,101,95,97,117,116,111,115,101,
  108,101,99,116,25,111,101,95,97,117,116,111,115,101,108,101,99,116,111,110,
  102,105,114,115,116,99,108,105,99,107,16,111,101,95,97,117,116,111,112,111,
  112,117,112,109,101,110,117,13,111,101,95,107,101,121,101,120,101,99,117,116,
  101,12,111,101,95,115,97,118,101,118,97,108,117,101,12,111,101,95,115,97,
  118,101,115,116,97,116,101,0,9,111,110,107,101,121,100,111,119,110,7,7,
  115,99,100,105,107,101,121,7,111,110,107,101,121,117,112,7,7,115,99,100,
  105,107,101,121,13,114,101,102,102,111,110,116,104,101,105,103,104,116,2,14,
  0,0,11,116,115,116,114,105,110,103,101,100,105,116,4,115,99,101,100,13,
  111,112,116,105,111,110,115,119,105,100,103,101,116,11,13,111,119,95,109,111,
  117,115,101,102,111,99,117,115,11,111,119,95,116,97,98,102,111,99,117,115,
  13,111,119,95,97,114,114,111,119,102,111,99,117,115,17,111,119,95,100,101,
  115,116,114,111,121,119,105,100,103,101,116,115,18,111,119,95,102,111,110,116,
  103,108,121,112,104,104,101,105,103,104,116,12,111,119,95,97,117,116,111,115,
  99,97,108,101,0,8,98,111,117,110,100,115,95,120,2,67,8,98,111,117,
  110,100,115,95,121,3,33,1,9,98,111,117,110,100,115,95,99,120,3,196,
  0,9,98,111,117,110,100,115,95,99,121,2,37,12,102,114,97,109,101,46,
  108,101,118,101,108,111,2,0,16,102,114,97,109,101,46,102,114,97,109,101,
  119,105,100,116,104,2,1,16,102,114,97,109,101,46,99,111,108,111,114,102,
  114,97,109,101,4,2,0,0,160,13,102,114,97,109,101,46,99,97,112,116,
  105,111,110,6,9,38,83,104,111,114,116,99,117,116,16,102,114,97,109,101,
  46,108,111,99,97,108,112,114,111,112,115,11,10,102,114,108,95,108,101,118,
  101,108,111,14,102,114,108,95,102,114,97,109,101,119,105,100,116,104,14,102,
  114,108,95,99,111,108,111,114,102,114,97,109,101,0,11,102,114,97,109,101,
  46,100,117,109,109,121,2,0,16,102,114,97,109,101,46,111,117,116,101,114,
  102,114,97,109,101,1,2,0,2,17,2,0,2,0,0,7,97,110,99,104,
  111,114,115,11,7,97,110,95,108,101,102,116,9,97,110,95,98,111,116,116,
  111,109,0,8,116,97,98,111,114,100,101,114,2,4,10,111,110,97,99,116,
  105,118,97,116,101,7,10,101,100,97,99,116,105,118,97,116,101,12,111,110,
  100,101,97,99,116,105,118,97,116,101,7,12,101,100,100,101,97,99,116,105,
  118,97,116,101,11,111,112,116,105,111,110,115,101,100,105,116,11,11,111,101,
  95,114,101,97,100,111,110,108,121,12,111,101,95,117,110,100,111,111,110,101,
  115,99,13,111,101,95,99,108,111,115,101,113,117,101,114,121,16,111,101,95,
  99,104,101,99,107,109,114,99,97,110,99,101,108,15,111,101,95,101,120,105,
  116,111,110,99,117,114,115,111,114,14,111,101,95,115,104,105,102,116,114,101,
  116,117,114,110,12,111,101,95,101,97,116,114,101,116,117,114,110,20,111,101,
  95,114,101,115,101,116,115,101,108,101,99,116,111,110,101,120,105,116,13,111,
  101,95,101,110,100,111,110,101,110,116,101,114,13,111,101,95,97,117,116,111,
  115,101,108,101,99,116,25,111,101,95,97,117,116,111,115,101,108,101,99,116,
  111,110,102,105,114,115,116,99,108,105,99,107,16,111,101,95,97,117,116,111,
  112,111,112,117,112,109,101,110,117,13,111,101,95,107,101,121,101,120,101,99,
  117,116,101,12,111,101,95,115,97,118,101,118,97,108,117,101,12,111,101,95,
  115,97,118,101,115,116,97,116,101,0,9,111,110,107,101,121,100,111,119,110,
  7,7,115,99,100,105,107,101,121,7,111,110,107,101,121,117,112,7,7,115,
  99,100,105,107,101,121,13,114,101,102,102,111,110,116,104,101,105,103,104,116,
  2,14,0,0,7,116,98,117,116,116,111,110,9,100,101,102,97,117,108,116,
  98,117,8,98,111,117,110,100,115,95,120,2,8,8,98,111,117,110,100,115,
  95,121,3,50,1,9,98,111,117,110,100,115,95,99,120,2,50,9,98,111,
  117,110,100,115,95,99,121,2,20,5,99,111,108,111,114,4,3,0,0,128,
  7,97,110,99,104,111,114,115,11,7,97,110,95,108,101,102,116,9,97,110,
  95,98,111,116,116,111,109,0,8,116,97,98,111,114,100,101,114,2,5,5,
  115,116,97,116,101,11,15,97,115,95,108,111,99,97,108,99,97,112,116,105,
  111,110,13,97,115,95,108,111,99,97,108,99,111,108,111,114,17,97,115,95,
  108,111,99,97,108,111,110,101,120,101,99,117,116,101,0,7,99,97,112,116,
  105,111,110,6,7,68,101,102,97,117,108,116,9,111,110,101,120,101,99,117,
  116,101,7,9,100,101,102,97,117,108,116,101,120,0,0,10,116,112,111,112,
  117,112,109,101,110,117,11,116,112,111,112,117,112,109,101,110,117,49,18,109,
  101,110,117,46,115,117,98,109,101,110,117,46,99,111,117,110,116,2,2,18,
  109,101,110,117,46,115,117,98,109,101,110,117,46,105,116,101,109,115,14,1,
  7,99,97,112,116,105,111,110,6,10,69,120,112,97,110,100,32,97,108,108,
  5,115,116,97,116,101,11,15,97,115,95,108,111,99,97,108,99,97,112,116,
  105,111,110,17,97,115,95,108,111,99,97,108,111,110,101,120,101,99,117,116,
  101,0,9,111,110,101,120,101,99,117,116,101,7,9,101,120,112,97,110,100,
  97,108,108,0,1,7,99,97,112,116,105,111,110,6,12,67,111,108,108,97,
  112,115,101,32,97,108,108,5,115,116,97,116,101,11,15,97,115,95,108,111,
  99,97,108,99,97,112,116,105,111,110,17,97,115,95,108,111,99,97,108,111,
  110,101,120,101,99,117,116,101,0,9,111,110,101,120,101,99,117,116,101,7,
  11,99,111,108,108,97,112,115,101,97,108,108,0,0,4,108,101,102,116,2,
  32,3,116,111,112,2,64,0,0,0)
 );

initialization
 registerobjectdata(@objdata,tmseshortcutdialogfo,'');
end.
