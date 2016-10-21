{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepython;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseprocess,mclasses,msearrayprops,msemacros,mseclasses,msestrings;

const
 defaultpythonprocoptions = defaultprocessoptions + [pro_input];
type
 tpythonstringlist = class(tmacrostringlist)
 end;
 
 tpythonstringlistitem = class(townedpersistent)
  private
   fname: msestring;
   fscript: tpythonstringlist;
   procedure setscript(const avalue: tpythonstringlist);
  protected
  public
   constructor create(aowner: tobject); override;
   destructor destroy; override;
   procedure assign(source: tpersistent); override;
   function execute(const atimeoutus: integer = -1): int32; //-1 -> infinite
                     //returns exitcode, -1 for timeout
  published
   property name: msestring read fname write fname;
   property script: tpythonstringlist read fscript write setscript;
 end;
 
 tpythonscript = class;
 
 tpythonscripts = class(townedpersistentarrayprop)
  private
   function getitems(const aindex: integer): tpythonstringlistitem;
   procedure setitems(const aindex: integer; 
                                  const avalue: tpythonstringlistitem);
  protected
  public
   constructor create(const aowner: tpythonscript); reintroduce;
   property items[const aindex: integer]: tpythonstringlistitem read getitems 
                     write setitems; default;
   function itembyname(const aname: msestring): tpythonstringlistitem;
   class function getitemclasstype: persistentclassty; override;
               //used in dumpunitgroups
  published
 end;
 
 tpythonscript = class(tcustommseprocess)
  private
   fscripts: tpythonscripts;
   procedure setscripts(const avalue: tpythonscripts);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
  published
   property scripts: tpythonscripts read fscripts write setscripts;
   property filename;
   property parameter;
   property workingdirectory;
   property params;
   property envvars;
//   property active;
   property options default defaultpythonprocoptions;
   property pipewaitus;
   property statfile;
   property statvarname;
   property statpriority;
   property input;
   property output;
   property erroroutput;
   property onprocfinished;
   property oncheckabort;
 end;
 
implementation
uses
 sysutils;
 
{ tpythonscript }

constructor tpythonscript.create(aowner: tcomponent);
begin
 fscripts:= tpythonscripts.create(self);
 inherited;
 filename:= 'python';
 options:= defaultpythonprocoptions;
end;

destructor tpythonscript.destroy();
begin
 inherited;
 fscripts.free();
end;

procedure tpythonscript.setscripts(const avalue: tpythonscripts);
begin
 fscripts.assign(avalue);
end;

{ tpythonstringlistitem }

constructor tpythonstringlistitem.create(aowner: tobject);
begin
 fscript:= tpythonstringlist.create();
 inherited;
end;

destructor tpythonstringlistitem.destroy;
begin
 fscript.free;
 inherited;
end;

procedure tpythonstringlistitem.assign(source: tpersistent);
begin
 if source is tpythonstringlistitem then begin
  with tpythonstringlistitem(source) do begin
   self.name:= name;
   self.script:= script;
  end;
 end;
end;

function tpythonstringlistitem.execute(const atimeoutus: integer = -1): int32;
var
// po1,pe: pmsestring;
// bo1: boolean;
 s1: string;
begin
 with tpythonscript(fowner) do begin
 {
  bo1:= false;
  po1:= params.datapo;
  pe:= po1 + params.count;
  while po1 < pe do begin
   if po1^ = '-' then begin
    bo1:= true;
    break;
   end;
   inc(po1);
  end;
  if not bo1 then begin
   params.add('-');
  end;
  }
  params.add('-c');
  params.add(fscript.text);
  try
   active:= true;
  finally
//   if not bo1 then begin
   params.count:= params.count - 2;
//   end;
  end;
//  input.pipewriter.write(fscript.text);
//  input.pipewriter.close();
  if atimeoutus < 0 then begin
   result:= waitforprocess();
  end
  else begin
   if atimeoutus > 0 then begin
    if not waitforprocess(atimeoutus) then begin
     result:= -1;
    end
    else begin
     result:= exitcode;
    end;
   end
   else begin
    result:= exitcode;
   end;
  end;
 end;
end;

procedure tpythonstringlistitem.setscript(const avalue: tpythonstringlist);
begin
 fscript.assign(avalue);
end;

{ tpythonscripts }

constructor tpythonscripts.create(const aowner: tpythonscript);
begin
 fowner:= aowner;
 inherited create(aowner,tpythonstringlistitem);
end;

function tpythonscripts.getitems(const aindex: integer): tpythonstringlistitem;
begin
 result:= tpythonstringlistitem(inherited getitems(aindex));
end;

procedure tpythonscripts.setitems(const aindex: integer;
               const avalue: tpythonstringlistitem);
begin
 inherited;
end;

function tpythonscripts.itembyname(
              const aname: msestring): tpythonstringlistitem;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to high(fitems) do begin
  if tpythonstringlistitem(fitems[int1]).name = aname then begin
   result:= tpythonstringlistitem(fitems[int1]);
   break;
  end;
 end;
 if result = nil then begin
  raise exception.create('Script "'+ansistring(aname)+'" not found.');
 end;
end;

class function tpythonscripts.getitemclasstype: persistentclassty;
begin
 result:= tpythonstringlistitem;
end;

end.
