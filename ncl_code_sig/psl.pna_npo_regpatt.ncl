; Calculates PNA, NPO and  (patterns and PC timeseries), as well as 
; regressions of those PC timeseries onto selected quantities (see reg_var)
;
; Variables used: psl and selected quantities 
; 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: psl.pna_npo_regpatt.ncl")
  
  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")  
  OUTPUT_DATA      = getenv("OUTPUT_DATA")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COMPUTE_MODES_MON = getenv("COMPUTE_MODES_MON")
  COLORMAP         = getenv("COLORMAP")  
  
  nsim = numAsciiRow("namelist_byvar/namelist_psl")
  na = asciiread("namelist_byvar/namelist_psl",(/nsim/),"string")
  names = new(nsim,"string")
  paths = new(nsim,"string")
  syear = new(nsim,"integer",-999)
  eyear = new(nsim,"integer",-999)
  delim = "|"

  do gg = 0,nsim-1
     names(gg) = str_strip(str_get_field(na(gg),1,delim))
     paths(gg) = str_strip(str_get_field(na(gg),2,delim))
     syear(gg) = stringtointeger(str_strip(str_get_field(na(gg),3,delim)))
     eyear(gg) = stringtointeger(str_strip(str_get_field(na(gg),4,delim)))
  end do
  nyr = eyear-syear+1
  nyr_max = max(nyr)

  pi=4.*atan(1.0)
  rad=(pi/180.)
 
 regvars = (/"psl","sst","trefht","prect","u10","v10","taux","tauy","shflx","lhflx", "eth", \
             "swcre","olr","cldtot","u850","v850","th850","z500","u200","v200"/)
 landmsk = (/    0,    1,       0,      0,    0,    0,     0,     0,   0,   0,     1, \
                   0,      0,       0,     0,     0,      0,     0,     0,   0 /)
 varfacs = (/3.0,   1.0,     1.0,    1.0,  1.0,  1.0,   2.0,   2.0, 5.0, 10.0,  5.0, \
                  5.0, 5.0,     5.0,  2.0,    2.0,  1.0,   15.0,   5.0,   2.5/)
 nsvars  = dimsizes(regvars)

 do ss = 0, nsvars-1,1
  ;---------Regressions coding-------------------------------------------------
  if(regvars(ss).eq."sst") then 
    vnm   = "ts"
  else 
    vnm   = regvars(ss)
  end if 
  lmsk  = landmsk(ss)
  vrfac = varfacs(ss)
  nsim_reg = numAsciiRow("namelist_byvar/namelist_"+vnm)
  na_reg   = asciiread("namelist_byvar/namelist_"+vnm,(/nsim_reg/),"string")

  names_reg = new(nsim_reg,"string")
  paths_reg = new(nsim_reg,"string")
  syear_reg = new(nsim_reg,"integer",-999)
  eyear_reg = new(nsim_reg,"integer",-999)

  do gg = 0,nsim_reg-1
     names_reg(gg) = str_strip(str_get_field(na_reg(gg),1,delim))
     paths_reg(gg) = str_strip(str_get_field(na_reg(gg),2,delim))
     syear_reg(gg) = stringtointeger(str_strip(str_get_field(na_reg(gg),3,delim)))
     eyear_reg(gg) = stringtointeger(str_strip(str_get_field(na_reg(gg),4,delim)))
  end do
  delete(na_reg)
  nyr_reg = eyear_reg-syear_reg+1 
 
;-------------------------------------------------------------------------------------------------
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if
  
  wks_pna  = gsn_open_wks(wks_type,getenv("OUTDIR")+"pna.vxreg")
  wks_npo = gsn_open_wks(wks_type,getenv("OUTDIR")+"npo.vxreg")
  
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_pna,"MPL_RdBu")  
     gsn_define_colormap(wks_npo,"MPL_RdBu") 
     gsn_reverse_colormap(wks_pna)           ; Reverse the color map.
     gsn_reverse_colormap(wks_npo)           ; Reverse the color map.
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_pna,"NCV_jaisnd")  
     gsn_define_colormap(wks_npo,"NCV_jaisnd") 
  end if
  
  reg_pna_djf = new(nsim,"graphic")  
  reg_pna_mam = new(nsim,"graphic")  
  reg_pna_jja = new(nsim,"graphic")  
  reg_pna_son = new(nsim,"graphic")  
  reg_pna_ann = new(nsim,"graphic")  
  reg_pna_mon = new(nsim,"graphic")  
  
  reg_npo_djf = new(nsim,"graphic")  
  reg_npo_mam = new(nsim,"graphic")  
  reg_npo_jja = new(nsim,"graphic")  
  reg_npo_son = new(nsim,"graphic")  
  reg_npo_ann = new(nsim,"graphic")  
  reg_npo_mon = new(nsim,"graphic")  
  
  vxreg_frame  = 1 

  do ee = 0,nsim-1
;    print(paths(ee)+" "+syear(ee)+" "+eyear(ee)) 
     arr = data_read_in(paths(ee),"PSL",syear(ee),eyear(ee))    ; read in data, orient lats/lons correctly, set time coordinate variable up
     if (isatt(arr,"is_all_missing")) then
        delete(arr)
        continue
     end if 
     
     if (OPT_CLIMO.eq."Full") then
        arr = rmMonAnnCycTLL(arr)
     else
        check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
        temp_arr = arr
        delete(temp_arr&time)
        temp_arr&time = cd_calendar(arr&time,-1)
        if (CLIMO_SYEAR.lt.0) then
           climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
        else
           climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
        end if   
        delete(temp_arr)
        arr   = calcMonAnomTLL(arr,climo) 
        delete(climo)
     end if

     arrT =  runave_n_Wrap(arr,3,0,0)               ; form DJF averages
     arrT(0,:,:) = (/ dim_avg_n(arr(:1,:,:),0) /)   
     arr_djf = arrT(0::12,:,:)
     arr_mam = arrT(3::12,:,:)
     arr_jja = arrT(6::12,:,:)                       ; form JJA averages
     arr_son = arrT(9::12,:,:)
     delete(arrT)
     
     arrV = runave_n_Wrap(arr,12,0,0)
     arr_ann = arrV(5::12,:,:)
     delete(arrV)
;          
;     arr_djf = (/ dtrend_msg_n(ispan(0,dimsizes(arr_djf&time)-1,1),arr_djf,True,False,0) /)
;     arr_mam = (/ dtrend_msg_n(ispan(0,dimsizes(arr_mam&time)-1,1),arr_mam,True,False,0) /)
;     arr_jja = (/ dtrend_msg_n(ispan(0,dimsizes(arr_jja&time)-1,1),arr_jja,True,False,0) /)
;     arr_son = (/ dtrend_msg_n(ispan(0,dimsizes(arr_son&time)-1,1),arr_son,True,False,0) /)
;     
;     arr_ann = (/ dtrend_msg_n(ispan(0,dimsizes(arr_ann&time)-1,1),arr_ann,True,False,0) /)
;     
;     arr_ndjfm = (/ dtrend_msg_n(ispan(0,dimsizes(arr_ndjfm&time)-1,1),arr_ndjfm,True,False,0) /)
;     
;     arr = (/ dtrend_msg_n(ispan(0,dimsizes(arr&time)-1,1),arr,True,False,0) /)
;---------Regressions coding-------------------------------------------------
     if (any(ismissing((/syear(ee),syear_reg(ee),eyear(ee),eyear_reg(ee)/)))) then
        vxreg_plot_flag = 1
     else
        if (syear(ee).eq.syear_reg(ee)) then     ; check that the start and end years match for regression variable 
           if (eyear(ee).eq.eyear_reg(ee)) then
              vxreg_plot_flag = 0
           else
              vxreg_plot_flag = 1
           end if
        else
           vxreg_plot_flag = 1
        end if
     end if 

     if (vxreg_plot_flag.eq.0) then 
        ; print("Data to be read in: "+paths_reg(ee)+" from "+syear_reg(ee)+":"+eyear_reg(ee))
        if(vnm.eq."qnet") then
          vnmi = "Qn"
        else
          vnmi = str_upper(vnm)
        end if
        vreg = data_read_in(paths_reg(ee),vnmi,syear_reg(ee),eyear_reg(ee))
        if (isatt(vreg,"is_all_missing")) then
           vxreg_plot_flag = 1
           delete(vreg)
        end if
        
        if (vxreg_plot_flag.eq.0) then     ; only continue if both PSL/TS fields are present
           if(vnm.eq."ts") then 
             vreg = where(vreg.le.-1.8,-1.8,vreg)
           end if 
           if(vnm.eq."trefht") then
             d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")    
             basemap = d->LSMASK
             lsm = landsea_mask(basemap,vreg&lat,vreg&lon)
             vreg = mask(vreg,conform(vreg,lsm,(/1,2/)).eq.0,False)
             delete(lsm)
           end if 
           if(lmsk.eq.1) then 
             d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   
             basemap = d->LSMASK
             lsm = landsea_mask(basemap,vreg&lat,vreg&lon)
             vreg = mask(vreg,conform(vreg,lsm,(/1,2/)).ge.1,False)
             delete(lsm)
           end if   
           if (OPT_CLIMO.eq."Full") then
              vreg = rmMonAnnCycTLL(vreg)
           else
              check_custom_climo(names_reg(ee),syear_reg(ee),eyear_reg(ee),CLIMO_SYEAR,CLIMO_EYEAR)
              temp_arr = vreg
              delete(temp_arr&time)
              temp_arr&time = cd_calendar(vreg&time,1)
              if (CLIMO_SYEAR.lt.0) then
                 climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
              else
                 climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
              end if   
              delete(temp_arr)
              vreg   = calcMonAnomTLL(vreg,climo) 
              delete(climo)
           end if
