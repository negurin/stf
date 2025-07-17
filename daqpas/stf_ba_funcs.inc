///////////////////////////////////////////////////////////////////// STF BA funcs:
 {}
 procedure La1LogicControl;
  function IsValidIndex(i:Integer):Boolean;
  begin
   if ((i>0) and (i<=LA1SectNumbers)) then IsValidIndex:=true else IsValidIndex:=false;
  end;

  //
  procedure InitRunning(var rec:TLa1Rec);
  begin
   if IsValidIndex(rec.head) then bNul(iSetTag(rec.SECN[rec.head].tag, 1));
   if (rec.head>1) then begin
    rec.body:=rec.head-1;
    if IsValidIndex(rec.BODY) then bNul(iSetTag(rec.SECN[rec.body].tag, 2));
   end;
   if (rec.body>STF.IntenLength) then begin
    rec.tile:=rec.body-STF.IntenLength;
    if IsValidIndex(rec.TILE) then bNul(iSetTag(rec.SECN[rec.tile].tag, 3));
   end;
   if (rec.tile>1) then begin
    rec.pipe:=rec.tile-1;
    if IsValidIndex(rec.PIPE) then bNul(iSetTag(rec.SECN[rec.pipe].tag, 4));
   end;
   rec.head:=rec.head+1;
   if (rec.head>LA1SectNumbers) then begin
    rec.head:=1;
    rec.body:=rec.body+1;
    rec.tile:=rec.tile+1;
    rec.pipe:=rec.pipe+1;
    rec.Init:=0;
   end;
  end;

  //
  procedure PollRunning(var rec:TLa1Rec);
  begin
   if IsValidIndex(rec.head) then bNul(iSetTag(rec.SECN[rec.head].tag, 1));
   if IsValidIndex(rec.body) then bNul(iSetTag(rec.SECN[rec.body].tag, 2));
   if IsValidIndex(rec.tile) then bNul(iSetTag(rec.SECN[rec.tile].tag, 3));
   if IsValidIndex(rec.pipe) then bNul(iSetTag(rec.SECN[rec.pipe].tag, 4));
   rec.head:=rec.head+1;
   rec.body:=rec.body+1;
   rec.tile:=rec.tile+1;
   rec.pipe:=rec.pipe+1;
   if (rec.head>LA1SectNumbers) then rec.head:=1;
   if (rec.body>LA1SectNumbers) then rec.body:=1;
   if (rec.tile>LA1SectNumbers) then rec.tile:=1;
   if (rec.pipe>LA1SectNumbers) then rec.pipe:=1;
  end;

 begin
  if (SysTimer_Pulse(STF.EnergyValue)>0) then begin
   if (STF.BA.LA1.Init=stt_init)
   then InitRunning(STF.BA.LA1)
   else if (STF.BA.LA1.Init=stt_poll)
   then PollRunning(STF.BA.LA1);
  end;
 end;


 {}
 procedure TLa1RecInit(var Rec:TLa1Rec; tagPrefix:String);
 var i:Integer;
 begin
  for i:=1 to LA1SectNumbers do begin
   InitTag(Rec.SECN[i].tag, tagPrefix+'.BA.LA1.SEC'+Str(i), 1);
  end;
 end;

 {}
 procedure TInjRecInit(var Rec:TInjRec; tagPrefix:String);
 var i:Integer;
 begin
  for i:=1 to INJSectNumbers do begin
   InitTag(Rec.SEC.NUM[i].tag, tagPrefix+'.BA.INJ.SEC'+Str(i), 1);
  end;
 end;

 {}
 procedure TBsRecInit(var Rec:TBsRec; tagPrefix:String);
 var i:Integer;
 begin
  for i:=1 to BsSectNumbers do begin
   InitTag(Rec.SEC.NUM[i].tag, tagPrefix+'.BA.BS.SEC'+Str(i), 1);
  end;
 end;

 {}
 procedure TBpcRecInit(var Rec:TBpcRec; tagPrefix:String);
 var i:Integer;
 begin
  for i:=1 to BpcSectNumbers do begin
   InitTag(Rec.SEC.NUM[i].tag, tagPrefix+'.BA.BPC.SEC'+Str(i), 1);
  end;
 end;

 {}
 procedure TBtcRecInit(var Rec:TBtcRec; tagPrefix:String);
 var i:Integer;
 begin
  for i:=1 to BtcSectNumbers do begin
   InitTag(Rec.SEC.NUM[i].tag, tagPrefix+'.BA.BTC.SEC'+Str(i), 1);
  end;
 end;

 {}
 procedure TBtcTcxRecInit(var Rec:TBtcRec; tagPrefix:String);
 var i:Integer;
 begin
  for i:=1 to BtcTcxSectNumbers do begin
   InitTag(Rec.TC11.SEC.NUM[i].tag, tagPrefix+'.BA.BTC.TC11.SEC'+Str(i), 1);
   InitTag(Rec.TC12.SEC.NUM[i].tag, tagPrefix+'.BA.BTC.TC12.SEC'+Str(i), 1);
   InitTag(Rec.TC13.SEC.NUM[i].tag, tagPrefix+'.BA.BTC.TC13.SEC'+Str(i), 1);
  end;
 end;


 procedure StfBaRecInit;
 begin
  STF.BA.LA1.head:=1; // FIXIT: Magical numbers...
  STF.BA.LA1.body:=0;
  STF.BA.LA1.tile:=0;
  STF.BA.LA1.pipe:=0;
  STF.BA.LA1.Init:=1;
  //
  STF.BA.INJ.SEC.head:=1; // FIXIT: Magical numbers...
  STF.BA.INJ.SEC.tile:=0;
  STF.BA.INJ.SEC.Init:=1;
  STF.BA.INJ.SEC.Secs:=InjSectNumbers;
  //
  STF.BA.BS.SEC.head:=1;
  STF.BA.BS.SEC.tile:=0;
  STF.BA.BS.SEC.Init:=1;
  STF.BA.BS.SEC.Secs:=BsSectNumbers;
  //
  STF.BA.BPC.SEC.head:=1;
  STF.BA.BPC.SEC.tile:=0;
  STF.BA.BPC.SEC.Init:=1;
  STF.BA.BPC.SEC.Secs:=BpcSectNumbers;
  //
  STF.BA.BTC.SEC.head:=1;
  STF.BA.BTC.SEC.tile:=0;
  STF.BA.BTC.SEC.Init:=1;
  STF.BA.BTC.SEC.Secs:=BtcSectNumbers;
  //
  STF.BA.BTC.TC11.SEC.head:=1;
  STF.BA.BTC.TC11.SEC.tile:=0;
  STF.BA.BTC.TC11.SEC.Init:=1;
  STF.BA.BTC.TC11.SEC.Secs:=BtcTcxSectNumbers;
  //
  STF.BA.BTC.TC12.SEC.head:=1;
  STF.BA.BTC.TC12.SEC.tile:=0;
  STF.BA.BTC.TC12.SEC.Init:=1;
  STF.BA.BTC.TC12.SEC.Secs:=BtcTcxSectNumbers;
  //
  STF.BA.BTC.TC13.SEC.head:=1;
  STF.BA.BTC.TC13.SEC.tile:=0;
  STF.BA.BTC.TC13.SEC.Init:=1;
  STF.BA.BTC.TC13.SEC.Secs:=BtcTcxSectNumbers;
 end;
