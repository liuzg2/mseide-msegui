{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefirebird;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

uses
 firebird,msestrings,msectypes,msetypes;
{$define cvcall}
const
{$ifdef mswindows}
 {$define wincall}
 firebirdlib: array[0..0] of filenamety = ('fbclient.dll');
{$else}
 firebirdlib: array[0..2] of filenamety = 
             ('libfbclient.so.3','libfbclient.so.2','libfbclient.so');
{$endif}

const
 SQL_TEXT =          452;
 SQL_VARYING =       448;
 SQL_SHORT =         500;
 SQL_LONG =          496;
 SQL_FLOAT =         482;
 SQL_DOUBLE =        480;
 SQL_D_FLOAT =       530;
 SQL_TIMESTAMP =     510;
 SQL_BLOB =          520;
 SQL_ARRAY =         540;
 SQL_QUAD =          550;
 SQL_TYPE_TIME =     560;
 SQL_TYPE_DATE =     570;
 SQL_INT64 =         580;
 SQL_BOOLEAN =     32764;
 SQL_NULL =        32766;

 CS_NONE =        0; //* No Character Set */
 CS_BINARY =      1; //* BINARY BYTES     */
 CS_ASCII =       2; //* ASCII            */
 CS_UNICODE_FSS = 3; //* UNICODE in FSS format */
 CS_UTF8 =        4; //* UTF-8 */

{$ifdef cpu64}
 FB_DOUBLE_ALIGN = 8;
{$else}  
 FB_DOUBLE_ALIGN = 4; //check!
{$endif}
 ISC_TIME_SECONDS_PRECISION = 10000;
 GDS_EPOCH_START = 40617;
 fbdatetimeoffset = -15018; //fpdate -> tdatetime;
 EPB_version1 = 1;
 
(*
#define dtype_unknown	0
#define dtype_text		1
#define dtype_cstring	2
#define dtype_varying	3

#define dtype_packed	6
#define dtype_byte		7
#define dtype_short		8
#define dtype_long		9
#define dtype_quad		10
#define dtype_real		11
#define dtype_double	12
#define dtype_d_float	13
#define dtype_sql_date	14
#define dtype_sql_time	15
#define dtype_timestamp	16
#define dtype_blob		17
#define dtype_array		18
#define dtype_int64		19
#define dtype_dbkey		20
#define dtype_boolean	21
#define DTYPE_TYPE_MAX	22

static const USHORT type_alignments[DTYPE_TYPE_MAX] =
{
	0,
	0,							/* dtype_text */
	0,							/* dtype_cstring */
	sizeof(SSHORT),				/* dtype_varying */
	0,							/* unused */
	0,							/* unused */
	sizeof(SCHAR),				/* dtype_packed */
	sizeof(SCHAR),				/* dtype_byte */
	sizeof(SSHORT),				/* dtype_short */
	sizeof(SLONG),				/* dtype_long */
	sizeof(SLONG),				/* dtype_quad */
	sizeof(float),				/* dtype_real */
	FB_DOUBLE_ALIGN,			/* dtype_double */
	FB_DOUBLE_ALIGN,			/* dtype_d_float */
	sizeof(GDS_DATE),			/* dtype_sql_date */
	sizeof(GDS_TIME),			/* dtype_sql_time */
	sizeof(GDS_DATE),			/* dtype_timestamp */
	sizeof(SLONG),				/* dtype_blob */
	sizeof(SLONG),				/* dtype_array */
	sizeof(SINT64),				/* dtype_int64 */
	sizeof(ULONG),				/* dtype_dbkey */
	sizeof(UCHAR)				/* dtype_boolean */
};

static const USHORT type_lengths[DTYPE_TYPE_MAX] =
{
	0,
	0,							/* dtype_text */
	0,							/* dtype_cstring */
	0,							/* dtype_varying */
	0,							/* unused */
	0,							/* unused */
	0,							/* dtype_packed */
	sizeof(SCHAR),				/* dtype_byte */
	sizeof(SSHORT),				/* dtype_short */
	sizeof(SLONG),				/* dtype_long */
	sizeof(ISC_QUAD),			/* dtype_quad */
	sizeof(float),				/* dtype_real */
	sizeof(double),				/* dtype_double */
	sizeof(double),				/* dtype_d_float */
	sizeof(GDS_DATE),			/* dtype_sql_date */
	sizeof(GDS_TIME),			/* dtype_sql_time */
	sizeof(GDS_TIMESTAMP),		/* dtype_timestamp */
	sizeof(ISC_QUAD),			/* dtype_blob */
	sizeof(ISC_QUAD),			/* dtype_array */
	sizeof(SINT64),				/* dtype_int64 */
	sizeof(RecordNumber::Packed), /*dtype_dbkey */
	sizeof(UCHAR)				/* dtype_boolean */
};
*)

//****************************/
//* Common, structural codes */
//****************************/

 isc_info_end =            1;
 isc_info_truncated =      2;
 isc_info_error =          3;
 isc_info_data_not_ready = 4;
 isc_info_length =       126;
 isc_info_flag_end =     127;

//**************************/
//* Blob information items */
//**************************/

 isc_info_blob_num_segments = 4;
 isc_info_blob_max_segment =  5;
 isc_info_blob_total_length = 6;
 isc_info_blob_type =         7;

//*************************/
//* SQL information items */
//*************************/

  isc_info_sql_select =          4;
  isc_info_sql_bind =            5;
  isc_info_sql_num_variables =   6;
  isc_info_sql_describe_vars =   7;
  isc_info_sql_describe_end =    8;
  isc_info_sql_sqlda_seq =       9;
  isc_info_sql_message_seq =    10;
  isc_info_sql_type =           11;
  isc_info_sql_sub_type =       12;
  isc_info_sql_scale =          13;
  isc_info_sql_length =         14;
  isc_info_sql_null_ind =       15;
  isc_info_sql_field =          16;
  isc_info_sql_relation =       17;
  isc_info_sql_owner =          18;
  isc_info_sql_alias =          19;
  isc_info_sql_sqlda_start =    20;
  isc_info_sql_stmt_type =      21;
  isc_info_sql_get_plan =       22;
  isc_info_sql_records =        23;
  isc_info_sql_batch_fetch =    24;
  isc_info_sql_relation_alias = 25;
  isc_info_sql_explain_plan =   26;
  isc_info_sql_stmt_flags  =    27;

//*********************************/
//* SQL information return values */
//*********************************/

  isc_info_sql_stmt_select =          1;
  isc_info_sql_stmt_insert =          2;
  isc_info_sql_stmt_update =          3;
  isc_info_sql_stmt_delete =          4;
  isc_info_sql_stmt_ddl =             5;
  isc_info_sql_stmt_get_segment =     6;
  isc_info_sql_stmt_put_segment =     7;
  isc_info_sql_stmt_exec_procedure =  8;
  isc_info_sql_stmt_start_trans =     9;
  isc_info_sql_stmt_commit =         10;
  isc_info_sql_stmt_rollback =       11;
  isc_info_sql_stmt_select_for_upd = 12;
  isc_info_sql_stmt_set_generator =  13;
  isc_info_sql_stmt_savepoint =      14;

//*****************************/
//* Request information items */
//*****************************/

 isc_info_number_messages =   4;
 isc_info_max_message =       5;
 isc_info_max_send =          6;
 isc_info_max_receive =       7;
 isc_info_state =             8;
 isc_info_message_number =    9;
 isc_info_message_size =     10;
 isc_info_request_cost =     11;
 isc_info_access_path =      12;
 isc_info_req_select_count = 13;
 isc_info_req_insert_count = 14;
 isc_info_req_update_count = 15;
 isc_info_req_delete_count = 16;

 isc_spb_version = isc_spb_current_version;
 isc_spb_user_name = isc_dpb_user_name;           //shortstring
 isc_spb_password = isc_dpb_password;             //shortstring
 isc_spb_sql_role_name = isc_dpb_sql_role_name;
 isc_spb_res_stat = isc_spb_bkp_stat;

type
 {$packrecords c}
 SSHORT = cshort;
 USHORT = cushort;
 SLONG = int32;
 ULONG = card32;
 pULONG = ^ULONG;
 ISC_USHORT = cushort;
 ISC_SHORT = cshort;
 pISC_SHORT = ^ISC_SHORT;
 ISC_LONG = SLONG;
 pISC_QUAD = ^ISC_QUAD;
 
 ISC_DATE = int32;
 pISC_DATE = ^ISC_DATE;
 ISC_TIME = card32;
 pISC_TIME = ^ISC_TIME;
 
 ISC_TIMESTAMP = record
  timestamp_date: ISC_DATE;
  timestamp_time: ISC_TIME;
 end;
 pISC_TIMESTAMP = ^ISC_TIMESTAMP;
 ISC_STATUS = ptrint;
 pISC_STATUS = ^ISC_STATUS;
 
 vary = record
  vary_length: ISC_USHORT;
  vary_string: record
  end;
 end;
 pvary = ^vary;

 fbapity = record
  master: imaster;
  status: istatus;
  provider: iprovider;
  util: iutil;
 end;
 
procedure inifbapi(var api: fbapity);
procedure finifbapi(var api: fbapity);

procedure initializefirebird(const sonames: array of filenamety;
                                          const onlyonce: boolean = false);
                                     //[] = default
procedure releasefirebird();

function formatstatus(status: istatus): string;
function event_block(out eventbuffer: pbyte;
                                         const names: array of string): int32;
procedure freeeventblock(var eventbuffer: pbyte);

var
 fb_get_master_interface: function: IMaster
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 isc_get_client_major_version: function(): cint
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 isc_get_client_minor_version: function(): cint
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 gds__alloc: function (size_request: SLONG): pointer
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 gds__free: function(blk: pointer): ULONG;
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
 gds__vax_integer: function (ptr: pbyte; length: SSHORT): ISC_LONG;
                               {$ifdef wincall}stdcall{$else}cdecl{$endif};
(*
 gds__event_block: function (event_buffer: ppbyte; result_buffer: ppbyte;
                           count: USHORT; names: array of const):ISC_LONG
                            {$ifdef cvcall}cdecl{$else}error{$endif}; {varargs;}
*)
 isc_event_counts: procedure (result_vector: pULONG; legth: SSHORT;
                     before: pbyte; after: pbyte)
                                  {$ifdef wincall}stdcall{$else}cdecl{$endif};
 gds__sqlcode: function(status_vector: pISC_STATUS): SLONG
                                  {$ifdef wincall}stdcall{$else}cdecl{$endif};

implementation
uses
 msedynload,sysutils;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
var 
 libinfo: dynlibinfoty;
 master: imaster;
 util: iutil;
 
procedure initfb(const data: pointer);
begin
 master:= fb_get_master_interface();
 util:= master.getutilinterface();
end;

procedure releasefb(const data: pointer);
begin
 master.getdispatcher().shutdown(nil,0,0);
end;

procedure inifbapi(var api: fbapity);
begin
 initializefirebird([],true);
 with api do begin
  if master = nil then begin
   master:= fb_get_master_interface();
  end;
  if status = nil then begin
   status:= master.getstatus();
  end;
  if provider = nil then begin
   provider:= master.getdispatcher();
  end;
  if util = nil then begin
   util:= master.getutilinterface();
  end;
 end;
end;

procedure finifbapi(var api: fbapity);
begin
 with api do begin
  util:= nil;
  provider:= nil;
  if status <> nil then begin
   status.dispose();
   status:= nil;
  end;
  master:= nil;
 end;
end;

procedure initializefirebird(const sonames: array of filenamety; //[] = default
                                         const onlyonce: boolean = false);
                                     
const
 funcs: array[0..7] of funcinfoty = (
  (n: 'fb_get_master_interface'; d: @fb_get_master_interface),
  (n: 'isc_get_client_major_version'; d: @isc_get_client_major_version),
  (n: 'isc_get_client_minor_version'; d: @isc_get_client_minor_version),
  (n: 'gds__vax_integer'; d: @gds__vax_integer),
//  (n: 'gds__event_block'; d: @gds__event_block),
  (n: 'isc_event_counts'; d: @isc_event_counts),
  (n: 'gds__alloc'; d: @gds__alloc),
  (n: 'gds__free'; d: @gds__free),
  (n: 'gds__sqlcode'; d: @gds__sqlcode)
 );
 errormessage = 'Can not load Firebird library. ';

begin
 if not onlyonce or (libinfo.refcount = 0) then begin
  initializedynlib(libinfo,sonames,firebirdlib,funcs,[],errormessage,@initfb);
 end;
end;

procedure releasefirebird();
begin
 releasedynlib(libinfo,@releasefb);
end;

function event_block(out eventbuffer: pbyte;
                                        const names: array of string): int32;
var
 i1,i2,i3: int32;
 po1: pbyte;
begin
 i2:= 1;
 for i1:= 0 to high(names) do begin
  i3:= length(names[i1]);
  if i3 > 255 then begin
   raise exception.create('event_block: name too long');
  end;
  i2:= i2 + i3 + 5;
 end;
 result:= i2;
 po1:= gds__alloc(i2);
 eventbuffer:= po1;
 po1^:= EPB_version1;
 inc(po1);
 for i1:= 0 to high(names) do begin
  i3:= length(names[i1]);
  po1^:= i3;
  inc(po1);
  move(pointer(names[i1])^,po1^,i3);
  inc(po1,i3);
  po1^:= 0;
  inc(po1);
  po1^:= 0;
  inc(po1);
  po1^:= 0;
  inc(po1);
  po1^:= 0;
  inc(po1);
 end;
end;

procedure freeeventblock(var eventbuffer: pbyte);
begin
 if eventbuffer <> nil then begin
  gds__free(eventbuffer);
  eventbuffer:= nil;
 end;
end;

function formatstatus(status: istatus): string;
var
 ca1: card32;
begin
 setlength(result,256);
 while true do begin
  ca1:= util.formatstatus(pointer(result),length(result),status);
  if ca1 < length(result) then begin
   break;
  end;
  setlength(result,2*length(result));
 end;
 setlength(result,ca1);
end;

initialization
 initializelibinfo(libinfo);
finalization
 if libinfo.refcount > 0 then begin
  libinfo.refcount:= 1;
  releasefirebird();
 end;
 finalizelibinfo(libinfo);
end.
