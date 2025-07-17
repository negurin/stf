 {
 ***********************************************************************
 STF main control program
 ***********************************************************************
 Next text uses by @Help command. Do not remove it.
 ***********************************************************************
[@Help]
|StdIn Command list: "@cmd=arg" or "@cmd arg"
|********************************************************
| @MenuToolsOpen - open Menu Tools dialog.
| @MenuConsolesOpen - open consoles menu.
| @MenuEditProgramOpen - open edit program menu.
| @MenuDeviceRestartOpen - open device restart menu.
|********************************************************
[]
 }
program stf_main_ctrl;          { Main control program             }
const
 {------------------------------}{ Declare uses program constants:  }
 {$I _con_StdLibrary}            { Include all Standard constants,  }
 {------------------------------}{ And add User defined constants:  }
 SmilePeriod = 1000;             { Polling period for smile face    }
 AwakePeriod = 100;              { Period of checks to awake DatSrv }

type
 {------------------------------}{ Declare uses program types:      }
 {$I _typ_StdLibrary}            { Include all Standard types,      }
 {------------------------------}{ And add User defined types:      }
 TSTFMainRec = record           { Main control & GUI               }
  CMD    : record                { Commands to control GUI          }
   OPEN  : TTagRef;              { Open DAT file(s)                 }
   SAVE  : TTagRef;              { Save DAT file(s)                 }
   SOUND : TTagRef;              { Sound menu                       }
   SMILE : TTagRef;              { Smile menu                       }
   CLOSE : TTagRef;              { Close DAQ/CRW/WIN                }
  end;                           {                                  }
 end;                            {                                  }