;           vreg = (/ dtrend_msg_n(ispan(0,dimsizes(vreg&time)-1,1),vreg,False,False,0) /)  
        
           vregT =  runave_n_Wrap(vreg,3,0,0)               ; form DJF averages
           vregT(0,:,:) = (/ dim_avg_n(vreg(:1,:,:),0) /)   
           vreg_djf = vregT(0::12,:,:)
           vreg_mam = vregT(3::12,:,:)
           vreg_jja = vregT(6::12,:,:)                       ; form JJA averages
           vreg_son = vregT(9::12,:,:)
           delete(vregT)
     
           vregV = runave_n_Wrap(vreg,12,0,0)
           vreg_ann = vregV(5::12,:,:)
           delete(vregV)
        end if
     end if    
;------------------------------------------------------------------
     arr_djf_CW = SqrtCosWeight(arr_djf)
     arr_mam_CW = SqrtCosWeight(arr_mam)
     arr_jja_CW = SqrtCosWeight(arr_jja)
     arr_son_CW = SqrtCosWeight(arr_son)
     arr_ann_CW = SqrtCosWeight(arr_ann)
     if (COMPUTE_MODES_MON.eq."True") then   
        arr_mon_CW = SqrtCosWeight(arr)
     else
        if (isvar("arr")) then
           delete(arr)
        end if
        if (isvar("vreg")) then
           delete(vreg)
        end if 
     end if    
