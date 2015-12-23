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
  groupname: msestring;
  rolename: msestring;
  userid: card32;
  groupid: card32;
  admin: card32;
  password: ansistring;
 end;
 pfbuserinfoty = ^fbuserinfoty;
 fbuserinfoarty = array of fbuserinfoty;

 fbuseritemty = (fbu_username,fbu_firstname,fbu_middlename,fbu_lastname,
                 fbu_groupname,fbu_rolename,fbu_userid,fbu_groupid,fbu_admin,
                 fbu_password);
 fbuseritemsty = set of fbuseritemty;

const
 allfbuseritems = [fbu_username,fbu_firstname,fbu_middlename,fbu_lastname,
                 fbu_groupname,fbu_rolename,fbu_userid,fbu_groupid,fbu_admin,
                 fbu_password];

type
 accessmodety = (amo_readonly,amo_readwrite);
 writemodety = (wmo_async,wmo_sync);
 runmodety = (rmo_normal,rmo_multi,rmo_single,rmo_full);
 reservespacety = (rsp_full,rsp_res);
 propertyoptionty = (pro_activate,pro_dbonline);
 propertyoptionsty = set of propertyoptionty;
 
 fbpropertyinfoty = record
  pagebuffers: card32;
  sweepinterval: card32;
  shutdowndb: card32;
  denynewattachments: card32;
  denynewtransactions: card32;
  reservespace: reservespacety;
  writemode: writemodety;
  accessmode: accessmodety;
  setsqldialect: card32;
  options: propertyoptionsty;
  forceshutdown: card32;
  attachmentsshutdown: card32;
  transactionsshutdown: card32;
  shutdownmode: runmodety;
  onlinemode: runmodety;
 end;
 
 fbpropertyitemty = (fbp_pagebuffers,fbp_sweepinterval,fbp_shutdowndb,
                     fbp_denynewattachments,fbp_denynewtransactions,
                     fbp_reservespace,fbp_writemode,fbp_accessmode,
                     fbp_setsqldialect,fbp_options,fbp_forceshutdown,
                     fbp_attachmentsshutdown,fbp_transactionsshutdown,
                     fbp_shutdownmode,fbp_onlinemode);
 fbpropertyitemsty = set of fbpropertyitemty;
 
const
 allfbpropertyitems = [fbp_pagebuffers,fbp_sweepinterval,fbp_shutdowndb,
                     fbp_denynewattachments,fbp_denynewtransactions,
                     fbp_reservespace,fbp_writemode,fbp_accessmode,
                     fbp_setsqldialect,fbp_options,fbp_forceshutdown,
                     fbp_attachmentsshutdown,fbp_transactionsshutdown,
                     fbp_shutdownmode,fbp_onlinemode];

