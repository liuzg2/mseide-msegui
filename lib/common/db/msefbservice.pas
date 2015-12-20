unit msefbservice;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$if fpc_fullversion >= 30000}
 {$define fpcv3}
{$endif}
{under construction}
interface
uses
 classes,mclasses,mseclasses,ibase60dyn,msetypes,mdb,msestrings,mibconnection,
 msethread,sysutils;

const
 defaultinfotimeout = 60; //seconds
 
type
 fbserverinfoty = record
  version: card32;
  server_version: msestring;
  _implementation: msestring;
  capabilities: card32;
  user_dbpath: msestring;
  get_env: msestring;
  get_env_lock: msestring;
  get_env_msg: msestring;
 end;

 fbuserinfoty = record
  username: msestring;
  firstname: msestring;
  middlename: msestring;
  lastname: msestring;
  userid: card32;
  groupid: card32;
  admin: card32;
 end;
 pfbuserinfoty = ^fbuserinfoty;
 fbuserinfoarty = array of fbuserinfoty;
 
 tfbservice = class;
 
 efbserviceerror = class(edatabaseerror)
  private
   ferror: integer;
   ferrormessage: msestring;
   fsender: tfbservice;
   fstatus: statusvectorty;
  public
   constructor create(const asender: tfbservice; const amessage: msestring;
                       const aerror: statusvectorty);
   property sender: tfbservice read fsender;
   property error: integer read ferror;
   property errormessage: msestring read ferrormessage;
   property status: statusvectorty read fstatus;
 end;

 fbservicestatety = (fbss_connected,fbss_busy);
 fbservicestatesty = set of fbservicestatety;
 fbserviceoptionty = (fbso_utf8,fbso_utf8message);
 fbserviceoptionsty = set of fbserviceoptionty;

 fbservicetexteventty = procedure (const sender: tfbservice;
                                           const atext: msestring) of object;
 fbserviceerroreventty = procedure (const sender: tfbservice; 
                            var e: exception; var handled: boolean) of object;
 fbserviceendeventty = procedure (const sender: tfbservice;
                                            const aborted: boolean) of object;
 tfbservicemonitor = class(tmutexthread)
  private
   fprocname: string;
  protected
   fowner: tfbservice;
   function execute(thread: tmsethread): integer; override;
  public
   constructor create(const aowner: tfbservice; const procname: string);
 end;
  
 tfbservice = class(tmsecomponent)
  private
   fhostname: ansistring;
   fusername: ansistring;
   fpassword: ansistring;
   fstate: fbservicestatesty;
   fhandle: isc_svc_handle;
   fstatus: statusvectorty; //array [0..19] of isc_status;
   flasterror: statusvectorty;
   flasterrormessage: msestring;
   foptions: fbserviceoptionsty;
   finfotimeout: int32;
   fonasynctext: fbservicetexteventty;
   fmonitor: tfbservicemonitor;
   fonerror: fbserviceerroreventty;
   fonasyncend: fbserviceendeventty;
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
  protected
   function connectionmessage(atext: pchar): msestring;
   procedure loaded(); override;
   procedure connect();
   procedure disconnect();
   procedure readstate(reader: treader); override;
   procedure raiseerror(const e: exception);
   procedure dberror(const msg: string; const comp: tcomponent);
   procedure checkerror(const procname : string;
                            const status : statusvectorty);
   procedure checkerror(const procname : string;
                            const status: integer);
   procedure checkbusy();
   procedure invalidresponse(const procname: string);

   procedure doasyncend(const aborted: boolean);
   
   procedure start(const procname: string; const params: string);
//   function getvalueitem(var buffer: pointer; const id: int32): card32;
//   function getstringitem(var buffer: pointer; const id: int32): string;
   function getinfo(const procname: string; const items: array of byte): string;