;----------PNA/NPO/ calculations----------------------------------------------------------------------     
     evecv = eofunc(arr_djf_CW({lat|20:85},{lon|120:240},time|:),3,75)
     pcts = eofunc_ts(arr_djf_CW({lat|20:85},{lon|120:240},time|:),evecv,False)  
     pna_pc_djf = dim_standardize(pcts(0,:),0)
     npo_pc_djf = dim_standardize(pcts(1,:),0)
     pna_djf = arr_djf(0,:,:)
     pna_djf = (/ regCoef(pna_pc_djf,arr_djf(lat|:,lon|:,time|:)) /)
     npo_djf = arr_djf(0,:,:)
     npo_djf = (/ regCoef(npo_pc_djf,arr_djf(lat|:,lon|:,time|:)) /)

     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(pna_pc_djf, vreg_djf, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval    
        b         = 0.5
        pna_vreg_djf  = vreg_djf(0,:,:)
        pna_prob_djf  = vreg_djf(0,:,:)
        pna_vreg_djf  = (/ rc /) 
        pna_prob_djf  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/)
        pna_prob_djf  = where(ismissing(pna_vreg_djf),pna_vreg_djf@_FillValue,pna_prob_djf)
        pna_vreg_djf@units = vreg_djf@units +" (per std dev)"
        delete([/rc,tval,df,b/]) 
        rc        = regCoef_n(npo_pc_djf, vreg_djf, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval    
        b         = 0.5
        npo_vreg_djf  = vreg_djf(0,:,:)
        npo_prob_djf  = vreg_djf(0,:,:)
        npo_vreg_djf  = (/ rc /) 
        npo_prob_djf  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/)
        npo_prob_djf  = where(ismissing(npo_vreg_djf),npo_vreg_djf@_FillValue,npo_prob_djf)
        npo_vreg_djf@units = vreg_djf@units +" (per std dev)"
        delete([/rc,tval,df,b,vreg_djf/]) 
     end if     
     
     if (.not.all(ismissing(pna_djf({47:52},{182:187})))) then
        if (avg(pna_djf({-82:},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           pna_djf = pna_djf*-1.
           pna_pc_djf = pna_pc_djf*-1.
           if (vxreg_plot_flag.eq.0) then
              pna_vreg_djf = pna_vreg_djf*-1.
           end if
        end if
     end if
     if (.not.all(ismissing(npo_djf({62:67},{182:187})))) then
        if (avg(npo_djf({62:67},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           npo_djf = npo_djf*-1.
           npo_pc_djf = npo_pc_djf*-1.
           if (vxreg_plot_flag.eq.0) then
              npo_vreg_djf = npo_vreg_djf*-1.
           end if
        end if
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(pna_pc_djf),False)
     if (sig_pcv(0)) then    ; if True then significant
        pna_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        pna_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     if (sig_pcv(1)) then    ; if True then significant
        npo_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
     else
        npo_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
     end if
     delete(sig_pcv)    
     pna_pc_djf!0 = "TIME"
     pna_pc_djf&TIME = ispan(syear(ee),eyear(ee),1)
     pna_pc_djf&TIME@units = "YYYY"
     pna_pc_djf&TIME@long_name = "time"     
     
     copy_VarCoords(pna_pc_djf,npo_pc_djf)
     delete([/evecv,pcts/])
     
     evecv = eofunc(arr_mam_CW({lat|20:85},{lon|120:240},time|:),3,75)
     pcts = eofunc_ts(arr_mam_CW({lat|20:85},{lon|120:240},time|:),evecv,False)  
     pna_pc_mam = dim_standardize(pcts(0,:),0)
     npo_pc_mam = dim_standardize(pcts(1,:),0)
     pna_mam = arr_mam(0,:,:)
     pna_mam = (/ regCoef(pna_pc_mam,arr_mam(lat|:,lon|:,time|:)) /)
     npo_mam = arr_mam(0,:,:)
     npo_mam = (/ regCoef(npo_pc_mam,arr_mam(lat|:,lon|:,time|:)) /)
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(pna_pc_mam, vreg_mam, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        pna_vreg_mam  = vreg_mam(0,:,:)
        pna_prob_mam  = vreg_mam(0,:,:)
        pna_vreg_mam  = (/ rc /)
        pna_prob_mam  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        pna_prob_mam  = where(ismissing(pna_vreg_mam),pna_vreg_mam@_FillValue,pna_prob_mam)
        pna_vreg_mam@units = vreg_mam@units +" (per std dev)"
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(npo_pc_mam, vreg_mam, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        npo_vreg_mam  = vreg_mam(0,:,:)
        npo_prob_mam  = vreg_mam(0,:,:)
        npo_vreg_mam  = (/ rc /)
        npo_prob_mam  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        npo_prob_mam  = where(ismissing(npo_vreg_mam),npo_vreg_mam@_FillValue,npo_prob_mam)
        npo_vreg_mam@units = vreg_mam@units +" (per std dev)"
        delete([/rc,tval,df,b,vreg_mam/])
     end if

     if (.not.all(ismissing(pna_mam({47:52},{182:187})))) then
        if (avg(pna_mam({47:52},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           pna_mam = pna_mam*-1.
           pna_pc_mam = pna_pc_mam*-1.
           if (vxreg_plot_flag.eq.0) then
              pna_vreg_mam = pna_vreg_mam*-1.
           end if
        end if
     end if
     if (.not.all(ismissing(npo_mam({62:67},{182:187})))) then
        if (avg(npo_mam({62:67},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           npo_mam = npo_mam*-1.
           npo_pc_mam = npo_pc_mam*-1.
           if (vxreg_plot_flag.eq.0) then
              npo_vreg_mam = npo_vreg_mam*-1.
           end if
        end if
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(pna_pc_mam),False)
     if (sig_pcv(0)) then    ; if True then significant
        pna_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        pna_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     if (sig_pcv(1)) then    ; if True then significant
        npo_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
     else
        npo_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(pna_pc_djf,pna_pc_mam) 
     copy_VarCoords(pna_pc_djf,npo_pc_mam)
     delete([/evecv,pcts/])
     
     evecv = eofunc(arr_jja_CW({lat|20:85},{lon|120:240},time|:),3,75)
     pcts = eofunc_ts(arr_jja_CW({lat|20:85},{lon|120:240},time|:),evecv,False)  
     pna_pc_jja = dim_standardize(pcts(0,:),0)
     npo_pc_jja = dim_standardize(pcts(1,:),0)
     pna_jja = arr_jja(0,:,:)
     pna_jja = (/ regCoef(pna_pc_jja,arr_jja(lat|:,lon|:,time|:)) /)
     npo_jja = arr_jja(0,:,:)
     npo_jja = (/ regCoef(npo_pc_jja,arr_jja(lat|:,lon|:,time|:)) /)
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(pna_pc_jja, vreg_jja, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        pna_vreg_jja  = vreg_jja(0,:,:)
        pna_prob_jja  = vreg_jja(0,:,:)
        pna_vreg_jja  = (/ rc /)
        pna_prob_jja  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        pna_prob_jja  = where(ismissing(pna_vreg_jja),pna_vreg_jja@_FillValue,pna_prob_jja)
        pna_vreg_jja@units = vreg_jja@units +" (per std dev)"
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(npo_pc_jja, vreg_jja, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        npo_vreg_jja  = vreg_jja(0,:,:)
        npo_prob_jja  = vreg_jja(0,:,:)
        npo_vreg_jja  = (/ rc /)
        npo_prob_jja  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        npo_prob_jja  = where(ismissing(npo_vreg_jja),npo_vreg_jja@_FillValue,npo_prob_jja)
        npo_vreg_jja@units = vreg_jja@units +" (per std dev)"
        delete([/rc,tval,df,b,vreg_jja/])
     end if

     if (.not.all(ismissing(pna_jja({47:52},{182:187})))) then
        if (avg(pna_jja({47:52},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           pna_jja = pna_jja*-1.
           pna_pc_jja = pna_pc_jja*-1.
           if (vxreg_plot_flag.eq.0) then
              pna_vreg_jja = pna_vreg_jja*-1.
           end if
        end if
     end if
     if (.not.all(ismissing(npo_jja({62:67},{182:187})))) then
        if (avg(npo_jja({62:67},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           npo_jja = npo_jja*-1.
           npo_pc_jja = npo_pc_jja*-1.
           if (vxreg_plot_flag.eq.0) then
              npo_vreg_jja = npo_vreg_jja*-1.
           end if
        end if
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(pna_pc_jja),False)
     if (sig_pcv(0)) then    ; if True then significant
        pna_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        pna_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     if (sig_pcv(1)) then    ; if True then significant
        npo_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
     else
        npo_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(pna_pc_djf,pna_pc_jja) 
     copy_VarCoords(pna_pc_djf,npo_pc_jja)
     delete([/evecv,pcts/])
 
     evecv = eofunc(arr_son_CW({lat|20:85},{lon|120:240},time|:),3,75)
     pcts = eofunc_ts(arr_son_CW({lat|20:85},{lon|120:240},time|:),evecv,False)  
     pna_pc_son = dim_standardize(pcts(0,:),0)
     npo_pc_son = dim_standardize(pcts(1,:),0)
     pna_son = arr_son(0,:,:)
     pna_son = (/ regCoef(pna_pc_son,arr_son(lat|:,lon|:,time|:)) /)
     npo_son = arr_son(0,:,:)
     npo_son = (/ regCoef(npo_pc_son,arr_son(lat|:,lon|:,time|:)) /)
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(pna_pc_son, vreg_son, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        pna_vreg_son  = vreg_son(0,:,:)
        pna_prob_son  = vreg_son(0,:,:)
        pna_vreg_son  = (/ rc /)
        pna_prob_son  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        pna_prob_son  = where(ismissing(pna_vreg_son),pna_vreg_son@_FillValue,pna_prob_son)
        pna_vreg_son@units = vreg_son@units +" (per std dev)"
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(npo_pc_son, vreg_son, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        npo_vreg_son  = vreg_son(0,:,:)
        npo_prob_son  = vreg_son(0,:,:)
        npo_vreg_son  = (/ rc /)
        npo_prob_son  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        npo_prob_son  = where(ismissing(npo_vreg_son),npo_vreg_son@_FillValue,npo_prob_son)
        npo_vreg_son@units = vreg_son@units +" (per std dev)"
        delete([/rc,tval,df,b,vreg_son/])
     end if

     if (.not.all(ismissing(pna_son({47:52},{182:187})))) then
        if (avg(pna_son({47:52},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           pna_son = pna_son*-1.
           pna_pc_son = pna_pc_son*-1.
           if (vxreg_plot_flag.eq.0) then
              pna_vreg_son = pna_vreg_son*-1.
           end if
        end if
     end if
     if (.not.all(ismissing(npo_son({62:67},{182:187})))) then
        if (avg(npo_son({62:67},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           npo_son = npo_son*-1.
           npo_pc_son = npo_pc_son*-1.
           if (vxreg_plot_flag.eq.0) then
              npo_vreg_son = npo_vreg_son*-1.
           end if
        end if
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(pna_pc_son),False)
     if (sig_pcv(0)) then    ; if True then significant
        pna_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        pna_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     if (sig_pcv(1)) then    ; if True then significant
        npo_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
     else
        npo_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(pna_pc_djf,pna_pc_son) 
     copy_VarCoords(pna_pc_djf,npo_pc_son)
     delete([/evecv,pcts/])

     evecv = eofunc(arr_ann_CW({lat|20:85},{lon|120:240},time|:),3,75)
     pcts = eofunc_ts(arr_ann_CW({lat|20:85},{lon|120:240},time|:),evecv,False)  
     pna_pc_ann = dim_standardize(pcts(0,:),0)
     npo_pc_ann = dim_standardize(pcts(1,:),0)
     pna_ann = arr_ann(0,:,:)
     pna_ann = (/ regCoef(pna_pc_ann,arr_ann(lat|:,lon|:,time|:)) /)
     npo_ann = arr_ann(0,:,:)
     npo_ann = (/ regCoef(npo_pc_ann,arr_ann(lat|:,lon|:,time|:)) /)
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(pna_pc_ann, vreg_ann, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        pna_vreg_ann  = vreg_ann(0,:,:)
        pna_prob_ann  = vreg_ann(0,:,:)
        pna_vreg_ann  = (/ rc /)
        pna_prob_ann  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        pna_prob_ann  = where(ismissing(pna_vreg_ann),pna_vreg_ann@_FillValue,pna_prob_ann)
        pna_vreg_ann@units = vreg_ann@units +" (per std dev)"
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(npo_pc_ann, vreg_ann, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        npo_vreg_ann  = vreg_ann(0,:,:)
        npo_prob_ann  = vreg_ann(0,:,:)
        npo_vreg_ann  = (/ rc /)
        npo_prob_ann  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        npo_prob_ann  = where(ismissing(npo_vreg_ann),npo_vreg_ann@_FillValue,npo_prob_ann)
        npo_vreg_ann@units = vreg_ann@units +" (per std dev)"
        delete([/rc,tval,df,b,vreg_ann/])
     end if

     if (.not.all(ismissing(pna_ann({47:52},{182:187})))) then
        if (avg(pna_ann({47:52},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           pna_ann = pna_ann*-1.
           pna_pc_ann = pna_pc_ann*-1.
           if (vxreg_plot_flag.eq.0) then
              pna_vreg_ann = pna_vreg_ann*-1.
           end if
        end if
     end if
     if (.not.all(ismissing(npo_ann({62:67},{182:187})))) then
        if (avg(npo_ann({62:67},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           npo_ann = npo_ann*-1.
           npo_pc_ann = npo_pc_ann*-1.
           if (vxreg_plot_flag.eq.0) then
              npo_vreg_ann = npo_vreg_ann*-1.
           end if
        end if
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(pna_pc_ann),False)
     if (sig_pcv(0)) then    ; if True then significant
        pna_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        pna_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     if (sig_pcv(1)) then    ; if True then significant
        npo_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
     else
        npo_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(pna_pc_djf,pna_pc_ann) 
     copy_VarCoords(pna_pc_djf,npo_pc_ann)
     delete([/evecv,pcts/])
     
     if (COMPUTE_MODES_MON.eq."True") then     
        evecv = eofunc(arr_mon_CW({lat|20:85},{lon|120:240},time|:),3,75)
        pcts = eofunc_ts(arr_mon_CW({lat|20:85},{lon|120:240},time|:),evecv,False)  
        pna_pc_mon = dim_standardize(pcts(0,:),0)
        npo_pc_mon = dim_standardize(pcts(1,:),0)
        pna_mon = arr(0,:,:)
        pna_mon = (/ regCoef(pna_pc_mon,arr(lat|:,lon|:,time|:)) /)
        npo_mon = arr(0,:,:)
        npo_mon = (/ regCoef(npo_pc_mon,arr(lat|:,lon|:,time|:)) /)
        if (vxreg_plot_flag.eq.0) then
           rc           = regCoef_n(pna_pc_mon, vreg, 0, 0) ; rc(nlat,mlon)
           tval         = onedtond(rc@tval , dimsizes(rc))
           df           = onedtond(rc@nptxy, dimsizes(rc)) - 2
           b            = tval
           b            = 0.5
           pna_vreg_mon  = vreg(0,:,:)
           pna_prob_mon  = vreg(0,:,:)
           pna_vreg_mon  = (/ rc /)
           pna_prob_mon  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
           pna_prob_mon  = where(ismissing(pna_vreg_mon),pna_vreg_mon@_FillValue,pna_prob_mon)
           pna_vreg_mon@units = vreg@units +" (per std dev)"
           delete([/rc,tval,df,b/])
           rc           = regCoef_n(npo_pc_mon, vreg, 0, 0) ; rc(nlat,mlon)
           tval         = onedtond(rc@tval , dimsizes(rc))
           df           = onedtond(rc@nptxy, dimsizes(rc)) - 2
           b            = tval
           b            = 0.5
           npo_vreg_mon  = vreg(0,:,:)
           npo_prob_mon  = vreg(0,:,:)
           npo_vreg_mon  = (/ rc /)
           npo_prob_mon  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
           npo_prob_mon  = where(ismissing(npo_vreg_mon),npo_vreg_mon@_FillValue,npo_prob_mon)
           npo_vreg_mon@units = vreg@units +" (per std dev)"
           delete([/rc,tval,df,b,vreg/])
        end if

        if (.not.all(ismissing(pna_mon({47:52},{182:187})))) then
           if (avg(pna_mon({47:52},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
              pna_mon = pna_mon*-1.
              pna_pc_mon = pna_pc_mon*-1.
              if (vxreg_plot_flag.eq.0) then
                 pna_vreg_mon = pna_vreg_mon*-1.
              end if
           end if
        end if
        if (.not.all(ismissing(npo_mon({62:67},{182:187})))) then
           if (avg(npo_mon({62:67},{182:187})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
              npo_mon = npo_mon*-1.
              npo_pc_mon = npo_pc_mon*-1.
              if (vxreg_plot_flag.eq.0) then
                 npo_vreg_mon = npo_vreg_mon*-1.
              end if
           end if
        end if
        sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(pna_pc_mon),False)
        if (sig_pcv(0)) then    ; if True then significant
           pna_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
        else
           pna_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
        end if
        if (sig_pcv(1)) then    ; if True then significant
           npo_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
        else
           npo_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
        end if
        delete(sig_pcv)
        pna_pc_mon!0 = "time"
        pna_pc_mon&time = arr&time   
        npo_pc_mon!0 = "time"
        npo_pc_mon&time = arr&time   
        delete([/evecv,pcts,arr_mon_CW,arr/])
     end if
     delete([/arr_djf_CW,arr_mam_CW,arr_jja_CW,arr_son_CW,arr_ann_CW/])
     delete([/arr_djf,arr_mam,arr_jja,arr_son,arr_ann/])

;------------------------------------------------------------------------------------------------------
     if (vxreg_frame.eq.1.and.vxreg_plot_flag.eq.0) then      ; vxreg_frame = flag to create regressions .ps/.png files 
        vxreg_frame = 0
     end if            
;------------------------------------------------------------------------------------------------------
     if (OUTPUT_DATA.eq."True") then
        if (vxreg_plot_flag.eq.0) then
           modname = str_sub_str(names_reg(ee)," ","_")
           bc = (/"/","'","(",")"/)
           do gg = 0,dimsizes(bc)-1
              modname = str_sub_str(modname,bc(gg),"_")
           end do
           fn = getenv("OUTDIR")+modname+".cvdp_data.psl.pna_npo."+vnm+"."+syear_reg(ee)+"-"+eyear_reg(ee)+".nc"
           if (.not.isfilepresent2(fn)) then
              z = addfile(fn,"c")
              z@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
              z@notes = "Data from "+names_reg(ee)+" from "+syear_reg(ee)+"-"+eyear_reg(ee)
              if (OPT_CLIMO.eq."Full") then
                 z@climatology = syear_reg(ee)+"-"+eyear_reg(ee)+" climatology removed prior to all calculations (other than means)"
              else
                 if (CLIMO_SYEAR.lt.0) then
                    z@climatology = (eyear(ee)+CLIMO_SYEAR)+"-"+(eyear(ee)+CLIMO_EYEAR)+" climatology removed prior to all calculations (other than means)"
                 else
                    z@climatology = CLIMO_SYEAR+"-"+CLIMO_EYEAR+" climatology removed prior to all calculations (other than means)"
                 end if
              end if
              z@Conventions = "CF-1.6"
           else
              z = addfile(fn,"w")
           end if

           z->pna_timeseries_djf = set_varAtts(pna_pc_djf,"PNA normalized principal component timeseries (DJF)","1","")
           z->pna_timeseries_mam = set_varAtts(pna_pc_mam,"PNA normalized principal component timeseries (MAM)","1","")
           z->pna_timeseries_jja = set_varAtts(pna_pc_jja,"PNA normalized principal component timeseries (JJA)","1","")
           z->pna_timeseries_son = set_varAtts(pna_pc_son,"PNA normalized principal component timeseries (SON)","1","")
           z->pna_timeseries_ann = set_varAtts(pna_pc_ann,"PNA normalized principal component timeseries (annual)","1","")

           z->npo_timeseries_djf = set_varAtts(npo_pc_djf,"NPO normalized principal component timeseries (DJF)","1","")
           z->npo_timeseries_mam = set_varAtts(npo_pc_mam,"NPO normalized principal component timeseries (MAM)","1","")
           z->npo_timeseries_jja = set_varAtts(npo_pc_jja,"NPO normalized principal component timeseries (JJA)","1","")
           z->npo_timeseries_son = set_varAtts(npo_pc_son,"NPO normalized principal component timeseries (SON)","1","")
           z->npo_timeseries_ann = set_varAtts(npo_pc_ann,"NPO normalized principal component timeseries (annual)","1","")

           vout = "pna_"+vnm+"_regression_djf"
           vosr = vnm+" regression onto PNA principal component timeseries (DJF)"
           z->$vout$ = set_varAtts(pna_vreg_djf,vosr,"","") 
           vout = "pna_"+vnm+"_regression_mam"
           vosr = vnm+" regression onto PNA principal component timeseries (MAM)"
           z->$vout$ = set_varAtts(pna_vreg_mam,vosr,"","")  
           vout = "pna_"+vnm+"_regression_jja"
           vosr = vnm+" regression onto PNA principal component timeseries (JJA)"
           z->$vout$ = set_varAtts(pna_vreg_jja,vosr,"","")  
           vout = "pna_"+vnm+"_regression_son"
           vosr = vnm+" regression onto PNA principal component timeseries (SON)"
           z->$vout$ = set_varAtts(pna_vreg_son,vosr,"","")  
           vout = "pna_"+vnm+"_regression_ann"
           vosr = vnm+" regression onto PNA principal component timeseries (annual)"
           z->$vout$ = set_varAtts(pna_vreg_ann,vosr,"","")  

           vout = "npo_"+vnm+"_regression_djf"
           vosr = vnm+" regression onto NPO principal component timeseries (DJF)"
           z->$vout$ = set_varAtts(npo_vreg_djf,vosr,"","")
           vout = "npo_"+vnm+"_regression_mam"
           vosr = vnm+" regression onto NPO principal component timeseries (MAM)"
           z->$vout$ = set_varAtts(npo_vreg_mam,vosr,"","")
           vout = "npo_"+vnm+"_regression_jja"
           vosr = vnm+" regression onto NPO principal component timeseries (JJA)"
           z->$vout$ = set_varAtts(npo_vreg_jja,vosr,"","")
           vout = "npo_"+vnm+"_regression_son"
           vosr = vnm+" regression onto NPO principal component timeseries (SON)"
           z->$vout$ = set_varAtts(npo_vreg_son,vosr,"","")  
           vout = "npo_"+vnm+"_regression_ann"
           vosr = vnm+" regression onto NPO principal component timeseries (annual)"
           z->$vout$ = set_varAtts(npo_vreg_ann,vosr,"","")

           vout = "pna_"+vnm+"_regprob_djf"
           vosr = vnm+" PNA regression t-test probility(DJF)"
           z->$vout$ = set_varAtts(pna_prob_djf,vosr,"","")
           vout = "pna_"+vnm+"_regprob_mam"
           vosr = vnm+" PNA regression t-test probility(MAM)"
           z->$vout$ = set_varAtts(pna_prob_mam,vosr,"","")
           vout = "pna_"+vnm+"_regprob_jja"
           vosr = vnm+" PNA regression t-test probility(JJA)"
           z->$vout$ = set_varAtts(pna_prob_jja,vosr,"","")
           vout = "pna_"+vnm+"_regprob_son"
           vosr = vnm+" PNA regression t-test probility(SON)"
           z->$vout$ = set_varAtts(pna_prob_son,vosr,"","")
           vout = "pna_"+vnm+"_regprob_ann"
           vosr = vnm+" PNA regression t-test probility(annual)"
           z->$vout$ = set_varAtts(pna_prob_ann,vosr,"","")

           vout = "npo_"+vnm+"_regprob_djf"
           vosr = vnm+" NPO regression t-test probility(DJF)"
           z->$vout$ = set_varAtts(npo_prob_djf,vosr,"","")
           vout = "npo_"+vnm+"_regprob_mam"
           vosr = vnm+" NPO regression t-test probility(MAM)"
           z->$vout$ = set_varAtts(npo_prob_mam,vosr,"","")
           vout = "npo_"+vnm+"_regprob_jja"
           vosr = vnm+" NPO regression t-test probility(JJA)"
           z->$vout$ = set_varAtts(npo_prob_jja,vosr,"","")
           vout = "npo_"+vnm+"_regprob_son"
           vosr = vnm+" NPO regression t-test probility(SON)"
           z->$vout$ = set_varAtts(npo_prob_son,vosr,"","")
           vout = "npo_"+vnm+"_regprob_ann"
           vosr = vnm+" NPO regression t-test probility(annual)"
           z->$vout$ = set_varAtts(npo_prob_ann,vosr,"","")

           if (COMPUTE_MODES_MON.eq."True") then   

              z->pna_timeseries_mon  = set_varAtts(pna_pc_mon,"PNA principal component timeseries (monthly)","","")
              z->npo_timeseries_mon = set_varAtts(npo_pc_mon,"NPO principal component timeseries (monthly)","","")

              vout = "pna_"+vnm+"_regression_mon"
              vosr = vnm+" regression onto PNA principal component timeseries (monthly)"
              z->$vout$ = set_varAtts(pna_vreg_mon,vosr,"","")

              vout = "npo_"+vnm+"_regression_mon"
              vosr = vnm+" regression onto NPO principal component timeseries (monthly)"
              z->$vout$ = set_varAtts(npo_vreg_mon,vosr,"","")

              vout = "pna_"+vnm+"_regprob_mon"
              vosr = vnm+" PNA regression t-test probility(monthly)"
              z->$vout$ = set_varAtts(pna_prob_mon,vosr,"","")

              vout = "npo_"+vnm+"_regprob_mon"
              vosr = vnm+" NPO regression t-test probility(monthly)"
              z->$vout$ = set_varAtts(npo_prob_mon,vosr,"","")

           end if
           delete(z)
           delete([/modname,fn/])
        end if
     end if     
     delete([/pna_pc_djf,pna_pc_jja,pna_pc_mam,pna_pc_son,pna_pc_ann,pna_pc_mon/])
     delete([/npo_pc_djf,npo_pc_jja,npo_pc_mam,npo_pc_son,npo_pc_ann,npo_pc_mon/])

;========================================================================
     res = True
     res@mpGeophysicalLineColor = "gray42"
     res@mpGeophysicalLineThicknessF = 2.     
     res@mpGridAndLimbOn = False
     res@mpFillOn = False
     res@mpOutlineOn = True  
     res@gsnDraw      = False
     res@gsnFrame     = False
     res@cnLevelSelectionMode = "ExplicitLevels"
     res@cnLineLabelsOn = False
     res@cnFillOn        = True
     res@cnLinesOn       = False
     res@lbLabelBarOn    = False

     res@gsnLeftStringOrthogonalPosF = -0.03
     res@gsnLeftStringParallelPosF = .005
     res@gsnRightStringOrthogonalPosF = -0.03
     res@gsnRightStringParallelPosF = 0.96
     res@gsnRightString = ""
     res@gsnLeftString = ""
     if (nsim.le.5) then
        res@gsnLeftStringFontHeightF = 0.018
        res@gsnCenterStringFontHeightF = 0.022
        res@gsnRightStringFontHeightF = 0.018
     else
        res@gsnLeftStringFontHeightF = 0.024
        res@gsnCenterStringFontHeightF = 0.028
        res@gsnRightStringFontHeightF = 0.024     
     end if
     res@gsnPolar     = "NH"     
     res@mpMinLatF    = 20.
     res@mpCenterLonF = 0.
 
     res@cnLevels := (/-0.8,-0.6,-0.4,-0.2,-0.1,0,0.1,0.2,0.4,0.6,0.8/)
     res@cnLevels = res@cnLevels * vrfac
     res@gsnLeftString = syear(ee)+"-"+eyear(ee)
     res@gsnCenterString = names(ee)
 
     res2 = True
     res2@gsnDraw         = False
     res2@gsnFrame        = False
     res2@lbLabelBarOn    = False
     res2@gsnTickMarksOn  = False     ; no tickmarks
     res2@tiMainString    = ""
     res2@gsnLeftString   = ""
     res2@gsnRightString  = ""
     res2@cnLevelSelectionMode = "ExplicitLevels"
     res2@cnLevels          = (/95/) ;-- draw only the 5% contour line
     res2@cnMonoFillPattern = True
     res2@cnMonoFillColor   = True
     res2@cnFillOn          = False      ; color fill
     res2@cnLinesOn         = True
     res2@cnLineThicknessF  = 0.5
     res2@cnLineLabelsOn    = False        ; True is default
     res2@cnInfoLabelOn     = False                ; turn off info label
     res2@gsnAddCyclic      = False

     opt = True
     opt@gsnShadeFillType      = "pattern" ;-- shading is a pattern fill
     opt@gsnShadeHigh          = 17 ;-- pattern type is dots (#17) for all values <= 0.05
     opt@gsnShadeFillScaleF    = 0.75 ;-- density of fill pattern (the lower the denser); default=1.0
     opt@gsnShadeFillDotSizeF  = 0.002
    
     if (isfilepresent2("obs_psl").and.ee.eq.0) then    ; for pattern correlation table. Save entire lat/lon array
        patcor_vreg_pna_djf = new((/nsim,dimsizes(pna_vreg_djf&lat),dimsizes(pna_vreg_djf&lon)/),typeof(pna_vreg_djf))
        patcor_vreg_pna_djf!1 = "lat"
        patcor_vreg_pna_djf&lat = pna_vreg_djf&lat
        patcor_vreg_pna_djf!2 = "lon"
        patcor_vreg_pna_djf&lon = pna_vreg_djf&lon
        patcor_vreg_pna_mam = patcor_vreg_pna_djf
        patcor_vreg_pna_jja = patcor_vreg_pna_djf
        patcor_vreg_pna_son = patcor_vreg_pna_djf
        patcor_vreg_pna_ann = patcor_vreg_pna_djf
        patcor_vreg_npo_djf = patcor_vreg_pna_djf
        patcor_vreg_npo_mam = patcor_vreg_pna_djf
        patcor_vreg_npo_jja = patcor_vreg_pna_djf
        patcor_vreg_npo_son = patcor_vreg_pna_djf
        patcor_vreg_npo_ann = patcor_vreg_pna_djf
        patcor_vreg_pna_djf(ee,:,:) = (/ pna_vreg_djf /)
        patcor_vreg_pna_mam(ee,:,:) = (/ pna_vreg_mam /)
        patcor_vreg_pna_jja(ee,:,:) = (/ pna_vreg_jja /)
        patcor_vreg_pna_son(ee,:,:) = (/ pna_vreg_son /)
        patcor_vreg_pna_ann(ee,:,:) = (/ pna_vreg_ann /)
        patcor_vreg_npo_djf(ee,:,:) = (/ npo_vreg_djf /)
        patcor_vreg_npo_mam(ee,:,:) = (/ npo_vreg_mam /)
        patcor_vreg_npo_jja(ee,:,:) = (/ npo_vreg_jja /)
        patcor_vreg_npo_son(ee,:,:) = (/ npo_vreg_son /)
        patcor_vreg_npo_ann(ee,:,:) = (/ npo_vreg_ann /)
        if (COMPUTE_MODES_MON.eq."True") then
          patcor_vreg_pna_mon = patcor_vreg_pna_djf
          patcor_vreg_npo_mon = patcor_vreg_pna_djf
          patcor_vreg_pna_mon(ee,:,:) = (/ pna_vreg_mon /)
          patcor_vreg_npo_mon(ee,:,:) = (/ npo_vreg_mon /)
        end if
     end if
     if (isfilepresent2("obs_psl").and.ee.ge.1.and.isvar("patcor_vreg_pna_djf")) then       
        patcor_vreg_pna_djf(ee,:,:) = (/ totype(linint2(pna_vreg_djf&lon,pna_vreg_djf&lat,pna_vreg_djf,True,patcor_vreg_pna_djf&lon,patcor_vreg_pna_djf&lat,0),typeof(patcor_vreg_pna_djf)) /)
        patcor_vreg_pna_mam(ee,:,:) = (/ totype(linint2(pna_vreg_mam&lon,pna_vreg_mam&lat,pna_vreg_mam,True,patcor_vreg_pna_mam&lon,patcor_vreg_pna_mam&lat,0),typeof(patcor_vreg_pna_mam)) /)
        patcor_vreg_pna_jja(ee,:,:) = (/ totype(linint2(pna_vreg_jja&lon,pna_vreg_jja&lat,pna_vreg_jja,True,patcor_vreg_pna_jja&lon,patcor_vreg_pna_jja&lat,0),typeof(patcor_vreg_pna_jja)) /)
        patcor_vreg_pna_son(ee,:,:) = (/ totype(linint2(pna_vreg_son&lon,pna_vreg_son&lat,pna_vreg_son,True,patcor_vreg_pna_son&lon,patcor_vreg_pna_son&lat,0),typeof(patcor_vreg_pna_son)) /)
        patcor_vreg_pna_ann(ee,:,:) = (/ totype(linint2(pna_vreg_ann&lon,pna_vreg_ann&lat,pna_vreg_ann,True,patcor_vreg_pna_ann&lon,patcor_vreg_pna_ann&lat,0),typeof(patcor_vreg_pna_ann)) /)
        
        patcor_vreg_npo_djf(ee,:,:) = (/ totype(linint2(npo_vreg_djf&lon,npo_vreg_djf&lat,npo_vreg_djf,True,patcor_vreg_npo_djf&lon,patcor_vreg_npo_djf&lat,0),typeof(patcor_vreg_npo_djf)) /)
        patcor_vreg_npo_mam(ee,:,:) = (/ totype(linint2(npo_vreg_mam&lon,npo_vreg_mam&lat,npo_vreg_mam,True,patcor_vreg_npo_mam&lon,patcor_vreg_npo_mam&lat,0),typeof(patcor_vreg_npo_mam)) /)
        patcor_vreg_npo_jja(ee,:,:) = (/ totype(linint2(npo_vreg_jja&lon,npo_vreg_jja&lat,npo_vreg_jja,True,patcor_vreg_npo_jja&lon,patcor_vreg_npo_jja&lat,0),typeof(patcor_vreg_npo_jja)) /)
        patcor_vreg_npo_son(ee,:,:) = (/ totype(linint2(npo_vreg_son&lon,npo_vreg_son&lat,npo_vreg_son,True,patcor_vreg_npo_son&lon,patcor_vreg_npo_son&lat,0),typeof(patcor_vreg_npo_son)) /)
        patcor_vreg_npo_ann(ee,:,:) = (/ totype(linint2(npo_vreg_ann&lon,npo_vreg_ann&lat,npo_vreg_ann,True,patcor_vreg_npo_ann&lon,patcor_vreg_npo_ann&lat,0),typeof(patcor_vreg_npo_ann)) /)
        if (COMPUTE_MODES_MON.eq."True") then
          patcor_vreg_pna_mon(ee,:,:) = (/ totype(linint2(pna_vreg_mon&lon,pna_vreg_mon&lat,pna_vreg_mon,True,patcor_vreg_pna_mon&lon,patcor_vreg_pna_mon&lat,0),typeof(patcor_vreg_pna_mon)) /)
          patcor_vreg_npo_mon(ee,:,:) = (/ totype(linint2(npo_vreg_mon&lon,npo_vreg_mon&lat,npo_vreg_mon,True,patcor_vreg_npo_mon&lon,patcor_vreg_npo_mon&lat,0),typeof(patcor_vreg_npo_mon)) /)
        end if       
     end if
      
     if (vxreg_plot_flag.eq.0) then
        res@gsnCenterString = names_reg(ee)
        res@gsnRightString = ""
        lbunitstr = pna_vreg_djf@units
        reg_pna_djf(ee) = gsn_csm_contour_map_polar(wks_pna,pna_vreg_djf,res)
        reg_pna_mam(ee) = gsn_csm_contour_map_polar(wks_pna,pna_vreg_mam,res)
        reg_pna_jja(ee) = gsn_csm_contour_map_polar(wks_pna,pna_vreg_jja,res)
        reg_pna_son(ee) = gsn_csm_contour_map_polar(wks_pna,pna_vreg_son,res)
        reg_pna_ann(ee) = gsn_csm_contour_map_polar(wks_pna,pna_vreg_ann,res)     
        delete([/pna_vreg_djf,pna_vreg_mam,pna_vreg_jja,pna_vreg_son,pna_vreg_ann/])
        o_djf = gsn_csm_contour(wks_pna,pna_prob_djf,res2)
        o_djf = gsn_contour_shade(o_djf,-999,95,opt) 
        o_mam = gsn_csm_contour(wks_pna,pna_prob_mam,res2)
        o_mam = gsn_contour_shade(o_mam,-999,95,opt) 
        o_jja = gsn_csm_contour(wks_pna,pna_prob_jja,res2)
        o_jja = gsn_contour_shade(o_jja,-999,95,opt)
        o_son = gsn_csm_contour(wks_pna,pna_prob_son,res2)
        o_son = gsn_contour_shade(o_son,-999,95,opt)
        o_ann = gsn_csm_contour(wks_pna,pna_prob_ann,res2)
        o_ann = gsn_contour_shade(o_ann,-999,95,opt)
        delete([/pna_prob_djf,pna_prob_mam,pna_prob_jja,pna_prob_son,pna_prob_ann/])
        overlay(reg_pna_djf(ee),o_djf)
        overlay(reg_pna_mam(ee),o_mam)
        overlay(reg_pna_jja(ee),o_jja)
        overlay(reg_pna_son(ee),o_son)
        overlay(reg_pna_ann(ee),o_ann)
        delete([/o_djf,o_mam,o_jja,o_son,o_ann/])
        if (COMPUTE_MODES_MON.eq."True") then                    
           reg_pna_mon(ee) = gsn_csm_contour_map_polar(wks_pna,pna_vreg_mon,res)
           delete([/pna_vreg_mon/])
           o_mon = gsn_csm_contour(wks_pna,pna_prob_mon,res2)
           o_mon = gsn_contour_shade(o_mon,-999,95,opt)
           overlay(reg_pna_mon(ee),o_mon)
           delete([/o_mon,pna_prob_mon/])
        end if
     
        reg_npo_djf(ee) = gsn_csm_contour_map_polar(wks_npo,npo_vreg_djf,res)
        reg_npo_mam(ee) = gsn_csm_contour_map_polar(wks_npo,npo_vreg_mam,res)
        reg_npo_jja(ee) = gsn_csm_contour_map_polar(wks_npo,npo_vreg_jja,res)
        reg_npo_son(ee) = gsn_csm_contour_map_polar(wks_npo,npo_vreg_son,res)
        reg_npo_ann(ee) = gsn_csm_contour_map_polar(wks_npo,npo_vreg_ann,res)     
        delete([/npo_vreg_djf,npo_vreg_mam,npo_vreg_jja,npo_vreg_son,npo_vreg_ann/])
        o_djf = gsn_csm_contour(wks_npo,npo_prob_djf,res2)
        o_djf = gsn_contour_shade(o_djf,-999,95,opt)
        o_mam = gsn_csm_contour(wks_npo,npo_prob_mam,res2)
        o_mam = gsn_contour_shade(o_mam,-999,95,opt)
        o_jja = gsn_csm_contour(wks_npo,npo_prob_jja,res2)
        o_jja = gsn_contour_shade(o_jja,-999,95,opt)
        o_son = gsn_csm_contour(wks_npo,npo_prob_son,res2)
        o_son = gsn_contour_shade(o_son,-999,95,opt)
        o_ann = gsn_csm_contour(wks_npo,npo_prob_ann,res2)
        o_ann = gsn_contour_shade(o_ann,-999,95,opt)
        delete([/npo_prob_djf,npo_prob_mam,npo_prob_jja,npo_prob_son,npo_prob_ann/])
        overlay(reg_npo_djf(ee),o_djf)
        overlay(reg_npo_mam(ee),o_mam)
        overlay(reg_npo_jja(ee),o_jja)
        overlay(reg_npo_son(ee),o_son)
        overlay(reg_npo_ann(ee),o_ann)
        delete([/o_djf,o_mam,o_jja,o_son,o_ann/])
        if (COMPUTE_MODES_MON.eq."True") then
           reg_npo_mon(ee) = gsn_csm_contour_map_polar(wks_npo,npo_vreg_mon,res)
           delete([/npo_vreg_mon/])
           o_mon = gsn_csm_contour(wks_npo,npo_prob_mon,res2)
           o_mon = gsn_contour_shade(o_mon,-999,95,opt)
           overlay(reg_npo_mon(ee),o_mon)
           delete([/o_mon,npo_prob_mon/])
        end if

     end if

     delete(vxreg_plot_flag)  
  end do
  
  if (isvar("clim_syear")) then
     delete(clim_syear)
  end if
  if (isvar("clim_eyear")) then
     delete(clim_eyear)
  end if
 
  if (isvar("patcor_vreg_pna_djf").and.isvar("patcor_vreg_npo_djf")) then    ; for pattern correlation table
    mods = (/"pna","npo"/)
    if (COMPUTE_MODES_MON.eq."True") then
      seas = (/"djf","mam","jja","son","ann","mon"/)
    else
      seas = (/"djf","mam","jja","son","ann"/)
    end if
    do kk = 0,dimsizes(seas)-1
     do ll = 0,dimsizes(mods)-1
      vreg_nam  = "patcor_vreg_"+mods(ll)+"_"+seas(kk)
      if(vreg_nam.eq."patcor_vreg_pna_djf") then
        patcor_vreg = patcor_vreg_pna_djf
      end if
      if(vreg_nam.eq."patcor_vreg_pna_mam") then
        patcor_vreg = patcor_vreg_pna_mam
      end if
      if(vreg_nam.eq."patcor_vreg_pna_jja") then
        patcor_vreg = patcor_vreg_pna_jja
      end if
      if(vreg_nam.eq."patcor_vreg_pna_son") then
        patcor_vreg = patcor_vreg_pna_son
      end if
      if(vreg_nam.eq."patcor_vreg_pna_ann") then
        patcor_vreg = patcor_vreg_pna_ann
      end if
      if(vreg_nam.eq."patcor_vreg_pna_mon") then
        patcor_vreg = patcor_vreg_pna_mon
      end if
      if(vreg_nam.eq."patcor_vreg_npo_djf") then
        patcor_vreg = patcor_vreg_npo_djf
      end if
      if(vreg_nam.eq."patcor_vreg_npo_mam") then
        patcor_vreg = patcor_vreg_npo_mam
      end if
      if(vreg_nam.eq."patcor_vreg_npo_jja") then
        patcor_vreg = patcor_vreg_npo_jja
      end if
      if(vreg_nam.eq."patcor_vreg_npo_son") then
        patcor_vreg = patcor_vreg_npo_son
      end if
      if(vreg_nam.eq."patcor_vreg_npo_ann") then
        patcor_vreg = patcor_vreg_npo_ann
      end if
      if(vreg_nam.eq."patcor_vreg_npo_mon") then
        patcor_vreg = patcor_vreg_npo_mon
      end if
      clat = cos(0.01745329*patcor_vreg&lat)
      clat!0 = "lat"
      clat&lat = patcor_vreg&lat
      line3  = "                  "    ; Must be 18 characters long
      line4  = line3
      header = (/"","Pattern Correlations   Observations vs. Model(s)",""/)
      finpr  = str_upper(mods(ll))+" ("+str_upper(seas(kk))+")         "
      do hh = 1,nsim-1
         dimY = dimsizes(tochar(names(hh)))
         nchar = dimY
         nchar = where(nchar.le.10,10,nchar)
         if (dimY.lt.10) then
            ntb = ""
            do ii = 0,10-dimY-1
               ntb = ntb+" "
            end do
            ntb = ntb+names(hh)
         else
            ntb = names(hh)
         end if

         ntc = ""
         do ii = 0,nchar-1
            ntc = ntc+"-"
         end do
         format2 = "%"+(nchar-5+1)+".2f"
         format3 = "%4.2f"
         line3 = line3+" "+ntb
         line4 = line4+" "+ntc
         if (all(ismissing(patcor_vreg_pna_djf(hh,{20:85},{120:240})))) then
            finpr = finpr+sprintf(format2,9.99)+"/"+sprintf(format3,9.99)
         else
            finpr = finpr+sprintf(format2,(pattern_cor(patcor_vreg(0,{20:85},{120:240}),patcor_vreg(hh,{20:85},{120:240}),clat({20:85}),0)))+"/"+sprintf(format3,(wgt_arearmse(patcor_vreg(0,{20:85},{120:240}),patcor_vreg(hh,{20:85},{120:240}),clat({20:85}),1.0,0)))
         end if
      end do
;
     if (dimsizes(tochar(line4)).ge.8190) then   ; system or fortran compiler limit
        print("Metrics table warning: Not creating regpatt_metrics.table as size of comparison results in a invalid ascii row size.")
     else
        if(kk.eq.0.and.ll.eq.0) then
          write_table(getenv("OUTDIR")+"regpatt_metrics.psl.pna_npo_"+vnm+".txt","w",[/header/],"%s")
          write_table(getenv("OUTDIR")+"regpatt_metrics.psl.pna_npo_"+vnm+".txt","a",[/line3/],"%s")
          write_table(getenv("OUTDIR")+"regpatt_metrics.psl.pna_npo_"+vnm+".txt","a",[/line4/],"%s")
          write_table(getenv("OUTDIR")+"regpatt_metrics.psl.pna_npo_"+vnm+".txt","a",[/finpr/],"%s")
        else
          write_table(getenv("OUTDIR")+"regpatt_metrics.psl.pna_npo_"+vnm+".txt","a",[/finpr/],"%s")
        end if
     end if
     delete([/line3,line4,format2,format3,nchar,ntc,clat,dimY,ntb,header/])
     end do
    end do
    delete([/mods,seas/])
    delete([/patcor_vreg_pna_djf,patcor_vreg_pna_mam,patcor_vreg_pna_jja,patcor_vreg_pna_son,patcor_vreg_pna_ann/])
    delete([/patcor_vreg_npo_djf,patcor_vreg_npo_mam,patcor_vreg_npo_jja,patcor_vreg_npo_son,patcor_vreg_npo_ann/])
    if (COMPUTE_MODES_MON.eq."True") then
      delete([/patcor_vreg_pna_mon,patcor_vreg_npo_mon/])
    end if
  end if
 
  panres = True
  panres@gsnMaximize = True
  panres@gsnPaperOrientation = "portrait"
  panres@gsnPanelLabelBar = True
  panres@gsnPanelYWhiteSpacePercent = 3.0
  panres@pmLabelBarHeightF = 0.05
  panres@pmLabelBarWidthF = 0.55
  panres@pmLabelBarOrthogonalPosF = -0.05
  panres@lbTitleOn = True
  panres@lbBoxLineColor = "gray70"
  if (nsim.le.4) then
     if (nsim.eq.1) then
        panres@txFontHeightF = 0.022
        panres@gsnPanelBottom = 0.50
        panres@lbLabelFontHeightF = 0.018
        panres@lbTitleFontHeightF = 0.018
     else
        panres@txFontHeightF = 0.0145
        panres@gsnPanelBottom = 0.50
        panres@lbLabelFontHeightF = 0.012
        panres@lbTitleFontHeightF = 0.012
     end if
  else
     panres@txFontHeightF = 0.016
     panres@gsnPanelBottom = 0.05
     panres@lbLabelFontHeightF = 0.012
     panres@lbTitleFontHeightF = 0.012
  end if
  if (nsim.le.3) then
    ncol = nsim
    nrow = 1
  else if (nsim.le.6) then
    nrow = 2
    ncol = 3
  else
    ncol = floattointeger(sqrt(nsim))
    nrow = (nsim/ncol)+mod(nsim,ncol)
  end if
  end if
  
  if (vxreg_frame.eq.0) then
     if(vnm.eq."qnet") then
       txt0 = "Qnet"
     else
       txt0 = str_upper(vnm)
     end if
     panres@lbTitleString = txt0 + " [" + lbunitstr +"]"
     panres@txString = "PNA Regressions (DJF)" 
     gsn_panel2(wks_pna,reg_pna_djf,(/nrow,ncol/),panres)
     delete(reg_pna_djf)
     panres@txString = "PNA Regressions (MAM)"
     gsn_panel2(wks_pna,reg_pna_mam,(/nrow,ncol/),panres)
     delete(reg_pna_mam)
     panres@txString = "PNA Regressions (JJA)"
     gsn_panel2(wks_pna,reg_pna_jja,(/nrow,ncol/),panres)
     delete(reg_pna_jja)
     panres@txString = "PNA Regressions (SON)"
     gsn_panel2(wks_pna,reg_pna_son,(/nrow,ncol/),panres)
     delete(reg_pna_son)
     panres@txString = "PNA Regressions (Annual)"
     gsn_panel2(wks_pna,reg_pna_ann,(/nrow,ncol/),panres)
     delete(reg_pna_ann)
     if (COMPUTE_MODES_MON.eq."True") then    
        panres@txString = "PNA Regressions (Monthly)"
        gsn_panel2(wks_pna,reg_pna_mon,(/nrow,ncol/),panres)
        delete(reg_pna_mon)
     end if
     delete(wks_pna)
  end if
  
  if (vxreg_frame.eq.0) then
     if(vnm.eq."qnet") then
       txt0 = "Qnet"
     else
       txt0 = str_upper(vnm)
     end if
     panres@lbTitleString = txt0 + " [" + lbunitstr +"]"
     panres@txString = "NPO Regressions (DJF)" 
     gsn_panel2(wks_npo,reg_npo_djf,(/nrow,ncol/),panres)
     delete(reg_npo_djf)
     panres@txString = "NPO Regressions (MAM)"
     gsn_panel2(wks_npo,reg_npo_mam,(/nrow,ncol/),panres)
     delete(reg_npo_mam)
     panres@txString = "NPO Regressions (JJA)"
     gsn_panel2(wks_npo,reg_npo_jja,(/nrow,ncol/),panres)
     delete(reg_npo_jja)
     panres@txString = "NPO Regressions (SON)"
     gsn_panel2(wks_npo,reg_npo_son,(/nrow,ncol/),panres)
     delete(reg_npo_son)
     panres@txString = "NPO Regressions (Annual)"
     gsn_panel2(wks_npo,reg_npo_ann,(/nrow,ncol/),panres)
     delete(reg_npo_ann)
     if (COMPUTE_MODES_MON.eq."True") then    
        panres@txString = "NPO Regressions (Monthly)"
        gsn_panel2(wks_npo,reg_npo_mon,(/nrow,ncol/),panres)
        delete(reg_npo_mon)
     end if
     delete(wks_npo)
  end if

;--------------------------------------------------------------------------------------------------
  OUTDIR = getenv("OUTDIR") 
  if (wks_type.eq."png") then       
     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"pna.vxreg.000001.png "+OUTDIR+"pna."+vnm+"reg.djf.png")
        system("mv "+OUTDIR+"pna.vxreg.000002.png "+OUTDIR+"pna."+vnm+"reg.mam.png")
        system("mv "+OUTDIR+"pna.vxreg.000003.png "+OUTDIR+"pna."+vnm+"reg.jja.png")
        system("mv "+OUTDIR+"pna.vxreg.000004.png "+OUTDIR+"pna."+vnm+"reg.son.png")
        system("mv "+OUTDIR+"pna.vxreg.000005.png "+OUTDIR+"pna."+vnm+"reg.ann.png")
        if (COMPUTE_MODES_MON.eq."True") then
          system("mv "+OUTDIR+"pna.vxreg.000006.png "+OUTDIR+"pna."+vnm+"reg.mon.png")   
        end if 
     end if

     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"npo.vxreg.000001.png "+OUTDIR+"npo."+vnm+"reg.djf.png")
        system("mv "+OUTDIR+"npo.vxreg.000002.png "+OUTDIR+"npo."+vnm+"reg.mam.png")
        system("mv "+OUTDIR+"npo.vxreg.000003.png "+OUTDIR+"npo."+vnm+"reg.jja.png")
        system("mv "+OUTDIR+"npo.vxreg.000004.png "+OUTDIR+"npo."+vnm+"reg.son.png")
        system("mv "+OUTDIR+"npo.vxreg.000005.png "+OUTDIR+"npo."+vnm+"reg.ann.png")
        if (COMPUTE_MODES_MON.eq."True") then
          system("mv "+OUTDIR+"npo.vxreg.000006.png "+OUTDIR+"npo."+vnm+"reg.mon.png")
        end if
     end if

  else     
     system("psplit "+OUTDIR+"pna.vxreg.ps "+OUTDIR+"pnavx_sp")
     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"pnavx_sp0001.ps "+OUTDIR+"pna."+vnm+"reg.djf.ps") 
        system("mv "+OUTDIR+"pnavx_sp0002.ps "+OUTDIR+"pna."+vnm+"reg.mam.ps") 
        system("mv "+OUTDIR+"pnavx_sp0003.ps "+OUTDIR+"pna."+vnm+"reg.jja.ps") 
        system("mv "+OUTDIR+"pnavx_sp0004.ps "+OUTDIR+"pna."+vnm+"reg.son.ps") 
        system("mv "+OUTDIR+"pnavx_sp0005.ps "+OUTDIR+"pna."+vnm+"reg.ann.ps")
        if (COMPUTE_MODES_MON.eq."True") then
           system("mv "+OUTDIR+"pnavx_sp0006.ps "+OUTDIR+"pna."+vnm+"reg.mon.ps") 
        end if
     end if

     system("psplit "+OUTDIR+"npo.vxreg.ps "+OUTDIR+"pnavx_sp")
     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"pnavx_sp0001.ps "+OUTDIR+"npo."+vnm+"reg.djf.ps")
        system("mv "+OUTDIR+"pnavx_sp0002.ps "+OUTDIR+"npo."+vnm+"reg.mam.ps") 
        system("mv "+OUTDIR+"pnavx_sp0003.ps "+OUTDIR+"npo."+vnm+"reg.jja.ps")
        system("mv "+OUTDIR+"pnavx_sp0004.ps "+OUTDIR+"npo."+vnm+"reg.son.ps") 
        system("mv "+OUTDIR+"pnavx_sp0005.ps "+OUTDIR+"npo."+vnm+"reg.ann.ps")
        if (COMPUTE_MODES_MON.eq."True") then
           system("mv "+OUTDIR+"pnavx_sp0006.ps "+OUTDIR+"npo."+vnm+"reg.mon.ps")
        end if
     end if

     system(OUTDIR+"npo.vxreg.ps "+OUTDIR+"pna.vxreg.ps")     
  end if

  delete([/vnm,lmsk,nsim_reg,names_reg,paths_reg,syear_reg,syear_reg,eyear_reg,nyr_reg,vrfac/])
 end do 
    
 print("Finished: psl.pna_npo_regpatt.ncl")

end  