type
 dbstatoptionty = (dbsto_datapages,dbsto_dblog,dbsto_hdrpages,
                   dbsto_idxpages,dbsto_sysrelations,dbsto_recordversions,
                   dbsto_table,dbsto_nocreation);
 dbstatoptionsty = set of dbstatoptionty;

 backupoptionty = (bao_ignorechecksums,bao_ignorelimbo,bao_metadataonly,
           bao_no_garbagecollect,bao_olddescriptions,bao_nontransportable,
           bao_convert,bao_expand,bao_notriggers {=$8000});
 backupoptionsty = set of backupoptionty;

 restoreoptionty = (reo_deactivateidx,reo_no_shadow,reo_no_validity,
                    reo_one_at_a_time,reo_replace,reo_create,reo_use_all_space);
 restoreoptionsty = set of restoreoptionty;

 repairoptionty = (rpo_validate_db,rpo_sweep_db,rpo_mend_db,limbo_trans,
                   rpo_check_db,rpo_ignore_checksum,rpo_kill_shadows,rpo_full);
 repairoptionsty = set of repairoptionty;

 nbakoptionty = (nbo_notriggers);
 nbakoptionsty = set of nbakoptionty;
  
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
 tfbservicemonitor = class(tmsethread)
  private
   fprocname: string;
  protected
   fowner: tfbservice;
   function execute(thread: tmsethread): integer; override;
  public
   constructor create(const aowner: tfbservice; const procname: string);
   destructor destroy(); override;
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
   procedure closeconn();
   procedure disconnect();
   procedure readstate(reader: treader); override;
   procedure raiseerror(const e: exception; const dberr: boolean);
   procedure dberror(const msg: string; const comp: tcomponent;
                                                         const dberr: boolean);
   procedure checkerror(const procname : string;
                            const status : statusvectorty);
   procedure checkerror(const procname : string;
                            const status: integer);
   procedure checkbusy();
   procedure invalidresponse(const procname: string);

   procedure start(const procname: string; const params: string);
   function getinfo(const procname: string; const items: array of byte;
                                                  const async: boolean): string;
   procedure runcommand(const procname: string; const params: string);
   function getmsestringitem(var buffer: pointer; out res: msestring;
                               const cutspace: boolean = false): boolean;
                                                         //returns eof state
   function getmsestringitem(var buffer: pointer; const id: int32;
                                                var value: msestring): boolean;
   procedure addmseparam(var params: string; const id: int32;
                                              const value: msestring); 
                                                //value limited to 65535 chars
   function internalusers(const ausername: string): fbuserinfoarty;
   procedure gettext(const procname: string; const params: string;
                 var res:  msestringarty; const maxrowcount: integer);
                                 //ring buffer
   procedure startmonitor(const procname: string; const aparams: string);
   function serviceisrunning: boolean;
   procedure tagaction(const aprocname: string; const aaction: int32; 
                              var res: msestringarty;
                              const maxrowcount: int32);
   procedure tagaction(const aprocname: string; const aaction: int32);
   procedure traceaction(const aprocname: string; const aaction: int32;
                         const aid: card32; var res: msestringarty;
                         const maxrowcount: int32);
   procedure adduserparams(var params1: string; 
                      const ainfo: fbuserinfoty; const aitems: fbuseritemsty);
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
   procedure adduser(const ainfo: fbuserinfoty; const items: fbuseritemsty);
   procedure modifyuser(const ainfo: fbuserinfoty; const items: fbuseritemsty);
                                                     //fbu_username must be set
   procedure deleteuser(const ausername: msestring; 
                                           const arolename: msestring = '');
   procedure getlog(var res: msestringarty; const maxrowcount: int32 = 0);
                             //ring buffer, 0 -> unlimited
   procedure tracestart(const cfg: msestring; const _name: msestring = '');
                //async, stop it by connected:= false or call of cancel()
   procedure tracelist(var res: msestringarty; const maxrowcount: int32 = 0);
                            //ring buffer, 0 -> unlimited
   procedure tracestop(const aid: card32; var res: msestringarty;
                         const maxrowcount: int32 = 0);
   procedure tracesuspend(const aid: card32; var res: msestringarty;
                         const maxrowcount: int32 = 0);
   procedure traceresume(const aid: card32; var res: msestringarty;
                         const maxrowcount: int32 = 0);
   procedure setmapping();
   procedure dropmapping();

   procedure dbstats(const adbname: msestring;
               const aoptions: dbstatoptionsty; const acommandline: msestring; 
               var res: msestringarty; const maxrowcount: int32 = 0);
   procedure properties(const adbname: msestring;
                const ainfo: fbpropertyinfoty; const aitems: fbpropertyitemsty;
                var res:  msestringarty; const maxrowcount: integer);
                         //ring buffer, 0 -> unlimited                
                    
   procedure validatestart(const dbname: msestring;
             const tabincl: msestring = ''; const tabexcl: msestring = '';
             const idxincl: msestring = ''; const idxexcl: msestring = '';
                                                 const locktimeout: card32 = 0);
   procedure backupstart(const dbname: msestring;
          const backupfiles: array of msestring; const lengths: array of card32;
                                             //bytes, none for last file
          const verbose: boolean = false; const stat: string = '';
             //stat for FB 2.5.5 only, 1..4 chars, valid chars = T|D|R|W
          const aoptions: backupoptionsty = []; const factor: card32 = 0);
   procedure restorestart(const backupfiles: array of msestring;
           const dbfiles: array of msestring; const lengths: array of card32;
                                              //pages, none for last dbfile
           const verbose: boolean = false; const stat: string = '';
             //stat for FB 2.5.5 only, 1..4 chars, valid chars = T|D|R|W
           const aoptions: restoreoptionsty = [];
           const accessmode: accessmodety = amo_readwrite;
           const buffers: card32 = 0; const pagesize: card32 = 0;
           const fixfssdata: string = ''; const fixfssmetadata: string = '');
                              //CHARACTER SET                 CHARACTER SET   
   procedure nbakstart(const dbname: msestring; const _file: msestring;
                        const level: card32; const options: nbakoptionsty;
                        const direct: string = '');
                                  //'on or 'off'
   procedure repairstart(const adbname: msestring;
                                       const aoptions: repairoptionsty);

   property lasterror: statusvectorty read flasterror;
   property lasterrormessage: msestring read flasterrormessage;
  published
   property hostname : ansistring read fhostname write fhostname;
   property username : ansistring read fusername write fusername;
   property password : ansistring read fpassword write fpassword;
   property connected: boolean read getconnected 
                                    write setconnected default false;
                                 //connected will be rest by a server error
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
 msebits,msearrayutils,mseapplication,msesysintf;
