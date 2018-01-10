{ MSEgui Copyright (c) 2015-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseassistiveclient;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}
interface
uses
 msestrings,mseglob,mseinterfaces,msetypes,mseificompglob;
type
 assistiveflagty = (asf_embedded,asf_container,asf_grid,asf_gridcell,
                    asf_datetime,asf_menu,asf_message,asf_popup,
                    asf_textedit,asf_graphicedit,asf_readonly,
                    asf_inplaceedit,asf_button,asf_db,
                    asf_focused,asf_hasdropdown);
 assistiveflagsty = set of assistiveflagty;
 
 iassistiveclient = interface(inullinterface)[miid_iassistiveclient]
  function getinstance: tobject;
  function getassistivewidget: tobject; //twidget, can be nil
  function getassistivename(): msestring;
  function getassistivecaption(): msestring;
  function getassistivetext(): msestring;
  function getassistivecaretindex(): int32; //-1 -> none
  function getassistivehint(): msestring;
  function getassistiveflags(): assistiveflagsty;
 {$ifdef mse_with_ifi}
  function getifidatalinkintf(): iifidatalink; //can be nil
 {$endif}
 end;

 assistivegridinfoty = record
  colmin: int32;
  colmax: int32;
  rowmin: int32;
  rowmax: int32;
 end;
 
 iassistiveclientgrid = interface(iassistiveclient)[miid_iassistiveclientgrid]
  function getassistivecellcaption(const acell: gridcoordty): msestring;
  function getassistivecelltext(const acell: gridcoordty): msestring;
  function getassistivefocusedcell(): gridcoordty;
  function getassistivegridinfo(): assistivegridinfoty;
 end;

 iassistiveclientedit = interface(iassistiveclient)[miid_iassistiveclientedit]
 end;

 iassistiveclientdata = interface(iassistiveclient)[miid_iassistiveclientdata]
 end;
 
 iassistiveclientmenu = interface(iassistiveclient)[miid_iassistiveclientmenu]
  function getassistiveselfcaption(): msestring;
  function getassistiveselfname(): msestring;
  function getassistiveselfhint(): msestring;
 end;

implementation
end.
