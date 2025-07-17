///////////////////////////////////////////////////////////////////// STF MS funcs:
 {}
 procedure TMsRecInit(var REC:TMsRec; tagPrefix:String);
 var i:Integer;
 begin
  for i:=1 to MsSectNumbers do begin
   InitTag(REC.SEC.NUM[i].tag, tagPrefix+'.MS.SEC'+Str(i), 1);
  end;
 end;

 {}
 procedure TMsTcRecInit(var REC:TMsTcRec; tagPrefix:String);
 var i:Integer;
 begin
  for i:=1 to MsTcSectNumbers do begin
   InitTag(REC.SEC.NUM[i].tag, tagPrefix+'.MS.TC.SEC'+Str(i), 1);
  end;
 end;

 {}
 procedure TMsTc21RecInit(var REC:TMsTcxRec; tagPrefix:String);
 var i:Integer;
 begin
  for i:=1 to MsTc2SectNumbers do begin
   InitTag(REC.SEC.NUM[i].tag, tagPrefix+'.MS.TC.TC21.SEC'+Str(i), 1);
  end;
 end;

 {}
 procedure TMsTc22RecInit(var REC:TMsTcxRec; tagPrefix:String);
 var i:Integer;
 begin
  for i:=1 to MsTc2SectNumbers do begin
   InitTag(REC.SEC.NUM[i].tag, tagPrefix+'.MS.TC.TC22.SEC'+Str(i), 1);
  end;
 end;

 {}
 procedure TMsTc3RecInit(var REC:TMsTcxRec; tagPrefix:String);
 var i:Integer;
 begin
  for i:=1 to MsTc3SectNumbers do begin
   InitTag(REC.SEC.NUM[i].tag, tagPrefix+'.MS.TC.TC3.SEC'+Str(i), 1);
  end;
 end;

 {}
 procedure StfMsRecInit;
 begin
  STF.MS.SEC.head:=1; // FIXIT: Magical numbers...
  STF.MS.SEC.tile:=0;
  STF.MS.SEC.Init:=1;
  STF.MS.SEC.Secs:=MsSectNumbers;
  //
  STF.MS.TC.SEC.head:=1;
  STF.MS.TC.SEC.tile:=0;
  STF.MS.TC.SEC.Init:=1;
  STF.MS.TC.SEC.Secs:=MsTcSectNumbers;
  //
  STF.MS.TC.TC21.SEC.head:=1;
  STF.MS.TC.TC21.SEC.tile:=0;
  STF.MS.TC.TC21.SEC.Init:=1;
  STF.MS.TC.TC21.SEC.Secs:=MsTc2SectNumbers;
  //
  STF.MS.TC.TC22.SEC.head:=1;
  STF.MS.TC.TC22.SEC.tile:=0;
  STF.MS.TC.TC22.SEC.Init:=1;
  STF.MS.TC.TC22.SEC.Secs:=MsTc2SectNumbers;
  //
  STF.MS.TC.TC3.SEC.head:=1;
  STF.MS.TC.TC3.SEC.tile:=0;
  STF.MS.TC.TC3.SEC.Init:=1;
  STF.MS.TC.TC3.SEC.Secs:=MsTc3SectNumbers;
 end;