const
 restoreconsts: array[restoreoptionty] of card32 = (isc_spb_res_deactivate_idx,
     isc_spb_res_no_shadow,isc_spb_res_no_validity,isc_spb_res_one_at_a_time,
     isc_spb_res_replace,isc_spb_res_create,isc_spb_res_use_all_space);
 accessmodeconsts: array[accessmodety] of card32 = (isc_spb_prp_am_readonly,
                                                     isc_spb_prp_am_readwrite);
 writemodeconsts: array[writemodety] of card32 = (isc_spb_prp_wm_async,
                                                   isc_spb_prp_wm_sync);
 propertyconsts: array[propertyoptionty] of card32 = (isc_spb_prp_activate,
                                                       isc_spb_prp_db_online);
 reservespaceconsts: array[reservespacety] of card32 = (isc_spb_prp_res_use_full,
                                                       isc_spb_prp_res);
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

procedure addparam(var params: string; const id: int32;
                                              const value: card8); 
var
 i2: int32;
 po1: pbyte;
begin
 i2:= length(params);
 setlength(params,i2+1+1);
 po1:= pointer(params)+i2;
 po1^:= id;
 inc(po1);
 po1^:= value;
 inc(po1);
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

destructor tfbservicemonitor.destroy();
begin
 terminate();
 application.waitforthread(self);
 inherited;
end;

function tfbservicemonitor.execute(thread: tmsethread): integer;

 procedure cancel();
 begin
  if fowner.connected then begin
   fowner.closeconn();
   fowner.connected:= true;
  end;
 end; //cancel

var
 params1,items1,buffer1: string;
 po1: pointer;
 i1,i2: int32;
 str1: string;
 ok: boolean;
const
 buffersize = 4096;
begin
 ok:= false;
 params1:= '';
 addtimeout(params1,1); //1 sec min timeout
 setlength(buffer1,buffersize);
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
    end;
    if i1 < buffersize-10 then begin 
                 //not truncated, firebird seems not to fill buffer completely
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
     end
     else begin
      application.lock();
      try
       if not fowner.serviceisrunning() then begin
        ok:= true;
        cancel();
        if assigned(fowner.fonasyncend) then begin
         fowner.fonasyncend(fowner,false);
        end;
        break;
       end;
      finally
       application.unlock();
      end;
     end;
    end;
   end;
   else begin
    fowner.invalidresponse(fprocname);
   end;
  end;
 end;
 if not ok then begin 
  application.lock();
  try
   cancel();
   if assigned(fowner.fonasyncend) then begin
     fowner.fonasyncend(fowner,true);
   end;
  finally
   application.unlock();
  end;
 end;
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

procedure tfbservice.closeconn();
begin
 fstate:= fstate - [fbss_connected,fbss_busy];
 if fhandle <> FB_API_NULLHANDLE then begin
  isc_service_detach(@fstatus,@fhandle);
  fhandle:= FB_API_NULLHANDLE;
  releaseibase60();
 end;
end;

procedure tfbservice.disconnect();
begin
 if (fmonitor <> nil) and 
              (sys_getcurrentthread() <> fmonitor.id) then begin
  freeandnil(fmonitor);
 end;
 closeconn();
