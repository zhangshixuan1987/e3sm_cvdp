;;;;This script saved the shared code to get the observational data;;;;;;
  if ( pltvarnam .eq. "WIND_STRESS" ) then

     vmsvar                           := (/"TAUX","TAUY"/)
     vmsign                           := (/-1,-1/)

     if (compare.eq."Model_vs_OBS") then

       if (isfilevar(f2, "metss").and.isfilevar(f2, "mntss")) then
         vosvar                       := (/"metss","mntss"/)
         vosign                       := (/1,1/) 
       else if (isfilevar(f2, "inss").and.isfilevar(f2, "iews")) then
         vosvar                       := (/"inss","iews"/)
         vosign                       := (/1,1/)
       else
         vosvar                       := (/"xxxx","xxxx"/)
         vosign                       := (/1,1/) 
       end if 
       end if 

     end if 

  else if ( isStrSubset(pltvarnam,"WIND") ) then

     vmsvar                           := (/"U","V"/)
     vmsign                           := (/1,1/)

     if (compare.eq."Model_vs_OBS") then

       if (isfilevar(f2, "u").and.isfilevar(f2, "v")) then
         vosvar                       := (/"u","v"/)
         vosign                       := (/1,1/)
       else if (isfilevar(f2, "uwnd").and.isfilevar(f2, "vwnd")) then
         vosvar                       := (/"uwnd","vwnd"/)
         vosign                       := (/1,1/)
       else
         vosvar                       := (/"xxxx","xxxx"/)
         vosign                       := (/1,1/)
       end if
       end if 

     end if

  else
  
   print("Variable does not found, please check ")
   print("Error happens at function_read_vector_var.ncl")
   exit

  end if
 
  end if 
 
  ;read the variables;;;;;;;;
  if ( pltvarnam .eq. "WIND_STRESS" ) then
     tmp1_c1   = f1->$vmsvar(0)$(:,{latS:latN},:)
     tmp1_c2   = f1->$vmsvar(1)$(:,{latS:latN},:)

     if (compare.ne."Model_vs_OBS") then
       tmp2_c1   = f2->$vmsvar(0)$(:,{latS:latN},:)
       tmp2_c2   = f2->$vmsvar(1)$(:,{latS:latN},:)
     end if 

     if (compare.eq."Model_vs_OBS") then
       if (isfilevar(f2, vosvar(0)).and.isfilevar(f2, vosvar(1))) then
         tmp2_c1   = f2->$vosvar(0)$(:,{latS:latN},:)
         tmp2_c2   = f2->$vosvar(1)$(:,{latS:latN},:)
       else
         print(vosvar(0)+" and " + vosvar(1)+" are not found, using missing values")
         tmp2_c1   = tmp1_c1
         tmp2_c2   = tmp1_c2
         tmp2_c1   = -9999.
         tmp2_c2   = -9999.
       end if 
     end if

  else

     tmp1          = vinth2p(f1->$vmsvar(0)$,f1->hyam,f1->hybm,presnew,f1->PS,intyp,f1->P0/100.0,1,False)
     tmp2          = vinth2p(f1->$vmsvar(1)$,f1->hyam,f1->hybm,presnew,f1->PS,intyp,f1->P0/100.0,1,False)
     tmp1_c1       = tmp1(:,0,{latS:latN},:)
     tmp1_c2       = tmp2(:,0,{latS:latN},:)
     delete([/tmp1,tmp2/])

     if (compare.ne."Model_vs_OBS") then
       tmp1        = vinth2p(f2->$vmsvar(0)$,f2->hyam,f2->hybm,presnew,f2->PS,intyp,f2->P0/100.0,1,False)
       tmp2        = vinth2p(f2->$vmsvar(1)$,f2->hyam,f2->hybm,presnew,f2->PS,intyp,f2->P0/100.0,1,False)
       tmp2_c1     = tmp1(:,0,{latS:latN},:)
       tmp2_c2     = tmp2(:,0,{latS:latN},:)
       delete([/tmp1,tmp2/])
     end if

     if (compare.eq."Model_vs_OBS") then

       if (isfilevar(f2, vosvar(0)).and.isfilevar(f2, vosvar(1))) then
         lev       = f2->lev
         indl      = ind(lev.eq.presnew) 
         if(.not.ismissing(indl)) then
           tmp2_c1 = f2->$vosvar(0)$(:,indl,{latS:latN},:)  
           tmp2_c2 = f2->$vosvar(1)$(:,indl,{latS:latN},:)     
         else
           tmp1    = int2p_n_Wrap(lev,f2->$vosvar(0)$, presnew, intyp, 1)
           tmp2    = int2p_n_Wrap(lev,f2->$vosvar(1)$, presnew, intyp, 1)
           tmp2_c1 = tmp1(:,0,{latS:latN},:)
           tmp2_c2 = tmp2(:,0,{latS:latN},:)
           delete([/tmp1,tmp2/]) 
         end if  
         delete([/lev,indl/])
       else
         print(vosvar(0)+" and " + vosvar(1)+" are not found, using missing values")
         tmp2_c1   = tmp1_c1
         tmp2_c2   = tmp1_c2
         tmp2_c1   = -9999.
         tmp2_c2   = -9999.
       end if

     end if

   end if 
  
  tmp1_c1@_FillValue = -9999.
  tmp1_c2@_FillValue = -9999.
  tmp2_c1@_FillValue = -9999.
  tmp2_c2@_FillValue = -9999.

  var1_1   = tmp1_c1
  var1_2   = tmp1_c2
  var1_1   = vmsign(0)* var1_1 * factor 
  var1_2   = vmsign(1)* var1_2 * factor
  var1_m   = var1_1
  var1_m   = sqrt(var1_1^2+var1_2^2)

  var2_1   = tmp2_c1
  var2_2   = tmp2_c2
  var2_1   = vmsign(0)* var2_1 * factor
  var2_2   = vmsign(1)* var2_2 * factor
  var2_m   = var2_1
  var2_m   = sqrt(var2_1^2+var2_2^2)

  delete ([/tmp1_c1,tmp1_c2,tmp2_c1,tmp2_c2/])

 
