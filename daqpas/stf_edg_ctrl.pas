 {
 ***********************************************************************
 Daq Pascal application program edg.
 ***********************************************************************
 Next text uses by @Help command. Do not remove it.
 ***********************************************************************
[@Help]
|StdIn Command list: "@cmd=arg" or "@cmd arg"
|********************************************************
| @Edit tag - Show tag edit dialog for tag
| @AssignTag t v - Assign tag t to value v
|********************************************************
[]
 }
program edg;
const
 {------------------------------}{ Declare uses program constants:  }
 {$I _con_StdLibrary}            { Include all Standard constants,  }
 {------------------------------}{ And add User defined constants:  }

type
 {------------------------------}{ Declare uses program types:      }
 {$I _typ_StdLibrary}            { Include all Standard types,      }
 {------------------------------}{ And add User defined types:      }
 TGenRec = record
  ENAB : TTagRef;
  FREQ : TTagRef;
 end;

var
 {------------------------------}{ Declare uses program variables:  }
 {$I _var_StdLibrary}            { Include all Standard variables,  }
 {------------------------------}{ And add User defined variables:  }
 STF : record
  EDG : record
   GEN1 : TGenRec;
   GEN2 : TGenRec;
   GEN3 : TGenRec;
   COUNT : TTagRef;
   FREQ : TTagRef;
   START : TTagRef;
   OBJECT : TTagRef;
   ACTION : TTagRef;
   status : Integer;
   timer : Real;
   delay : Integer;
   counter : Integer;
  end;
 end;
 cmdEdit : Integer;              { @Edit                            }
 cmdAssignTag : Integer;         { @AssignTag                       }

 {------------------------------}{ Declare procedures & functions:  }
 {$I _fun_StdLibrary}            { Include all Standard functions,  }
 {------------------------------}{ And add User defined functions:  }

 {}
 procedure StfEdgInitValues;
 begin
  bNul(iSetTag(STF.EDG.OBJECT.tag, 0));
  bNul(iSetTag(STF.EDG.ACTION.tag, 0));
  bNul(iSetTag(STF.EDG.START.tag, 0));
  STF.EDG.counter:=0;
  STF.EDG.status:=0;
  STF.EDG.timer:=0;
 end;

 {}
 procedure LogicControl;
 var genCnt:Integer;

  procedure GeneratorsLogicCtrl;
  var genFreq:Integer;

   procedure GenxLogicCtrl(GEN:TGenRec);
   begin
    if (iGetTag(STF.EDG.START.tag)<>0) then begin
     if (iGetTag(GEN.ENAB.tag)<>0) then bNul(iSetTag(GEN.FREQ.tag, genFreq));
    end else bNul(iSetTag(GEN.FREQ.tag, 0));
   end;

  begin
   genCnt:=iGetTag(STF.EDG.GEN1.ENAB.tag)+iGetTag(STF.EDG.GEN2.ENAB.tag)+iGetTag(STF.EDG.GEN3.ENAB.tag);
   genFreq:=Round(iGetTag(STF.EDG.FREQ.tag)/genCnt);
   GenxLogicCtrl(STF.EDG.GEN1);
   GenxLogicCtrl(STF.EDG.GEN2);
   GenxLogicCtrl(STF.EDG.GEN3);
  end;

 //
 procedure GeneralLogicCtrl;
 const minFreq=50; KHz=1000; sttInit=0;
       sttShowBug=1; sttBlowInit=2;
       sttBlowBug=3; sttRestBug=4;
       minDelay=1000; maxDelay=3000;
       blowTime=100; coalTime=5000;
       RestBug = 1; BlowBug = 2; CoalBug = 3;
 begin
  if (genCnt>0) then begin
   if (STF.EDG.status=sttInit) then begin
    STF.EDG.delay:=Round(Random(minDelay, maxDelay));
    STF.EDG.timer:=mSecNow;
    STF.EDG.status:=sttShowBug;
   end else if (STF.EDG.status=sttShowBug) then begin
    if (msElapsedSinceMarker(STF.EDG.timer)>STF.EDG.delay) then begin
     bNul(iSetTag(STF.EDG.OBJECT.tag, 1));
     STF.EDG.timer:=0;
     STF.EDG.status:=sttBlowInit;
    end;
   end;
   if (STF.EDG.status>sttShowBug) then begin
    if (iGetTag(STF.EDG.START.tag)<>0) then begin
     if (STF.EDG.counter>iGetTag(STF.EDG.COUNT.tag)-1) then begin
      bNul(iSetTag(STF.EDG.START.tag, 0));
      STF.EDG.timer:=mSecNow;
     end;
     if (STF.EDG.status=sttBlowInit) then begin
      STF.EDG.delay:=iMax(Round(KHz/iGetTag(STF.EDG.FREQ.tag)), minFreq);
      STF.EDG.timer:=mSecNow;
      STF.EDG.status:=sttBlowBug;
     end else if (STF.EDG.status=sttBlowBug) then begin
      if (msElapsedSinceMarker(STF.EDG.timer)>STF.EDG.delay) then begin
       bNul(iSetTag(STF.EDG.OBJECT.tag, BlowBug));
       bNul(iSetTag(STF.EDG.ACTION.tag, 1));
       STF.EDG.timer:=mSecNow;
       STF.EDG.status:=sttRestBug;
      end;
     end else if (STF.EDG.status=sttRestBug) then begin
      if (msElapsedSinceMarker(STF.EDG.timer)>blowTime) then begin
       bNul(iSetTag(STF.EDG.OBJECT.tag, RestBug));
       bNul(iSetTag(STF.EDG.ACTION.tag, 0));
       STF.EDG.counter:=STF.EDG.counter+1;
       STF.EDG.timer:=mSecNow;
       STF.EDG.status:=sttBlowBug;
      end;
     end;
    end else begin
     if (STF.EDG.status<>sttBlowInit) then begin
      bNul(iSetTag(STF.EDG.OBJECT.tag, CoalBug));
      bNul(iSetTag(STF.EDG.ACTION.tag, 0));
      STF.EDG.counter:=0;
      STF.EDG.status:=sttBlowInit;
     end else if (msElapsedSinceMarker(STF.EDG.timer)>coalTime) then StfEdgInitValues;
    end;
   end;
  end else begin
   StfEdgInitValues;
  end;
 end;

 begin
  GeneratorsLogicCtrl;
  GeneralLogicCtrl;
 end;

 {
 Xor bit on click (local version)
 }
 procedure ClickBitXorLocal(tag, XorMask:Integer);
 begin
  if (ClickTag=tag) then begin
   bNul(iSetTagXor(tag, XorMask));
   bNul(Voice(snd_Click));
  end;
 end;

 {
 Procedure to show sensor help
 }
 procedure SensorHelp(s:String);
 begin
  StdSensorHelpTooltip(s, 15000);
 end;

 {
 GUI Handler to process user input...
 }
 procedure GUIHandler;
 var s:String; ClickCurve:Integer;

  procedure Cleanup;
  begin
   s:=''; ClickCurve:=0;
  end;

 //
 // Send to console command (cmd data) to set new tag value if one in range (min,max)
 //
 procedure SendEditTagCmd(tag:Integer; cmd:String; min,max:Real);
 var v:Real; s:String;
 begin
  s:='';
  if CheckEditTag(tag, s) then begin
   if IsRefTag(tag) then
   if not IsEmptyStr(s) then begin
    v:=rVal(s);
    if isNan(v) then Trouble('Invalid tag edit') else begin
     if (v<min) then s:=Str(min) else
     if (v>max) then s:=Str(max);
     DevPostCmdLocal(cmd+' '+Trim(s));
    end;
   end;
  end;
  s:='';
 end;

 begin
  Cleanup;
  {
  Handle user mouse/keyboard clicks...
  ClickWhat=(cw_Nothing,cw_MouseDown,cw_MouseUp,cw_MouseMove,cw_KeyDown,cw_KeyUp,cw_MouseWheel,...)
  ClickButton=(VK_LBUTTON,VK_RBUTTON,VK_CANCEL,VK_MBUTTON,VK_BACK,VK_TAB,VK_CLEAR,VK_RETURN,...)
  }
  if (ClickWhat<>0) then
  repeat
   {
   Handle MouseDown/KeyDown
   }
   if (ClickWhat=cw_MouseDown) or (ClickWhat=cw_KeyDown) then begin
    {
    Handle Left mouse button click
    }
    if (ClickButton=VK_LBUTTON) then begin
     {
     Handle tag clicks...
     }
     if (ClickTag<>0) then begin
      ClickBitXorLocal(STF.EDG.GEN1.ENAB.tag, 1);
      ClickBitXorLocal(STF.EDG.GEN2.ENAB.tag, 1);
      ClickBitXorLocal(STF.EDG.GEN3.ENAB.tag, 1);
      ClickBitXorLocal(STF.EDG.START.tag, 1);
      //
      s:=mime_encode(SetFormUnderSensorLeftBottom(ClickParams('')));
      if (ClickTag=STF.EDG.COUNT.tag) then DevSendCmdLocal('@Edit '+NameTag(ClickTag)+' '+s);
      if (ClickTag=STF.EDG.FREQ.tag) then DevSendCmdLocal('@Edit '+NameTag(ClickTag)+' '+s);
     end;
     {
     Handle sensor clicks...
     }
     if IsSameText(ClickSensor,'HELP') then begin
      DevPostCmdLocal('@BrowseHelp');
      bNul(Voice(snd_Click));
     end;
     {
     Select Plot & Tab windows by curve...
     }
     ClickCurve:=RefFind('Curve '+ClickParams('Curve'));
     if IsRefCurve(ClickCurve) then begin
      iNul(WinSelectByCurve(ClickCurve, ClickCurve));
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
   SendEditTagCmd(STF.EDG.COUNT.tag, '@AssignTag '+NameTag(STF.EDG.COUNT.tag), 0, 1000); // FIXIT: Magical numbers
   SendEditTagCmd(STF.EDG.FREQ.tag, '@AssignTag '+NameTag(STF.EDG.FREQ.tag), 0, 10000);
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
 var tag,i:Integer; w1,w2:String;
  procedure Cleanup;
  begin
   w1:=''; w2:='';
  end;
 begin
  Cleanup;
  if (arg<>'') then begin
   w1:=ExtractWord(1, arg);
   tag:=FindTag(w1);
   if (tag<>0) then begin
    w2:=ExtractWord(2, arg);
    if (tag=STF.EDG.COUNT.tag) then UpdateTag(tag, w2, 0, MaxInt);
    if (tag=STF.EDG.FREQ.tag) then UpdateTag(tag, w2, 0, MaxInt);
   end;
  end;
  Cleanup;
 end;

 {
 Initialize STF EDG tags
 }
 procedure StfEdgTagsInit(tagPrefix:String);
 begin
  tagPrefix:=Trim(tagPrefix);
  if not IsEmptyStr(tagPrefix) then begin
   InitTag(STF.EDG.GEN1.ENAB.tag, tagPrefix+'.EDG.GEN1.ENAB', 1);
   InitTag(STF.EDG.GEN2.ENAB.tag, tagPrefix+'.EDG.GEN2.ENAB', 1);
   InitTag(STF.EDG.GEN3.ENAB.tag, tagPrefix+'.EDG.GEN3.ENAB', 1);
   InitTag(STF.EDG.GEN1.FREQ.tag, tagPrefix+'.EDG.GEN1.FREQ', 1);
   InitTag(STF.EDG.GEN2.FREQ.tag, tagPrefix+'.EDG.GEN2.FREQ', 1);
   InitTag(STF.EDG.GEN3.FREQ.tag, tagPrefix+'.EDG.GEN3.FREQ', 1);
   InitTag(STF.EDG.COUNT.tag, tagPrefix+'.EDG.COUNT', 1);
   InitTag(STF.EDG.FREQ.tag, tagPrefix+'.EDG.FREQ', 1);
   InitTag(STF.EDG.START.tag, tagPrefix+'.EDG.START', 1);
   InitTag(STF.EDG.OBJECT.tag, tagPrefix+'.EDG.OBJECT', 1);
   InitTag(STF.EDG.ACTION.tag, tagPrefix+'.EDG.ACTION', 1);
  end else Trouble('Tags initialization error. Prefix not specified!');
 end;

 {
 DAQ program data initialization...
 }
 procedure StfEdgInit;
 begin
  //
  // Initialize tags & devices
  //
  StfEdgTagsInit(ReadIni('TagPrefix'));
  //
  // Initialize timers & values
  //
  StfEdgInitValues;
  bNul(iSetTag(STF.EDG.FREQ.tag, 100));
  bNul(iSetTag(STF.EDG.COUNT.tag, 10));
 end;

 {
 Clear user application strings...
 }
 procedure ClearApplication;
 begin
 end;

 {
 User application Initialization...
 }
 procedure InitApplication;
 begin
  StdIn_SetScripts('', '');
  StdIn_SetTimeouts(0, 0, 0, MaxInt);
  iNul(ClickFilter(ClickFilter(1)));
  iNul(ClickAwaker(ClickAwaker(1)));
  StfEdgInit;
  cmdEdit:=RegisterStdInCmd('@Edit', '');
  cmdAssignTag:=RegisterStdInCmd('@AssignTag', '');
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
  GUIHandler;
  LogicControl;
 end;

 {
 Process data coming from standard input...
 }
 procedure StdIn_Processor(var Data:String);
 var cmd,arg,s,par:String; cmdid,tag:Integer;

  procedure Cleanup;
  begin
   cmd:=''; arg:=''; s:=''; par:='';
  end;

 begin
  Cleanup;
  if DebugFlagEnabled(dfViewImp) then ViewImp('CON: '+Data);
  {
  Handle "@cmd=arg" or "@cmd arg" commands:
  }
  if GotCommandId(Data, cmd, arg, cmdid) then begin
   {
   @Edit tag - Show tag edit dialog for tag
   @Edit STF.ENERGY - Enter Beam energy
   }
   if (cmdid=cmdEdit) then begin
    par:=mime_decode(ExtractWord(2, arg));
    s:=ExtractWord(1, arg);
    tag:=FindTag(s);
    if (Pos('COUNT', s)>0) then StartEditTagEx(tag, 'Введите количество импульсов', par);
    if (Pos('FREQ', s)>0) then StartEditTagEx(tag, 'Введите частоту импультсов', par);
    Data:='';
   end else
   {
   @AssignTag t v - Assign tag t (tag name) to value v
   @AssignTag STF.PARTICLE 1 - Set particle type to 0
   }
   if (cmdid=cmdAssignTag) then begin
    OnAssignTag(arg);
    Data:='';
   end else
   {
   Handle other commands by default handler...
   }
   StdIn_DefaultHandler(Data, cmd, arg);
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