//   function getline(const procname: string; 
//                           var res: msestring; out eof: boolean): boolean;
//                               //returns false on timeout
   function getmsestringitem(var buffer: pointer; out res: msestring;
                               const cutspace: boolean = false): boolean;
                                                         //returns eof state
   function getmsestringitem(var buffer: pointer; const id: int32;
                                                var value: msestring): boolean;
   function internalusers(const ausername: string): fbuserinfoarty;
   function gettext(const procname: string;
                 const maxrowcount: integer; var res:  msestringarty): boolean;
                                 //circular buffer
   procedure startmonitor(const procname: string);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   function todbstring(const avalue: msestring): string;
   function tomsestring(const avalue: string): msestring;
   procedure cancel();
   function busy(): boolean;
   function serverinfo(): fbserverinfoty;
   function users(): fbuserinfoarty;
   function user(const ausername: msestring; var ainfo: fbuserinfoty): boolean;
                                                       //false if not found
   function getlog(var res: msestringarty;
                                 const maxrowcount: int32 = 0): boolean;
              //circular buffer, 0 -> unlimited, returns false on timeout
   procedure tracestart(const cfg: msestring; 
                                     const _name: msestring = '');
                        //stop by connected:= false or cancel()
   property lasterror: statusvectorty read flasterror;
   property lasterrormessage: msestring read flasterrormessage;
  published
   property hostname : ansistring read fhostname write fhostname;
   property username : ansistring read fusername write fusername;
   property password : ansistring read fpassword write fpassword;
   property connected: boolean read getconnected 
                                    write setconnected default false;   
   property options: fbserviceoptionsty read foptions write foptions default [];
   property infotimeout: int32 read finfotimeout write finfotimeout 
                       default defaultinfotimeout; //seconds, -1 -> none
   property onasynctext: fbservicetexteventty read fonasynctext 
                                                   write fonasynctext;
   property onasyncend: fbserviceendeventty read fonasyncend 
                                                    write fonasyncend;
   property onerror: fbserviceerroreventty read fonerror write fonerror;
 end;
 
implementation
uses
 msebits,msearrayutils,mseapplication;

function readvalue16(var buffer: pbyte): card16;
begin
 result:= buffer^;
 inc(buffer);
 result:= result + buffer^ shl 8;
 inc(buffer);
end;

function readvalue32(var buffer: pbyte): card16;
begin
 result:= buffer^;
 inc(buffer);
 result:= result + buffer^ shl 8;
 inc(buffer);
 result:= result + buffer^ shl 16;
 inc(buffer);
 result:= result + buffer^ shl 24;
 inc(buffer);
end;

procedure storevalue(var buffer: pbyte; const value: card16);
begin
 buffer^:= value;
 inc(buffer);
 buffer^:= value shr 8;
 inc(buffer); 
end;

procedure storevalue(var buffer: pbyte; const value: card32);
begin
 buffer^:= value;
 inc(buffer);
 buffer^:= value shr 8;
 inc(buffer); 
 buffer^:= value shr 16;
 inc(buffer); 
 buffer^:= value shr 24;
 inc(buffer); 
end;

procedure addshortparam(var params: string; const id: int32;
                                              const value: string); 
                                                //value limited to 255 chars
var
 i1,i2: int32;
 po1: pbyte;
begin
 i1:= length(value);
 if i1 > 255 then begin
  i1:= 255;
 end;
 i2:= length(params);
 setlength(params,i2+2+i1);
 po1:= pointer(params)+i2;
 po1^:= id;
 inc(po1);
 po1^:= i1;
 inc(po1);
 move(pointer(value)^,po1^,i1);
end;

procedure addparam(var params: string; const id: int32;
                                              const value: string); 
                                                //value limited to 65535 chars
var
 i1,i2: int32;
 po1: pbyte;
begin
 i1:= length(value);
 if i1 > 65535 then begin
  i1:= 65553;
 end;
 i2:= length(params);
 setlength(params,i2+3+i1);
 po1:= pointer(params)+i2;
 po1^:= id;
 inc(po1);
 storevalue(po1,card16(i1));
 move(pointer(value)^,po1^,i1);
end;

procedure addparam(var params: string; const id: int32;
                                              const value: card32); 
