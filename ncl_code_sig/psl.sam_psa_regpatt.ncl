; Calculates SAM, PSA1 and PSA2 (patterns and PC timeseries), as well as 
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
  print("Starting: psl.sam_psa_regpatt.ncl")
  
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
 
 regvars = (/"psl","sst","trefht","prect","u10","v10","taux","tauy","sh","lh", "eth", \
             "swcre","fldsc","cldtot","u850","v850","th850","z500","u200","v200"/)
 landmsk = (/    0,    1,       0,      0,    0,    0,     0,     0,   0,   0,     1, \
                 0,    0,       0,      0,    0,    0,     0,     0,   0 /)
 nsvars  = dimsizes(regvars)

 do ss = 0, nsvars-1,1
  ;---------Regressions coding-------------------------------------------------
  if(regvars(ss).eq."sst") then 
    vnm   = "ts"
  else 
    vnm   = regvars(ss)
  end if 
  lmsk  = landmsk(ss)
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
  
  wks_sam  = gsn_open_wks(wks_type,getenv("OUTDIR")+"sam.vxreg")
  wks_psa1 = gsn_open_wks(wks_type,getenv("OUTDIR")+"psa1.vxreg")
  wks_psa2 = gsn_open_wks(wks_type,getenv("OUTDIR")+"psa2.vxreg")
  
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_sam,"MPL_RdBu")  
     gsn_define_colormap(wks_psa1,"MPL_RdBu") 
     gsn_define_colormap(wks_psa2,"MPL_RdBu") 
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_sam,"NCV_jaisnd")  
     gsn_define_colormap(wks_psa1,"NCV_jaisnd") 
     gsn_define_colormap(wks_psa2,"NCV_jaisnd") 
  end if
  
  reg_sam_djf = new(nsim,"graphic")  
  reg_sam_mam = new(nsim,"graphic")  
  reg_sam_jja = new(nsim,"graphic")  
  reg_sam_son = new(nsim,"graphic")  
  reg_sam_ann = new(nsim,"graphic")  
  reg_sam_mon = new(nsim,"graphic")  
  
  reg_psa1_djf = new(nsim,"graphic")  
  reg_psa1_mam = new(nsim,"graphic")  
  reg_psa1_jja = new(nsim,"graphic")  
  reg_psa1_son = new(nsim,"graphic")  
  reg_psa1_ann = new(nsim,"graphic")  
  reg_psa1_mon = new(nsim,"graphic")  
  
  reg_psa2_djf = new(nsim,"graphic")  
  reg_psa2_mam = new(nsim,"graphic")  
  reg_psa2_jja = new(nsim,"graphic")  
  reg_psa2_son = new(nsim,"graphic")  
  reg_psa2_ann = new(nsim,"graphic")  
  reg_psa2_mon = new(nsim,"graphic")
  
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
;----------SAM/PSA1/PSA2 calculations----------------------------------------------------------------------     
     evecv = eofunc(arr_djf_CW({lat|:-20},lon|:,time|:),4,75)
     pcts = eofunc_ts(arr_djf_CW({lat|:-20},lon|:,time|:),evecv,False)  
     sam_pc_djf = dim_standardize(pcts(0,:),0)
     psa1_pc_djf = dim_standardize(pcts(1,:),0)
     psa2_pc_djf = dim_standardize(pcts(2,:),0)     
     sam_djf = arr_djf(0,:,:)
     sam_djf = (/ regCoef(sam_pc_djf,arr_djf(lat|:,lon|:,time|:)) /)
     psa1_djf = arr_djf(0,:,:)
     psa1_djf = (/ regCoef(psa1_pc_djf,arr_djf(lat|:,lon|:,time|:)) /)
     psa2_djf = arr_djf(0,:,:)
     psa2_djf = (/ regCoef(psa2_pc_djf,arr_djf(lat|:,lon|:,time|:)) /)

     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(sam_pc_djf, vreg_djf, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval    
        b         = 0.5
        sam_vreg_djf  = vreg_djf(0,:,:)
        sam_prob_djf  = vreg_djf(0,:,:)
        sam_vreg_djf  = (/ rc /) 
        sam_prob_djf  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/)
        delete([/rc,tval,df,b/]) 
        rc        = regCoef_n(psa1_pc_djf, vreg_djf, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval    
        b         = 0.5
        psa1_vreg_djf  = vreg_djf(0,:,:)
        psa1_prob_djf  = vreg_djf(0,:,:)
        psa1_vreg_djf  = (/ rc /) 
        psa1_prob_djf  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/)
        delete([/rc,tval,df,b/]) 
        rc        = regCoef_n(psa2_pc_djf, vreg_djf, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval    
        b         = 0.5 
        psa2_vreg_djf  = vreg_djf(0,:,:)
        psa2_prob_djf  = vreg_djf(0,:,:)
        psa2_vreg_djf  = (/ rc /)
        psa2_prob_djf  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b,vreg_djf/]) 
     end if     
     
     if (.not.ismissing(sam_djf({-85},{5}))) then
        if (sam_djf({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           sam_djf = sam_djf*-1.
           sam_pc_djf = sam_pc_djf*-1.
           if (vxreg_plot_flag.eq.0) then
              sam_vreg_djf = sam_vreg_djf*-1.
           end if
        end if
     end if
     if (.not.ismissing(psa1_djf({-62},{210}))) then
        if (psa1_djf({-62},{210}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           psa1_djf = psa1_djf*-1.
           psa1_pc_djf = psa1_pc_djf*-1.
           if (vxreg_plot_flag.eq.0) then
              psa1_vreg_djf = psa1_vreg_djf*-1.
           end if
        end if
     end if
     if (.not.ismissing(psa2_djf({-60},{280}))) then
        if (psa2_djf({-60},{280}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           psa2_djf = psa2_djf*-1.
           psa2_pc_djf = psa2_pc_djf*-1.
           if (vxreg_plot_flag.eq.0) then
              psa2_vreg_djf = psa2_vreg_djf*-1.
           end if
        end if     
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(sam_pc_djf),False)
     if (sig_pcv(0)) then    ; if True then significant
        sam_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        sam_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     if (sig_pcv(1)) then    ; if True then significant
        psa1_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
     else
        psa1_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
     end if
     if (sig_pcv(2)) then    ; if True then significant
        psa2_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%*"
     else
        psa2_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%"
     end if
     delete(sig_pcv)    
     sam_pc_djf!0 = "TIME"
     sam_pc_djf&TIME = ispan(syear(ee),eyear(ee),1)
     sam_pc_djf&TIME@units = "YYYY"
     sam_pc_djf&TIME@long_name = "time"     
     
     copy_VarCoords(sam_pc_djf,psa1_pc_djf)
     copy_VarCoords(sam_pc_djf,psa2_pc_djf)  
     delete([/evecv,pcts/])
     
     evecv = eofunc(arr_mam_CW({lat|:-20},lon|:,time|:),4,75)
     pcts = eofunc_ts(arr_mam_CW({lat|:-20},lon|:,time|:),evecv,False)  
     sam_pc_mam = dim_standardize(pcts(0,:),0)
     psa1_pc_mam = dim_standardize(pcts(1,:),0)
     psa2_pc_mam = dim_standardize(pcts(2,:),0)     
     sam_mam = arr_mam(0,:,:)
     sam_mam = (/ regCoef(sam_pc_mam,arr_mam(lat|:,lon|:,time|:)) /)
     psa1_mam = arr_mam(0,:,:)
     psa1_mam = (/ regCoef(psa1_pc_mam,arr_mam(lat|:,lon|:,time|:)) /)
     psa2_mam = arr_mam(0,:,:)
     psa2_mam = (/ regCoef(psa2_pc_mam,arr_mam(lat|:,lon|:,time|:)) /)
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(sam_pc_mam, vreg_mam, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        sam_vreg_mam  = vreg_mam(0,:,:)
        sam_prob_mam  = vreg_mam(0,:,:)
        sam_vreg_mam  = (/ rc /)
        sam_prob_mam  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(psa1_pc_mam, vreg_mam, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        psa1_vreg_mam  = vreg_mam(0,:,:)
        psa1_prob_mam  = vreg_mam(0,:,:)
        psa1_vreg_mam  = (/ rc /)
        psa1_prob_mam  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(psa2_pc_mam, vreg_mam, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        psa2_vreg_mam  = vreg_mam(0,:,:)
        psa2_prob_mam  = vreg_mam(0,:,:)
        psa2_vreg_mam  = (/ rc /)
        psa2_prob_mam  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b,vreg_mam/])
     end if

     if (.not.ismissing(sam_mam({-85},{5}))) then
        if (sam_mam({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           sam_mam = sam_mam*-1.
           sam_pc_mam = sam_pc_mam*-1.
           if (vxreg_plot_flag.eq.0) then
              sam_vreg_mam = sam_vreg_mam*-1.
           end if
        end if
     end if
     if (.not.ismissing(psa1_mam({-62},{210}))) then
        if (psa1_mam({-62},{210}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           psa1_mam = psa1_mam*-1.
           psa1_pc_mam = psa1_pc_mam*-1.
           if (vxreg_plot_flag.eq.0) then
              psa1_vreg_mam = psa1_vreg_mam*-1.
           end if
        end if
     end if
     if (.not.ismissing(psa2_mam({-60},{280}))) then
        if (psa2_mam({-60},{280}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           psa2_mam = psa2_mam*-1.
           psa2_pc_mam = psa2_pc_mam*-1.
           if (vxreg_plot_flag.eq.0) then
              psa2_vreg_mam = psa2_vreg_mam*-1.
           end if
        end if     
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(sam_pc_mam),False)
     if (sig_pcv(0)) then    ; if True then significant
        sam_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        sam_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     if (sig_pcv(1)) then    ; if True then significant
        psa1_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
     else
        psa1_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
     end if
     if (sig_pcv(2)) then    ; if True then significant
        psa2_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%*"
     else
        psa2_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(sam_pc_djf,sam_pc_mam) 
     copy_VarCoords(sam_pc_djf,psa1_pc_mam)
     copy_VarCoords(sam_pc_djf,psa2_pc_mam)  
     delete([/evecv,pcts/])
     
     evecv = eofunc(arr_jja_CW({lat|:-20},lon|:,time|:),4,75)
     pcts = eofunc_ts(arr_jja_CW({lat|:-20},lon|:,time|:),evecv,False)  
     sam_pc_jja = dim_standardize(pcts(0,:),0)
     psa1_pc_jja = dim_standardize(pcts(1,:),0)
     psa2_pc_jja = dim_standardize(pcts(2,:),0)     
     sam_jja = arr_jja(0,:,:)
     sam_jja = (/ regCoef(sam_pc_jja,arr_jja(lat|:,lon|:,time|:)) /)
     psa1_jja = arr_jja(0,:,:)
     psa1_jja = (/ regCoef(psa1_pc_jja,arr_jja(lat|:,lon|:,time|:)) /)
     psa2_jja = arr_jja(0,:,:)
     psa2_jja = (/ regCoef(psa2_pc_jja,arr_jja(lat|:,lon|:,time|:)) /)
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(sam_pc_jja, vreg_jja, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        sam_vreg_jja  = vreg_jja(0,:,:)
        sam_prob_jja  = vreg_jja(0,:,:)
        sam_vreg_jja  = (/ rc /)
        sam_prob_jja  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(psa1_pc_jja, vreg_jja, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        psa1_vreg_jja  = vreg_jja(0,:,:)
        psa1_prob_jja  = vreg_jja(0,:,:)
        psa1_vreg_jja  = (/ rc /)
        psa1_prob_jja  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(psa2_pc_jja, vreg_jja, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        psa2_vreg_jja  = vreg_jja(0,:,:)
        psa2_prob_jja  = vreg_jja(0,:,:)
        psa2_vreg_jja  = (/ rc /)
        psa2_prob_jja  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b,vreg_jja/])
     end if

     if (.not.ismissing(sam_jja({-85},{5}))) then
        if (sam_jja({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           sam_jja = sam_jja*-1.
           sam_pc_jja = sam_pc_jja*-1.
           if (vxreg_plot_flag.eq.0) then
              sam_vreg_jja = sam_vreg_jja*-1.
           end if
        end if
     end if
     if (.not.ismissing(psa1_jja({-62},{210}))) then
        if (psa1_jja({-62},{210}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           psa1_jja = psa1_jja*-1.
           psa1_pc_jja = psa1_pc_jja*-1.
           if (vxreg_plot_flag.eq.0) then
              psa1_vreg_jja = psa1_vreg_jja*-1.
           end if
        end if
     end if
     if (.not.ismissing(psa2_jja({-60},{280}))) then
        if (psa2_jja({-60},{280}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           psa2_jja = psa2_jja*-1.
           psa2_pc_jja = psa2_pc_jja*-1.
           if (vxreg_plot_flag.eq.0) then
              psa2_vreg_jja = psa2_vreg_jja*-1.
           end if
        end if     
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(sam_pc_jja),False)
     if (sig_pcv(0)) then    ; if True then significant
        sam_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        sam_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     if (sig_pcv(1)) then    ; if True then significant
        psa1_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
     else
        psa1_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
     end if
     if (sig_pcv(2)) then    ; if True then significant
        psa2_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%*"
     else
        psa2_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(sam_pc_djf,sam_pc_jja) 
     copy_VarCoords(sam_pc_djf,psa1_pc_jja)
     copy_VarCoords(sam_pc_djf,psa2_pc_jja)  
     delete([/evecv,pcts/])
 
     evecv = eofunc(arr_son_CW({lat|:-20},lon|:,time|:),4,75)
     pcts = eofunc_ts(arr_son_CW({lat|:-20},lon|:,time|:),evecv,False)  
     sam_pc_son = dim_standardize(pcts(0,:),0)
     psa1_pc_son = dim_standardize(pcts(1,:),0)
     psa2_pc_son = dim_standardize(pcts(2,:),0)     
     sam_son = arr_son(0,:,:)
     sam_son = (/ regCoef(sam_pc_son,arr_son(lat|:,lon|:,time|:)) /)
     psa1_son = arr_son(0,:,:)
     psa1_son = (/ regCoef(psa1_pc_son,arr_son(lat|:,lon|:,time|:)) /)
     psa2_son = arr_son(0,:,:)
     psa2_son = (/ regCoef(psa2_pc_son,arr_son(lat|:,lon|:,time|:)) /)
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(sam_pc_son, vreg_son, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        sam_vreg_son  = vreg_son(0,:,:)
        sam_prob_son  = vreg_son(0,:,:)
        sam_vreg_son  = (/ rc /)
        sam_prob_son  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(psa1_pc_son, vreg_son, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        psa1_vreg_son  = vreg_son(0,:,:)
        psa1_prob_son  = vreg_son(0,:,:)
        psa1_vreg_son  = (/ rc /)
        psa1_prob_son  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(psa2_pc_son, vreg_son, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        psa2_vreg_son  = vreg_son(0,:,:)
        psa2_prob_son  = vreg_son(0,:,:)
        psa2_vreg_son  = (/ rc /)
        psa2_prob_son  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b,vreg_son/])
     end if

     if (.not.ismissing(sam_son({-85},{5}))) then
        if (sam_son({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           sam_son = sam_son*-1.
           sam_pc_son = sam_pc_son*-1.
           if (vxreg_plot_flag.eq.0) then
              sam_vreg_son = sam_vreg_son*-1.
           end if
        end if
     end if
     if (.not.ismissing(psa1_son({-62},{210}))) then
        if (psa1_son({-62},{210}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           psa1_son = psa1_son*-1.
           psa1_pc_son = psa1_pc_son*-1.
           if (vxreg_plot_flag.eq.0) then
              psa1_vreg_son = psa1_vreg_son*-1.
           end if
        end if
     end if
     if (.not.ismissing(psa2_son({-60},{280}))) then
        if (psa2_son({-60},{280}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           psa2_son = psa2_son*-1.
           psa2_pc_son = psa2_pc_son*-1.
           if (vxreg_plot_flag.eq.0) then
              psa2_vreg_son = psa2_vreg_son*-1.
           end if
        end if     
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(sam_pc_son),False)
     if (sig_pcv(0)) then    ; if True then significant
        sam_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        sam_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     if (sig_pcv(1)) then    ; if True then significant
        psa1_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
     else
        psa1_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
     end if
     if (sig_pcv(2)) then    ; if True then significant
        psa2_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%*"
     else
        psa2_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(sam_pc_djf,sam_pc_son) 
     copy_VarCoords(sam_pc_djf,psa1_pc_son)
     copy_VarCoords(sam_pc_djf,psa2_pc_son)  
     delete([/evecv,pcts/])

     evecv = eofunc(arr_ann_CW({lat|:-20},lon|:,time|:),4,75)
     pcts = eofunc_ts(arr_ann_CW({lat|:-20},lon|:,time|:),evecv,False)  
     sam_pc_ann = dim_standardize(pcts(0,:),0)
     psa1_pc_ann = dim_standardize(pcts(1,:),0)
     psa2_pc_ann = dim_standardize(pcts(2,:),0)     
     sam_ann = arr_ann(0,:,:)
     sam_ann = (/ regCoef(sam_pc_ann,arr_ann(lat|:,lon|:,time|:)) /)
     psa1_ann = arr_ann(0,:,:)
     psa1_ann = (/ regCoef(psa1_pc_ann,arr_ann(lat|:,lon|:,time|:)) /)
     psa2_ann = arr_ann(0,:,:)
     psa2_ann = (/ regCoef(psa2_pc_ann,arr_ann(lat|:,lon|:,time|:)) /)
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(sam_pc_ann, vreg_ann, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        sam_vreg_ann  = vreg_ann(0,:,:)
        sam_prob_ann  = vreg_ann(0,:,:)
        sam_vreg_ann  = (/ rc /)
        sam_prob_ann  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(psa1_pc_ann, vreg_ann, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        psa1_vreg_ann  = vreg_ann(0,:,:)
        psa1_prob_ann  = vreg_ann(0,:,:)
        psa1_vreg_ann  = (/ rc /)
        psa1_prob_ann  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b/])
        rc        = regCoef_n(psa2_pc_ann, vreg_ann, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        psa2_vreg_ann  = vreg_ann(0,:,:)
        psa2_prob_ann  = vreg_ann(0,:,:)
        psa2_vreg_ann  = (/ rc /)
        psa2_prob_ann  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        delete([/rc,tval,df,b,vreg_ann/])
     end if

     if (.not.ismissing(sam_ann({-85},{5}))) then
        if (sam_ann({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           sam_ann = sam_ann*-1.
           sam_pc_ann = sam_pc_ann*-1.
           if (vxreg_plot_flag.eq.0) then
              sam_vreg_ann = sam_vreg_ann*-1.
           end if
        end if
     end if
     if (.not.ismissing(psa1_ann({-62},{210}))) then
        if (psa1_ann({-62},{210}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           psa1_ann = psa1_ann*-1.
           psa1_pc_ann = psa1_pc_ann*-1.
           if (vxreg_plot_flag.eq.0) then
              psa1_vreg_ann = psa1_vreg_ann*-1.
           end if
        end if
     end if
     if (.not.ismissing(psa2_ann({-60},{280}))) then
        if (psa2_ann({-60},{280}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           psa2_ann = psa2_ann*-1.
           psa2_pc_ann = psa2_pc_ann*-1.
           if (vxreg_plot_flag.eq.0) then
              psa2_vreg_ann = psa2_vreg_ann*-1.
           end if
        end if     
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(sam_pc_ann),False)
     if (sig_pcv(0)) then    ; if True then significant
        sam_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        sam_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     if (sig_pcv(1)) then    ; if True then significant
        psa1_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
     else
        psa1_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
     end if
     if (sig_pcv(2)) then    ; if True then significant
        psa2_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%*"
     else
        psa2_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(sam_pc_djf,sam_pc_ann) 
     copy_VarCoords(sam_pc_djf,psa1_pc_ann)
     copy_VarCoords(sam_pc_djf,psa2_pc_ann)  
     delete([/evecv,pcts/])
     
     if (COMPUTE_MODES_MON.eq."True") then     
        evecv = eofunc(arr_mon_CW({lat|:-20},lon|:,time|:),4,75)
        pcts = eofunc_ts(arr_mon_CW({lat|:-20},lon|:,time|:),evecv,False)  
        sam_pc_mon = dim_standardize(pcts(0,:),0)
        psa1_pc_mon = dim_standardize(pcts(1,:),0)
        psa2_pc_mon = dim_standardize(pcts(2,:),0)        
        sam_mon = arr(0,:,:)
        sam_mon = (/ regCoef(sam_pc_mon,arr(lat|:,lon|:,time|:)) /)
        psa1_mon = arr(0,:,:)
        psa1_mon = (/ regCoef(psa1_pc_mon,arr(lat|:,lon|:,time|:)) /)
        psa2_mon = arr(0,:,:)
        psa2_mon = (/ regCoef(psa2_pc_mon,arr(lat|:,lon|:,time|:)) /)
        if (vxreg_plot_flag.eq.0) then
           rc           = regCoef_n(sam_pc_mon, vreg, 0, 0) ; rc(nlat,mlon)
           tval         = onedtond(rc@tval , dimsizes(rc))
           df           = onedtond(rc@nptxy, dimsizes(rc)) - 2
           b            = tval
           b            = 0.5
           sam_vreg_mon  = vreg(0,:,:)
           sam_prob_mon  = vreg(0,:,:)
           sam_vreg_mon  = (/ rc /)
           sam_prob_mon  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
           delete([/rc,tval,df,b/])
           rc           = regCoef_n(psa1_pc_mon, vreg, 0, 0) ; rc(nlat,mlon)
           tval         = onedtond(rc@tval , dimsizes(rc))
           df           = onedtond(rc@nptxy, dimsizes(rc)) - 2
           b            = tval
           b            = 0.5
           psa1_vreg_mon  = vreg(0,:,:)
           psa1_prob_mon  = vreg(0,:,:)
           psa1_vreg_mon  = (/ rc /)
           psa1_prob_mon  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
           delete([/rc,tval,df,b/])
           rc           = regCoef_n(psa2_pc_mon, vreg, 0, 0) ; rc(nlat,mlon)
           tval         = onedtond(rc@tval , dimsizes(rc))
           df           = onedtond(rc@nptxy, dimsizes(rc)) - 2
           b            = tval
           b            = 0.5
           psa2_vreg_mon  = vreg(0,:,:)
           psa2_prob_mon  = vreg(0,:,:)
           psa2_vreg_mon  = (/ rc /)
           psa2_prob_mon  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
           delete([/rc,tval,df,b,vreg/])
        end if

        if (.not.ismissing(sam_mon({-85},{5}))) then
           if (sam_mon({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
              sam_mon = sam_mon*-1.
              sam_pc_mon = sam_pc_mon*-1.
              if (vxreg_plot_flag.eq.0) then
                 sam_vreg_mon = sam_vreg_mon*-1.
              end if
           end if
        end if
        if (.not.ismissing(psa1_mon({-62},{210}))) then
           if (psa1_mon({-62},{210}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
              psa1_mon = psa1_mon*-1.
              psa1_pc_mon = psa1_pc_mon*-1.
              if (vxreg_plot_flag.eq.0) then
                 psa1_vreg_mon = psa1_vreg_mon*-1.
              end if
           end if
        end if
        if (.not.ismissing(psa2_mon({-60},{280}))) then
           if (psa2_mon({-60},{280}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
              psa2_mon = psa2_mon*-1.
              psa2_pc_mon = psa2_pc_mon*-1.
              if (vxreg_plot_flag.eq.0) then
                 psa2_vreg_mon = psa2_vreg_mon*-1.
              end if
           end if     
        end if
        sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(sam_pc_mon),False)
        if (sig_pcv(0)) then    ; if True then significant
           sam_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
        else
           sam_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
        end if
        if (sig_pcv(1)) then    ; if True then significant
           psa1_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%*"
        else
           psa1_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(1)))+"%"
        end if
        if (sig_pcv(2)) then    ; if True then significant
           psa2_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%*"
        else
           psa2_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(2)))+"%"
        end if
        delete(sig_pcv)
        sam_pc_mon!0 = "time"
        sam_pc_mon&time = arr&time   
        psa1_pc_mon!0 = "time"
        psa1_pc_mon&time = arr&time   
        psa2_pc_mon!0 = "time"
        psa2_pc_mon&time = arr&time   
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
           fn = getenv("OUTDIR")+modname+".cvdp_data.psl.sam_psa."+vnm+"."+syear_reg(ee)+"-"+eyear_reg(ee)+".nc"
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

           z->sam_timeseries_djf = set_varAtts(sam_pc_djf,"SAM normalized principal component timeseries (DJF)","1","")
           z->sam_timeseries_mam = set_varAtts(sam_pc_mam,"SAM normalized principal component timeseries (MAM)","1","")
           z->sam_timeseries_jja = set_varAtts(sam_pc_jja,"SAM normalized principal component timeseries (JJA)","1","")
           z->sam_timeseries_son = set_varAtts(sam_pc_son,"SAM normalized principal component timeseries (SON)","1","")
           z->sam_timeseries_ann = set_varAtts(sam_pc_ann,"SAM normalized principal component timeseries (annual)","1","")

           z->psa1_timeseries_djf = set_varAtts(psa1_pc_djf,"PSA1 normalized principal component timeseries (DJF)","1","")
           z->psa1_timeseries_mam = set_varAtts(psa1_pc_mam,"PSA1 normalized principal component timeseries (MAM)","1","")
           z->psa1_timeseries_jja = set_varAtts(psa1_pc_jja,"PSA1 normalized principal component timeseries (JJA)","1","")
           z->psa1_timeseries_son = set_varAtts(psa1_pc_son,"PSA1 normalized principal component timeseries (SON)","1","")
           z->psa1_timeseries_ann = set_varAtts(psa1_pc_ann,"PSA1 normalized principal component timeseries (annual)","1","")

           z->psa2_timeseries_djf = set_varAtts(psa2_pc_djf,"PSA2 normalized principal component timeseries (DJF)","1","")
           z->psa2_timeseries_mam = set_varAtts(psa2_pc_mam,"PSA2 normalized principal component timeseries (MAM)","1","")
           z->psa2_timeseries_jja = set_varAtts(psa2_pc_jja,"PSA2 normalized principal component timeseries (JJA)","1","")
           z->psa2_timeseries_son = set_varAtts(psa2_pc_son,"PSA2 normalized principal component timeseries (SON)","1","")
           z->psa2_timeseries_ann = set_varAtts(psa2_pc_ann,"PSA2 normalized principal component timeseries (annual)","1","")

           vout = "sam_"+vnm+"_regression_djf"
           vosr = vnm+" regression onto SAM principal component timeseries (DJF)"
           z->$vout$ = set_varAtts(sam_vreg_djf,vosr,"","") 
           vout = "sam_"+vnm+"_regression_mam"
           vosr = vnm+" regression onto SAM principal component timeseries (MAM)"
           z->$vout$ = set_varAtts(sam_vreg_mam,vosr,"","")  
           vout = "sam_"+vnm+"_regression_jja"
           vosr = vnm+" regression onto SAM principal component timeseries (JJA)"
           z->$vout$ = set_varAtts(sam_vreg_jja,vosr,"","")  
           vout = "sam_"+vnm+"_regression_son"
           vosr = vnm+" regression onto SAM principal component timeseries (SON)"
           z->$vout$ = set_varAtts(sam_vreg_son,vosr,"","")  
           vout = "sam_"+vnm+"_regression_ann"
           vosr = vnm+" regression onto SAM principal component timeseries (annual)"
           z->$vout$ = set_varAtts(sam_vreg_ann,vosr,"","")  

           vout = "psa1_"+vnm+"_regression_djf"
           vosr = vnm+" regression onto PSA1 principal component timeseries (DJF)"
           z->$vout$ = set_varAtts(psa1_vreg_djf,vosr,"","")
           vout = "psa1_"+vnm+"_regression_mam"
           vosr = vnm+" regression onto PSA1 principal component timeseries (MAM)"
           z->$vout$ = set_varAtts(psa1_vreg_mam,vosr,"","")
           vout = "psa1_"+vnm+"_regression_jja"
           vosr = vnm+" regression onto PSA1 principal component timeseries (JJA)"
           z->$vout$ = set_varAtts(psa1_vreg_jja,vosr,"","")
           vout = "psa1_"+vnm+"_regression_son"
           vosr = vnm+" regression onto PSA1 principal component timeseries (SON)"
           z->$vout$ = set_varAtts(psa1_vreg_son,vosr,"","")  
           vout = "psa1_"+vnm+"_regression_ann"
           vosr = vnm+" regression onto PSA1 principal component timeseries (annual)"
           z->$vout$ = set_varAtts(psa1_vreg_ann,vosr,"","")

           vout = "psa2_"+vnm+"_regression_djf"
           vosr = vnm+" regression onto PSA2 principal component timeseries (DJF)"
           z->$vout$ = set_varAtts(psa2_vreg_djf,vosr,"","")
           vout = "psa2_"+vnm+"_regression_mam"
           vosr = vnm+" regression onto PSA2 principal component timeseries (MAM)"
           z->$vout$ = set_varAtts(psa2_vreg_mam,vosr,"","")
           vout = "psa2_"+vnm+"_regression_jja"
           vosr = vnm+" regression onto PSA2 principal component timeseries (JJA)"
           z->$vout$ = set_varAtts(psa2_vreg_jja,vosr,"","")
           vout = "psa2_"+vnm+"_regression_son"
           vosr = vnm+" regression onto PSA2 principal component timeseries (SON)"
           z->$vout$ = set_varAtts(psa2_vreg_son,vosr,"","")
           vout = "psa2_"+vnm+"_regression_ann"
           vosr = vnm+" regression onto PSA2 principal component timeseries (annual)"
           z->$vout$ = set_varAtts(psa2_vreg_ann,vosr,"","")

           vout = "sam_"+vnm+"_regprob_djf"
           vosr = vnm+" SAM regression t-test probility(DJF)"
           z->$vout$ = set_varAtts(sam_prob_djf,vosr,"","")
           vout = "sam_"+vnm+"_regprob_mam"
           vosr = vnm+" SAM regression t-test probility(MAM)"
           z->$vout$ = set_varAtts(sam_prob_mam,vosr,"","")
           vout = "sam_"+vnm+"_regprob_jja"
           vosr = vnm+" SAM regression t-test probility(JJA)"
           z->$vout$ = set_varAtts(sam_prob_jja,vosr,"","")
           vout = "sam_"+vnm+"_regprob_son"
           vosr = vnm+" SAM regression t-test probility(SON)"
           z->$vout$ = set_varAtts(sam_prob_son,vosr,"","")
           vout = "sam_"+vnm+"_regprob_ann"
           vosr = vnm+" SAM regression t-test probility(annual)"
           z->$vout$ = set_varAtts(sam_prob_ann,vosr,"","")

           vout = "psa1_"+vnm+"_regprob_djf"
           vosr = vnm+" PSA1 regression t-test probility(DJF)"
           z->$vout$ = set_varAtts(psa1_prob_djf,vosr,"","")
           vout = "psa1_"+vnm+"_regprob_mam"
           vosr = vnm+" PSA1 regression t-test probility(MAM)"
           z->$vout$ = set_varAtts(psa1_prob_mam,vosr,"","")
           vout = "psa1_"+vnm+"_regprob_jja"
           vosr = vnm+" PSA1 regression t-test probility(JJA)"
           z->$vout$ = set_varAtts(psa1_prob_jja,vosr,"","")
           vout = "psa1_"+vnm+"_regprob_son"
           vosr = vnm+" PSA1 regression t-test probility(SON)"
           z->$vout$ = set_varAtts(psa1_prob_son,vosr,"","")
           vout = "psa1_"+vnm+"_regprob_ann"
           vosr = vnm+" PSA1 regression t-test probility(annual)"
           z->$vout$ = set_varAtts(psa1_prob_ann,vosr,"","")

           vout = "psa2_"+vnm+"_regprob_djf"
           vosr = vnm+" PSA2 regression t-test probility(DJF)"
           z->$vout$ = set_varAtts(psa2_prob_djf,vosr,"","")
           vout = "psa2_"+vnm+"_regprob_mam"
           vosr = vnm+" PSA2 regression t-test probility(MAM)"
           z->$vout$ = set_varAtts(psa2_prob_mam,vosr,"","")
           vout = "psa2_"+vnm+"_regprob_jja"
           vosr = vnm+" PSA2 regression t-test probility(JJA)"
           z->$vout$ = set_varAtts(psa2_prob_jja,vosr,"","")
           vout = "psa2_"+vnm+"_regprob_son"
           vosr = vnm+" PSA2 regression t-test probility(SON)"
           z->$vout$ = set_varAtts(psa2_prob_son,vosr,"","")
           vout = "psa2_"+vnm+"_regprob_ann"
           vosr = vnm+" PSA2 regression t-test probility(annual)"
           z->$vout$ = set_varAtts(psa2_prob_ann,vosr,"","")

           if (COMPUTE_MODES_MON.eq."True") then   

              z->sam_timeseries_mon  = set_varAtts(sam_pc_mon,"SAM principal component timeseries (monthly)","","")
              z->psa1_timeseries_mon = set_varAtts(psa1_pc_mon,"PSA1 principal component timeseries (monthly)","","")
              z->psa2_timeseries_mon = set_varAtts(psa2_pc_mon,"PSA2 principal component timeseries (monthly)","","")

              vout = "sam_"+vnm+"_regression_mon"
              vosr = vnm+" regression onto SAM principal component timeseries (monthly)"
              z->$vout$ = set_varAtts(sam_vreg_mon,vosr,"","")

              vout = "psa1_"+vnm+"_regression_mon"
              vosr = vnm+" regression onto PSA1 principal component timeseries (monthly)"
              z->$vout$ = set_varAtts(psa1_vreg_mon,vosr,"","")

              vout = "psa2_"+vnm+"_regression_mon"
              vosr = vnm+" regression onto PSA2 principal component timeseries (monthly)"
              z->$vout$ = set_varAtts(psa2_vreg_mon,vosr,"","")

              vout = "sam_"+vnm+"_regprob_mon"
              vosr = vnm+" SAM regression t-test probility(monthly)"
              z->$vout$ = set_varAtts(sam_prob_mon,vosr,"","")

              vout = "psa1_"+vnm+"_regprob_mon"
              vosr = vnm+" PSA1 regression t-test probility(monthly)"
              z->$vout$ = set_varAtts(psa1_prob_mon,vosr,"","")

              vout = "psa2_"+vnm+"_regprob_mon"
              vosr = vnm+" PSA2 regression t-test probility(monthly)"
              z->$vout$ = set_varAtts(psa2_prob_mon,vosr,"","")

           end if
           delete(z)
           delete([/modname,fn/])
        end if
     end if     
     delete([/sam_pc_djf,sam_pc_jja,sam_pc_mam,sam_pc_son,sam_pc_mon/])
     delete([/psa1_pc_djf,psa1_pc_jja,psa1_pc_mam,psa1_pc_son,psa1_pc_mon/])
     delete([/psa2_pc_djf,psa2_pc_jja,psa2_pc_mam,psa2_pc_son,psa2_pc_mon/])

     x1d = ndtooned((/sam_vreg_djf({:-20},:),psa1_vreg_djf({:-20},:),psa2_vreg_djf({:-20},:)/))
     xm  = dim_median(abs(x1d))
     sfcfacs = 1.0
     if(xm.gt.1) then
       sfcfacs= toint(xm)*1.0
     else if (xm.gt.1e-1) then
       sfcfacs = 1.0
     else if (xm.gt.1e-2) then
       sfcfacs = 0.1
     else if (xm.gt.1e-3) then
       sfcfacs = 0.01
     end if
     end if
     end if
     end if
     delete([/xm,x1d/])

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
     res@gsnPolar     = "SH"     
     res@mpMaxLatF    = -20.
     res@mpCenterLonF = 0.
 
     res@cnLevels := (/-0.8,-0.6,-0.4,-0.2,-0.1,0,0.1,0.2,0.4,0.6,0.8/)
     res@cnLevels = res@cnLevels * sfcfacs
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
        patcor_sam_djf = new((/nsim,dimsizes(sam_djf&lat),dimsizes(sam_djf&lon)/),typeof(sam_djf))
        patcor_sam_djf!1 = "lat"
        patcor_sam_djf&lat = sam_djf&lat
        patcor_sam_djf!2 = "lon"
        patcor_sam_djf&lon = sam_djf&lon
        patcor_sam_jja = patcor_sam_djf
        patcor_sam_ann = patcor_sam_djf
        patcor_psa1_djf = patcor_sam_djf
        patcor_psa1_jja = patcor_sam_djf
        patcor_psa1_ann = patcor_sam_djf
        patcor_psa2_djf = patcor_sam_djf
        patcor_psa2_jja = patcor_sam_djf
        patcor_psa2_ann = patcor_sam_djf
        patcor_sam_djf(ee,:,:) = (/ sam_djf /)
        patcor_sam_jja(ee,:,:) = (/ sam_jja /)
        patcor_sam_ann(ee,:,:) = (/ sam_ann /)
        patcor_psa1_djf(ee,:,:) = (/ psa1_djf /)
        patcor_psa1_jja(ee,:,:) = (/ psa1_jja /)
        patcor_psa1_ann(ee,:,:) = (/ psa1_ann /)
        patcor_psa2_djf(ee,:,:) = (/ psa2_djf /)
        patcor_psa2_jja(ee,:,:) = (/ psa2_jja /)
        patcor_psa2_ann(ee,:,:) = (/ psa2_ann /)
     end if
     if (isfilepresent2("obs_psl").and.ee.ge.1.and.isvar("patcor_sam_djf")) then       
        patcor_sam_djf(ee,:,:) = (/ totype(linint2(sam_djf&lon,sam_djf&lat,sam_djf,True,patcor_sam_djf&lon,patcor_sam_djf&lat,0),typeof(patcor_sam_djf)) /)
        patcor_sam_jja(ee,:,:) = (/ totype(linint2(sam_jja&lon,sam_jja&lat,sam_jja,True,patcor_sam_jja&lon,patcor_sam_jja&lat,0),typeof(patcor_sam_jja)) /)
        patcor_sam_ann(ee,:,:) = (/ totype(linint2(sam_ann&lon,sam_ann&lat,sam_ann,True,patcor_sam_ann&lon,patcor_sam_ann&lat,0),typeof(patcor_sam_ann)) /)
        
        patcor_psa1_djf(ee,:,:) = (/ totype(linint2(psa1_djf&lon,psa1_djf&lat,psa1_djf,True,patcor_psa1_djf&lon,patcor_psa1_djf&lat,0),typeof(patcor_psa1_djf)) /)
        patcor_psa1_jja(ee,:,:) = (/ totype(linint2(psa1_jja&lon,psa1_jja&lat,psa1_jja,True,patcor_psa1_jja&lon,patcor_psa1_jja&lat,0),typeof(patcor_psa1_jja)) /)
        patcor_psa1_ann(ee,:,:) = (/ totype(linint2(psa1_ann&lon,psa1_ann&lat,psa1_ann,True,patcor_psa1_ann&lon,patcor_psa1_ann&lat,0),typeof(patcor_psa1_ann)) /)
        
        patcor_psa2_djf(ee,:,:) = (/ totype(linint2(psa2_djf&lon,psa2_djf&lat,psa2_djf,True,patcor_psa2_djf&lon,patcor_psa2_djf&lat,0),typeof(patcor_psa2_djf)) /)
        patcor_psa2_jja(ee,:,:) = (/ totype(linint2(psa2_jja&lon,psa2_jja&lat,psa2_jja,True,patcor_psa2_jja&lon,patcor_psa2_jja&lat,0),typeof(patcor_psa2_jja)) /)
        patcor_psa2_ann(ee,:,:) = (/ totype(linint2(psa2_ann&lon,psa2_ann&lat,psa2_ann,True,patcor_psa2_ann&lon,patcor_psa2_ann&lat,0),typeof(patcor_psa2_ann)) /)
     end if
      
     if (vxreg_plot_flag.eq.0) then
        res@gsnCenterString = names_reg(ee)
        res@gsnRightString = ""
        reg_sam_djf(ee) = gsn_csm_contour_map_polar(wks_sam,sam_vreg_djf,res)
        reg_sam_mam(ee) = gsn_csm_contour_map_polar(wks_sam,sam_vreg_mam,res)
        reg_sam_jja(ee) = gsn_csm_contour_map_polar(wks_sam,sam_vreg_jja,res)
        reg_sam_son(ee) = gsn_csm_contour_map_polar(wks_sam,sam_vreg_son,res)
        reg_sam_ann(ee) = gsn_csm_contour_map_polar(wks_sam,sam_vreg_ann,res)     
        delete([/sam_vreg_djf,sam_vreg_mam,sam_vreg_jja,sam_vreg_son,sam_vreg_ann/])
        o_djf = gsn_csm_contour(wks_sam,sam_prob_djf,res2)
        o_djf = gsn_contour_shade(o_djf,-999,95,opt) 
        o_mam = gsn_csm_contour(wks_sam,sam_prob_mam,res2)
        o_mam = gsn_contour_shade(o_mam,-999,95,opt) 
        o_jja = gsn_csm_contour(wks_sam,sam_prob_jja,res2)
        o_jja = gsn_contour_shade(o_jja,-999,95,opt)
        o_son = gsn_csm_contour(wks_sam,sam_prob_son,res2)
        o_son = gsn_contour_shade(o_son,-999,95,opt)
        o_ann = gsn_csm_contour(wks_sam,sam_prob_ann,res2)
        o_ann = gsn_contour_shade(o_ann,-999,95,opt)
        delete([/sam_prob_djf,sam_prob_mam,sam_prob_jja,sam_prob_son,sam_prob_ann/])
        overlay(reg_sam_djf(ee),o_djf)
        overlay(reg_sam_mam(ee),o_mam)
        overlay(reg_sam_jja(ee),o_jja)
        overlay(reg_sam_son(ee),o_son)
        overlay(reg_sam_ann(ee),o_ann)
        delete([/o_djf,o_mam,o_jja,o_son,o_ann/])
        if (COMPUTE_MODES_MON.eq."True") then                    
           reg_sam_mon(ee) = gsn_csm_contour_map_polar(wks_sam,sam_vreg_mon,res)
           delete([/sam_vreg_mon/])
           o_mon = gsn_csm_contour(wks_sam,sam_prob_mon,res2)
           o_mon = gsn_contour_shade(o_mon,-999,95,opt)
           overlay(reg_sam_mon(ee),o_mon)
           delete([/o_mon,sam_prob_mon/])
        end if
     
        reg_psa1_djf(ee) = gsn_csm_contour_map_polar(wks_psa1,psa1_vreg_djf,res)
        reg_psa1_mam(ee) = gsn_csm_contour_map_polar(wks_psa1,psa1_vreg_mam,res)
        reg_psa1_jja(ee) = gsn_csm_contour_map_polar(wks_psa1,psa1_vreg_jja,res)
        reg_psa1_son(ee) = gsn_csm_contour_map_polar(wks_psa1,psa1_vreg_son,res)
        reg_psa1_ann(ee) = gsn_csm_contour_map_polar(wks_psa1,psa1_vreg_ann,res)     
        delete([/psa1_vreg_djf,psa1_vreg_mam,psa1_vreg_jja,psa1_vreg_son,psa1_vreg_ann/])
        o_djf = gsn_csm_contour(wks_psa1,psa1_prob_djf,res2)
        o_djf = gsn_contour_shade(o_djf,-999,95,opt)
        o_mam = gsn_csm_contour(wks_psa1,psa1_prob_mam,res2)
        o_mam = gsn_contour_shade(o_mam,-999,95,opt)
        o_jja = gsn_csm_contour(wks_psa1,psa1_prob_jja,res2)
        o_jja = gsn_contour_shade(o_jja,-999,95,opt)
        o_son = gsn_csm_contour(wks_psa1,psa1_prob_son,res2)
        o_son = gsn_contour_shade(o_son,-999,95,opt)
        o_ann = gsn_csm_contour(wks_psa1,psa1_prob_ann,res2)
        o_ann = gsn_contour_shade(o_ann,-999,95,opt)
        delete([/psa1_prob_djf,psa1_prob_mam,psa1_prob_jja,psa1_prob_son,psa1_prob_ann/])
        overlay(reg_psa1_djf(ee),o_djf)
        overlay(reg_psa1_mam(ee),o_mam)
        overlay(reg_psa1_jja(ee),o_jja)
        overlay(reg_psa1_son(ee),o_son)
        overlay(reg_psa1_ann(ee),o_ann)
        delete([/o_djf,o_mam,o_jja,o_son,o_ann/])
        if (COMPUTE_MODES_MON.eq."True") then
           reg_psa1_mon(ee) = gsn_csm_contour_map_polar(wks_psa1,psa1_vreg_mon,res)
           delete([/psa1_vreg_mon/])
           o_mon = gsn_csm_contour(wks_psa1,psa1_prob_mon,res2)
           o_mon = gsn_contour_shade(o_mon,-999,95,opt)
           overlay(reg_psa1_mon(ee),o_mon)
           delete([/o_mon,psa1_prob_mon/])
        end if

        reg_psa2_djf(ee) = gsn_csm_contour_map_polar(wks_psa2,psa2_vreg_djf,res)
        reg_psa2_mam(ee) = gsn_csm_contour_map_polar(wks_psa2,psa2_vreg_mam,res)
        reg_psa2_jja(ee) = gsn_csm_contour_map_polar(wks_psa2,psa2_vreg_jja,res)
        reg_psa2_son(ee) = gsn_csm_contour_map_polar(wks_psa2,psa2_vreg_son,res)
        reg_psa2_ann(ee) = gsn_csm_contour_map_polar(wks_psa2,psa2_vreg_ann,res)     
        delete([/psa2_vreg_djf,psa2_vreg_mam,psa2_vreg_jja,psa2_vreg_son,psa2_vreg_ann/])
        o_djf = gsn_csm_contour(wks_psa2,psa2_prob_djf,res2)
        o_djf = gsn_contour_shade(o_djf,-999,95,opt)
        o_mam = gsn_csm_contour(wks_psa2,psa2_prob_mam,res2)
        o_mam = gsn_contour_shade(o_mam,-999,95,opt)
        o_jja = gsn_csm_contour(wks_psa2,psa2_prob_jja,res2)
        o_jja = gsn_contour_shade(o_jja,-999,95,opt)
        o_son = gsn_csm_contour(wks_psa2,psa2_prob_son,res2)
        o_son = gsn_contour_shade(o_son,-999,95,opt)
        o_ann = gsn_csm_contour(wks_psa2,psa2_prob_ann,res2)
        o_ann = gsn_contour_shade(o_ann,-999,95,opt)
        delete([/psa2_prob_djf,psa2_prob_mam,psa2_prob_jja,psa2_prob_son,psa2_prob_ann/])
        overlay(reg_psa2_djf(ee),o_djf)
        overlay(reg_psa2_mam(ee),o_mam)
        overlay(reg_psa2_jja(ee),o_jja)
        overlay(reg_psa2_son(ee),o_son)
        overlay(reg_psa2_ann(ee),o_ann)
        delete([/o_djf,o_mam,o_jja,o_son,o_ann/])
        if (COMPUTE_MODES_MON.eq."True") then
           reg_psa2_mon(ee) = gsn_csm_contour_map_polar(wks_psa2,psa2_vreg_mon,res)
           delete([/psa2_vreg_mon/])
           o_mon = gsn_csm_contour(wks_psa2,psa2_prob_mon,res2)
           o_mon = gsn_contour_shade(o_mon,-999,95,opt)
           overlay(reg_psa2_mon(ee),o_mon)
           delete([/o_mon,psa2_prob_mon/])
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
  
  if (isvar("patcor_sam_djf")) then    ; for pattern correlation table  
     clat = cos(0.01745329*patcor_sam_djf&lat)
     clat!0 = "lat"
     clat&lat = patcor_sam_djf&lat
     line3   = "                  "    ; Must be 18 characters long
     line4   = line3
     header = (/"","Pattern Correlations   Observations vs. Model(s)",""/)
     finpr_sam_djf  = "SAM (DJF)         "     
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
        if (all(ismissing(patcor_sam_djf(hh,{:-20},:)))) then
           finpr_sam_djf = finpr_sam_djf+sprintf(format2,9.99)+"/"+sprintf(format3,9.99)
        else
           finpr_sam_djf = finpr_sam_djf+sprintf(format2,(pattern_cor(patcor_sam_djf(0,{:-20},:),patcor_sam_djf(hh,{:-20},:),clat({:-20}),0)))+"/"+sprintf(format3,(wgt_arearmse(patcor_sam_djf(0,{:-20},:),patcor_sam_djf(hh,{:-20},:),clat({:-20}),1.0,0)))
        end if        
     end do
;     
     if (dimsizes(tochar(line4)).ge.8190) then   ; system or fortran compiler limit
        print("Metrics table warning: Not creating metrics table as size of comparison results in a invalid ascii row size.")   
     else           
        write_table(getenv("OUTDIR")+"metrics.psl.sam_psa_"+vnm+"_regpatt.txt","w",[/header/],"%s")
        write_table(getenv("OUTDIR")+"metrics.psl.sam_psa_"+vnm+"_regpatt.txt","a",[/line3/],"%s")
        write_table(getenv("OUTDIR")+"metrics.psl.sam_psa_"+vnm+"_regpatt.txt","a",[/line4/],"%s")  
        write_table(getenv("OUTDIR")+"metrics.psl.sam_psa_"+vnm+"_regpatt.txt","a",[/finpr_sam_djf/],"%s")
     end if
     delete([/line3,line4,format2,format3,nchar,ntc,clat,patcor_sam_djf,patcor_sam_jja,patcor_sam_ann/])
     delete([/patcor_psa1_djf,patcor_psa1_jja,patcor_psa1_ann,patcor_psa2_djf,patcor_psa2_jja,patcor_psa2_ann,dimY,ntb,header/])
  end if 

  panres = True
  panres@gsnMaximize = True
  panres@gsnPaperOrientation = "portrait"
  panres@gsnPanelLabelBar = True
  panres@gsnPanelYWhiteSpacePercent = 3.0
  panres@pmLabelBarHeightF = 0.05
  panres@pmLabelBarWidthF = 0.55
  panres@lbTitleOn = False
  panres@lbBoxLineColor = "gray70"
  if (nsim.le.4) then
     if (nsim.eq.1) then
        panres@txFontHeightF = 0.022
        panres@gsnPanelBottom = 0.50
     else
        panres@txFontHeightF = 0.0145
        panres@gsnPanelBottom = 0.50
     end if
  else
     panres@txFontHeightF = 0.016
     panres@gsnPanelBottom = 0.05
  end if
  ncol = floattointeger(sqrt(nsim))
  nrow = (nsim/ncol)+mod(nsim,ncol) 
  
  if (vxreg_frame.eq.0) then
     if(vnm.eq."qnet") then
       txt0 = "Qnet"
     else
       txt0 = str_upper(vnm)
     end if
     panres@txString = "SAM "+txt0+" Regressions (DJF)" 
     gsn_panel2(wks_sam,reg_sam_djf,(/nrow,ncol/),panres)
     delete(reg_sam_djf)
     panres@txString = "SAM "+txt0+" Regressions (MAM)"
     gsn_panel2(wks_sam,reg_sam_mam,(/nrow,ncol/),panres)
     delete(reg_sam_mam)
     panres@txString = "SAM "+txt0+" Regressions (JJA)"
     gsn_panel2(wks_sam,reg_sam_jja,(/nrow,ncol/),panres)
     delete(reg_sam_jja)
     panres@txString = "SAM "+txt0+" Regressions (SON)"
     gsn_panel2(wks_sam,reg_sam_son,(/nrow,ncol/),panres)
     delete(reg_sam_son)
     panres@txString = "SAM "+txt0+" Regressions (Annual)"
     gsn_panel2(wks_sam,reg_sam_ann,(/nrow,ncol/),panres)
     delete(reg_sam_ann)
     if (COMPUTE_MODES_MON.eq."True") then    
        panres@txString = "SAM "+txt0+" Regressions (Monthly)"
        gsn_panel2(wks_sam,reg_sam_mon,(/nrow,ncol/),panres)
        delete(reg_sam_mon)
     end if
     delete(wks_sam)
  end if
  
  if (vxreg_frame.eq.0) then
     if(vnm.eq."qnet") then
       txt0 = "Qnet"
     else
       txt0 = str_upper(vnm)
     end if
     panres@txString = "PSA1 "+txt0+" Regressions (DJF)" 
     gsn_panel2(wks_psa1,reg_psa1_djf,(/nrow,ncol/),panres)
     delete(reg_psa1_djf)
     panres@txString = "PSA1 "+txt0+" Regressions (MAM)"
     gsn_panel2(wks_psa1,reg_psa1_mam,(/nrow,ncol/),panres)
     delete(reg_psa1_mam)
     panres@txString = "PSA1 "+txt0+" Regressions (JJA)"
     gsn_panel2(wks_psa1,reg_psa1_jja,(/nrow,ncol/),panres)
     delete(reg_psa1_jja)
     panres@txString = "PSA1 "+txt0+" Regressions (SON)"
     gsn_panel2(wks_psa1,reg_psa1_son,(/nrow,ncol/),panres)
     delete(reg_psa1_son)
     panres@txString = "PSA1 "+txt0+" Regressions (Annual)"
     gsn_panel2(wks_psa1,reg_psa1_ann,(/nrow,ncol/),panres)
     delete(reg_psa1_ann)
     if (COMPUTE_MODES_MON.eq."True") then    
        panres@txString = "PSA1 "+txt0+" Regressions (Monthly)"
        gsn_panel2(wks_psa1,reg_psa1_mon,(/nrow,ncol/),panres)
        delete(reg_psa1_mon)
     end if
     delete(wks_psa1)
  end if

  if (vxreg_frame.eq.0) then
     if(vnm.eq."qnet") then
       txt0 = "Qnet"
     else
       txt0 = str_upper(vnm)
     end if
     panres@txString = "PSA2 "+txt0+" Regressions (DJF)" 
     gsn_panel2(wks_psa2,reg_psa2_djf,(/nrow,ncol/),panres)
     delete(reg_psa2_djf)
     panres@txString = "PSA2 "+txt0+" Regressions (MAM)"
     gsn_panel2(wks_psa2,reg_psa2_mam,(/nrow,ncol/),panres)
     delete(reg_psa2_mam)
     panres@txString = "PSA2 "+txt0+" Regressions (JJA)"
     gsn_panel2(wks_psa2,reg_psa2_jja,(/nrow,ncol/),panres)
     delete(reg_psa2_jja)
     panres@txString = "PSA2 "+txt0+" Regressions (SON)"
     gsn_panel2(wks_psa2,reg_psa2_son,(/nrow,ncol/),panres)
     delete(reg_psa2_son)
     panres@txString = "PSA2 "+txt0+" Regressions (Annual)"
     gsn_panel2(wks_psa2,reg_psa2_ann,(/nrow,ncol/),panres)
     delete(reg_psa2_ann)
     if (COMPUTE_MODES_MON.eq."True") then    
        panres@txString = "PSA2 "+txt0+" Regressions (Monthly)"
        gsn_panel2(wks_psa2,reg_psa2_mon,(/nrow,ncol/),panres)
        delete(reg_psa2_mon)
     end if
     delete(wks_psa2)
  end if

;--------------------------------------------------------------------------------------------------
  OUTDIR = getenv("OUTDIR") 
  if (wks_type.eq."png") then       
     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"sam.vxreg.000001.png "+OUTDIR+"sam."+vnm+"reg.djf.png")
        system("mv "+OUTDIR+"sam.vxreg.000002.png "+OUTDIR+"sam."+vnm+"reg.mam.png")
        system("mv "+OUTDIR+"sam.vxreg.000003.png "+OUTDIR+"sam."+vnm+"reg.jja.png")
        system("mv "+OUTDIR+"sam.vxreg.000004.png "+OUTDIR+"sam."+vnm+"reg.son.png")
        system("mv "+OUTDIR+"sam.vxreg.000005.png "+OUTDIR+"sam."+vnm+"reg.ann.png")
        if (COMPUTE_MODES_MON.eq."True") then
          system("mv "+OUTDIR+"sam.vxreg.000006.png "+OUTDIR+"sam."+vnm+"reg.mon.png")   
        end if 
     end if

     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"psa1.vxreg.000001.png "+OUTDIR+"psa1."+vnm+"reg.djf.png")
        system("mv "+OUTDIR+"psa1.vxreg.000002.png "+OUTDIR+"psa1."+vnm+"reg.mam.png")
        system("mv "+OUTDIR+"psa1.vxreg.000003.png "+OUTDIR+"psa1."+vnm+"reg.jja.png")
        system("mv "+OUTDIR+"psa1.vxreg.000004.png "+OUTDIR+"psa1."+vnm+"reg.son.png")
        system("mv "+OUTDIR+"psa1.vxreg.000005.png "+OUTDIR+"psa1."+vnm+"reg.ann.png")
        if (COMPUTE_MODES_MON.eq."True") then
          system("mv "+OUTDIR+"psa1.vxreg.000006.png "+OUTDIR+"psa1."+vnm+"reg.mon.png")
        end if
     end if

     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"psa2.vxreg.000001.png "+OUTDIR+"psa2."+vnm+"reg.djf.png")
        system("mv "+OUTDIR+"psa2.vxreg.000002.png "+OUTDIR+"psa2."+vnm+"reg.mam.png")
        system("mv "+OUTDIR+"psa2.vxreg.000003.png "+OUTDIR+"psa2."+vnm+"reg.jja.png")
        system("mv "+OUTDIR+"psa2.vxreg.000004.png "+OUTDIR+"psa2."+vnm+"reg.son.png")
        system("mv "+OUTDIR+"psa2.vxreg.000005.png "+OUTDIR+"psa2."+vnm+"reg.ann.png")
        if (COMPUTE_MODES_MON.eq."True") then
          system("mv "+OUTDIR+"psa2.vxreg.000006.png "+OUTDIR+"psa2."+vnm+"reg.mon.png")
        end if
     end if

  else     
     system("psplit "+OUTDIR+"sam.vxreg.ps "+OUTDIR+"vx_sp")
     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"vx_sp0001.ps "+OUTDIR+"sam."+vnm+"reg.djf.ps") 
        system("mv "+OUTDIR+"vx_sp0002.ps "+OUTDIR+"sam."+vnm+"reg.mam.ps") 
        system("mv "+OUTDIR+"vx_sp0003.ps "+OUTDIR+"sam."+vnm+"reg.jja.ps") 
        system("mv "+OUTDIR+"vx_sp0004.ps "+OUTDIR+"sam."+vnm+"reg.son.ps") 
        system("mv "+OUTDIR+"vx_sp0005.ps "+OUTDIR+"sam."+vnm+"reg.ann.ps")
        if (COMPUTE_MODES_MON.eq."True") then
           system("mv "+OUTDIR+"vx_sp0006.ps "+OUTDIR+"sam."+vnm+"reg.mon.ps") 
        end if
     end if

     system("psplit "+OUTDIR+"psa1.vxreg.ps "+OUTDIR+"vx_sp")
     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"vx_sp0001.ps "+OUTDIR+"psa1."+vnm+"reg.djf.ps")
        system("mv "+OUTDIR+"vx_sp0002.ps "+OUTDIR+"psa1."+vnm+"reg.mam.ps") 
        system("mv "+OUTDIR+"vx_sp0003.ps "+OUTDIR+"psa1."+vnm+"reg.jja.ps")
        system("mv "+OUTDIR+"vx_sp0004.ps "+OUTDIR+"psa1."+vnm+"reg.son.ps") 
        system("mv "+OUTDIR+"vx_sp0005.ps "+OUTDIR+"psa1."+vnm+"reg.ann.ps")
        if (COMPUTE_MODES_MON.eq."True") then
           system("mv "+OUTDIR+"vx_sp0006.ps "+OUTDIR+"psa1."+vnm+"reg.mon.ps")
        end if
     end if

     system("psplit "+OUTDIR+"psa2.vxreg.ps "+OUTDIR+"vx_sp")
     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"vx_sp0001.ps "+OUTDIR+"psa2."+vnm+"reg.djf.ps")
        system("mv "+OUTDIR+"vx_sp0002.ps "+OUTDIR+"psa2."+vnm+"reg.mam.ps") 
        system("mv "+OUTDIR+"vx_sp0003.ps "+OUTDIR+"psa2."+vnm+"reg.jja.ps")
        system("mv "+OUTDIR+"vx_sp0004.ps "+OUTDIR+"psa2."+vnm+"reg.son.ps") 
        system("mv "+OUTDIR+"vx_sp0005.ps "+OUTDIR+"psa2."+vnm+"reg.ann.ps")
        if (COMPUTE_MODES_MON.eq."True") then
           system("mv "+OUTDIR+"vx_sp0006.ps "+OUTDIR+"psa2."+vnm+"reg.mon.ps")
        end if
     end if
     system(OUTDIR+"psa2.vxreg.ps "+OUTDIR+"psa1.vxreg.ps "+OUTDIR+"sam.vxreg.ps")     
  end if

  delete([/vnm,lmsk,nsim_reg,names_reg,paths_reg,syear_reg,syear_reg,eyear_reg,nyr_reg,sfcfacs/])
 end do 
    
 print("Finished: psl.sam_psa_regpatt.ncl")

end  
