 {
 ***********************************************************************
 Daq Pascal application program stf
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
[Compiler.Options]
Compiler.dtabmax = 8192*8
[]
 }
program stf;
const
 {------------------------------}{ Declare uses program constants:  }
 {$I _con_StdLibrary}            { Include all Standard constants,  }
 {$I stf_ba_const}               { Include STF.BA constants,        }
 {$I stf_ms_const}               { Include STF.MS constants,        }
 {------------------------------}{ And add User defined constants:  }
 MaxEnergy = 100;
 MinEnergy = 1.9;
 MaxIntens = 5;
 MinIntens = 1;
 stt_poll = 0;
 stt_init = 1;
 st_empty = 0;
 st_bunch = 1;
 st_warn = 2;
 st_error = 3;

type
 {------------------------------}{ Declare uses program types:      }
 {$I _typ_StdLibrary}            { Include all Standard types,      }
 {$I stf_ba_types}               { Include STF.BA types,            }
 {$I stf_ms_types}               { Include STF.MS types,            }
 {------------------------------}{ And add User defined types:      }
 TStfRec = record
  BA : TBaRec;
  MS : TMsRec;
  PARTICLE : TTagRef;
  ENERGY : TTagRef;
  INTENSITY : TTagRef;
  MODE : TTagRef;
  IntenLength : Integer;
  EnergyValue : Integer;
 end;