var
 i2: int32;
 po1: pbyte;
begin
 i2:= length(params);
 setlength(params,i2+1+4);
 po1:= pointer(params)+i2;
 po1^:= id;
 inc(po1);
 storevalue(po1,value);
end;

procedure addparam(var params: string; const id: int32); 
var
 i2: int32;
 po1: pbyte;
begin
 i2:= length(params);
 setlength(params,i2+1+0);
 po1:= pointer(params)+i2;
 po1^:= id;
end;

procedure addtimeout(var params: string; const atimeout: card32);
var
 i2: int32;
 po1: pbyte;
begin
 if int32(atimeout) >= 0 then begin
  i2:= length(params);
  setlength(params,i2+1+4+4+1);
  po1:= pointer(params)+i2;
  po1^:= isc_info_svc_timeout;
  inc(po1);
  storevalue(po1,card16(4)); //len
  storevalue(po1,atimeout);
  inc(po1);
  po1^:= isc_info_end;
 end;
end;

function getvalueitem(var buffer: pointer; const id: int32;
                                                var value: card32): boolean;
begin
 result:= false;
 if pbyte(buffer)^ = id then begin
  inc(buffer);
  value:= readvalue32(buffer);
  result:= true;
 end;
end;

function getstringitem(var buffer: pointer; const id: int32;
                                                var value: string): boolean;
var
 i1: int32;
begin
 result:= false;
 if pbyte(buffer)^ = id then begin
  inc(buffer);
  i1:= readvalue16(buffer);
  setlength(value,i1);
  move((buffer)^,pointer(value)^,i1);
  inc(buffer,i1);
  result:= true;
 end;
end;

{ efbserviceerror }

constructor efbserviceerror.create(const asender: tfbservice;
               const amessage: msestring; const aerror: statusvectorty);
begin
 fstatus:= aerror;
 fsender:= sender;
 ferror:= aerror[1];
 ferrormessage:= amessage;
 inherited create(asender.name+': '+ansistring(amessage));
end;

{ tfbservicemonitor }

constructor tfbservicemonitor.create(const aowner: tfbservice;
                                               const procname: string);
begin
 fowner:= aowner;
 fprocname:= procname;
 inherited create();
end;

function tfbservicemonitor.execute(thread: tmsethread): integer;
var
 params1,items1,buffer1: string;
 po1: pointer;
 i1,i2: int32;
 str1: string;
begin
 params1:= '';
 addtimeout(params1,1); //1 sec min timeout
 setlength(buffer1,4096);
 items1:= char(isc_info_svc_to_eof);
 str1:= '';
 while not terminated and not application.terminated do begin
  fowner.checkerror(fprocname,isc_service_query(@fowner.fstatus,@fowner.fhandle,
    nil,length(params1),pointer(params1),length(items1),pointer(items1),
                                             length(buffer1),pointer(buffer1)));
  if terminated or application.terminated then begin
   break;
  end;
  case pbyte(pointer(buffer1))^ of
   isc_info_svc_to_eof: begin            
    po1:= pointer(buffer1)+1;
    i1:= readvalue16(po1);
    if i1 > 0 then begin
     i2:= length(str1);
     setlength(str1,i1+i2);
     move(po1^,(pointer(str1)+i2)^,i1);
    end
    else begin
     if str1 <> '' then begin
      application.lock();
      try
       if assigned(fowner.fonasynctext) then begin
        fowner.fonasynctext(fowner,fowner.tomsestring(str1));
       end;
      finally
       application.unlock();
      end;
      str1:= '';
     end;
    end;
   end;
   else begin
    exclude(fowner.fstate,fbss_busy);
    fowner.invalidresponse(fprocname);
   end;
  end;
 end;
 exclude(fowner.fstate,fbss_busy);
 result:= 0;
end;

{ tfbservice }

constructor tfbservice.create(aowner: tcomponent);
begin
 fhandle:= FB_API_NULLHANDLE;
 finfotimeout:= defaultinfotimeout;
 inherited;
