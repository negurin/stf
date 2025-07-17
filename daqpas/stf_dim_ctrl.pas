 {
 ***********************************************************************
 Daq Pascal application program stf.
 ***********************************************************************
 Next text uses by @Help command. Do not remove it.
 ***********************************************************************
[@Help]
|StdIn Command list: "@cmd=arg" or "@cmd arg"
|********************************************************
| @AssignTag t v - Assign tag t to value v
| @DimTagUpdate  - Update tag from DIM
|********************************************************
[]
 }
program dim_stf;
const
 {------------------------------}{ Declare uses program constants:  }
 {$I _con_StdLibrary}            { Include all Standard constants,  }
 {------------------------------}{ And add User defined constants:  }
 DimDeadline     = 5000;         { Detect DIM server is dead        }
 DimUpdatePeriod = 10000;        { Enforce update period            }

type
 {------------------------------}{ Declare uses program types:      }
 {$I _typ_StdLibrary}            { Include all Standard types,      }
 {------------------------------}{ And add User defined types:      }

var
 {------------------------------}{ Declare uses program variables:  }
 {$I _var_StdLibrary}            { Include all Standard variables,  }
 {------------------------------}{ And add User defined variables:  }
 STF          : record          { All STF data:                   }
  DIM             : record       {  DIM records:                    }
   SERVID         : TTagRef;     {  Server Identifier pid@hostname  }
   CLOCK          : TTagRef;     {  Server Date-Time                }
   ROLE           : TTagRef;     {  Role: Client/Server             }
   SelfId         : String;      {  Self pid@hostname               }
  end;                           {                                  }
 end;                            {                                  }
 ColorNorm        : Integer;     { Color in normal state: lime,aqua }
 ColorWarn        : Integer;     { Color in warning state: yellow   }
 cmd_AssignTag    : Integer;     { Commands: @AssignTag             }
 cmd_DimTagUpdate : Integer;     {  @DimTagUpdate                   }

 {------------------------------}{ Declare procedures & functions:  }
 {$I _fun_StdLibrary}            { Include all Standard functions,  }
 {------------------------------}{ And add User defined functions:  }

 {
 Prefix for DIM @remote commands
 }
 function DimRemote:String;
 var CanRemote:Boolean;
 begin
  CanRemote:=DIM_IsServerMode or DIM_IsClientMode;
  if (DIM_GuiClickTag=0) then CanRemote:=false;
  if (devDimSrv=0) then CanRemote:=false;
  if CanRemote
  then DimRemote:='@remote '
  else DimRemote:='';
 end;
 {
 Xor bit on click (remote version)
 }
 procedure ClickTagXorRemote(tag,XorMask:Integer);
 begin
  if IsRefTag(tag) then
  if (ClickTag=tag) then begin
   DevSendCmdLocal(DimRemote+'@AssignTag '+NameTag(tag)+' '+Str(iXor(iGetTag(tag),XorMask)));
   bNul(Voice(snd_Click));
  end;
 end;
 {
 Procedure to show sensor help
 }
 procedure SensorHelp(s:String);
 begin
  StdSensorHelpTooltip(s,15000);
 end;
 {
 GUI Handler to process user input...
 }
 procedure GUIHandler;
 var s:String; ClickCurve:Integer;
  procedure Cleanup;
  begin
   DIM_GuiClickBuff:=''; s:=''; ClickCurve:=0;
  end;
 begin
  Cleanup;
  {
  Handle user mouse/keyboard clicks...
  ClickWhat=(cw_Nothing,cw_MouseDown,cw_MouseUp,cw_MouseMove,cw_KeyDown,cw_KeyUp,cw_MouseWheel,...)
  ClickButton=(VK_LBUTTON,VK_RBUTTON,VK_CANCEL,VK_MBUTTON,VK_BACK,VK_TAB,VK_CLEAR,VK_RETURN,...)
  }
  if ClickWhat<>0 then
  repeat
   {
   Copy GUI click to DIM buffer for remote execution.
   }
   DIM_GuiClickBuff:=DIM_GuiClickCopy;
   {
   Handle MouseDown/KeyDown
   }
   if (ClickWhat=cw_MouseDown) or (ClickWhat=cw_KeyDown) then begin
    {
    Handle Left mouse button click
    }
    if (ClickButton=VK_LBUTTON) then begin
     {
     Handle local clicks
     }
     if ClickIsLocal then begin
      {
      Handle tag clicks...
      }
      if ClickTag<>0 then begin
       // ClickTagXorRemote(STF.DIM.BT.tag,1); // Sample
      end;
      {
      Handle sensor clicks...
      }
      if IsSameText(ClickSensor,'HELP') then begin
       Cron('@Browse '+DaqFileRef(ReadIni('[DAQ] HelpFile'),'.htm'));
       bNul(Voice(snd_Click));
      end;
      {
      Select Plot & Tab windows by curve...
      }
      ClickCurve:=RefFind('Curve '+ClickParams('Curve'));
      if IsRefCurve(ClickCurve) then begin
       iNul(WinSelectByCurve(ClickCurve,ClickCurve));
       bNul(Voice(snd_Wheel));
      end;
      {
      Console commands: @url_encoded_sensor ...
      }
      if LooksLikeCommand(ClickSensor) then begin
       DevSendCmdLocal(url_decode(ClickSensor));
       bNul(Voice(snd_Click));
      end;
     end;
     {
     Handle remote clicks comes from DIM via @DimGuiClick message.
     @DimGuiClick default handler decode and write events to FIFO,
     so we can find it as clicks and can handle it in usual way.
     }
     if ClickIsRemote then begin
      //
      // Show time difference.
      //
      if DebugFlagEnabled(dfDetails) then
      Details('Remote Click Time Diff '+Str(mSecNow-rVal(ClickParams('When')))+' ms');
      //
      // Handle remote console commands...
      //
      s:=Dim_GuiConsoleRecv(DevName,'');
      if LooksLikeCommand(s) then DevSendCmdLocal(s);
     end;
    end;
    {
    Handle Right mouse button click
    }
    if (ClickButton=VK_RBUTTON) then begin
     SensorHelp(ClickParams('Sensor')+' - '+Url_Decode(ClickParams('Hint')));
    end;
   end;
  until (ClickRead=0);
  {
  Edit handling...
  }
  if EditStateDone then begin
   {
   Warning,Information.
   }
   if EditTestResultName('Warning') then EditReset;
   if EditTestResultName('Information') then EditReset;
  end;
  if EditStateDone then begin
   Problem('Unhandled edit detected!');
   EditReset;
  end else
  if EditStateError then begin
   Problem('Edit error detected!');
   EditReset;
  end;
  Cleanup;
 end;
 {
 Handle message @AssignTag arg
 }
 procedure OnAssignTag(arg:String);
 var tag:Integer; w1,w2:String;
  procedure Cleanup;
  begin
   w1:=''; w2:='';
  end;
 begin
  Cleanup;
  if (arg<>'') then begin
   w1:=ExtractWord(1,arg);
   tag:=FindTag(w1);
   if (tag<>0) then begin
    w2:=ExtractWord(2,arg);
    // if tag=STF.DIM.BT.tag then UpdateTag(tag,w2,MinInt,MaxInt); // Sample
   end;
  end;
  Cleanup;
 end;
 {
 Handle message @DimTagUpdate arg
 }
 procedure OnDimTagUpdate(arg:String);
 var tag,typ:Integer; x,y:Real;
 begin
  if (arg<>'') then begin
   if DIM_IsClientMode and not DIM_IsServerMode then begin
    tag:=FindTag(ExtractWord(1,arg));
    if (tag<>0) then begin
     typ:=TypeTag(tag);
     if (typ=1) then y:=iGetTag(tag) else
     if (typ=2) then y:=rGetTag(tag) else y:=_Nan;
     x:=time;
     if not IsNan(y) then begin
      // if tag=STF.DIM.DI.tag then UpdateDo(do_STF_DI,x,y); // Sample
      // if tag=STF.DIM.AI.tag then UpdateAo(ao_STF_AI,x,y); // Sample
     end;
    end;
   end;
  end;
 end;
 //
 // Tags filling
 //
 procedure FillTags(InitVal:Real);
 begin
  STF.DIM.CLOCK.val:=InitVal;
  STF.DIM.SERVID.val:=InitVal;
 end;
 {
 Update DIM services
 }
 procedure DimUpdateState;
 begin
  if DIM_IsServerMode then begin
   // Enforce update
   if SysTimer_Pulse(DimUpdatePeriod)>0 then FillTags(-MaxReal);
   if ShouldRefresh(STF.DIM.CLOCK.val, GetStampOfTag(STF.DIM.CLOCK.tag,0))>0  then DIM_UpdateTag(STF.DIM.CLOCK.tag, '');
   if ShouldRefresh(STF.DIM.SERVID.val,GetStampOfTag(STF.DIM.SERVID.tag,0))>0 then DIM_UpdateTag(STF.DIM.SERVID.tag,'');
  end;
 end;
 {
 Poll DIM client
 }
 procedure UpdateDateTimeClient;
 begin
  if DIM_IsClientMode then begin
   if (ShouldRefresh(STF.DIM.CLOCK.dat,GetStampOfTag(STF.DIM.CLOCK.tag,0))>0) then begin
    bNul(SetTagColor(STF.DIM.SERVID.tag,ColorNorm));
    bNul(SetTagColor(STF.DIM.CLOCK.tag,ColorNorm));
    STF.DIM.CLOCK.tim:=mSecNow;
   end;
   if (SysTimer_Pulse(1000)>0) then if (mSecNow-STF.DIM.CLOCK.tim>DimDeadline) then begin
    bNul(sSetTag(STF.DIM.SERVID.tag,'Server Disconnected'));
    bNul(SetTagColor(STF.DIM.SERVID.tag,ColorWarn));
    bNul(SetTagColor(STF.DIM.CLOCK.tag,ColorWarn));
   end;
  end;
 end;
 {
 Poll DIM server (update host date-time)
 }
 procedure UpdateDateTimeServer;
 begin
  if (SysTimer_Pulse(1000)>0) then begin
   bNul(sSetTag(STF.DIM.SERVID.tag,STF.DIM.SelfId));
   bNul(sSetTag(STF.DIM.CLOCK.tag,GetDateTime(mSecNow)));
   bNul(SetTagColor(STF.DIM.SERVID.tag,ColorNorm));
   bNul(SetTagColor(STF.DIM.CLOCK.tag,ColorNorm));
  end;
 end;
 {
 Initialize STF tags
 }
 procedure STF_TagInit(tagPrefix:String);
 begin
  tagPrefix:=Trim(tagPrefix);
  if not IsEmptyStr(tagPrefix) then begin
   DIM_GuiClickInit(tagPrefix+'.DIMGUICLICK');
   InitTag(STF.DIM.SERVID.tag,tagPrefix+'.SERVID',3);
   InitTag(STF.DIM.CLOCK.tag, tagPrefix+'.CLOCK', 3);
   InitTag(STF.DIM.ROLE.tag,  tagPrefix+'.ROLE',  3);
  end else Trouble('Tags initialization error. Prefix not specified!');
 end;
 {
 STF data initialization
 }
 procedure STF_Init;
 begin
  //
  // Initialize tags & devices...
  //
  STF_TagInit(ReadIni('tagPrefix'));
  if DIM_IsServerMode then Success('Run as Server') else
  if DIM_IsClientMode then Success('Run as Client');
  //
  // Set the server identifier
  //
  if DIM_IsServerMode
  then STF.DIM.SelfId:=Str(getpid)+'@'+ParamStr('HostName')
  else STF.DIM.SelfId:=Str(getpid)+'@'+ParamStr('ComputerName');
  //
  // Set the host role
  //
  if DIM_IsServerMode
  then bNul(sSetTag(STF.DIM.ROLE.tag,'Server'))
  else bNul(sSetTag(STF.DIM.ROLE.tag,'Client'));
  //
  // Set tags color
  //
  ColorNorm:=StringToColorDef('clDodgerBlue',clAqua);
  ColorWarn:=StringToColorDef('clGold',clYellow);
  if DIM_IsServerMode then ColorNorm:=StringToColorDef('clLimeGreen',clLime);
  if DIM_IsClientMode then ColorNorm:=StringToColorDef('clLimeGreen',clLime);
  bNul(SetTagColor(STF.DIM.CLOCK.tag,ColorNorm));
  bNul(SetTagColor(STF.DIM.SERVID.tag,ColorNorm));
  //
  // Initialize timers & values
  //
  STF.DIM.CLOCK.tim:=mSecNow;
 end;
 {
 STF cleanup
 }
 procedure STF_Clear;
 begin
  FillTags(-MaxReal);
  STF.DIM.SERVID.tag:=0;
  STF.DIM.CLOCK.tag:=0;
  STF.DIM.SelfId:='';
 end;
 {
 Clear user application strings...
 }
 procedure ClearApplication;
 begin
  STF_Clear;
 end;
 {
 User application Initialization...
 }
 procedure InitApplication;
 begin
  StdIn_SetScripts('','');
  StdIn_SetTimeouts(0,0,0,MaxInt);
  iNul(ClickFilter(ClickFilter(1)));
  iNul(ClickAwaker(ClickAwaker(1)));
  STF_Init;
  cmd_AssignTag:=RegisterStdInCmd('@AssignTag','');
  cmd_DimTagUpdate:=RegisterStdInCmd('@DimTagUpdate','');
 end;
 {
 User application Finalization...
 }
 procedure FreeApplication;
 begin
 end;
 {
 User application Polling...
 }
 procedure PollApplication;
 begin
  if DIM_IsServerMode
  then UpdateDateTimeServer
  else UpdateDateTimeClient;
  GUIHandler;     // Handle GUI: edit, buttons etc
  DimUpdateState; // Update DIM services
 end;
 {
 Process data coming from standard input...
 }
 procedure StdIn_Processor(var Data:String);
 var cmd,arg:String; cmdid:Integer;
  procedure Cleanup;
  begin
   cmd:=''; arg:='';
  end;
 begin
  Cleanup;
  if DebugFlagEnabled(dfViewImp) then ViewImp('CON: '+Data);
  {
  Handle "@cmd=arg" or "@cmd arg" commands:
  }
  if GotCommandId(Data,cmd,arg,cmdid) then begin
   {
   @AssignTag t v - assign tag t (tag name) to value v
   @AssignTag STF.DIM.BT 0 - disable button (set tag to zero value)
   }
   if (cmdid=cmd_AssignTag) then begin
    OnAssignTag(arg);
    Data:='';
   end else
   {
   @DimTagUpdate tag - update tag from DIM
   }
   if (cmdid=cmd_DimTagUpdate) then begin
    OnDimTagUpdate(arg);
    Data:='';
   end else
   {
   Handle other commands by default handler...
   }
   StdIn_DefaultHandler(Data,cmd,arg);
  end;
  Data:='';
  Cleanup;
 end;

{***************************************************}
{***************************************************}
{***                                             ***}
{***  MMM    MMM        AAA   IIII   NNN    NN   ***}
{***  MMMM  MMMM       AAAA    II    NNNN   NN   ***}
{***  MM MMMM MM      AA AA    II    NN NN  NN   ***}
{***  MM  MM  MM     AA  AA    II    NN  NN NN   ***}
{***  MM      MM    AAAAAAA    II    NN   NNNN   ***}
{***  MM      MM   AA    AA   IIII   NN    NNN   ***}
{***                                             ***}
{***************************************************}
{$I _std_main}{*** Please never change this code ***}
{***************************************************}
