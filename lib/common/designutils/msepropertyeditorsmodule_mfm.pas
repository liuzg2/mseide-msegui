unit msepropertyeditorsmodule_mfm;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 mseclasses,msepropertyeditorsmodule;

const
 objdata: record size: integer; data: array[0..413] of byte end =
      (size: 414; data: (
  84,80,70,48,21,116,109,115,101,112,114,111,112,101,114,116,121,101,100,105,
  116,111,114,115,109,111,20,109,115,101,112,114,111,112,101,114,116,121,101,100,
  105,116,111,114,115,109,111,9,98,111,117,110,100,115,95,99,120,2,100,9,
  98,111,117,110,100,115,95,99,121,2,100,4,108,101,102,116,2,100,3,116,
  111,112,2,100,15,109,111,100,117,108,101,99,108,97,115,115,110,97,109,101,
  6,14,116,109,115,101,100,97,116,97,109,111,100,117,108,101,0,16,116,115,
  116,114,105,110,103,99,111,110,116,97,105,110,101,114,1,99,12,115,116,114,
  105,110,103,115,46,100,97,116,97,1,6,15,79,112,101,110,32,105,109,97,
  103,101,32,102,105,108,101,6,16,73,110,118,97,108,105,100,32,115,101,116,
  32,105,116,101,109,6,7,85,110,107,110,111,119,110,6,20,87,114,111,110,
  103,32,112,114,111,112,101,114,116,121,32,118,97,108,117,101,6,19,73,110,
  118,97,108,105,100,32,109,101,116,104,111,100,32,110,97,109,101,6,11,77,
  101,116,104,111,100,32,110,97,109,101,6,6,101,120,105,115,116,115,6,22,
  68,111,32,121,111,117,32,119,105,115,104,32,116,111,32,100,101,115,116,114,
  111,121,6,27,68,111,32,121,111,117,32,119,105,115,104,32,116,111,32,100,
  101,108,101,116,101,32,105,116,101,109,115,6,2,116,111,6,10,69,109,112,
  116,121,32,100,97,116,101,6,10,69,109,112,116,121,32,116,105,109,101,6,
  20,68,111,32,121,111,117,32,119,105,115,104,32,116,111,32,99,108,101,97,
  114,6,10,84,101,120,116,101,100,105,116,111,114,6,22,73,110,118,97,108,
  105,100,32,99,111,109,112,111,110,101,110,116,32,110,97,109,101,0,4,108,
  101,102,116,2,32,3,116,111,112,2,40,0,0,0)
 );

initialization
 registerobjectdata(@objdata,tmsepropertyeditorsmo,'');
end.