end;

destructor tfbservice.destroy();
begin
 disconnect();
 fmonitor.free;
 inherited;
end;

procedure tfbservice.cancel();
begin
 freeandnil(fmonitor);
 if connected then begin
  connected:= false;
  connected:= true;
 end;
end;

function tfbservice.busy(): boolean;
begin
 result:= fbss_busy in fstate;
end;

function tfbservice.getconnected: boolean;
begin
 result:= fhandle <> FB_API_NULLHANDLE;
end;

procedure tfbservice.setconnected(const avalue: boolean);
begin
 if csreading in componentstate then begin
  updatebit1(card32(fstate),ord(fbss_connected),avalue);
 end
 else begin
  if avalue then begin
   connect();
  end
  else begin
   disconnect();
  end;
 end;
end;

function tfbservice.connectionmessage(atext: pchar): msestring;
begin
 if fbso_utf8message in foptions then begin
  result:= utf8tostring(atext);
 end
 else begin
  result:= atext;
 end;
end;

procedure tfbservice.loaded();
begin
 inherited;
 if fbss_connected in fstate then begin
  connect();
 end;
end;

procedure tfbservice.connect();
const
 servicename = 'service_mgr';
var
 params1: string;
 str1: string;
begin
 if fhandle = FB_API_NULLHANDLE then begin
  try
   initializeibase60([]);
   if fhostname = '' then begin
    str1:= servicename;
   end
   else begin
    str1:= fhostname + ':' + servicename; //tcp/ip
   end;
   params1:=  char(isc_spb_version)+char(isc_spb_current_version);
   addshortparam(params1,isc_spb_user_name,fusername);
   addshortparam(params1,isc_spb_password,fpassword);
   checkerror('Connect',isc_service_attach(@fstatus,length(str1),pointer(str1),
                                    @fhandle,length(params1),pointer(params1)));
  except
   exclude(fstate,fbss_connected);
   fhandle:= FB_API_NULLHANDLE;
   releaseibase60();
   raise;
  end;
 end;
 include(fstate,fbss_connected);
end;

procedure tfbservice.disconnect();
begin
 freeandnil(fmonitor);
 fstate:= fstate - [fbss_connected,fbss_busy];
 if fhandle <> FB_API_NULLHANDLE then begin
  isc_service_detach(@fstatus,@fhandle);
  fhandle:= FB_API_NULLHANDLE;
  releaseibase60();
 end;
end;

procedure tfbservice.readstate(reader: treader);
begin
 disconnect();
 inherited;
end;

procedure tfbservice.raiseerror(const e: exception);
var
 bo1: boolean;
 e1: exception;
begin
 connected:= false; //cancel possible running task
 e1:= e;
 if canevent(tmethod(fonerror)) then begin
  bo1:= false;
  application.lock();
  try
   fonerror(self,e1,bo1);
  except
   application.unlock();
   e1.free;
   raise;
  end;
  application.unlock();
  if bo1 then begin
   e1.free;
  end
  else begin
   raise e1;
  end;
 end
 else begin
  raise e1;
 end;
end;

procedure tfbservice.dberror(const msg: string; const comp: tcomponent);
begin
 raiseerror(edatabaseerror.create(msg,comp));
end;

procedure tfbservice.checkerror(const procname: string;
               const status: statusvectorty);
var
 buf: array [0..1024] of char;
 p: pointer;
 Msg: msestring;
begin
 if ((Status[0] = 1) and (Status[1] <> 0)) then begin
  p:= @Status;
  msg:= msestring(procname);
//{$warnings off}
  while isc_interprete(Buf, @p) > 0 do begin
   Msg := Msg + lineend +' -' + connectionmessage(Buf);
  end;
  flasterror:= status;
  flasterrormessage:= msg;
  raiseerror(efbserviceerror.create(self,msg,status{,flastsqlcode}));
 end;
end;
//{$warnings on}

