///////////////////////////////////////////////////////////////////// STF BA types:
 TButtonRec = record BT:TTagRef; end;                              // Button
 TStatusRec = record ST:TTagRef; end;                              // Status
 TButStaRec = record BT,ST:TTagRef; end;                           // Button and status
 TPowerRec  = record BT,PW:TTagRef; end;                           // Button and power
 TBtStPwRec = record BT,ST,PW:TTagRef; end;                        // Button,status and power
 TCtlRec = record head,tile,Init,Secs:Integer; end;                // Control head, tile, init and sections number
 TSecRec = record                                                  //
  NUM : array [1..MaxSecsNumber] of TTagRef;                       //
  head,tile,Init,Secs:Integer;                                     //
 end;                                                              //
/////////////////////////////////////////////////////////////////////
 TLa1Rec = record                { All LA1 data:                    }
  SECN : array [1..La1SectNumbers] of TTagRef;
  head : Integer;
  body : Integer;
  tile : Integer;
  pipe : Integer;
  Init : Integer;
 end;

 TTcRec = record
  SEC : TSecRec;                 {                                  }
 end;

 TInjRec = record
  SEC : TSecRec;                 {                                  }
 end;

 TBsRec = record
  SEC : TSecRec;                 {                                  }
 end;

 TBpcRec = record
  SEC : TSecRec;                 {                                  }
 end;

 TBtcRec = record
  SEC : TSecRec;                 {                                  }
  TC11 : TTcRec;
  TC12 : TTcRec;
  TC13 : TTcRec;
 end;

/////////////////////////////////////////////////////////////////////
 TBaRec = record                 { All Booster accelerator data:    }
  LA1 : TLa1Rec;                 {  Linear accelerator              }
  INJ : TInjRec;                 {  Injection channel               }
  BS : TBsRec;                   {  Booster synchrotron             }
  BPC : TBpcRec;                 {  Bypass channel                  }
  BTC : TBtcRec;                 {  Beam transport channel          }
 end;                            {                                  }
/////////////////////////////////////////////////////////////////////