end;

procedure tfbservice.readstate(reader: treader);
begin
 disconnect();
 inherited;
end;

procedure tfbservice.raiseerror(const e: exception; const dberr: boolean);
var
 bo1: boolean;
 e1: exception;
begin
 application.lock();
 try
  if dberr then begin
   connected:= false; //cancel possible running task
  end;
  e1:= e;
  if canevent(tmethod(fonerror)) then begin
   bo1:= false;
   try
    fonerror(self,e1,bo1);
   except
    e1.free;
    raise;
   end;
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
 finally
  application.unlock();
 end;
end;

procedure tfbservice.dberror(const msg: string; const comp: tcomponent;
                                                         const dberr: boolean);
begin
 raiseerror(edatabaseerror.create(msg,comp),dberr);
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
  raiseerror(efbserviceerror.create(self,msg,status),true);
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
  dberror('Not connected',self,false);
 end;
 if busy then begin
  dberror('Busy',self,false);
 end;
end;

procedure tfbservice.invalidresponse(const procname: string);
begin
 raiseerror(edatabaseerror.create('Invalid '+procname+' response',self),true);
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
 checkerror(procname,isc_service_start(@fstatus,@fhandle,nil,
                                   length(params),pointer(params)));
 include(fstate,fbss_busy);
end;

function tfbservice.getinfo(const procname: string; 
                   const items: array of byte; const async: boolean): string;
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
   if not async then begin
    exclude(fstate,fbss_busy);
   end;
   break;
  end;
  setlength(result,2*length(result));
 end;
end;

procedure tfbservice.runcommand(const procname: string;
               const params: string);
var
 ar1: msestringarty;
begin
 gettext(procname,params,ar1,1);
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

procedure tfbservice.addmseparam(var params: string; const id: int32;
               const value: msestring);
begin
 addparam(params,id,todbstring(value));
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
            isc_info_svc_get_env_msg],false);
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
 buffer1:= getinfo('users',[isc_info_svc_get_users],false);
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
            getmsestringitem(po1,isc_spb_sec_groupname,groupname) or
            getmsestringitem(po1,isc_spb_sql_role_name,rolename) or
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

procedure tfbservice.adduserparams(var params1: string; 
                      const ainfo: fbuserinfoty; const aitems: fbuseritemsty);
begin
 with ainfo do begin
  if fbu_username in aitems then begin
   addmseparam(params1,isc_spb_sec_username,username);
  end;
  if fbu_firstname in aitems then begin
   addmseparam(params1,isc_spb_sec_firstname,firstname);
  end;
  if fbu_middlename in aitems then begin
   addmseparam(params1,isc_spb_sec_middlename,middlename);
  end;
  if fbu_lastname in aitems then begin
   addmseparam(params1,isc_spb_sec_lastname,lastname);
  end;
  if fbu_groupname in aitems then begin
   addmseparam(params1,isc_spb_sec_groupname,groupname);
  end;
  if fbu_rolename in aitems then begin
   addmseparam(params1,isc_spb_sql_role_name,rolename);
  end;
  if fbu_userid in aitems then begin
   addparam(params1,isc_spb_sec_userid,userid);
  end;
  if fbu_groupid in aitems then begin
   addparam(params1,isc_spb_sec_groupid,groupid);
  end;
  if fbu_admin in aitems then begin
   addparam(params1,isc_spb_sec_admin,admin);
  end;
  if fbu_password in aitems then begin
   addparam(params1,isc_spb_sec_password,password);
  end;
 end;
end;

procedure tfbservice.adduser(const ainfo: fbuserinfoty;
                                         const items: fbuseritemsty);
var
 params1: string;
begin
 params1:= char(isc_action_svc_add_user);
 adduserparams(params1,ainfo,items);
 runcommand('adduser',params1);
end;

procedure tfbservice.modifyuser(const ainfo: fbuserinfoty;
               const items: fbuseritemsty);
var
 params1: string;
begin
 params1:= char(isc_action_svc_modify_user);
 adduserparams(params1,ainfo,items);
 runcommand('modifyuser',params1);
end;

procedure tfbservice.deleteuser(const ausername: msestring;
                                        const arolename: msestring = '');