procedure tfbservice.checkerror(const procname: string; const status: integer);
begin
 if status <> 0 then begin
  checkerror(procname,fstatus);
 end;
end;

procedure tfbservice.checkbusy();
begin
 if not connected then begin
  dberror('Not connected',self);
 end;
 if busy then begin
  dberror('Busy',self);
 end;
end;

procedure tfbservice.invalidresponse(const procname: string);
begin
 raiseerror(edatabaseerror.create('Invalid '+procname+' response',self));
end;

procedure tfbservice.doasyncend(const aborted: boolean);
begin
 if canevent(tmethod(fonasyncend)) then begin
  application.lock();
  try
   fonasyncend(self,aborted);
  finally
   application.unlock();
  end;
 end;
end;

function tfbservice.todbstring(const avalue: msestring): string;
begin
 if fbso_utf8 in foptions then begin
  result:= stringtoutf8ansi(avalue);
 end
 else begin
  result:= ansistring(avalue);
 end;
end;

function tfbservice.tomsestring(const avalue: string): msestring;
begin
 if fbso_utf8 in foptions then begin
  result:= utf8tostring(avalue);
 end
 else begin
  result:= msestring(avalue);
 end;
end;

procedure tfbservice.start(const procname: string; const params: string);
begin
 checkbusy();
 checkerror(procname,isc_service_start(@fstatus,@fhandle,FB_API_NULLHANDLE,
                                   length(params),pointer(params)));
 include(fstate,fbss_busy);
end;

function tfbservice.getinfo(const procname: string; 
                                         const items: array of byte): string;
var
 params1: string;
begin
 params1:= '';
 addtimeout(params1,finfotimeout);
 setlength(result,1024);
 while true do begin
  checkerror(procname,isc_service_query(@fstatus,@fhandle,nil,length(params1),
      pointer(params1),length(items),@items[0],length(result),pointer(result)));
  if pbyte(pointer(result))^ <> isc_info_truncated then begin
   exclude(fstate,fbss_busy);
   break;
  end;
  setlength(result,2*length(result));
 end;
end;

function tfbservice.getmsestringitem(var buffer: pointer; out res: msestring;
                           const cutspace: boolean = false): boolean;
var
 i1,i2: int32;
begin
 i1:= readvalue16(buffer);
 i2:= i1;
 result:= i1 <= 0;
 if cutspace and not result and (pchar(buffer)[i1-1] = ' ') then begin
  dec(i2);
 end;
 if fbso_utf8 in foptions then begin
  res:= utf8tostring(buffer,i2);
 end
 else begin
  widestringmanager.ansi2unicodemoveproc(buffer,
                                  {$ifdef fpcv3}cp_acp,{$endif}res,i2);
 end;
 inc(buffer,i1);
end;

function tfbservice.getmsestringitem(var buffer: pointer; const id: int32;
               var value: msestring): boolean;
begin
 result:= false;
 if pbyte(buffer)^ = id then begin
  inc(buffer);
  getmsestringitem(buffer,value);
  result:= true;
 end;
end;
{
function tfbservice.getline(const procname: string; 
                           var res: msestring; out eof: boolean): boolean;
var
 params1: string;
 items1: string;
 buffer1: string;
 po1: pointer;
begin
 result:= true;
 eof:= true;
 params1:= '';
 addparam(params1,isc_info_svc_timeout,1); //minimal timeout (1sec)
 setlength(buffer1,1024); //max line length
 items1:= char(isc_info_svc_line);
// addparam(items1,isc_info_svc_timeout,1); //minimal timeout (1sec)
 checkerror(procname,isc_service_query(@fstatus,@fhandle,nil,length(params1),
                   pointer(params1),length(items1),pointer(items1),
                                            length(buffer1),pointer(buffer1)));
 case pbyte(pointer(buffer1))^ of
  isc_info_svc_line: begin            //timeout?
   po1:= pointer(buffer1)+1;
   eof:= getmsestringitem(po1,res,true);
  end;
  else begin
   invalidresponse(procname);
  end;
 end;
end;
}
function tfbservice.serverinfo(): fbserverinfoty;
var
 buffer: string;
 po1: pbyte;
