; use the user specified namelist / namelist_obs files to locate
; the files to be used, and write those file paths to namelist_byvar/namelist_*
; for use by other CVDP scripts.
;
; Note: ".nc" is removed from the paths given in namelist. 
;
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: namelist.ncl")
  o = getenv("OBS")
  case_sens = getenv("MACHINE")
  
  if (o.eq."True") then
     obsflag = True
  else
     obsflag = False
  end if
  
  if (.not.isfilepresent2("namelist_byvar/")) then
     system("mkdir namelist_byvar")
  end if
  
  nsim = numAsciiRow("namelist")
  na = asciiread("namelist",(/nsim/),"string")
  
  blankrow = ind(na.eq."")
  if (.not.any(ismissing(blankrow))) then
     goodrows = ind(na.ne."")
     na2 = na(goodrows)
     delete(na)
     na = na2
     delete(na2)
     nsim = dimsizes(na)
  end if     

  system("   export NSIM="+nsim)
  
  nentry = numAsciiCol("namelist")
  names = new(nsim,"string")
  paths = new(nsim,"string")
  syear = new(nsim,"integer",-999)
  eyear = new(nsim,"integer",-999)
  names_EM = new(nsim,"string")
  names_EM = names_EM@_FillValue
  EM_num = new(nsim,integer)
    
  delim = "|"
  do gg = 0,nsim-1
     names(gg) = str_strip(str_get_field(na(gg),1,delim))
     paths(gg) = str_strip(str_get_field(na(gg),2,delim))
     syear(gg) = stringtointeger(str_strip(str_get_field(na(gg),3,delim)))
     eyear(gg) = stringtointeger(str_strip(str_get_field(na(gg),4,delim)))
     names_EM(gg) = str_strip(str_get_field(na(gg),5,delim))
     temp := str_split(names_EM(gg),"-")
     EM_num(gg) = toint(temp(0))
  end do
  delete([/na,delim,temp/])

  test_int = toint(names_EM)
  if (any(ismissing(test_int))) then
     print("A model simulation has not been assigned to an ensemble, make sure within namelist that each row ends with a  | 1-$Ensemble Name (ex. | 2-CESM1 Control)")
     print("See documentation. Alter namelist and rerun.")
     exit
  end if
  
  do gg = 1,max(EM_num)    ; check that every member of an ensemble span the same number of years, and if not, reset the years to a common span (if possible)
     wind := ind(EM_num.eq.gg)
     yspan := eyear(wind) - syear(wind)
     if (min(yspan).ne.max(yspan)) then
        print("namelist.ncl: Each member of an ensemble must span the same number of years. Resetting "+names_EM(wind(0))+" ensemble to common year span of "+min(yspan)+" years.") 
        eyear(wind) = syear(wind)+min(yspan)
     end if
  end do

  do gg = 0,nsim-1         ; if path ends in .nc remove it. (It will get appended to the end of the path automatically when searching below.)
     paths(gg) = str_sub_str(paths(gg),".nc","")
  end do
;----- Read in namelist_obs, and check number of supplied Observational datasets ------

  maxnumobs = 0    ; set maximum number of obs datasets per variable. if(obsflag).eq.True, this will likely get altered.

  if (obsflag) then
     nobs    = numAsciiRow("namelist_obs")
     nentryB = numAsciiCol("namelist_obs")
     vnamesB  = new(nobs,"string")
     namesB  = new(nobs,"string")
     pathsB  = new(nobs,"string")
     syearBT  = new(nobs,"string")
     eyearBT  = new(nobs,"string")
     syearB  = new(nobs,"integer")
     eyearB  = new(nobs,"integer")
  
     na = asciiread("namelist_obs",(/nobs/),"string")
     delim = "|"

     do gg = 0,nobs-1
        vnamesB(gg) = str_strip(str_get_field(na(gg),1,delim))
        namesB(gg)  = str_strip(str_get_field(na(gg),2,delim))
        pathsB(gg)  = str_strip(str_get_field(na(gg),3,delim))
        syearBT(gg) = str_strip(str_get_field(na(gg),4,delim))
        eyearBT(gg) = str_strip(str_get_field(na(gg),5,delim))

        if (.not.isfilepresent2(pathsB(gg))) then   ; check to see if the specified observational file is present, if not, set to missing
           pathsB(gg) = pathsB@_FillValue
        end if
        if (syearBT(gg).eq."") then
           syearBT(gg) = "-999"
           eyearBT(gg) = "-999"
        end if          
     end do
     
     maxnumobs = max((/dimsizes(ind(vnamesB.eq."T")),dimsizes(ind(vnamesB.eq."Q")),\
                       dimsizes(ind(vnamesB.eq."U")),dimsizes(ind(vnamesB.eq."V")),\
                       dimsizes(ind(vnamesB.eq."TS")),dimsizes(ind(vnamesB.eq."PSL")),\
                       dimsizes(ind(vnamesB.eq."PRECT")),dimsizes(ind(vnamesB.eq."Z500")),\
                       dimsizes(ind(vnamesB.eq."CLDTOT")),dimsizes(ind(vnamesB.eq."PRECST")),\
                       dimsizes(ind(vnamesB.eq."LWP")),dimsizes(ind(vnamesB.eq."IWP")),\
                       dimsizes(ind(vnamesB.eq."U200")),dimsizes(ind(vnamesB.eq."V200")),\
                       dimsizes(ind(vnamesB.eq."Qn")),dimsizes(ind(vnamesB.eq."QnRad")), \
                       dimsizes(ind(vnamesB.eq."FLDS")),dimsizes(ind(vnamesB.eq."FLDSC")),\
                       dimsizes(ind(vnamesB.eq."FLNS")),dimsizes(ind(vnamesB.eq."FLNSC")),\
                       dimsizes(ind(vnamesB.eq."FSNS")),dimsizes(ind(vnamesB.eq."FSNSC")),\
                       dimsizes(ind(vnamesB.eq."SWCRE")),dimsizes(ind(vnamesB.eq."LWCRE")),\
                       dimsizes(ind(vnamesB.eq."SH")),dimsizes(ind(vnamesB.eq."LH")),\
                       dimsizes(ind(vnamesB.eq."SF920")),dimsizes(ind(vnamesB.eq."VP920")),\
                       dimsizes(ind(vnamesB.eq."SF470")),dimsizes(ind(vnamesB.eq."VP470")),\
                       dimsizes(ind(vnamesB.eq."HFLX")),dimsizes(ind(vnamesB.eq."ETH1")),\
                       dimsizes(ind(vnamesB.eq."ETH2")),dimsizes(ind(vnamesB.eq."ETH")),\
                       dimsizes(ind(vnamesB.eq."U850")),dimsizes(ind(vnamesB.eq."V850")),\
                       dimsizes(ind(vnamesB.eq."U10")),dimsizes(ind(vnamesB.eq."V10")),\
                       dimsizes(ind(vnamesB.eq."TAUX")),dimsizes(ind(vnamesB.eq."TAUY")),\
                       dimsizes(ind(vnamesB.eq."TREFHT")), dimsizes(ind(vnamesB.eq."MOC")), \
                       dimsizes(ind(vnamesB.eq."aice_nh")),dimsizes(ind(vnamesB.eq."aice_sh"))/))
     syearB = stringtointeger(syearBT)
     eyearB = stringtointeger(eyearBT)
     
     do gg = 0,nobs-1      ; check to see if any names are duplicated. If they are, add a "_2", "_3" to the name
        dupn = ind(namesB.eq.namesB(gg))            ; this is needed so that each output .nc file has a different name
        if (dimsizes(dupn).ge.2) then
           do hh = 1,dimsizes(dupn)-1
              namesB(dupn(hh)) = namesB(dupn(hh))+"_"+hh
           end do
        end if
        delete(dupn)
     end do
     delete([/eyearBT,syearBT/])
     delete([/na,delim,nentryB,nobs/])
  end if