var
 params1: string;
begin
 params1:= char(isc_action_svc_delete_user);
 addmseparam(params1,isc_spb_sec_username,ausername);
 if arolename <> '' then begin
  addmseparam(params1,isc_spb_sql_role_name,arolename);
 end;
 runcommand('deleteuser',params1);
end;

procedure tfbservice.gettext(const procname: string; const params: string;
            var res:  msestringarty; const maxrowcount: integer);

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
 checkbusy();
 start(procname,params);
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
     if serviceisrunning() then begin
      dberror(procname+': Timeout',self,true);
     end;
     break; //eof
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

procedure tfbservice.startmonitor(const procname: string; const aparams: string);
begin
 checkbusy();
 start(procname,aparams);
 freeandnil(fmonitor);
 fmonitor:= tfbservicemonitor.create(self,procname);
end;

function tfbservice.serviceisrunning(): boolean;
var
 buffer1: string;
 po1: pointer;
 ca1: card32;
begin
 result:= false;
 if busy then begin
  buffer1:= getinfo('serviceisrunning',[isc_info_svc_running],true);
  po1:= pointer(buffer1);
  if getvalueitem(po1,isc_info_svc_running,ca1) then begin
   result:= ca1 <> 0;
  end;
 end; 
end;

procedure tfbservice.getlog(var res: msestringarty;
                               const maxrowcount: int32 = 0);
begin
 tagaction('getlog',isc_action_svc_get_fb_log,res,maxrowcount);
end;

procedure tfbservice.tracestart(const cfg: msestring;
                                           const _name: msestring = '');
var
 params1: string;
begin
 params1:= char(isc_action_svc_trace_start);
 addmseparam(params1,isc_spb_trc_cfg,cfg);
 if _name <> '' then begin
  addmseparam(params1,isc_spb_trc_name,_name);
 end;
 startmonitor('tracestart',params1);
end;

procedure tfbservice.tagaction(const aprocname: string; const aaction: int32;
                              var res: msestringarty;
                              const maxrowcount: int32);
begin
 gettext(aprocname,char(aaction),res,maxrowcount);
end;

procedure tfbservice.tagaction(const aprocname: string; const aaction: int32);
var
 ar1: msestringarty;
begin
 tagaction(aprocname,aaction,ar1,1);
end;

procedure tfbservice.tracelist(var res: msestringarty;
                              const maxrowcount: int32 = 0);
begin
 tagaction('tracelist',isc_action_svc_trace_list,res,maxrowcount);
end;

procedure tfbservice.traceaction(const aprocname: string; const aaction: int32;
               const aid: card32; var res: msestringarty;
               const maxrowcount: int32);
var
 params1: string;
begin
 params1:= char(aaction);
 addparam(params1,isc_spb_trc_id,aid);
 gettext(aprocname,params1,res,maxrowcount);
end;

procedure tfbservice.tracestop(const aid: card32; var res: msestringarty;
                              const maxrowcount: int32 = 0);
begin
 traceaction('tracestop',isc_action_svc_trace_stop,aid,res,maxrowcount);
end;

procedure tfbservice.tracesuspend(const aid: card32; var res: msestringarty;
               const maxrowcount: int32 = 0);
begin
 traceaction('tracesuspend',isc_action_svc_trace_suspend,aid,res,maxrowcount);
end;

procedure tfbservice.traceresume(const aid: card32; var res: msestringarty;
                                                 const maxrowcount: int32 = 0);
begin
 traceaction('traceresume',isc_action_svc_trace_resume,aid,res,maxrowcount);
end;

procedure tfbservice.setmapping();
begin
 tagaction('setmapping',isc_action_svc_set_mapping);
end;

procedure tfbservice.dropmapping();
begin
 tagaction('dropmapping',isc_action_svc_drop_mapping);
end;

procedure tfbservice.dbstats(const adbname: msestring;
               const aoptions: dbstatoptionsty; const acommandline: msestring; 
               var res: msestringarty; const maxrowcount: int32 = 0);
var
 params1: string;