begin
 checkbusy();
 finalize(result);
 fillchar(result,sizeof(result),0);
 buffer:= getinfo('serverinfo',[isc_info_svc_version,
            isc_info_svc_server_version,isc_info_svc_implementation,
            isc_info_svc_capabilities,isc_info_svc_user_dbpath,
            isc_info_svc_get_env,isc_info_svc_get_env_lock,
            isc_info_svc_get_env_msg]);
 po1:= pointer(buffer);
 with result do begin
  while (po1^ <> isc_info_end) and (po1^ <> 0) do begin
   if not (getvalueitem(po1,isc_info_svc_version,version) or
           getmsestringitem(po1,isc_info_svc_server_version,server_version) or
           getmsestringitem(po1,isc_info_svc_implementation,_implementation) or
           getvalueitem(po1,isc_info_svc_capabilities,capabilities) or
           getmsestringitem(po1,isc_info_svc_user_dbpath,user_dbpath) or
           getmsestringitem(po1,isc_info_svc_get_env,get_env) or
           getmsestringitem(po1,isc_info_svc_get_env_lock,get_env_lock) or
           getmsestringitem(po1,isc_info_svc_get_env_msg,get_env_msg)) then begin
    invalidresponse('serverinfo');
   end;
  end;
 end;
end;

function tfbservice.internalusers(const ausername: string): fbuserinfoarty;
var
 params1,buffer1: string;
 po1: pbyte;
 count: int32;
 po2: pfbuserinfoty;
begin
 checkbusy();
 params1:= char(isc_action_svc_display_user_adm);
 if ausername <> '' then begin
  addparam(params1,isc_spb_sec_username,ausername);
 end;
 start('users',params1);
 result:= nil;
 count:= 0;
 buffer1:= getinfo('users',[isc_info_svc_get_users]);
 po1:= pointer(buffer1);
 if po1^ <> isc_info_svc_get_users then begin
  invalidresponse('users');
 end;
 inc(po1,3); //additional bytes 50 0 ???
 while (po1^ <> isc_info_flag_end) and (po1^ <> isc_info_end) and 
                                                        (po1^ <> 0) do begin
  if po1^ = isc_spb_sec_username then begin //must be first field
   additem(result,typeinfo(result),count);
   po2:= @result[count-1];
   getmsestringitem(po1,isc_spb_sec_username,po2^.username)   
  end
  else begin
   if result = nil then begin
    invalidresponse('users');
   end;
  end;
  with po2^ do begin
   while (po1^ <> isc_spb_sec_username) and (po1^ <> isc_info_flag_end) and 
                                 (po1^ <> isc_info_end) and (po1^ <> 0) do begin
    if not (getmsestringitem(po1,isc_spb_sec_firstname,firstname) or
            getmsestringitem(po1,isc_spb_sec_middlename,middlename) or
            getmsestringitem(po1,isc_spb_sec_lastname,lastname) or
            getvalueitem(po1,isc_spb_sec_userid,userid) or
            getvalueitem(po1,isc_spb_sec_groupid,groupid) or
            getvalueitem(po1,isc_spb_sec_admin,admin)) then begin
     invalidresponse('users');
    end;
   end;
  end;
 end;
 setlength(result,count);
end;

function tfbservice.users(): fbuserinfoarty;
begin
 result:= internalusers('');
end;

function tfbservice.user(const ausername: msestring;
                            var ainfo: fbuserinfoty): boolean;
var
 ar1: fbuserinfoarty;
begin
 ar1:= internalusers(todbstring(ausername));
 result:= ar1 <> nil;
 if result then begin
  ainfo:= ar1[0];
 end;