var
 {------------------------------}{ Declare uses program variables:  }
 {$I _var_StdLibrary}            { Include all Standard variables,  }
 {------------------------------}{ And add User defined variables:  }
 STF        : record            { All STF data                    }
  MAIN       : TSTFMainRec;     { Main control & GUI               }
  AwokeTime  : Real;             { Time when DatSrv last awoke      }
  DatSrvGate : TTagRef;          { Save data to DatSrv              }
 end;                            {                                  }
 cmd_MenuToolsOpen : Integer;    { @MenuToolsOpen                   }
 cmd_MenuConsolesOpen : Integer; { @MenuConsolesOpen                }
 cmd_MenuEditProgramOpen : Integer; { @MenuEditProgramOpen          }
 cmd_MenuDeviceRestartOpen : Integer; { @MenuDeviceRestartOpen      }

 {------------------------------}{ Declare procedures & functions:  }
 {$I _fun_StdLibrary}            { Include all Standard functions,  }
 {------------------------------}{ And add User defined functions:  }
 {$I _fun_StdMenuTools}          { Standard Menu Tools  functions,  }

 {
 Xor bit on click (local version)
 }
 procedure ClickBitXorLocal(tag,XorMask:Integer);
 begin
  if ClickTag=tag then begin
   bNul(iSetTagXor(tag,XorMask));
   bNul(Voice(snd_Click));
  end;
 end;
 {
 Initilize STF.MAIN record tags
 }
 procedure TSTFMainRec_Init(var Rec:TSTFMainRec; TagPrefix:String);
 begin
  TagPrefix:=Trim(TagPrefix);
  if not IsEmptyStr(TagPrefix) then begin
   InitTag(Rec.CMD.OPEN.tag,  TagPrefix+'.CMD.OPEN',  1);
   InitTag(Rec.CMD.SAVE.tag,  TagPrefix+'.CMD.SAVE',  1);
   InitTag(Rec.CMD.SOUND.tag, TagPrefix+'.CMD.SOUND', 1);
   InitTag(Rec.CMD.SMILE.tag, TagPrefix+'.CMD.SMILE', 1);
   InitTag(Rec.CMD.CLOSE.tag, TagPrefix+'.CMD.CLOSE', 1);
   Rec.CMD.SMILE.val:=GetErrCount(-2);
  end else Trouble('Tags initialization error. Prefix not specified!');
 end;
 {
 Procedure to show sensor help
 }
 procedure SensorHelp(s:String);
 begin
  StdSensorHelpTooltip(s,15000);
 end;
 {
 Menu CLOSE Starter to start editing
 }
 procedure MenuCloseStarter;
 var i,n:Integer; OS:String;
  procedure Cleanup;
  begin
   OS:='';
  end;
 begin
  Cleanup;
  if IsWindows then OS:='Windows' else
  if IsLinux   then OS:='Linux';
  if EditStateReady then begin
   //////////////////////////////////////////
   n:=0+EditAddOpening('Меню выхода ');
   n:=n+EditAddInputLn('Выберите, что вы хотите сделать:');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Продолжить работу текущего сеанса АСУ');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@tooltip text "Желаю успешной работы" preset stdSuccess delay 15000');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Завершить сеанс АСУ и закрыть программу');
   n:=n+EditAddConfirm(EditGetLastInputLn);
   n:=n+EditAddCommand('@Cron @Shutdown Crw Exit');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Завершить сеанс АСУ и продолжить работу');
   n:=n+EditAddConfirm(EditGetLastInputLn);
   n:=n+EditAddCommand('@Cron @Shutdown Daq Exit');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Перезагрузить сеанс АСУ и начать заново');
   n:=n+EditAddConfirm(EditGetLastInputLn);
   n:=n+EditAddCommand('@Cron @Shutdown Daq Restart');
   //////////////////////////////////////////
   for i:=1 to WordCount(EditGetWellKnownDevices(DevName)) do
   if (RefFind('device '+ExtractWord(i,EditGetWellKnownDevices(DevName)))<>0) then begin
    n:=n+EditAddInputLn('Перезапустить сервер '+ExtractWord(i,EditGetWellKnownDevices(DevName)));
    n:=n+EditAddConfirm(EditGetLastInputLn);
    n:=n+EditAddCommand('@SysEval @Daq Compile '+ExtractWord(i,EditGetWellKnownDevices(DevName)));
   end;
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Завершить сеанс '+OS);
   n:=n+EditAddConfirm(EditGetLastInputLn);
   n:=n+EditAddCommand('@Cron @Shutdown Win Logout');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Перезагрузить компьютер');
   n:=n+EditAddConfirm(EditGetLastInputLn);
   n:=n+EditAddCommand('@Cron @Shutdown Win Restart');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Выключить компьютер');
   n:=n+EditAddConfirm(EditGetLastInputLn);
   n:=n+EditAddCommand('@Cron @Shutdown Win Exit');
   //////////////////////////////////////////
   n:=n+EditAddSetting('@set ListBox.Font Size:14\Style:[Bold]');
   n:=n+EditAddSetting('@set Form.Left 530 relative '+Copy(DevName,2)+' PaintBox');
   n:=n+EditAddSetting('@set Form.Top  0   relative '+Copy(DevName,2)+' PaintBox');
   //////////////////////////////////////////
   n:=n+EditAddClosing('MenuList',EditGetUID('MENU_CLOSE'),'');
   if (n>0) then Problem('Error initializing MenuList!');
  end else Problem('Cannot edit right now!');
  Cleanup;
 end;
 {
 Menu CLOSE Handler to handle editing
 }
 procedure MenuCloseHandler;
 begin
  EditMenuDefaultHandler(EditGetUID('MENU_CLOSE'));
 end;
 {
 Menu TOOLS Starter to start editing
 }
 procedure MenuToolsStarter;
 var n:Integer;
 begin
  if EditStateReady then begin
   //////////////////////////////////////////
   n:=0+EditAddOpening('Меню инструментов ');
   n:=n+EditAddInputLn('Выберите, что вы хотите сделать:');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Посмотреть справочную информацию (help)');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@BrowseHelp');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Загрузить параметры из ini-файла');
   n:=n+EditAddConfirm(EditGetLastInputLn);
   n:=n+EditAddCommand('@LoadIni');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Сохранить параметры в  ini-файле');
   n:=n+EditAddConfirm(EditGetLastInputLn);
   n:=n+EditAddCommand('@SaveIni');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Открыть Консольное Окно …');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@MenuConsolesOpen');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Отредактировать Программу …');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@MenuEditProgramOpen');
   //////////////////////////////////////////
   n:=n+EditAddInputLn('Перезапустить Устройство …');
   n:=n+EditAddConfirm('');
   n:=n+EditAddCommand('@MenuDeviceRestartOpen');
   //////////////////////////////////////////
   n:=n+EditAddSetting('@set ListBox.Font Size:14\Style:[Bold]');
   n:=n+EditAddSetting('@set Form.Left 375 relative '+Copy(DevName,2)+' PaintBox');
   n:=n+EditAddSetting('@set Form.Top  0   relative '+Copy(DevName,2)+' PaintBox');
   //////////////////////////////////////////
   n:=n+EditAddClosing('MenuList',EditGetUID('MENU_TOOLS'),'');
   if (n>0) then Problem('Error initializing MenuList!');
  end else Problem('Cannot edit right now!');
 end;
 {
 Menu TOOLS Handler to handle editing
 }
 procedure MenuToolsHandler;
 begin
  EditMenuDefaultHandler(EditGetUID('MENU_TOOLS'));
 end;
 {
 Awake DatSrv to enforce data save
 }
 procedure AwakeDatSrv;
 begin
  STF.AwokeTime:=mSecNow;
  DevPostCmd(devDatSrv,'  ');
 end;
 {
 STF clear strings
 }
 procedure STF_CLEAR;
 begin
 end;
 {
 STF initialization
 }
 procedure STF_INIT;
 begin
  //
  // Initialize tags & devices
  //
  TSTFMainRec_Init(STF.MAIN,ReadIni('tagPrefix')+'.MAIN');
  InitTag(STF.DatSrvGate.tag,'DATSRV.GATE',-1);
  //
  // Initialize values
  //
  STF.AwokeTime:=0;
 end;
 {
 STF finalization
 }
 procedure STF_FREE;
 begin
 end;
 {
 STF polling
 }
 procedure STF_POLL;
 var s:String; ClickCurve:Integer; nerrors:Real;
  procedure Cleanup;
  begin
   s:=''; ClickCurve:=0;
  end;
 begin
  Cleanup;
  {
  Awake DatSrv to enforce data save
  }
  if (SysTimer_Pulse(AwakePeriod)>0) then bNul(iSetTag(STF.DatSrvGate.tag,Ord(iGetTag(STF.MAIN.CMD.SAVE.tag)<>0)));
  {
  Execute GUI commands
  }
  if (iGetTag(STF.MAIN.CMD.OPEN.tag)<>0) then begin
   Cron('@FileOpenDialog '+URL_Packed(AddBackSlash(DaqFileRef(ReadIni('['+DatSrv+'] DataPath'),''))+'*.DAT;*.CRW'));
   bNul(iSetTag(STF.MAIN.CMD.OPEN.tag,0));
  end;
  if (iGetTag(STF.MAIN.CMD.CLOSE.tag)<>0) then begin
   bNul(iSetTag(STF.MAIN.CMD.CLOSE.tag,0));
   MenuCloseStarter;
  end;
  {
  Handle Smile button state
  }
  if (SysTimer_Pulse(SmilePeriod)>0) then begin
   nerrors:=GetErrCount(-2);
   if nerrors>STF.MAIN.CMD.SMILE.val then bNul(iSetTag(STF.MAIN.CMD.SMILE.tag,2)) else
   if iGetTag(STF.MAIN.CMD.SMILE.tag)>1 then bNul(iSetTag(STF.MAIN.CMD.SMILE.tag,1));
   STF.MAIN.CMD.SMILE.val:=nerrors;
  end;
  {
  Handle user mouse/keyboard clicks
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
     //
     // Toolbar buttons
     //
     ClickBitXorLocal(STF.MAIN.CMD.OPEN.tag,1);
     ClickBitXorLocal(STF.MAIN.CMD.SAVE.tag,1);
     ClickBitXorLocal(STF.MAIN.CMD.SOUND.tag,1);
     ClickBitXorLocal(STF.MAIN.CMD.CLOSE.tag,1);
     if (ClickTag=STF.MAIN.CMD.SAVE.tag) then begin
      bNul(iSetTag(STF.DatSrvGate.tag,Ord(iGetTag(STF.MAIN.CMD.SAVE.tag)<>0)));
      if iGetTag(STF.MAIN.CMD.SAVE.tag)<>0 then AwakeDatSrv;
     end;
     if IsSameText(ClickSensor,'STF.MAIN.CMD.HOME') then begin
      DevPostCmdLocal('@Cron @Cron.Run STF.MAIN.CTRL.HOME');
      bNul(Voice(snd_Click));
     end;
     if IsSameText(ClickSensor,'STF.MAIN.CMD.HELP') then begin
      DevPostCmdLocal('@BrowseHelp');
      bNul(Voice(snd_Click));
     end;
     if IsSameText(ClickSensor,'STF.MAIN.CMD.TOOLS') then begin
      DevPostCmdLocal('@MenuToolsOpen');
      bNul(Voice(snd_Click));
     end;
     //
     // Smile face button
     //
     if (ClickTag=STF.MAIN.CMD.SMILE.tag) then begin
      bNul(Eval('@System @Async @Menu run FormDaqControlDialog.ActionDaqStatus')>0);
      bNul(iSetTag(STF.MAIN.CMD.SMILE.tag,0));
      bNul(Voice(snd_Click));
     end;
     //
     // Select Plot & Tab windows by curve
     //
     ClickCurve:=RefFind('Curve '+ClickParams('Curve'));
     if IsRefCurve(ClickCurve) then begin
      iNul(WinSelectByCurve(ClickCurve,ClickCurve));
      bNul(Voice(snd_Wheel));
     end;
     //
     // Console commands: @url_encoded_sensor
     //
     if LooksLikeCommand(ClickSensor) then begin
      DevSendCmdLocal(url_decode(ClickSensor));
      bNul(Voice(snd_Click));
     end;
     //
     // Calibrations
     //
     if IsSameText(ExtractFileExt(ClickSensor),'.CAL') then begin
      bNul(CalibrOpenByCurve(RefFind('Curve '+ExtractFileName(ClickSensor))));
      bNul(Voice(snd_Click));
     end;
    end;
    {
    Handle Right mouse button click
    }
    if (ClickButton=VK_RBUTTON) then begin
     SensorHelp(Url_Decode(ClickParams('Hint')));
    end;
   end;
  until (ClickRead=0);
  {
  Edit handling...
  }
  if EditStateDone then begin
   {
   Menu CLOSE
   }
   MenuCloseHandler;
   {
   Menu TOOLS
   }
   MenuToolsHandler;
   {
   Menu CONSOLES
   }
   MenuConsolesHandler;
   {
   Menu EDITPROGRAM
   }
   MenuEditProgramHandler;
   {
   Menu DEVICERESTART
   }
   MenuDeviceRestartHandler;
   {
   {
   Warning, Information dialog completion
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
 Clear user application strings
 }
 procedure ClearApplication;
 begin
  STF_CLEAR;
 end;
 {
 User application Initialization
 }
 procedure InitApplication;
 begin
  StdIn_SetScripts('','');
  StdIn_SetTimeouts(0,0,0,MaxInt);
  iNul(ClickFilter(ClickFilter(1)));
  iNul(ClickAwaker(ClickAwaker(1)));
  STF_INIT;
  if Val(ReadIni('CustomIniAutoLoad'))=1 then DevPostCmdLocal('@LoadIni');
  cmd_MenuToolsOpen:=RegisterStdInCmd('@MenuToolsOpen','');
  cmd_MenuConsolesOpen:=RegisterStdInCmd('@MenuConsolesOpen','');
  cmd_MenuEditProgramOpen:=RegisterStdInCmd('@MenuEditProgramOpen','');
  cmd_MenuDeviceRestartOpen:=RegisterStdInCmd('@MenuDeviceRestartOpen','');
 end;
 {
 User application Finalization
 }
 procedure FreeApplication;
 begin
  if Val(ReadIni('CustomIniAutoSave'))=1 then DevPostCmdLocal('@SaveIni');
  STF_FREE;
 end;
 {
 User application Polling
 }
 procedure PollApplication;
 begin
  STF_POLL;
 end;
 {
 Process data coming from standard input
 }
 procedure StdIn_Processor(var Data:String);
 var cmd,arg:String; cmdid:Integer;
  procedure Cleanup;
  begin
   cmd:=''; arg:='';
  end;
 begin
  Cleanup;
  ViewImp('CON: '+Data);
  {
  Handle "@cmd=arg" or "@cmd arg" commands:
  }
  if GotCommandId(Data,cmd,arg,cmdid) then begin
   {
   @MenuToolsOpen
   }
   if (cmdid=cmd_MenuToolsOpen) then begin
    MenuToolsStarter;
    Data:='';
   end else
   {
   @MenuConsolesOpen
   }
   if (cmdid=cmd_MenuConsolesOpen) then begin
    MenuConsolesStarter;
    Data:='';
   end else
   {
   @MenuEditProgramOpen
   }
   if (cmdid=cmd_MenuEditProgramOpen) then begin
    if HasUserAccessLevelTip('root',cmd,7,7000) then MenuEditProgramStarter;
    Data:='';
   end else
   {
   @MenuDeviceRestartOpen
   }
   if (cmdid=cmd_MenuDeviceRestartOpen) then begin 
    if HasUserAccessLevelTip('root',cmd,7,7000) then MenuDeviceRestartStarter;
    Data:='';
   end else
   {
   Handle other commands by default handler
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