begin
 params1:= char(isc_action_svc_db_stats);
 addmseparam(params1,isc_spb_dbname,adbname);
 addparam(params1,isc_spb_options,card32(aoptions));
 if acommandline <> '' then begin
  addmseparam(params1,isc_spb_command_line,acommandline);
 end;
 gettext('dbstats',params1,res,maxrowcount);
end;

procedure tfbservice.properties(const adbname: msestring;
               const ainfo: fbpropertyinfoty; const aitems: fbpropertyitemsty;
               var res:  msestringarty; const maxrowcount: integer);
var
 params1: string;
 ca1: card32;
 opt1: propertyoptionty;
begin
 params1:= char(isc_action_svc_properties);
 addmseparam(params1,isc_spb_dbname,adbname);
 with ainfo do begin
  if fbp_pagebuffers in aitems then begin
   addparam(params1,isc_spb_prp_page_buffers,pagebuffers);
  end;
  if fbp_sweepinterval in aitems then begin
   addparam(params1,isc_spb_prp_sweep_interval,sweepinterval);
  end;
  if fbp_shutdowndb in aitems then begin
   addparam(params1,isc_spb_prp_shutdown_db,shutdowndb);
  end;
  if fbp_denynewattachments in aitems then begin
   addparam(params1,isc_spb_prp_deny_new_attachments,denynewattachments);
  end;
  if fbp_denynewtransactions in aitems then begin
   addparam(params1,isc_spb_prp_deny_new_transactions,denynewtransactions);
  end;
  if fbp_reservespace in aitems then begin
   addparam(params1,isc_spb_prp_reserve_space,
                             card8(reservespaceconsts[reservespace]));
  end;
  if fbp_writemode in aitems then begin
   addparam(params1,isc_spb_prp_write_mode,
                             card8(writemodeconsts[writemode]));
  end;
  if fbp_accessmode in aitems then begin
   addparam(params1,isc_spb_prp_access_mode,
                             card8(accessmodeconsts[accessmode]));
  end;
  if fbp_setsqldialect in aitems then begin
   addparam(params1,isc_spb_prp_set_sql_dialect,setsqldialect);
  end;
  if fbp_options in aitems then begin
   ca1:= 0;
   for opt1:= low(opt1) to high(opt1) do begin
    ca1:= ca1 or propertyconsts[opt1];
   end;
   addparam(params1,isc_spb_options,ca1);
  end;
  if fbp_forceshutdown in aitems then begin
   addparam(params1,isc_spb_prp_force_shutdown,forceshutdown);
  end;
  if fbp_attachmentsshutdown in aitems then begin
   addparam(params1,isc_spb_prp_attachments_shutdown,attachmentsshutdown);
  end;
  if fbp_transactionsshutdown in aitems then begin
   addparam(params1,isc_spb_prp_transactions_shutdown,transactionsshutdown);
  end;
  if fbp_shutdownmode in aitems then begin
   addparam(params1,isc_spb_prp_shutdown_mode,card8(shutdownmode));
  end;
  if fbp_onlinemode in aitems then begin
   addparam(params1,isc_spb_prp_online_mode,card8(onlinemode));
  end;
 end;
 gettext('properties',params1,res,maxrowcount);
end;

procedure tfbservice.validatestart(const dbname: msestring;
               const tabincl: msestring = ''; const tabexcl: msestring = '';
               const idxincl: msestring = ''; const idxexcl: msestring = '';
               const locktimeout: card32 = 0);
var
 params1: string;
begin
 params1:= char(isc_action_svc_validate);
 addmseparam(params1,isc_spb_dbname,dbname);
 if tabincl <> '' then begin
  addmseparam(params1,isc_spb_val_tab_incl,tabincl);
 end;
 if tabexcl <> '' then begin
  addmseparam(params1,isc_spb_val_tab_excl,tabexcl);
 end;
 if idxincl <> '' then begin
  addmseparam(params1,isc_spb_val_idx_incl,idxincl);
 end;
 if idxexcl <> '' then begin
  addmseparam(params1,isc_spb_val_idx_excl,idxexcl);
 end;
 if locktimeout <> 0 then begin
  addparam(params1,isc_spb_val_lock_timeout,locktimeout);
 end;
 startmonitor('validatestart',params1);
end;