end;
{
function tfbservice.gettext(const procname: string;
            const maxrowcount: integer; var res:  msestringarty): boolean;
var
 mstr1: msestring;
 eof: boolean;
begin
 result:= false;
 res:= nil;
 while true do begin
  while not getline(procname,mstr1,eof) do begin
   //timeoutcheck
  end;
  if eof then begin 
   result:= true;
   break;
  end;
  additem(res,mstr1);   
 end;
end;
}
function tfbservice.gettext(const procname: string;
            const maxrowcount: integer; var res:  msestringarty): boolean;

var
 circindex: int32;
 
 procedure add(const atext: pchar; const len: int32);
 var
  mstr1: msestring;
 begin
  if fbso_utf8 in foptions then begin
   mstr1:= utf8tostring(atext,len);
  end
  else begin
   widestringmanager.ansi2unicodemoveproc(atext,
                                   {$ifdef fpcv3}cp_acp,{$endif}mstr1,len);
  end;
  if (maxrowcount > 0) and (length(res) >= maxrowcount) then begin
   res[circindex]:= mstr1;
   inc(circindex);
   if circindex >= maxrowcount then begin
    circindex:= 0;
   end;
  end
  else begin
   additem(res,mstr1);
  end;
 end;
 
var
 params1,items1,buffer1: string;
 po1: pointer;
 pa,pb,pc,pe: pchar;
 i1: int32;
 remainder: string;
 ar1: msestringarty;
begin
 result:= false;
 res:= nil;
 params1:= '';
 addtimeout(params1,finfotimeout);
 setlength(buffer1,4096);
 items1:= char(isc_info_svc_to_eof);
 remainder:= '';
 circindex:= 0;
 while true do begin
  checkerror(procname,isc_service_query(@fstatus,@fhandle,nil,length(params1),
                    pointer(params1),length(items1),pointer(items1),
                                             length(buffer1),pointer(buffer1)));
  case pbyte(pointer(buffer1))^ of
   isc_info_svc_to_eof: begin         
    po1:= pointer(buffer1)+1;
    i1:= readvalue16(po1);
    if i1 <= 0 then begin
     break; //eof or timeout
    end;
    if i1 > length(buffer1)-1-2 then begin
     invalidresponse(procname);
    end;
    pa:= po1;
    pb:= pa;
    pe:= pa + i1;
    while (pb < pe) do begin
     if pb^ = c_linefeed then begin
      pc:= pb;
      if (pc > pa) and ((pc-1)^ = c_return) then begin
       dec(pc);
      end;
      if remainder <> '' then begin
       remainder:= remainder+stringsegment(pa,pb);
       add(pointer(remainder),length(remainder));
       remainder:= '';
      end
      else begin
       add(pa,pc-pa);
      end;
      pa:= pb+1;
     end;
     inc(pb);
    end;
    remainder:= remainder+stringsegment(pa,pe);
   end;
   else begin
    invalidresponse(procname);
   end;
  end;
 end;
 if remainder <> '' then begin
  add(pointer(remainder),length(remainder));
 end;
 if circindex > 0 then begin
  ar1:= copy(res,circindex,maxrowcount-circindex);
  stackarray(copy(res,0,circindex),ar1);
  res:= ar1;
 end;
 exclude(fstate,fbss_busy);
end;

procedure tfbservice.startmonitor(const procname: string);
begin
 freeandnil(fmonitor);
 fmonitor:= tfbservicemonitor.create(self,procname);
end;

function tfbservice.getlog(var res: msestringarty;
                               const maxrowcount: int32 = 0): boolean ;
var
 params1: string;
begin
 checkbusy();
 params1:= char(isc_action_svc_get_fb_log);
 start('getlog',params1);
 result:= gettext('getlog',maxrowcount,res);
end;

procedure tfbservice.tracestart(const cfg: msestring;
                                           const _name: msestring = '');
var
 params1: string;
begin
 checkbusy();
 params1:= char(isc_action_svc_trace_start);
 addparam(params1,isc_spb_trc_cfg,todbstring(cfg));
 if _name <> '' then begin
  addparam(params1,isc_spb_trc_name,todbstring(_name));
 end;
 start('tracestart',params1);
 startmonitor('tracestart');
end;

end.
