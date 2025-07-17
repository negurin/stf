///////////////////////////////////////////////////////////////////// STF MS types:
 TMsTcxRec = record              {                                  }
  SEC : TSecRec;                 {                                  }
 end;                            {                                  }
                                 {                                  }
 TMsTcRec = record               {                                  }
  SEC : TSecRec;                 {                                  }
  TC21 : TMsTcxRec;              {                                  }
  TC22 : TMsTcxRec;              {                                  }
  TC3 : TMsTcxRec;               {                                  }
 end;                            {                                  }
                                 {                                  }
/////////////////////////////////////////////////////////////////////
 TMsRec = record                 { All Main synchrotron data:       }
  SEC : TSecRec;                 {                                  }
  TC : TMsTcRec;                 {                                  }
 end;                            {                                  }
/////////////////////////////////////////////////////////////////////