procedure tfbservice.backupstart(const dbname: msestring;
      const backupfiles: array of msestring; const lengths: array of card32;
      const verbose: boolean = false; const stat: string = '';
      const aoptions: backupoptionsty = [];
      const factor: card32 = 0);
var
 params1: string;
 i1: int32;
 ca1: card32;
begin
 params1:= char(isc_action_svc_backup);
 addmseparam(params1,isc_spb_dbname,dbname);
 for i1:= 0 to high(backupfiles) do begin
  addmseparam(params1,isc_spb_bkp_file,backupfiles[i1]);
  if i1 <= high(lengths) then begin
   addparam(params1,isc_spb_bkp_length,lengths[i1]);
  end;
 end;
 if verbose then begin
  addparam(params1,isc_spb_verbose);
 end;
 if stat <> '' then begin
  addparam(params1,isc_spb_bkp_stat,stat);
 end;
 ca1:= card32(aoptions - [bao_notriggers]);
 if bao_notriggers in aoptions then begin
  ca1:= ca1 or $8000;
 end;
 addparam(params1,isc_spb_options,ca1);
 startmonitor('backupstart',params1);
end;

procedure tfbservice.restorestart(const backupfiles: array of msestring;
              const dbfiles: array of msestring; const lengths: array of card32;
              const verbose: boolean = false; const stat: string = '';
              const aoptions: restoreoptionsty = [];
              const accessmode: accessmodety = amo_readwrite;
              const buffers: card32 = 0; const pagesize: card32 = 0;
              const fixfssdata: string = ''; const fixfssmetadata: string = '');
var
 params1: string;
 i1: int32;
 ca1: card32;
 opt1: restoreoptionty;
begin
 params1:= char(isc_action_svc_restore);
 for i1:= 0 to high(backupfiles) do begin
  addmseparam(params1,isc_spb_bkp_file,backupfiles[i1]);
 end;
 for i1:= 0 to high(dbfiles) do begin
  addmseparam(params1,isc_spb_dbname,dbfiles[i1]);
  if i1 <= high(lengths) then begin
   addparam(params1,isc_spb_res_length,lengths[i1]);
  end;
 end;
 if verbose then begin
  addparam(params1,isc_spb_verbose);
 end;
 if stat <> '' then begin
  addparam(params1,isc_spb_res_stat,stat);
 end;
 if aoptions <> [] then begin
  ca1:= 0;
  for opt1:= low(opt1) to high(opt1) do begin
   if opt1 in aoptions then begin
    ca1:= ca1 or restoreconsts[opt1];
   end;
  end;
  addparam(params1,isc_spb_options,ca1);
 end;
 addparam(params1,isc_spb_res_access_mode,card8(accessmodeconsts[accessmode]));
 if buffers <> 0 then begin
  addparam(params1,isc_spb_res_buffers,buffers);
 end;
 if pagesize <> 0 then begin
  addparam(params1,isc_spb_res_page_size,pagesize);
 end;
 if fixfssdata <> '' then begin
  addparam(params1,isc_spb_res_fix_fss_data,fixfssdata);
 end;
 if fixfssmetadata <> '' then begin
  addparam(params1,isc_spb_res_fix_fss_metadata,fixfssmetadata);
 end;
 startmonitor('restorestart',params1);
end;

procedure tfbservice.nbakstart(const dbname: msestring; const _file: msestring;
               const level: card32; const options: nbakoptionsty;
               const direct: string = '');
var
 params1: string;
begin
 params1:= char(isc_action_svc_nbak);
 addmseparam(params1,isc_spb_dbname,dbname);
 addmseparam(params1,isc_spb_nbk_file,_file);
 addparam(params1,isc_spb_nbk_level,level);
 addparam(params1,isc_spb_options,card32(options));
 if direct <> '' then begin
  addparam(params1,isc_spb_nbk_direct,direct);
 end; 
 startmonitor('nbak',params1);
end;

procedure tfbservice.repairstart(const adbname: msestring;
               const aoptions: repairoptionsty);
var
 params1: string;
begin
 params1:= char(isc_action_svc_repair);
 addmseparam(params1,isc_spb_dbname,adbname);
 addparam(params1,isc_spb_options,card32(aoptions));
 startmonitor('repairstart',params1);
end;

end.