var
 {------------------------------}{ Declare uses program variables:  }
 {$I _var_StdLibrary}            { Include all Standard variables,  }
 {------------------------------}{ And add User defined variables:  }
 STF : TStfRec;
 cmd_Edit : Integer;             { @Edit                            }
 cmd_AssignTag : Integer;        { @AssignTag                       }

 {------------------------------}{ Declare procedures & functions:  }
 {$I _fun_StdLibrary}            { Include all Standard functions,  }
 {$I stf_ba_funcs}               { Include STF.BA functions,        }
 {$I stf_ms_funcs}               { Include STF.MS functions,        }
 {------------------------------}{ And add User defined functions:  }

 {}
 procedure LogicControl;
  {}
  procedure SecsLogicControl(var REC:TSecRec);
   function IsValidIndex(i:Integer):Boolean;
   begin
    if ((i>0) and (i<=REC.Secs)) then IsValidIndex:=true else IsValidIndex:=false;
   end;

   procedure InitRunning;
   begin
    if IsValidIndex(REC.head) then bNul(iSetTag(REC.NUM[REC.head].tag, st_bunch));
    if (REC.head>=STF.IntenLength) then begin
     REC.tile:=REC.head-STF.IntenLength;
     if IsValidIndex(REC.tile) then bNul(iSetTag(REC.NUM[REC.tile].tag, st_empty));
    end;
    REC.head:=REC.head+1;
    if (REC.head>REC.Secs) then begin
     REC.head:=1;
     REC.tile:=REC.tile+1;
     REC.Init:=stt_poll;
    end;
   end;

   //
   procedure PollRunning;
   begin
    if IsValidIndex(REC.head) then bNul(iSetTag(REC.NUM[REC.head].tag, st_bunch));
    if IsValidIndex(REC.tile) then bNul(iSetTag(REC.NUM[REC.tile].tag, st_empty));
    REC.head:=REC.head+1;
    REC.tile:=REC.tile+1;
    if (REC.head>REC.Secs) then REC.head:=1;
    if (REC.tile>REC.Secs) then REC.tile:=1;
   end;

  begin
   if (SysTimer_Pulse(STF.EnergyValue)>0) then begin
    if (REC.Init=stt_init)
    then InitRunning
    else if (REC.Init=stt_poll)
    then PollRunning;
   end;
  end;

 begin
  La1LogicControl;
  SecsLogicControl(STF.BA.INJ.SEC);
  SecsLogicControl(STF.BA.BS.SEC);
  SecsLogicControl(STF.BA.BPC.SEC);
  SecsLogicControl(STF.BA.BTC.SEC);
  SecsLogicControl(STF.BA.BTC.TC11.SEC);
  SecsLogicControl(STF.BA.BTC.TC12.SEC);
  SecsLogicControl(STF.BA.BTC.TC13.SEC);
  SecsLogicControl(STF.MS.SEC);
  SecsLogicControl(STF.MS.TC.SEC);
  SecsLogicControl(STF.MS.TC.TC21.SEC);
  SecsLogicControl(STF.MS.TC.TC22.SEC);
  SecsLogicControl(STF.MS.TC.TC3.SEC);
  if (ShouldRefresh(STF.INTENSITY.val, GetStampOfTag(STF.INTENSITY.tag, 0))>0) then begin
   STF.BA.LA1.Init:=stt_init;
   STF.BA.BS.SEC.Init:=stt_init;
   STF.BA.INJ.SEC.Init:=stt_init;
   STF.BA.BPC.SEC.Init:=stt_init;
   STF.BA.BTC.SEC.Init:=stt_init;
   STF.BA.BTC.TC11.SEC.Init:=stt_init;
   STF.BA.BTC.TC12.SEC.Init:=stt_init;
   STF.BA.BTC.TC13.SEC.Init:=stt_init;
   STF.MS.SEC.Init:=stt_init;
   STF.MS.TC.SEC.Init:=stt_init;
   STF.MS.TC.TC21.SEC.Init:=stt_init;
   STF.MS.TC.TC22.SEC.Init:=stt_init;
   STF.MS.TC.TC3.SEC.Init:=stt_init;
  end;
 end;

 {
 Procedure to show sensor help
 }
 procedure SensorHelp(s:String);
 begin
  if Length(s)>0 then ShowTooltip('guid '+Str(getpid)+'@'+ProgName+' text "'+s+'" preset stdHelp delay 15000 btn1 Справка cmd1 '
                       +AnsiQuotedStr(GetEnv('WantedWebBrowser')+' '+DaqFileRef(ReadIni('[DAQ] HelpFile'), '.htm'), QuoteMark));
 end;

 {
 Menu Particle Starter to start editing
 }
 procedure MenuParticleStarter;
 var n:Integer;
 begin
  if EditStateReady then begin
   //////////////////////////////////////////
   n:=0+EditAddOpening('Тип частицы');
   n:=n+EditAddInputLn('Какие частицы хотите ускорить?');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('p - протоны');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@AssignTag STF.PARTICLE 0'); // FIXIT: Magical number
   //////////////////////////////////////////
   n:=n+EditAddInputLn('n - нейтроны');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@AssignTag STF.PARTICLE 1'); // FIXIT: Magical number 1
   //////////////////////////////////////////
   n:=n+EditAddInputLn('ТЗЧ');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@AssignTag STF.PARTICLE 2'); // FIXIT: Magical number 2
   //////////////////////////////////////////
   n:=n+EditAddInputLn('D (пыль)');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@AssignTag STF.PARTICLE 3'); // FIXIT: Magical number 3
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Опилки');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@AssignTag STF.PARTICLE 4'); // FIXIT: Magical number 4
   //////////////////////////////////////////
   n:=n+EditAddSetting('@set ListBox.Font Size:14\Style:[Bold]');
   n:=n+EditAddSetting(SetFormUnderSensorLeftBottom(ClickParams('')));
   //////////////////////////////////////////
   n:=n+EditAddClosing('MenuList', EditGetUID('MENU_PARTICLE'), Str(iGetTag(STF.PARTICLE.tag)));
   if (n>0) then Problem('Error initializing MenuList!');
  end else Problem('Cannot edit right now!');
 end;

 {
 Menu Particle Handler to handle editing
 }
 procedure MenuParticleHandler;
 begin
  EditMenuDefaultHandler(EditGetUID('MENU_PARTICLE'));
 end;

 {
 Menu Mode Starter to start editing
 }
 procedure MenuModeStarter;
 var n:Integer;
 begin
  if EditStateReady then begin
   //////////////////////////////////////////
   n:=0+EditAddOpening('Режим работы комплекса');
   n:=n+EditAddInputLn('Выберите режим работы:');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Auto - автоматический (не реализован)');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@tooltip text "Этот режим пока не реализован" preset stdNotify delay 15000');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Manual - ручной (не реализован)');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@tooltip text "Этот режим пока не реализован" preset stdNotify delay 15000');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Chaos - хаос (беспорядочное движение частиц по комплексу и не только)');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@AssignTag STF.MODE 2'); // FIXIT: Magical number 2
   //////////////////////////////////////////
   n:=n+EditAddSetting('@set ListBox.Font Size:14\Style:[Bold]');
   n:=n+EditAddSetting(SetFormUnderSensorLeftBottom(ClickParams('')));
   //////////////////////////////////////////
   n:=n+EditAddClosing('MenuList', EditGetUID('MENU_MODE'), Str(iGetTag(STF.MODE.tag)));
   if (n>0) then Problem('Error initializing MenuList!');
  end else Problem('Cannot edit right now!');
 end;

 {
 Menu Mode Handler to handle editing
 }
 procedure MenuModeHandler;
 begin
  EditMenuDefaultHandler(EditGetUID('MENU_MODE'));
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

 //
 // Set new tag value or one in range (min,max)
 //
 procedure UpdateTagEx(tag:Integer; data:String; min,max:Real);
 var v:Real;
 begin
  if IsRefTag(tag) then
  if not IsEmptyStr(data) then begin
   v:=rVal(data);
   if isNan(v) then Trouble('Invalid tag edit') else begin
    if (v<min) then data:=Str(min) else
    if (v>max) then data:=Str(max);
    UpdateTag(tag, data, min, max);
   end;
  end;
 end;

 {
 GUI Handler to process user input...
 }
 procedure GUIHandler;
 var s:String; ClickCurve,i:Integer;

  procedure Cleanup;
  begin
   s:=''; ClickCurve:=0;
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
      s:=mime_encode(SetFormUnderSensorLeftBottom(ClickParams('')));
      if (ClickTag=STF.ENERGY.tag) then DevSendCmdLocal('@Edit '+NameTag(ClickTag)+' '+s);
      if (ClickTag=STF.INTENSITY.tag) then DevSendCmdLocal('@Edit '+NameTag(ClickTag)+' '+s);
     end;
     {
     Handle sensor clicks...
     }
     //
     if IsSameText(ClickSensor, 'STF.BA.BS.BREAK') then begin
      for i:=1 to BsSectNumbers do begin
       bNul(iSetTag(STF.BA.BS.SEC.NUM[i].tag, st_warn));
       bNul(iSetTag(STF.BA.INJ.SEC.NUM[i].tag, st_empty));
       bNul(iSetTag(STF.BA.BPC.SEC.NUM[i].tag, st_empty));
       bNul(iSetTag(STF.BA.BTC.SEC.NUM[i].tag, st_empty));
       bNul(iSetTag(STF.BA.BTC.TC11.SEC.NUM[i].tag, st_empty));
       bNul(iSetTag(STF.BA.BTC.TC12.SEC.NUM[i].tag, st_empty));
       bNul(iSetTag(STF.BA.BTC.TC13.SEC.NUM[i].tag, st_empty));
      end;
      bNul(iSetTag(STF.BA.BS.SEC.NUM[Round(Random(1, BsSectNumbers))].tag, st_error));
      bNul(iSetTag(STF.BA.BS.SEC.NUM[Round(Random(1, BsSectNumbers))].tag, st_error));
      STF.BA.BS.SEC.Init:=st_warn;
      STF.BA.INJ.SEC.Init:=st_warn;
      STF.BA.BPC.SEC.Init:=st_warn;
      STF.BA.BTC.SEC.Init:=st_warn;
      STF.BA.BTC.TC11.SEC.Init:=st_warn;
      STF.BA.BTC.TC12.SEC.Init:=st_warn;
      STF.BA.BTC.TC13.SEC.Init:=st_warn;
     end;
     //
     if IsSameText(ClickSensor, 'STF.BA.BS.HEAL') then begin
      for i:=1 to BsSectNumbers do begin
       bNul(iSetTag(STF.BA.BS.SEC.NUM[i].tag, st_empty));
      end;
      STF.BA.BS.SEC.Init:=stt_init;
      STF.BA.INJ.SEC.Init:=stt_init;
      STF.BA.BPC.SEC.Init:=stt_init;
      STF.BA.BTC.SEC.Init:=stt_init;
      STF.BA.BTC.TC11.SEC.Init:=stt_init;
      STF.BA.BTC.TC12.SEC.Init:=stt_init;
      STF.BA.BTC.TC13.SEC.Init:=stt_init;
     end;
     //
     if IsSameText(ClickSensor, 'STF.MS.BREAK') then begin
      for i:=1 to MsSectNumbers do begin
       bNul(iSetTag(STF.MS.SEC.NUM[i].tag, st_warn));
       bNul(iSetTag(STF.MS.TC.SEC.NUM[i].tag, st_empty));
       bNul(iSetTag(STF.MS.TC.TC21.SEC.NUM[i].tag, st_empty));
       bNul(iSetTag(STF.MS.TC.TC22.SEC.NUM[i].tag, st_empty));
       bNul(iSetTag(STF.MS.TC.TC3.SEC.NUM[i].tag, st_empty));
      end;
      bNul(iSetTag(STF.MS.SEC.NUM[Round(Random(1, MsSectNumbers))].tag, st_error));
      STF.MS.SEC.Init:=st_warn;
      STF.MS.TC.SEC.Init:=st_warn;
      STF.MS.TC.TC21.SEC.Init:=st_warn;
      STF.MS.TC.TC22.SEC.Init:=st_warn;
      STF.MS.TC.TC3.SEC.Init:=st_warn;
     end;
     //
     if IsSameText(ClickSensor, 'STF.MS.HEAL') then begin
      for i:=1 to MsSectNumbers do begin
       bNul(iSetTag(STF.MS.SEC.NUM[i].tag, st_empty));
      end;
      STF.MS.SEC.Init:=stt_init;
      STF.MS.TC.SEC.Init:=stt_init;
      STF.MS.TC.TC21.SEC.Init:=stt_init;
      STF.MS.TC.TC22.SEC.Init:=stt_init;
      STF.MS.TC.TC3.SEC.Init:=stt_init;
     end;
     //
     if IsSameText(ClickSensor, 'STF.ENERGY.UP') then UpdateTagEx(STF.ENERGY.tag, Str(rGetTag(STF.ENERGY.tag)+10), MinEnergy, MaxEnergy);
     if IsSameText(ClickSensor, 'STF.ENERGY.DN') then UpdateTagEx(STF.ENERGY.tag, Str(rGetTag(STF.ENERGY.tag)-10), MinEnergy, MaxEnergy);
     if IsSameText(ClickSensor, 'STF.INTENSITY.UP') then UpdateTagEx(STF.INTENSITY.tag, Str(iGetTag(STF.INTENSITY.tag)+1), MinIntens, MaxIntens);
     if IsSameText(ClickSensor, 'STF.INTENSITY.DN') then UpdateTagEx(STF.INTENSITY.tag, Str(iGetTag(STF.INTENSITY.tag)-1), MinIntens, MaxIntens);
     if IsSameText(ClickSensor, 'STF.PARTICLE') then MenuParticleStarter;
     if IsSameText(ClickSensor, 'STF.MODE') then MenuModeStarter;
     if IsSameText(ClickSensor, 'HELP') then begin
      Cron('@Browse '+DaqFileRef(ReadIni('[DAQ] HelpFile'), '.htm'));
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
     SensorHelp(Url_Decode(ClickParams('Hint')));
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
   SendEditTagCmd(STF.ENERGY.tag, '@AssignTag '+NameTag(STF.ENERGY.tag), MinEnergy, MaxEnergy);
   SendEditTagCmd(STF.INTENSITY.tag, '@AssignTag '+NameTag(STF.INTENSITY.tag), MinIntens, MaxIntens);
   MenuParticleHandler;
   MenuModeHandler;
   {
   Warning,Information
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
    if (tag=STF.PARTICLE.tag) then UpdateTag(tag, w2, 0, MaxInt);
    if (tag=STF.ENERGY.tag) then UpdateTag(tag, w2, MinEnergy, MaxEnergy);
    if (tag=STF.INTENSITY.tag) then UpdateTag(tag, w2, MinIntens, MaxIntens);
    if (tag=STF.MODE.tag) then UpdateTag(tag, w2, MinIntens, MaxIntens);
   end;
  end;
  Cleanup;
 end;

 {
 Clear user application strings...
 }
 procedure ClearApplication;
 begin
 end;

 {}
 procedure TStfRecInit(var REC:TStfRec; tagPrefix:String);
 begin
  InitTag(REC.PARTICLE.tag, tagPrefix+'.PARTICLE', 1);
  InitTag(REC.ENERGY.tag, tagPrefix+'.ENERGY', 2);
  InitTag(REC.INTENSITY.tag, tagPrefix+'.INTENSITY', 1);
  InitTag(REC.MODE.tag, tagPrefix+'.MODE', 1);
 end;

 {
 Initialize STF record tags
 }
 procedure StfTagsInit(var Rec:TStfRec; tagPrefix:String);
 begin
  tagPrefix:=Trim(tagPrefix);
  if not IsEmptyStr(tagPrefix) then begin
   TStfRecInit(Rec, tagPrefix);
   TLa1RecInit(Rec.BA.LA1, tagPrefix);
   TInjRecInit(Rec.BA.INJ, tagPrefix);
   TBsRecInit(Rec.BA.BS, tagPrefix);
   TBpcRecInit(Rec.BA.BPC, tagPrefix);
   TMsRecInit(Rec.MS, tagPrefix);
   TMsTcRecInit(Rec.MS.TC, tagPrefix);
   TMsTc21RecInit(Rec.MS.TC.TC21, tagPrefix);
   TMsTc22RecInit(Rec.MS.TC.TC22, tagPrefix);
   TMsTc3RecInit(Rec.MS.TC.TC3, tagPrefix);
   TBtcRecInit(Rec.BA.BTC, tagPrefix);
   TBtcTcxRecInit(Rec.BA.BTC, tagPrefix);
  end else Trouble('Tags initialization error. Prefix not specified!');
 end;

 {
 DAQ program data initialization...
 }
 procedure StfMainInit;
 begin
  //
  // Initialize tags & devices
  //
  StfTagsInit(STF, ReadIni('TagPrefix'));
  //
  // Initialize timers & values
  //
  bNul(iSetTag(STF.PARTICLE.tag, 0));
  bNul(rSetTag(STF.ENERGY.tag, 10));
  bNul(iSetTag(STF.INTENSITY.tag, 3));
  STF.IntenLength:=1;
  //
  StfBaRecInit;
  StfMsRecInit;
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
  StfMainInit;
  cmd_Edit:=RegisterStdInCmd('@Edit', '');
  cmd_AssignTag:=RegisterStdInCmd('@AssignTag', '');
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
  STF.IntenLength:=iGetTag(STF.INTENSITY.tag);
  STF.EnergyValue:=Round(50-(rGetTag(STF.ENERGY.tag)/3)); // FIXIT: Magical numbers
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
   if (cmdid=cmd_Edit) then begin
    par:=mime_decode(ExtractWord(2, arg));
    s:=ExtractWord(1, arg);
    tag:=FindTag(s);
    if (Pos('ENERGY', s)>0) then StartEditTagEx(tag, 'Введите энергию пучка, МэВ/нуклон', par);
    if (Pos('INTENSITY', s)>0) then StartEditTagEx(tag, 'Введите интенсивность, част/импульс', par);
    Data:='';
   end else
   {
   @AssignTag t v - Assign tag t (tag name) to value v
   @AssignTag STF.PARTICLE 1 - Set particle type to 0
   }
   if (cmdid=cmd_AssignTag) then begin
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