;  print(vnamesB+" "+namesB+" "+pathsB+" "+syearB+" "+eyearB)

;----- T section---------------
  namelist_ta = new(nsim+maxnumobs,string)
  if (obsflag) then
     ta_i = ind(vnamesB.eq."T")
     if (.not.ismissing(ta_i(0))) then
        incr = dimsizes(ta_i)
        do gg = 0,incr-1
           namelist_ta(gg) = namesB(ta_i(gg))+" | "+pathsB(ta_i(gg))+" | "+syearB(ta_i(gg))+" | "+eyearB(ta_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outa
           if (.not.ismissing(namelist_ta(0))) then
              nmiss = ind(ismissing(namelist_ta(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_ta(hh) = namesB(ta_i(0))+"_"+hh+" | "+pathsB(ta_i(0))+" | "+syearB(ta_i(0))+" | "+eyearB(ta_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(ta_i)
  end if

  if (case_sens.eq."True") then
     tatring1 = "T,ta,TA,t"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tatring1 = "T,TA"
  end if
  tar := str_split(tatring1,",")
  do gg = 0,nsim-1
     do hh = 0,dimsizes(tar)-1
        namelist_ta(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fta := systemfunc("bash -c 'ls "+paths(gg)+"*."+tar(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fta(0))) then
           if (dimsizes(fta).eq.1) then
              fta@path = fta
           else
              fta@path = paths(gg)+"*."+tar(hh)+".*.nc"
           end if
           namelist_ta(gg+maxnumobs) =  names(gg)+" | "+fta@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+tar(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+tar(hh)+"_")
           fta2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fta2(0))) then
              if (str_match_bool(fta2(0),tar(hh))) then
                 namelist_ta(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_ta",namelist_ta)

;----- Q section---------------
  namelist_qa = new(nsim+maxnumobs,string)
  if (obsflag) then
     qa_i = ind(vnamesB.eq."Q")
     if (.not.ismissing(qa_i(0))) then
        incr = dimsizes(qa_i)
        do gg = 0,incr-1
           namelist_qa(gg) = namesB(qa_i(gg))+" | "+pathsB(qa_i(gg))+" | "+syearB(qa_i(gg))+" | "+eyearB(qa_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-ouqa
           if (.not.ismissing(namelist_qa(0))) then
              nmiss = ind(ismissing(namelist_qa(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_qa(hh) = namesB(qa_i(0))+"_"+hh+" | "+pathsB(qa_i(0))+" | "+syearB(qa_i(0))+" | "+eyearB(qa_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(qa_i)
  end if

  if (case_sens.eq."True") then
     qatring1 = "Q,q,QA,qa,huss"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     qatring1 = "Q,QA"
  end if
  qar := str_split(qatring1,",")
  do gg = 0,nsim-1
     do hh = 0,dimsizes(qar)-1
        namelist_qa(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fqa := systemfunc("bash -c 'ls "+paths(gg)+"*."+qar(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all sqandard error output
        if (.not.ismissing(fqa(0))) then
           if (dimsizes(fqa).eq.1) then
              fqa@path = fqa
           else
              fqa@path = paths(gg)+"*."+qar(hh)+".*.nc"
           end if
           namelist_qa(gg+maxnumobs) =  names(gg)+" | "+fqa@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+qar(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+qar(hh)+"_")
           fqa2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fqa2(0))) then
              if (str_match_bool(fqa2(0),qar(hh))) then
                 namelist_qa(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_qa",namelist_qa)

;----- U section---------------
  namelist_ua = new(nsim+maxnumobs,string)
  if (obsflag) then
     ua_i = ind(vnamesB.eq."U")
     if (.not.ismissing(ua_i(0))) then
        incr = dimsizes(ua_i)
        do gg = 0,incr-1
           namelist_ua(gg) = namesB(ua_i(gg))+" | "+pathsB(ua_i(gg))+" | "+syearB(ua_i(gg))+" | "+eyearB(ua_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-ouua
           if (.not.ismissing(namelist_ua(0))) then
              nmiss = ind(ismissing(namelist_ua(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_ua(hh) = namesB(ua_i(0))+"_"+hh+" | "+pathsB(ua_i(0))+" | "+syearB(ua_i(0))+" | "+eyearB(ua_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(ua_i)
  end if

  if (case_sens.eq."True") then
     uatring1 = "U,u,UA,ua"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     uatring1 = "U,UA"
  end if
  uar := str_split(uatring1,",")
  do gg = 0,nsim-1
     do hh = 0,dimsizes(uar)-1
        namelist_ua(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fua := systemfunc("bash -c 'ls "+paths(gg)+"*."+uar(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all suandard error output
        if (.not.ismissing(fua(0))) then
           if (dimsizes(fua).eq.1) then
              fua@path = fua
           else
              fua@path = paths(gg)+"*."+uar(hh)+".*.nc"
           end if
           namelist_ua(gg+maxnumobs) =  names(gg)+" | "+fua@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+uar(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+uar(hh)+"_")
           fua2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fua2(0))) then
              if (str_match_bool(fua2(0),uar(hh))) then
                 namelist_ua(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_ua",namelist_ua)

;----- TS section---------------
  namelist_ts = new(nsim+maxnumobs,string)
  if (obsflag) then
     ts_i = ind(vnamesB.eq."TS")
     if (.not.ismissing(ts_i(0))) then
        incr = dimsizes(ts_i)
        do gg = 0,incr-1
           namelist_ts(gg) = namesB(ts_i(gg))+" | "+pathsB(ts_i(gg))+" | "+syearB(ts_i(gg))+" | "+eyearB(ts_i(gg))+" | 0-Observations" 
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_ts(0))) then
              nmiss = ind(ismissing(namelist_ts(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_ts(hh) = namesB(ts_i(0))+"_"+hh+" | "+pathsB(ts_i(0))+" | "+syearB(ts_i(0))+" | "+eyearB(ts_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(ts_i)
  end if  
  
  if (case_sens.eq."True") then
     tstring1 = "TS,ts,t_surf,sst"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "TS,t_surf,sst"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_ts(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_ts(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/") 
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_ts(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do  
  asciiwrite("namelist_byvar/namelist_ts",namelist_ts)

;----- QnRad section---------------
  namelist_qrad = new(nsim+maxnumobs,string)
  if (obsflag) then
     qrad_i = ind(vnamesB.eq."QnRad")
     if (.not.ismissing(qrad_i(0))) then
        incr = dimsizes(qrad_i)
        do gg = 0,incr-1
           namelist_qrad(gg) = namesB(qrad_i(gg))+" | "+pathsB(qrad_i(gg))+" | "+syearB(qrad_i(gg))+" | "+eyearB(qrad_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_qrad(0))) then
              nmiss = ind(ismissing(namelist_qrad(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_qrad(hh) = namesB(qrad_i(0))+"_"+hh+" | "+pathsB(qrad_i(0))+" | "+syearB(qrad_i(0))+" | "+eyearB(qrad_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(qrad_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "QnRad,qnrad,QnRad_SRF,qnrad_srf"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "QnRad,QnRad_SRF"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_qrad(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_qrad(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_qrad(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_qrad",namelist_qrad)

;----- Qn section---------------
  namelist_qn = new(nsim+maxnumobs,string)
  if (obsflag) then
     Qn_i = ind(vnamesB.eq."Qn")
     if (.not.ismissing(Qn_i(0))) then
        incr = dimsizes(Qn_i)
        do gg = 0,incr-1
           namelist_qn(gg) = namesB(Qn_i(gg))+" | "+pathsB(Qn_i(gg))+" | "+syearB(Qn_i(gg))+" | "+eyearB(Qn_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_qn(0))) then
              nmiss = ind(ismissing(namelist_qn(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_qn(hh) = namesB(Qn_i(0))+"_"+hh+" | "+pathsB(Qn_i(0))+" | "+syearB(Qn_i(0))+" | "+eyearB(Qn_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(Qn_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "Qn_SRF,QnTot,qn_srf"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "Qn_SRF,QnTot"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_qn(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_qn(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_qn(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_qn",namelist_qn)

;----- HFLX section---------------
  namelist_hflx = new(nsim+maxnumobs,string)
  if (obsflag) then
     HFLX_i = ind(vnamesB.eq."HFLX")
     if (.not.ismissing(HFLX_i(0))) then
        incr = dimsizes(HFLX_i)
        do gg = 0,incr-1
           namelist_hflx(gg) = namesB(HFLX_i(gg))+" | "+pathsB(HFLX_i(gg))+" | "+syearB(HFLX_i(gg))+" | "+eyearB(HFLX_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_hflx(0))) then
              nmiss = ind(ismissing(namelist_hflx(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_hflx(hh) = namesB(HFLX_i(0))+"_"+hh+" | "+pathsB(HFLX_i(0))+" | "+syearB(HFLX_i(0))+" | "+eyearB(HFLX_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(HFLX_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "QnTur_SRF,HFLX,qntur_srf,hflx"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "QnTur_SRF,HFLX"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_hflx(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_hflx(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_hflx(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_hflx",namelist_hflx)

;----- SH section---------------
  namelist_sh = new(nsim+maxnumobs,string)
  if (obsflag) then
     sh_i = ind(vnamesB.eq."SH")
     if (.not.ismissing(sh_i(0))) then
        incr = dimsizes(sh_i)
        do gg = 0,incr-1
           namelist_sh(gg) = namesB(sh_i(gg))+" | "+pathsB(sh_i(gg))+" | "+syearB(sh_i(gg))+" | "+eyearB(sh_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_sh(0))) then
              nmiss = ind(ismissing(namelist_sh(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_sh(hh) = namesB(sh_i(0))+"_"+hh+" | "+pathsB(sh_i(0))+" | "+syearB(sh_i(0))+" | "+eyearB(sh_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(sh_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "SHFLX,shflx"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "SHFLX"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_sh(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_sh(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_sh(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_sh",namelist_sh)

;----- LH section---------------
  namelist_lh = new(nsim+maxnumobs,string)
  if (obsflag) then
     lh_i = ind(vnamesB.eq."LH")
     if (.not.ismissing(lh_i(0))) then
        incr = dimsizes(lh_i)
        do gg = 0,incr-1
           namelist_lh(gg) = namesB(lh_i(gg))+" | "+pathsB(lh_i(gg))+" | "+syearB(lh_i(gg))+" | "+eyearB(lh_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_lh(0))) then
              nmiss = ind(ismissing(namelist_lh(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_lh(hh) = namesB(lh_i(0))+"_"+hh+" | "+pathsB(lh_i(0))+" | "+syearB(lh_i(0))+" | "+eyearB(lh_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(lh_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "LHFLX,lhflx"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "LHFLX"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_lh(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_lh(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_lh(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_lh",namelist_lh)

;----- ETH section---------------
  namelist_eth = new(nsim+maxnumobs,string)
  if (obsflag) then
     ETH_i = ind(vnamesB.eq."ETH")
     if (.not.ismissing(ETH_i(0))) then
        incr = dimsizes(ETH_i)
        do gg = 0,incr-1
           namelist_eth(gg) = namesB(ETH_i(gg))+" | "+pathsB(ETH_i(gg))+" | "+syearB(ETH_i(gg))+" | "+eyearB(ETH_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_eth(0))) then
              nmiss = ind(ismissing(namelist_eth(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_eth(hh) = namesB(ETH_i(0))+"_"+hh+" | "+pathsB(ETH_i(0))+" | "+syearB(ETH_i(0))+" | "+eyearB(ETH_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(ETH_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "ETH,ETH12,eth,eth12"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "ETH,ETH12"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_eth(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_eth(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_eth(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_eth",namelist_eth)

;----- ETH1 section---------------
  namelist_eth1 = new(nsim+maxnumobs,string)
  if (obsflag) then
     ETH1_i = ind(vnamesB.eq."ETH1")
     if (.not.ismissing(ETH1_i(0))) then
        incr = dimsizes(ETH1_i)
        do gg = 0,incr-1
           namelist_eth1(gg) = namesB(ETH1_i(gg))+" | "+pathsB(ETH1_i(gg))+" | "+syearB(ETH1_i(gg))+" | "+eyearB(ETH1_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_eth1(0))) then
              nmiss = ind(ismissing(namelist_eth1(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_eth1(hh) = namesB(ETH1_i(0))+"_"+hh+" | "+pathsB(ETH1_i(0))+" | "+syearB(ETH1_i(0))+" | "+eyearB(ETH1_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(ETH1_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "ETH1,eth1"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "ETH1"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_eth1(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_eth1(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_eth1(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_eth1",namelist_eth1)

;----- ETH2 section---------------
  namelist_eth2 = new(nsim+maxnumobs,string)
  if (obsflag) then
     ETH2_i = ind(vnamesB.eq."ETH2")
     if (.not.ismissing(ETH2_i(0))) then
        incr = dimsizes(ETH2_i)
        do gg = 0,incr-1
           namelist_eth2(gg) = namesB(ETH2_i(gg))+" | "+pathsB(ETH2_i(gg))+" | "+syearB(ETH2_i(gg))+" | "+eyearB(ETH2_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_eth2(0))) then
              nmiss = ind(ismissing(namelist_eth2(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_eth2(hh) = namesB(ETH2_i(0))+"_"+hh+" | "+pathsB(ETH2_i(0))+" | "+syearB(ETH2_i(0))+" | "+eyearB(ETH2_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(ETH2_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "ETH2,eth2"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "ETH2"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_eth2(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_eth2(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_eth2(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_eth2",namelist_eth2)

;----- U850 section---------------
  namelist_u850 = new(nsim+maxnumobs,string)
  if (obsflag) then
     u850_i = ind(vnamesB.eq."U850")
     if (.not.ismissing(u850_i(0))) then
        incr = dimsizes(u850_i)
        do gg = 0,incr-1
           namelist_u850(gg) = namesB(u850_i(gg))+" | "+pathsB(u850_i(gg))+" | "+syearB(u850_i(gg))+" | "+eyearB(u850_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_u850(0))) then
              nmiss = ind(ismissing(namelist_u850(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_u850(hh) = namesB(u850_i(0))+"_"+hh+" | "+pathsB(u850_i(0))+" | "+syearB(u850_i(0))+" | "+eyearB(u850_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(u850_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "U850,u850"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "U850"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_u850(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_u850(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_u850(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_u850",namelist_u850)

;----- V850 section---------------
  namelist_v850 = new(nsim+maxnumobs,string)
  if (obsflag) then
     v850_i = ind(vnamesB.eq."V850")
     if (.not.ismissing(v850_i(0))) then
        incr = dimsizes(v850_i)
        do gg = 0,incr-1
           namelist_v850(gg) = namesB(v850_i(gg))+" | "+pathsB(v850_i(gg))+" | "+syearB(v850_i(gg))+" | "+eyearB(v850_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_v850(0))) then
              nmiss = ind(ismissing(namelist_v850(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_v850(hh) = namesB(v850_i(0))+"_"+hh+" | "+pathsB(v850_i(0))+" | "+syearB(v850_i(0))+" | "+eyearB(v850_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(v850_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "V850,v850"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "V850"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_v850(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_v850(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_v850(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_v850",namelist_v850)

;----- lwp section---------------
  namelist_lwp = new(nsim+maxnumobs,string)
  if (obsflag) then
     lwp_i = ind(vnamesB.eq."LWP")
     if (.not.ismissing(lwp_i(0))) then
        incr = dimsizes(lwp_i)
        do gg = 0,incr-1
           namelist_lwp(gg) = namesB(lwp_i(gg))+" | "+pathsB(lwp_i(gg))+" | "+syearB(lwp_i(gg))+" | "+eyearB(lwp_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_lwp(0))) then
              nmiss = ind(ismissing(namelist_lwp(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_lwp(hh) = namesB(lwp_i(0))+"_"+hh+" | "+pathsB(lwp_i(0))+" | "+syearB(lwp_i(0))+" | "+eyearB(lwp_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(lwp_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "TGCLDLWP,tgcldlwp,LWP,lwp"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "TGCLDLWP,LWP"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_lwp(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_lwp(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_lwp(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_lwp",namelist_lwp)

;----- IWP section---------------
  namelist_iwp = new(nsim+maxnumobs,string)
  if (obsflag) then
     iwp_i = ind(vnamesB.eq."IWP")
     if (.not.ismissing(iwp_i(0))) then
        incr = dimsizes(iwp_i)
        do gg = 0,incr-1
           namelist_iwp(gg) = namesB(iwp_i(gg))+" | "+pathsB(iwp_i(gg))+" | "+syearB(iwp_i(gg))+" | "+eyearB(iwp_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_iwp(0))) then
              nmiss = ind(ismissing(namelist_iwp(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_iwp(hh) = namesB(iwp_i(0))+"_"+hh+" | "+pathsB(iwp_i(0))+" | "+syearB(iwp_i(0))+" | "+eyearB(iwp_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(iwp_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "TGCLDIWP,tgcldiwp,IWP,iwp"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "TGCLDIWP,IWP"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_iwp(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_iwp(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_iwp(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_iwp",namelist_iwp)

;----- FLDS section---------------
  namelist_flds = new(nsim+maxnumobs,string)
  if (obsflag) then
     flds_i = ind(vnamesB.eq."FLDS")
     if (.not.ismissing(flds_i(0))) then
        incr = dimsizes(flds_i)
        do gg = 0,incr-1
           namelist_flds(gg) = namesB(flds_i(gg))+" | "+pathsB(flds_i(gg))+" | "+syearB(flds_i(gg))+" | "+eyearB(flds_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_flds(0))) then
              nmiss = ind(ismissing(namelist_flds(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_flds(hh) = namesB(flds_i(0))+"_"+hh+" | "+pathsB(flds_i(0))+" | "+syearB(flds_i(0))+" | "+eyearB(flds_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(flds_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "FLDS,flds"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "FLDS"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_flds(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_flds(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_flds(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_flds",namelist_flds)

;----- FLDSC section---------------
  namelist_fldsc = new(nsim+maxnumobs,string)
  if (obsflag) then
     fldsc_i = ind(vnamesB.eq."FLDSC")
     if (.not.ismissing(fldsc_i(0))) then
        incr = dimsizes(fldsc_i)
        do gg = 0,incr-1
           namelist_fldsc(gg) = namesB(fldsc_i(gg))+" | "+pathsB(fldsc_i(gg))+" | "+syearB(fldsc_i(gg))+" | "+eyearB(fldsc_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_fldsc(0))) then
              nmiss = ind(ismissing(namelist_fldsc(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_fldsc(hh) = namesB(fldsc_i(0))+"_"+hh+" | "+pathsB(fldsc_i(0))+" | "+syearB(fldsc_i(0))+" | "+eyearB(fldsc_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(fldsc_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "FLDSC,fldsc"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "FLDSC"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_fldsc(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_fldsc(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_fldsc(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_fldsc",namelist_fldsc)

;----- FLNS section---------------
  namelist_flns = new(nsim+maxnumobs,string)
  if (obsflag) then
     flns_i = ind(vnamesB.eq."FLNS")
     if (.not.ismissing(flns_i(0))) then
        incr = dimsizes(flns_i)
        do gg = 0,incr-1
           namelist_flns(gg) = namesB(flns_i(gg))+" | "+pathsB(flns_i(gg))+" | "+syearB(flns_i(gg))+" | "+eyearB(flns_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_flns(0))) then
              nmiss = ind(ismissing(namelist_flns(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_flns(hh) = namesB(flns_i(0))+"_"+hh+" | "+pathsB(flns_i(0))+" | "+syearB(flns_i(0))+" | "+eyearB(flns_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(flns_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "FLNS,flns"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "FLNS"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_flns(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_flns(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_flns(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_flns",namelist_flns)

;----- FLNSC section---------------
  namelist_flnsc = new(nsim+maxnumobs,string)
  if (obsflag) then
     flnsc_i = ind(vnamesB.eq."FLNSC")
     if (.not.ismissing(flnsc_i(0))) then
        incr = dimsizes(flnsc_i)
        do gg = 0,incr-1
           namelist_flnsc(gg) = namesB(flnsc_i(gg))+" | "+pathsB(flnsc_i(gg))+" | "+syearB(flnsc_i(gg))+" | "+eyearB(flnsc_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_flnsc(0))) then
              nmiss = ind(ismissing(namelist_flnsc(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_flnsc(hh) = namesB(flnsc_i(0))+"_"+hh+" | "+pathsB(flnsc_i(0))+" | "+syearB(flnsc_i(0))+" | "+eyearB(flnsc_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(flnsc_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "FLNSC,flnsc"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "FLNSC"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_flnsc(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_flnsc(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_flnsc(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_flnsc",namelist_flnsc)

;----- FSNS section---------------
  namelist_fsns = new(nsim+maxnumobs,string)
  if (obsflag) then
     fsns_i = ind(vnamesB.eq."FSNS")
     if (.not.ismissing(fsns_i(0))) then
        incr = dimsizes(fsns_i)
        do gg = 0,incr-1
           namelist_fsns(gg) = namesB(fsns_i(gg))+" | "+pathsB(fsns_i(gg))+" | "+syearB(fsns_i(gg))+" | "+eyearB(fsns_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_fsns(0))) then
              nmiss = ind(ismissing(namelist_fsns(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_fsns(hh) = namesB(fsns_i(0))+"_"+hh+" | "+pathsB(fsns_i(0))+" | "+syearB(fsns_i(0))+" | "+eyearB(fsns_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(fsns_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "FSNS,fsns"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "FSNS"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_fsns(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_fsns(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_fsns(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_fsns",namelist_fsns)

;----- FSNSC section---------------
  namelist_fsnsc = new(nsim+maxnumobs,string)
  if (obsflag) then
     fsnsc_i = ind(vnamesB.eq."FSNSC")
     if (.not.ismissing(fsnsc_i(0))) then
        incr = dimsizes(fsnsc_i)
        do gg = 0,incr-1
           namelist_fsnsc(gg) = namesB(fsnsc_i(gg))+" | "+pathsB(fsnsc_i(gg))+" | "+syearB(fsnsc_i(gg))+" | "+eyearB(fsnsc_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_fsnsc(0))) then
              nmiss = ind(ismissing(namelist_fsnsc(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_fsnsc(hh) = namesB(fsnsc_i(0))+"_"+hh+" | "+pathsB(fsnsc_i(0))+" | "+syearB(fsnsc_i(0))+" | "+eyearB(fsnsc_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(fsnsc_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "FSNSC,fsnsc"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "FSNSC"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_fsnsc(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_fsnsc(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_fsnsc(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_fsnsc",namelist_fsnsc)

;----- CLDTOT section---------------
  namelist_cldtot = new(nsim+maxnumobs,string)
  if (obsflag) then
     cldtot_i = ind(vnamesB.eq."CLDTOT")
     if (.not.ismissing(cldtot_i(0))) then
        incr = dimsizes(cldtot_i)
        do gg = 0,incr-1
           namelist_cldtot(gg) = namesB(cldtot_i(gg))+" | "+pathsB(cldtot_i(gg))+" | "+syearB(cldtot_i(gg))+" | "+eyearB(cldtot_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_cldtot(0))) then
              nmiss = ind(ismissing(namelist_cldtot(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_cldtot(hh) = namesB(cldtot_i(0))+"_"+hh+" | "+pathsB(cldtot_i(0))+" | "+syearB(cldtot_i(0))+" | "+eyearB(cldtot_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(cldtot_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "CLDTOT,cldtot"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "CLDTOT"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_cldtot(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_cldtot(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_cldtot(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_cldtot",namelist_cldtot)

;----- Z500 section---------------
  namelist_z500 = new(nsim+maxnumobs,string)
  if (obsflag) then
     z500_i = ind(vnamesB.eq."Z500")
     if (.not.ismissing(z500_i(0))) then
        incr = dimsizes(z500_i)
        do gg = 0,incr-1
           namelist_z500(gg) = namesB(z500_i(gg))+" | "+pathsB(z500_i(gg))+" | "+syearB(z500_i(gg))+" | "+eyearB(z500_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_z500(0))) then
              nmiss = ind(ismissing(namelist_z500(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_z500(hh) = namesB(z500_i(0))+"_"+hh+" | "+pathsB(z500_i(0))+" | "+syearB(z500_i(0))+" | "+eyearB(z500_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(z500_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "Z500,z500"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "Z500"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_z500(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_z500(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_z500(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_z500",namelist_z500)

;----- U200 section---------------
  namelist_u200 = new(nsim+maxnumobs,string)
  if (obsflag) then
     u200_i = ind(vnamesB.eq."U200")
     if (.not.ismissing(u200_i(0))) then
        incr = dimsizes(u200_i)
        do gg = 0,incr-1
           namelist_u200(gg) = namesB(u200_i(gg))+" | "+pathsB(u200_i(gg))+" | "+syearB(u200_i(gg))+" | "+eyearB(u200_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_u200(0))) then
              nmiss = ind(ismissing(namelist_u200(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_u200(hh) = namesB(u200_i(0))+"_"+hh+" | "+pathsB(u200_i(0))+" | "+syearB(u200_i(0))+" | "+eyearB(u200_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(u200_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "U200,u200"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "U200"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_u200(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_u200(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_u200(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_u200",namelist_u200)

;----- V200 section---------------
  namelist_v200 = new(nsim+maxnumobs,string)
  if (obsflag) then
     v200_i = ind(vnamesB.eq."V200")
     if (.not.ismissing(v200_i(0))) then
        incr = dimsizes(v200_i)
        do gg = 0,incr-1
           namelist_v200(gg) = namesB(v200_i(gg))+" | "+pathsB(v200_i(gg))+" | "+syearB(v200_i(gg))+" | "+eyearB(v200_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_v200(0))) then
              nmiss = ind(ismissing(namelist_v200(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_v200(hh) = namesB(v200_i(0))+"_"+hh+" | "+pathsB(v200_i(0))+" | "+syearB(v200_i(0))+" | "+eyearB(v200_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(v200_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "V200,v200"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "V200"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_v200(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_v200(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_v200(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_v200",namelist_v200)

;----- U10 section---------------
  namelist_u10 = new(nsim+maxnumobs,string)
  if (obsflag) then
     u10_i = ind(vnamesB.eq."U10")
     if (.not.ismissing(u10_i(0))) then
        incr = dimsizes(u10_i)
        do gg = 0,incr-1
           namelist_u10(gg) = namesB(u10_i(gg))+" | "+pathsB(u10_i(gg))+" | "+syearB(u10_i(gg))+" | "+eyearB(u10_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_u10(0))) then
              nmiss = ind(ismissing(namelist_u10(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_u10(hh) = namesB(u10_i(0))+"_"+hh+" | "+pathsB(u10_i(0))+" | "+syearB(u10_i(0))+" | "+eyearB(u10_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(u10_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "U10,u10"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "U10"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_u10(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_u10(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_u10(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_u10",namelist_u10)

;----- V10 section---------------
  namelist_v10 = new(nsim+maxnumobs,string)
  if (obsflag) then
     v10_i = ind(vnamesB.eq."V10")
     if (.not.ismissing(v10_i(0))) then
        incr = dimsizes(v10_i)
        do gg = 0,incr-1
           namelist_v10(gg) = namesB(v10_i(gg))+" | "+pathsB(v10_i(gg))+" | "+syearB(v10_i(gg))+" | "+eyearB(v10_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_v10(0))) then
              nmiss = ind(ismissing(namelist_v10(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_v10(hh) = namesB(v10_i(0))+"_"+hh+" | "+pathsB(v10_i(0))+" | "+syearB(v10_i(0))+" | "+eyearB(v10_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(v10_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "V10,v10"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "V10"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_v10(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_v10(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_v10(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_v10",namelist_v10)

;----- TAUX section---------------
  namelist_taux = new(nsim+maxnumobs,string)
  if (obsflag) then
     taux_i = ind(vnamesB.eq."TAUX")
     if (.not.ismissing(taux_i(0))) then
        incr = dimsizes(taux_i)
        do gg = 0,incr-1
           namelist_taux(gg) = namesB(taux_i(gg))+" | "+pathsB(taux_i(gg))+" | "+syearB(taux_i(gg))+" | "+eyearB(taux_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_taux(0))) then
              nmiss = ind(ismissing(namelist_taux(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_taux(hh) = namesB(taux_i(0))+"_"+hh+" | "+pathsB(taux_i(0))+" | "+syearB(taux_i(0))+" | "+eyearB(taux_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(taux_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "TAUX,taux,TAUU,tauu"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "TAUX,TAUU"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_taux(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_taux(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_taux(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_taux",namelist_taux)

;----- TAUY section---------------
  namelist_tauy = new(nsim+maxnumobs,string)
  if (obsflag) then
     tauy_i = ind(vnamesB.eq."TAUY")
     if (.not.ismissing(tauy_i(0))) then
        incr = dimsizes(tauy_i)
        do gg = 0,incr-1
           namelist_tauy(gg) = namesB(tauy_i(gg))+" | "+pathsB(tauy_i(gg))+" | "+syearB(tauy_i(gg))+" | "+eyearB(tauy_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_tauy(0))) then
              nmiss = ind(ismissing(namelist_tauy(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_tauy(hh) = namesB(tauy_i(0))+"_"+hh+" | "+pathsB(tauy_i(0))+" | "+syearB(tauy_i(0))+" | "+eyearB(tauy_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(tauy_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "TAUY,TAUV,taux,tauv"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "TAUY,TAUV"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_tauy(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_tauy(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_tauy(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_tauy",namelist_tauy)

;----- TH850 section---------------
  namelist_th850 = new(nsim+maxnumobs,string)
  if (obsflag) then
     th850_i = ind(vnamesB.eq."TH850")
     if (.not.ismissing(th850_i(0))) then
        incr = dimsizes(th850_i)
        do gg = 0,incr-1
           namelist_th850(gg) = namesB(th850_i(gg))+" | "+pathsB(th850_i(gg))+" | "+syearB(th850_i(gg))+" | "+eyearB(th850_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_th850(0))) then
              nmiss = ind(ismissing(namelist_th850(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_th850(hh) = namesB(th850_i(0))+"_"+hh+" | "+pathsB(th850_i(0))+" | "+syearB(th850_i(0))+" | "+eyearB(th850_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(th850_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "TH850,th850,T850,t850"  ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "TH850,T850"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_th850(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_th850(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_th850(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_th850",namelist_th850)

;------- PSL section----------------------------  
  namelist_psl = new(nsim+maxnumobs,string)
  if (obsflag) then
     psl_i = ind(vnamesB.eq."PSL")
     if (.not.ismissing(psl_i(0))) then
        incr = dimsizes(psl_i)
        do gg = 0,incr-1
           namelist_psl(gg) = namesB(psl_i(gg))+" | "+pathsB(psl_i(gg))+" | "+syearB(psl_i(gg))+" | "+eyearB(psl_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_psl(0))) then
              nmiss = ind(ismissing(namelist_psl(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_psl(hh) = namesB(psl_i(0))+"_"+hh+" | "+pathsB(psl_i(0))+" | "+syearB(psl_i(0))+" | "+eyearB(psl_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(psl_i)
  end if  
  
  if (case_sens.eq."True") then
     tstring1 = "PSL,psl,SLP,slp"       ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "PSL,slp"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_psl(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)     ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_psl(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/") 
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_psl(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do  
  asciiwrite("namelist_byvar/namelist_psl",namelist_psl)
;------- SWCRE section----------------------------
  namelist_swcre = new(nsim+maxnumobs,string)
  if (obsflag) then
     swcre_i = ind(vnamesB.eq."SWCRE")
     if (.not.ismissing(swcre_i(0))) then
        incr = dimsizes(swcre_i)
        do gg = 0,incr-1
           namelist_swcre(gg) = namesB(swcre_i(gg))+" | "+pathsB(swcre_i(gg))+" | "+syearB(swcre_i(gg))+" | "+eyearB(swcre_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_swcre(0))) then
              nmiss = ind(ismissing(namelist_swcre(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_swcre(hh) = namesB(swcre_i(0))+"_"+hh+" | "+pathsB(swcre_i(0))+" | "+syearB(swcre_i(0))+" | "+eyearB(swcre_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(swcre_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "SWCRE,SWCF,swcre,swcf"       ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "SWCRE,SWCF"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_swcre(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)     ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_swcre(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_swcre(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_swcre",namelist_swcre)

;------- LWCRE section----------------------------
  namelist_lwcre = new(nsim+maxnumobs,string)
  if (obsflag) then
     lwcre_i = ind(vnamesB.eq."LWCRE")
     if (.not.ismissing(lwcre_i(0))) then
        incr = dimsizes(lwcre_i)
        do gg = 0,incr-1
           namelist_lwcre(gg) = namesB(lwcre_i(gg))+" | "+pathsB(lwcre_i(gg))+" | "+syearB(lwcre_i(gg))+" | "+eyearB(lwcre_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_lwcre(0))) then
              nmiss = ind(ismissing(namelist_lwcre(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_lwcre(hh) = namesB(lwcre_i(0))+"_"+hh+" | "+pathsB(lwcre_i(0))+" | "+syearB(lwcre_i(0))+" | "+eyearB(lwcre_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(lwcre_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "LWCRE,LWCF,lwcre,lwcf"       ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "LWCRE,LWCF"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_lwcre(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)     ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_lwcre(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_lwcre(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_lwcre",namelist_lwcre)

;------- TREFHT section----------------------------  
  namelist_trefht = new(nsim+maxnumobs,string)
  if (obsflag) then
     trefht_i = ind(vnamesB.eq."TREFHT")
     if (.not.ismissing(trefht_i(0))) then
        incr = dimsizes(trefht_i)
        do gg = 0,incr-1
           namelist_trefht(gg) = namesB(trefht_i(gg))+" | "+pathsB(trefht_i(gg))+" | "+syearB(trefht_i(gg))+" | "+eyearB(trefht_i(gg))+" | 0-Observations" 
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_trefht(0))) then
              nmiss = ind(ismissing(namelist_trefht(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_trefht(hh) = namesB(trefht_i(0))+"_"+hh+" | "+pathsB(trefht_i(0))+" | "+syearB(trefht_i(0))+" | "+eyearB(trefht_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(trefht_i)
  end if 
  
  if (case_sens.eq."True") then
     tstring1 = "TREFHT,tas,t_ref,T2"   ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "TREFHT,tas,t_ref,T2"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_trefht(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_trefht(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/") 
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then    
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_trefht(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do   
  asciiwrite("namelist_byvar/namelist_trefht",namelist_trefht)  

;----- PRECST section---------------
  namelist_precst = new(nsim+maxnumobs,string)
  if (obsflag) then
     precst_i = ind(vnamesB.eq."PRECST")
     if (.not.ismissing(precst_i(0))) then
        incr = dimsizes(precst_i)
        do gg = 0,incr-1
           namelist_precst(gg) = namesB(precst_i(gg))+" | "+pathsB(precst_i(gg))+" | "+syearB(precst_i(gg))+" | "+eyearB(precst_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_precst(0))) then
              nmiss = ind(ismissing(namelist_precst(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_precst(hh) = namesB(precst_i(0))+"_"+hh+" | "+pathsB(precst_i(0))+" | "+syearB(precst_i(0))+" | "+eyearB(precst_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(precst_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "PRECST,precst"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "PRECST"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_precst(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_precst(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_precst(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_precst",namelist_precst)

;----- VP920 section---------------
  namelist_vp920 = new(nsim+maxnumobs,string)
  if (obsflag) then
     vp920_i = ind(vnamesB.eq."VP920")
     if (.not.ismissing(vp920_i(0))) then
        incr = dimsizes(vp920_i)
        do gg = 0,incr-1
           namelist_vp920(gg) = namesB(vp920_i(gg))+" | "+pathsB(vp920_i(gg))+" | "+syearB(vp920_i(gg))+" | "+eyearB(vp920_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_vp920(0))) then
              nmiss = ind(ismissing(namelist_vp920(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_vp920(hh) = namesB(vp920_i(0))+"_"+hh+" | "+pathsB(vp920_i(0))+" | "+syearB(vp920_i(0))+" | "+eyearB(vp920_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(vp920_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "VP920,vp920,VP,vp"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "VP920,VP"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_vp920(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_vp920(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_vp920(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_vp920",namelist_vp920)

;----- VP470 section---------------
  namelist_vpot470 = new(nsim+maxnumobs,string)
  if (obsflag) then
     vpot_i = ind(vnamesB.eq."VP470")
     if (.not.ismissing(vpot_i(0))) then
        incr = dimsizes(vpot_i)
        do gg = 0,incr-1
           namelist_vpot470(gg) = namesB(vpot_i(gg))+" | "+pathsB(vpot_i(gg))+" | "+syearB(vpot_i(gg))+" | "+eyearB(vpot_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_vpot470(0))) then
              nmiss = ind(ismissing(namelist_vpot470(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_vpot470(hh) = namesB(vpot_i(0))+"_"+hh+" | "+pathsB(vpot_i(0))+" | "+syearB(vpot_i(0))+" | "+eyearB(vpot_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(vpot_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "VP470,vp470,VP,vp"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "VP470,VP"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_vpot470(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_vpot470(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_vpot470(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_vpot470",namelist_vpot470)

;----- SF920 section---------------
  namelist_sf920 = new(nsim+maxnumobs,string)
  if (obsflag) then
     sf920_i = ind(vnamesB.eq."SF920")
     if (.not.ismissing(sf920_i(0))) then
        incr = dimsizes(sf920_i)
        do gg = 0,incr-1
           namelist_sf920(gg) = namesB(sf920_i(gg))+" | "+pathsB(sf920_i(gg))+" | "+syearB(sf920_i(gg))+" | "+eyearB(sf920_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_sf920(0))) then
              nmiss = ind(ismissing(namelist_sf920(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_sf920(hh) = namesB(sf920_i(0))+"_"+hh+" | "+pathsB(sf920_i(0))+" | "+syearB(sf920_i(0))+" | "+eyearB(sf920_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(sf920_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "SF920,sf920,SF,sf"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "SF920,SF"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_sf920(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_sf920(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_sf920(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_sf920",namelist_sf920)

;----- SF470 section---------------
  namelist_sf470 = new(nsim+maxnumobs,string)
  if (obsflag) then
     sf470_i = ind(vnamesB.eq."SF470")
     if (.not.ismissing(sf470_i(0))) then
        incr = dimsizes(sf470_i)
        do gg = 0,incr-1
           namelist_sf470(gg) = namesB(sf470_i(gg))+" | "+pathsB(sf470_i(gg))+" | "+syearB(sf470_i(gg))+" | "+eyearB(sf470_i(gg))+" | 0-Observations"
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_sf470(0))) then
              nmiss = ind(ismissing(namelist_sf470(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_sf470(hh) = namesB(sf470_i(0))+"_"+hh+" | "+pathsB(sf470_i(0))+" | "+syearB(sf470_i(0))+" | "+eyearB(sf470_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(sf470_i)
  end if

  if (case_sens.eq."True") then
     tstring1 = "SF470,sf470,SF,sf"        ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "SF470,SF"
  end if
  sstr := str_split(tstring1,",")


  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_sf470(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_sf470(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/")
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_sf470(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do
  asciiwrite("namelist_byvar/namelist_sf470",namelist_sf470)

;------- PRECT section--(more complicated due to PRECC+PRECL, + pr being a common 2 letter combination)------  
  namelist_prect = new(nsim+maxnumobs,string)
  if (obsflag) then
     prect_i = ind(vnamesB.eq."PRECT")
     if (.not.ismissing(prect_i(0))) then
        incr = dimsizes(prect_i)
        do gg = 0,incr-1
           namelist_prect(gg) = namesB(prect_i(gg))+" | "+pathsB(prect_i(gg))+" | "+syearB(prect_i(gg))+" | "+eyearB(prect_i(gg))+" | 0-Observations" 
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-ouprect
           if (.not.ismissing(namelist_prect(0))) then
              nmiss = ind(ismissing(namelist_prect(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_prect(hh) = namesB(prect_i(0))+"_"+hh+" | "+pathsB(prect_i(0))+" | "+syearB(prect_i(0))+" | "+eyearB(prect_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(prect_i)
  end if 

  if (case_sens.eq."True") then
     tstring1 = "PRECT,PRECC,pr,precip,prate,prcp"   ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "PRECT,PRECC,pr,precip,prate,prcp"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_prect(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (sstr(hh).eq."PRECC") then   ; add PRECL to search string
              if (dimsizes(fsst).eq.1) then
                 fsst@path = str_sub_str(fsst,".PRECC.",".{PRECC,PRECL}.")
              else
                 fsst@path = str_sub_str(paths(gg)+"*."+sstr(hh)+".*.nc",".PRECC.",".{PRECC,PRECL}.")
              end if
           else
              if (dimsizes(fsst).eq.1) then
                 fsst@path = fsst
              else
                 fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
              end if
           end if
           namelist_prect(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else    ; if files have not been found, try the following
           if (sstr(hh).eq."PRECC") then
              tstring = "PRECC,PRECL"
           else
              tstring = sstr(hh)
           end if
           tpath = str_sub_str(paths(gg),"/*/","/"+tstring+"/") 
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),tstring)) then
                 x = addfile(fsst2(0),"r")
                 if (isfilevar(x,sstr(hh))) then
                    delete(x)
                    namelist_prect(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                    break
                 else
                    delete(x)
                 end if
              end if 
           end if
           delete([/tpath,tstring/])
        end if
     end do
  end do  
  asciiwrite("namelist_byvar/namelist_prect",namelist_prect)    
;------- MOC section----------------------------  
  namelist_moc = new(nsim+maxnumobs,string)
  if (obsflag) then
     moc_i = ind(vnamesB.eq."MOC")
     if (.not.ismissing(moc_i(0))) then
        incr = dimsizes(moc_i)
        do gg = 0,incr-1
           namelist_moc(gg) = namesB(moc_i(gg))+" | "+pathsB(moc_i(gg))+" | "+syearB(moc_i(gg))+" | "+eyearB(moc_i(gg))+" | 0-Observations" 
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_moc(0))) then
              nmiss = ind(ismissing(namelist_moc(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_moc(hh) = namesB(moc_i(0))+"_"+hh+" | "+pathsB(moc_i(0))+" | "+syearB(moc_i(0))+" | "+eyearB(moc_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(moc_i)
  end if 

  if (case_sens.eq."True") then
     tstring1 = "MOC,msftmyz,msftmz,stfmmc"   ; list in order of likelihood/preference: CESM name, CMIP name, other
  else
     tstring1 = "MOC,msftmyz,msftmz,stfmmc"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_moc(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)  ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_moc(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/") 
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_moc(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do   
  asciiwrite("namelist_byvar/namelist_moc",namelist_moc) 
;------- aice_nh section----------------------------  
  namelist_aice_nh = new(nsim+maxnumobs,string)
  if (obsflag) then
     aice_nh_i = ind(vnamesB.eq."aice_nh".or.vnamesB.eq."AICE_NH")
     if (.not.ismissing(aice_nh_i(0))) then
        incr = dimsizes(aice_nh_i)
        do gg = 0,incr-1
           namelist_aice_nh(gg) = namesB(aice_nh_i(gg))+" | "+pathsB(aice_nh_i(gg))+" | "+syearB(aice_nh_i(gg))+" | "+eyearB(aice_nh_i(gg))+" | 0-Observations" 
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_aice_nh(0))) then
              nmiss = ind(ismissing(namelist_aice_nh(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_aice_nh(hh) = namesB(aice_nh_i(0))+"_"+hh+" | "+pathsB(aice_nh_i(0))+" | "+syearB(aice_nh_i(0))+" | "+eyearB(aice_nh_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(aice_nh_i)
  end if 

  if (case_sens.eq."True") then
     tstring1 = "aice_nh,aice,siconc,sic,CN"   ; list in order of likelihood/preference: CESM name, CMIP name, other
  else                                         ; aice_nh (CESM1 nomenclature used in some data) should be checked before aice 
     tstring1 = "aice_nh,aice,siconc,sic,CN"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_aice_nh(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg) ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_aice_nh(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/") 
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_aice_nh(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do   
  asciiwrite("namelist_byvar/namelist_aice_nh",namelist_aice_nh) 

;------- aice_sh section----------------------------  
  namelist_aice_sh = new(nsim+maxnumobs,string)
  if (obsflag) then
     aice_sh_i = ind(vnamesB.eq."aice_sh".or.vnamesB.eq."AICE_SH")
     if (.not.ismissing(aice_sh_i(0))) then
        incr = dimsizes(aice_sh_i)
        do gg = 0,incr-1
           namelist_aice_sh(gg) = namesB(aice_sh_i(gg))+" | "+pathsB(aice_sh_i(gg))+" | "+syearB(aice_sh_i(gg))+" | "+eyearB(aice_sh_i(gg))+" | 0-Observations" 
        end do
        if (incr.lt.maxnumobs) then     ; fill in the missing obs rows with the first obs file, altering the name slightly for .nc write-outs
           if (.not.ismissing(namelist_aice_sh(0))) then
              nmiss = ind(ismissing(namelist_aice_sh(:maxnumobs-1)))
              do hh = nmiss(0),nmiss(dimsizes(nmiss)-1)
                 namelist_aice_sh(hh) = namesB(aice_sh_i(0))+"_"+hh+" | "+pathsB(aice_sh_i(0))+" | "+syearB(aice_sh_i(0))+" | "+eyearB(aice_sh_i(0))+" | 0-Observations"
              end do
              delete(nmiss)
           end if
        end if
        delete(incr)
     end if
     delete(aice_sh_i)
  end if 

  if (case_sens.eq."True") then
     tstring1 = "aice_sh,aice,siconc,sic,CN"   ; list in order of likelihood/preference: CESM name, CMIP name, other
  else                                         ; aice_sh (CESM1 nomenclature used in some data) should be checked before aice 
     tstring1 = "aice_sh,aice,siconc,sic,CN"
  end if
  sstr := str_split(tstring1,",")

  do gg = 0,nsim-1
     do hh = 0,dimsizes(sstr)-1
        namelist_aice_sh(gg+maxnumobs) =  names(gg)+" | missing | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg) ; set to missing as default
        fsst := systemfunc("bash -c 'ls "+paths(gg)+"*."+sstr(hh)+".*.nc 2> /dev/null'")   ; /dev/null suppresses all standard error output
        if (.not.ismissing(fsst(0))) then
           if (dimsizes(fsst).eq.1) then
              fsst@path = fsst
           else
              fsst@path = paths(gg)+"*."+sstr(hh)+".*.nc"
           end if
           namelist_aice_sh(gg+maxnumobs) =  names(gg)+" | "+fsst@path+" | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
           break
        else  ; try different method to find files
           tpath := str_sub_str(paths(gg),"/*/","/"+sstr(hh)+"/") 
           tpath = str_sub_str(tpath,"/*_","/"+sstr(hh)+"_")
           fsst2 := systemfunc("bash -c 'ls "+tpath+"*.nc 2> /dev/null'")
           if (.not.ismissing(fsst2(0))) then
              if (str_match_bool(fsst2(0),sstr(hh))) then
                 namelist_aice_sh(gg+maxnumobs) =  names(gg)+" | "+tpath+"*.nc | "+syear(gg)+" | "+eyear(gg)+" | "+names_EM(gg)
                 break
              end if
           end if
        end if
     end do
  end do    
  asciiwrite("namelist_byvar/namelist_aice_sh",namelist_aice_sh) 
;----------------------------------------------------------------------------
  if (obsflag) then
     delete([/vnamesB,namesB,pathsB,syearB,eyearB/])
  end if
  print("Finished: namelist.ncl")
end
