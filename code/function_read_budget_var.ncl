;;process  = (/"Dycore",   "DeepCu",   "MG2",    "CLUBB",          "Radiation"/)

 if(mvarnam.eq."T") then

  if(process(ii).eq."Radiation") then

     varnam1   = "QRL"
     varnam2   = "QRS"
     tmp1      = f1->$varnam1$
     tmp1      = f1->$varnam1$ + f1->$varnam2$

   else if (process(ii).eq."CLUBB") then

     varnam1   = "TTEND_CLUBB"
     varnam2   = "STEND_CLUBB" 

     if (isfilevar(f1, varnam1)) then
       tmp1      = f1->$varnam1$
     else if (isfilevar(f1, varnam2)) then
       tmp1      = f1->$varnam2$
       tmp1      = tmp1 / cpair
     else
       tmp1      = f1->T
       tmp1@_FillValue = -9999
       tmp1      = tmp1@_FillValue
     end if
     end if 
  
   else if (process(ii).eq."MG2") then
 
     varnam1   = "MPDT"
     tmp1      = f1->$varnam1$
     tmp1      = tmp1 / cpair
  
   else if (process(ii).eq."DeepCu") then

     varnam1   = "ZMDT"
     tmp1      = f1->$varnam1$
      
   else if (process(ii).eq."Dycore") then
     varnam1   = "DTCORE"
     tmp1      = f1->$varnam1$

   else

     print("The processes does not exist, please check share_info_for_budget_var.ncl ")
     exit

  end if 
  end if 
  end if 
  end if 
  end if 

else if(mvarnam.eq."Q") then

  if(process(ii).eq."Radiation") then

   varnam1   = "T"
   tmp1      = f1->$varnam1$
   tmp1@_FillValue = -9999
   tmp1      = tmp1@_FillValue

  else if (process(ii).eq."CLUBB") then

   varnam1   = "RVMTEND_CLUBB"
   tmp1      = f1->$varnam1$

  else if (process(ii).eq."MG2") then

   varnam1   = "MPDQ"
   tmp1      = f1->$varnam1$

  else if (process(ii).eq."DeepCu") then

   varnam1   = "ZMDQ"
   tmp1      = f1->$varnam1$

  else if (process(ii).eq."Dycore") then

   varnam1   = "RVMTEND_CLUBB"
   varnam2   = "MPDQ"
   varnam3   = "ZMDQ"
   tmp1      = f1->$varnam1$
   tmp1      = f1->$varnam1$ + f1->$varnam2$ + f1->$varnam3$
 
  else

   print("The processes does not exist, please check share_info_for_budget_var.ncl ")
   exit

  end if
  end if
  end if
  end if
  end if

else if(mvarnam.eq."CLDLIQ") then

  if(process(ii).eq."Radiation") then

   varnam1   = "T"
   tmp1      = f1->$varnam1$
   tmp1@_FillValue = -9999
   tmp1      = tmp1@_FillValue

  else if (process(ii).eq."CLUBB") then

   varnam1   = "RCMTEND_CLUBB"
   tmp1      = f1->$varnam1$

  else if (process(ii).eq."MG2") then

   varnam1   = "MPDLIQ"
   tmp1      = f1->$varnam1$

  else if (process(ii).eq."DeepCu") then

   varnam1   = "ZMDLIQ"
   tmp1      = f1->$varnam1$

  else if (process(ii).eq."Dycore") then

   varnam1   = "T"
   tmp1      = f1->$varnam1$
   tmp1@_FillValue = -9999
   tmp1      = tmp1@_FillValue

  else

   print("The processes does not exist, please check share_info_for_budget_var.ncl ")
   exit
  
  end if
  end if
  end if
  end if
  end if

else if(mvarnam.eq."CLDICE") then

  if(process(ii).eq."Radiation") then

   varnam1   = "T"
   tmp1      = f1->$varnam1$
   tmp1@_FillValue = -9999
   tmp1      = tmp1@_FillValue

  else if (process(ii).eq."CLUBB") then

   varnam1   = "RIMTEND_CLUBB"
   tmp1      = f1->$varnam1$

  else if (process(ii).eq."MG2") then

   varnam1   = "MPDICE"
   tmp1      = f1->$varnam1$

  else if (process(ii).eq."DeepCu") then

   varnam1   = "ZMDICE"
   tmp1      = f1->$varnam1$

  else if (process(ii).eq."Dycore") then

   varnam1   = "T"
   tmp1      = f1->$varnam1$
   tmp1@_FillValue = -9999
   tmp1      = tmp1@_FillValue

  else

   print("The processes does not exist, please check share_info_for_budget_var.ncl ")
   exit
  
  end if
  end if
  end if
  end if
  end if

else 
  
  print ("model variable "+ mvarnam + " is not selected for budget analysis, please check share_info_for_budget_var.ncl" ) 
  exit
 
end if 
end if 
end if 
end if 

