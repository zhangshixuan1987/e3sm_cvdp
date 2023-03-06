; Calculates MEI (MEI.v2) with 5 variables (sea level pressure (SLP), 
sea surface temperature (SST), surface zonal winds (U), 
surface meridional winds (V), and Outgoing Longwave Radiation (OLR))
to produce a time series of ENSO conditions (patterns and PC timeseries), 
as well as regressions of those PC timeseries onto ts, tas, psl, and pr.
;
; Variables used: psl, ts, tas, u10, v10, olr, and pr
; 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: enso.mei_5var.ncl")
  
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
  
;---------SST Regressions coding-------------------------------------------------
  nsim_ts = numAsciiRow("namelist_byvar/namelist_ts")
  na_ts = asciiread("namelist_byvar/namelist_ts",(/nsim_ts/),"string")
  names_ts = new(nsim_ts,"string")
  paths_ts = new(nsim_ts,"string")
  syear_ts = new(nsim_ts,"integer",-999)
  eyear_ts = new(nsim_ts,"integer",-999)

  do gg = 0,nsim_ts-1
     names_ts(gg) = str_strip(str_get_field(na_ts(gg),1,delim))
     paths_ts(gg) = str_strip(str_get_field(na_ts(gg),2,delim))
     syear_ts(gg) = stringtointeger(str_strip(str_get_field(na_ts(gg),3,delim)))
     eyear_ts(gg) = stringtointeger(str_strip(str_get_field(na_ts(gg),4,delim)))
  end do
  delete(na_ts)
  nyr_ts = eyear_ts-syear_ts+1  

;---------u10 Regressions coding-------------------------------------------------
  nsim_uas = numAsciiRow("namelist_byvar/namelist_u10")
  na_uas = asciiread("namelist_byvar/namelist_u10",(/nsim_uas/),"string")
  names_uas = new(nsim_uas,"string")
  paths_uas = new(nsim_uas,"string")
  syear_uas = new(nsim_uas,"integer",-999)
  eyear_uas = new(nsim_uas,"integer",-999)

  do gg = 0,nsim_uas-1
     names_uas(gg) = str_strip(str_get_field(na_uas(gg),1,delim))
     paths_uas(gg) = str_strip(str_get_field(na_uas(gg),2,delim))
     syear_uas(gg) = stringtointeger(str_strip(str_get_field(na_uas(gg),3,delim)))
     eyear_uas(gg) = stringtointeger(str_strip(str_get_field(na_uas(gg),4,delim)))
  end do
  delete(na_uas)
  nyr_uas = eyear_uas-syear_uas+1

;---------v10 Regressions coding-------------------------------------------------
  nsim_vas = numAsciiRow("namelist_byvar/namelist_v10")
  na_vas = asciiread("namelist_byvar/namelist_v10",(/nsim_vas/),"string")
  names_vas = new(nsim_vas,"string")
  paths_vas = new(nsim_vas,"string")
  syear_vas = new(nsim_vas,"integer",-999)
  eyear_vas = new(nsim_vas,"integer",-999)

  do gg = 0,nsim_vas-1
     names_vas(gg) = str_strip(str_get_field(na_vas(gg),1,delim))
     paths_vas(gg) = str_strip(str_get_field(na_vas(gg),2,delim))
     syear_vas(gg) = stringtointeger(str_strip(str_get_field(na_vas(gg),3,delim)))
     eyear_vas(gg) = stringtointeger(str_strip(str_get_field(na_vas(gg),4,delim)))
  end do
  delete(na_vas)
  nyr_vas = eyear_vas-syear_vas+1

;---------olr Regressions coding-------------------------------------------------
  nsim_olr = numAsciiRow("namelist_byvar/namelist_v10")
  na_olr = asciiread("namelist_byvar/namelist_v10",(/nsim_olr/),"string")
  names_olr = new(nsim_olr,"string")
  paths_olr = new(nsim_olr,"string")
  syear_olr = new(nsim_olr,"integer",-999)
  eyear_olr = new(nsim_olr,"integer",-999)

  do gg = 0,nsim_olr-1
     names_olr(gg) = str_strip(str_get_field(na_olr(gg),1,delim))
     paths_olr(gg) = str_strip(str_get_field(na_olr(gg),2,delim))
     syear_olr(gg) = stringtointeger(str_strip(str_get_field(na_olr(gg),3,delim)))
     eyear_olr(gg) = stringtointeger(str_strip(str_get_field(na_olr(gg),4,delim)))
  end do
  delete(na_olr)
  nyr_olr = eyear_olr-syear_olr+1

;-------------------------------------------------------------------------------------------------
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if
  
  wks_mei = gsn_open_wks(wks_type,getenv("OUTDIR")+"mei")
  wks_mei_pr = gsn_open_wks(wks_type,getenv("OUTDIR")+"mei.prreg")
  wks_mei_ts = gsn_open_wks(wks_type,getenv("OUTDIR")+"mei.timeseries")
  
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_mei,"ncl_default")   
     gsn_define_colormap(wks_mei_ts,"ncl_default")
     gsn_define_colormap(wks_mei_pr,"MPL_BrBG")  
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_mei,"BlueDarkRed18")   
     gsn_define_colormap(wks_mei_ts,"ncl_default")
     gsn_define_colormap(wks_mei_pr,"MPL_BrBG")  
  end if
  
  map_mei_djf = new(nsim,"graphic")  
  map_mei_mam = new(nsim,"graphic")  
  map_mei_jja = new(nsim,"graphic")  
  map_mei_son = new(nsim,"graphic")  
  map_mei_ann = new(nsim,"graphic")  
  map_mei_mon = new(nsim,"graphic")  
  xy_mei_djf = new(nsim,"graphic")
  xy_mei_mam = new(nsim,"graphic")
  xy_mei_jja = new(nsim,"graphic")
  xy_mei_son = new(nsim,"graphic")
  xy_mei_ann = new(nsim,"graphic")
  xy_mei_mon = new(nsim,"graphic")
  reg_mei_djf = new(nsim,"graphic")  
  reg_mei_mam = new(nsim,"graphic")  
  reg_mei_jja = new(nsim,"graphic")  
  reg_mei_son = new(nsim,"graphic")  
  reg_mei_ann = new(nsim,"graphic")  
  reg_mei_mon = new(nsim,"graphic")  
  reg_mei_pr_djf = new(nsim,"graphic")  
  reg_mei_pr_mam = new(nsim,"graphic")  
  reg_mei_pr_jja = new(nsim,"graphic")  
  reg_mei_pr_son = new(nsim,"graphic")  
  reg_mei_pr_ann = new(nsim,"graphic")  
  reg_mei_pr_mon = new(nsim,"graphic")  
  
  meireg_frame = 1    ; meireg_frame = flag to create regressions .ps/.png files. Created/used instead of meireg_plot_flag
                      ; so that if sst regressions are not created for the last simulation listed that .ps/png files are created
  tasreg_frame = 1
  prreg_frame  = 1

  do ee = 0,nsim-1

     d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
     basemap = d->LSMASK

     syall = (/syear(ee),syear_ts(ee),syear_uas(ee),syear_vas(ee),syear_olr(ee)/)
     eyall = (/eyear(ee),eyear_ts(ee),eyear_uas(ee),eyear_vas(ee),eyear_olr(ee)/)

     if (any(ismissing(syall)).or.any(ismissing(eyall)))then 
        meireg_plot_flag = 1
     else
        if (count_unique_values(syall).eq.1) then ; check that the start and end years match
           if (count_unique_values(eyall).eq.1) then 
              meireg_plot_flag = 0
           else
              meireg_plot_flag = 1
           end if
        else
           meireg_plot_flag = 1
        end if
     end if

     if (meireg_plot_flag.eq.0) then
       ;print(paths(ee)+" "+syear(ee)+" "+eyear(ee))
        arr = data_read_in(paths(ee),"PSL",syear(ee),eyear(ee))    ; read in data, orient lats/lons correctly, set time coordinate variable up
        if (isatt(arr,"is_all_missing")) then
           meireg_plot_flag = 1
           delete(arr)
           continue
        end if
        lsm = landsea_mask(basemap,arr&lat,arr&lon)
        arr = mask(arr,conform(arr,lsm,(/1,2/)).ge.1,False)
        delete(lsm)
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
     end if 

     if (meireg_plot_flag.eq.0) then
        sst = data_read_in(paths_ts(ee),"TS",syear_ts(ee),eyear_ts(ee))
        if (isatt(sst,"is_all_missing")) then
           meireg_plot_flag = 1
           delete(sst)
           continue
        end if
        sst = where(sst.le.-1.8,-1.8,sst)
        lsm = landsea_mask(basemap,sst&lat,sst&lon)
        sst = mask(sst,conform(sst,lsm,(/1,2/)).ge.1,False)
        delete(lsm)
        if (OPT_CLIMO.eq."Full") then
           sst = rmMonAnnCycTLL(sst)
        else
           check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
           temp_arr = sst
           delete(temp_arr&time)
           temp_arr&time = cd_calendar(sst&time,-1)
           if (CLIMO_SYEAR.lt.0) then
              climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))
           else
              climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))
           end if
           delete(temp_arr)
           sst   = calcMonAnomTLL(sst,climo)
           delete(climo)
        end if
     end if 

     if (meireg_plot_flag.eq.0) then
        uas = data_read_in(paths_uas(ee),"U10",syear_uas(ee),eyear_uas(ee))
        if (isatt(uas,"is_all_missing")) then
           meireg_plot_flag = 1
           delete(uas)
           continue
        end if
        lsm = landsea_mask(basemap,uas&lat,uas&lon)
        uas = mask(uas,conform(uas,lsm,(/1,2/)).ge.1,False)
        delete(lsm)
        if (OPT_CLIMO.eq."Full") then
           uas = rmMonAnnCycTLL(uas)
        else
           check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
           temp_arr = uas
           delete(temp_arr&time)
           temp_arr&time = cd_calendar(uas&time,-1)
           if (CLIMO_SYEAR.lt.0) then
              climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))
           else
              climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))
           end if
           delete(temp_arr)
           uas   = calcMonAnomTLL(uas,climo)
           delete(climo)
        end if
     end if

     if (meireg_plot_flag.eq.0) then
        vas = data_read_in(paths_vas(ee),"V10",syear_vas(ee),eyear_vas(ee))
        if (isatt(vas,"is_all_missing")) then
           meireg_plot_flag = 1
           delete(vas)
           continue
        end if
        lsm = landsea_mask(basemap,vas&lat,vas&lon)
        vas = mask(vas,conform(vas,lsm,(/1,2/)).ge.1,False)
        delete(lsm)
        if (OPT_CLIMO.eq."Full") then
           vas = rmMonAnnCycTLL(vas)
        else
           check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
           temp_arr = vas
           delete(temp_arr&time)
           temp_arr&time = cd_calendar(vas&time,-1)
           if (CLIMO_SYEAR.lt.0) then
              climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))
           else
              climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))
           end if
           delete(temp_arr)
           vas   = calcMonAnomTLL(vas,climo)
           delete(climo)
        end if
     end if

     if (meireg_plot_flag.eq.0) then
        olr = data_read_in(paths_olr(ee),"OLR",syear_olr(ee),eyear_olr(ee))
        if (isatt(olr,"is_all_missing")) then
           meireg_plot_flag = 1
           delete(olr)
           continue
        end if
        lsm = landsea_mask(basemap,olr&lat,olr&lon)
        olr = mask(olr,conform(olr,lsm,(/1,2/)).ge.1,False)
        delete(lsm)
        if (OPT_CLIMO.eq."Full") then
           olr = rmMonAnnCycTLL(olr)
        else
           check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
           temp_arr = olr
           delete(temp_arr&time)
           temp_arr&time = cd_calendar(olr&time,-1)
           if (CLIMO_SYEAR.lt.0) then
              climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))
           else
              climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))
           end if
           delete(temp_arr)
           olr   = calcMonAnomTLL(olr,climo)
           delete(climo)
        end if
     end if 

;     arr = (/ dtrend_msg_n(ispan(0,dimsizes(arr&time)-1,1),arr,False,False,0) /)
     arrT =  runave_n_Wrap(arr,2,0,0)               ; form overlapping 2moth averages 
     arr_2mo = arrT
     arr_dj  =  arrT(11::12,:,:) ;form DJ season 
     arr_2mo(0,:,:) = (/arr(0,:,:)/)
     arr_2mo(12::12,:,:) = arr_dj(1:) 
     do ff = 1,11  ; form JF/FM/MA/AM/MJ/JJ/JA/AS/SO/ON/ND averages
       arr_2mo(ff::12,:,:) = arrT(ff-1::12,:,:)
     end do 
     delete([/arrT,arr_dj/])
         
;---------SST Regressions coding-------------------------------------------------
;     sst = (/ dtrend_msg_n(ispan(0,dimsizes(sst&time)-1,1),sst,False,False,0) /)  
     sstT =  runave_n_Wrap(sst,2,0,0)               ; form DJF averages
     sst_2mo = sstT
     sst_dj  =  sstT(11::12,:,:) ;form DJ season
     sst_2mo(0,:,:) = (/sst(0,:,:)/)
     sst_2mo(12::12,:,:) = sst_dj(1:)
     do ff = 1,11  ; form JF/FM/MA/AM/MJ/JJ/JA/AS/SO/ON/ND averages
       sst_2mo(ff::12,:,:) = sstT(ff-1::12,:,:)
     end do
     delete([/sstT,sst_dj/])

;---------UAS Regressions coding-------------------------------------------------
;     uas = (/ dtrend_msg_n(ispan(0,dimsizes(uas&time)-1,1),uas,False,False,0) /)
     uasT =  runave_n_Wrap(uas,2,0,0)               ; form DJF averages
     uas_2mo = uasT
     uas_dj  =  uasT(11::12,:,:) ;form DJ season
     uas_2mo(0,:,:) = (/uas(0,:,:)/)
     uas_2mo(12::12,:,:) = uas_dj(1:)
     do ff = 1,11  ; form JF/FM/MA/AM/MJ/JJ/JA/AS/SO/ON/ND averages
       uas_2mo(ff::12,:,:) = uasT(ff-1::12,:,:)
     end do
     delete([/uasT,uas_dj/])

;---------VAS Regressions coding-------------------------------------------------
;     vas = (/ dtrend_msg_n(ispan(0,dimsizes(vas&time)-1,1),vas,False,False,0) /)
     vasT =  runave_n_Wrap(vas,2,0,0)               ; form DJF averages
     vas_2mo = vasT
     vas_dj  =  vasT(11::12,:,:) ;form DJ season
     vas_2mo(0,:,:) = (/vas(0,:,:)/)
     vas_2mo(12::12,:,:) = vas_dj(1:)
     do ff = 1,11  ; form JF/FM/MA/AM/MJ/JJ/JA/AS/SO/ON/ND averages
       vas_2mo(ff::12,:,:) = vasT(ff-1::12,:,:)
     end do
     delete([/vasT,vas_dj/])

;---------OLR Regressions coding-------------------------------------------------
;     olr = (/ dtrend_msg_n(ispan(0,dimsizes(olr&time)-1,1),olr,False,False,0) /)
     olrT =  runave_n_Wrap(olr,2,0,0)               ; form DJF averages
     olr_2mo = olrT
     olr_dj  =  olrT(11::12,:,:) ;form DJ season
     olr_2mo(0,:,:) = (/olr(0,:,:)/)
     olr_2mo(12::12,:,:) = olr_dj(1:)
     do ff = 1,11  ; form JF/FM/MA/AM/MJ/JJ/JA/AS/SO/ON/ND averages
       olr_2mo(ff::12,:,:) = olrT(ff-1::12,:,:)
     end do
     delete([/olrT,olr_dj/])

;------------------------------------------------------------------
    ;generate standarized anomaly
     arrN  =  dim_standardize_n(arr, 1, 0)
     sstN  =  dim_standardize_n(sst, 1, 0)
     uasN  =  dim_standardize_n(uas, 1, 0)
     vasN  =  dim_standardize_n(vas, 1, 0)
     olrN  =  dim_standardize_n(olr, 1, 0)

     ntim  = dimsizes(arr&time)

     arrT  =  runave_n_Wrap(arr,2,0,0)  ; form DJF averages
     arrT(1:ntim-1,:,:) =
     arrT(0,:,:) = (/ dim_avg_n(arr(:1,:,:),0) /)
     arr_djf = arrT(0::12,:,:)
     arr_mam = arrT(3::12,:,:)
     arr_jja = arrT(6::12,:,:)                       ; form JJA averages
     arr_son = arrT(9::12,:,:)
     delete(arrT)

    ;Combine the normalized data into one variable
     nefv  = 5
     ntim  = dimsizes(arr&time)
     arrT  = new((/nefv,2*dimsizes(arr&time),dimsizes(arr&lat),dimsizes(arr&lon)),typeof(arr)/)
     do kk = 0,dimsizes(arr&time)-1,1
       arrT(0,:,:) =
     end do

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
        if (isvar("sst")) then
           delete(sst)
        end if 
        if (isvar("tas")) then
           delete(tas)
        end if 
        if (isvar("pr")) then
           delete(pr)
        end if 
     end if    
;----------SAM/PSA1/PSA2 calculations----------------------------------------------------------------------     
     evecv = eofunc(arr_djf_CW({lat|:-20},lon|:,time|:),4,75)
     pcts = eofunc_ts(arr_djf_CW({lat|:-20},lon|:,time|:),evecv,False)  
     mei_pc_djf = dim_standardize(pcts(0,:),0)
     mei_djf = arr_djf(0,:,:)
     mei_djf = (/ regCoef(mei_pc_djf,arr_djf(lat|:,lon|:,time|:)) /)

     if (meireg_plot_flag.eq.0) then
        mei_sst_djf = sst_djf(0,:,:)
        mei_sst_djf = (/ regCoef(mei_pc_djf,sst_djf(lat|:,lon|:,time|:)) /)
        delete(sst_djf)
     end if     
     if (tasreg_plot_flag.eq.0) then
        mei_tas_djf = tas_djf(0,:,:)
        mei_tas_djf = (/ regCoef(mei_pc_djf,tas_djf(lat|:,lon|:,time|:)) /)
        delete(tas_djf)
     end if 
     if (prreg_plot_flag.eq.0) then
        mei_pr_djf = pr_djf(0,:,:)
        mei_pr_djf = (/ regCoef(mei_pc_djf,pr_djf(lat|:,lon|:,time|:)) /)
        delete(pr_djf)
     end if         
     
     if (.not.ismissing(mei_djf({-85},{5}))) then
        if (mei_djf({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           mei_djf = mei_djf*-1.
           mei_pc_djf = mei_pc_djf*-1.
           if (meireg_plot_flag.eq.0) then
              mei_sst_djf = mei_sst_djf*-1.
           end if
           if (tasreg_plot_flag.eq.0) then
              mei_tas_djf = mei_tas_djf*-1.
           end if
           if (prreg_plot_flag.eq.0) then
              mei_pr_djf = mei_pr_djf*-1.
           end if
        end if
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(mei_pc_djf),False)
     if (sig_pcv(0)) then    ; if True then significant
        mei_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        mei_djf@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     delete(sig_pcv)    
     mei_pc_djf!0 = "TIME"
     mei_pc_djf&TIME = ispan(syear(ee),eyear(ee),1)
     mei_pc_djf&TIME@units = "YYYY"
     mei_pc_djf&TIME@long_name = "time"     
     delete([/evecv,pcts/])
     
     evecv = eofunc(arr_mam_CW({lat|:-20},lon|:,time|:),4,75)
     pcts = eofunc_ts(arr_mam_CW({lat|:-20},lon|:,time|:),evecv,False)  
     mei_pc_mam = dim_standardize(pcts(0,:),0)
     mei_mam = arr_mam(0,:,:)
     mei_mam = (/ regCoef(mei_pc_mam,arr_mam(lat|:,lon|:,time|:)) /)
     if (meireg_plot_flag.eq.0) then
        mei_sst_mam = sst_mam(0,:,:)
        mei_sst_mam = (/ regCoef(mei_pc_mam,sst_mam(lat|:,lon|:,time|:)) /)
        delete(sst_mam)
     end if  
     if (tasreg_plot_flag.eq.0) then
        mei_tas_mam = tas_mam(0,:,:)
        mei_tas_mam = (/ regCoef(mei_pc_mam,tas_mam(lat|:,lon|:,time|:)) /)
        delete(tas_mam)
     end if 
     if (prreg_plot_flag.eq.0) then
        mei_pr_mam = pr_mam(0,:,:)
        mei_pr_mam = (/ regCoef(mei_pc_mam,pr_mam(lat|:,lon|:,time|:)) /)
        delete(pr_mam)
     end if         
     
     if (.not.ismissing(mei_mam({-85},{5}))) then
        if (mei_mam({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           mei_mam = mei_mam*-1.
           mei_pc_mam = mei_pc_mam*-1.
           if (meireg_plot_flag.eq.0) then
              mei_sst_mam = mei_sst_mam*-1.
           end if
           if (tasreg_plot_flag.eq.0) then
              mei_tas_mam = mei_tas_mam*-1.
           end if
           if (prreg_plot_flag.eq.0) then
              mei_pr_mam = mei_pr_mam*-1.
           end if
        end if
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(mei_pc_mam),False)
     if (sig_pcv(0)) then    ; if True then significant
        mei_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        mei_mam@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(mei_pc_djf,mei_pc_mam) 
     delete([/evecv,pcts/])
     
     evecv = eofunc(arr_jja_CW({lat|:-20},lon|:,time|:),4,75)
     pcts = eofunc_ts(arr_jja_CW({lat|:-20},lon|:,time|:),evecv,False)  
     mei_pc_jja = dim_standardize(pcts(0,:),0)
     mei_jja = arr_jja(0,:,:)
     mei_jja = (/ regCoef(mei_pc_jja,arr_jja(lat|:,lon|:,time|:)) /)
     if (meireg_plot_flag.eq.0) then
        mei_sst_jja = sst_jja(0,:,:)
        mei_sst_jja = (/ regCoef(mei_pc_jja,sst_jja(lat|:,lon|:,time|:)) /)
        delete(sst_jja)
     end if  
     if (tasreg_plot_flag.eq.0) then
        mei_tas_jja = tas_jja(0,:,:)
        mei_tas_jja = (/ regCoef(mei_pc_jja,tas_jja(lat|:,lon|:,time|:)) /)
        delete(tas_jja)
     end if 
     if (prreg_plot_flag.eq.0) then
        mei_pr_jja = pr_jja(0,:,:)
        mei_pr_jja = (/ regCoef(mei_pc_jja,pr_jja(lat|:,lon|:,time|:)) /)
        delete(pr_jja)
     end if         
     
     if (.not.ismissing(mei_jja({-85},{5}))) then
        if (mei_jja({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           mei_jja = mei_jja*-1.
           mei_pc_jja = mei_pc_jja*-1.
           if (meireg_plot_flag.eq.0) then
              mei_sst_jja = mei_sst_jja*-1.
           end if
           if (tasreg_plot_flag.eq.0) then
              mei_tas_jja = mei_tas_jja*-1.
           end if
           if (prreg_plot_flag.eq.0) then
              mei_pr_jja = mei_pr_jja*-1.
           end if
        end if
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(mei_pc_jja),False)
     if (sig_pcv(0)) then    ; if True then significant
        mei_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        mei_jja@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(mei_pc_djf,mei_pc_jja) 
     delete([/evecv,pcts/])
 
     evecv = eofunc(arr_son_CW({lat|:-20},lon|:,time|:),4,75)
     pcts = eofunc_ts(arr_son_CW({lat|:-20},lon|:,time|:),evecv,False)  
     mei_pc_son = dim_standardize(pcts(0,:),0)
     mei_son = arr_son(0,:,:)
     mei_son = (/ regCoef(mei_pc_son,arr_son(lat|:,lon|:,time|:)) /)
     if (meireg_plot_flag.eq.0) then
        mei_sst_son = sst_son(0,:,:)
        mei_sst_son = (/ regCoef(mei_pc_son,sst_son(lat|:,lon|:,time|:)) /)
        delete(sst_son)
     end if  
     if (tasreg_plot_flag.eq.0) then
        mei_tas_son = tas_son(0,:,:)
        mei_tas_son = (/ regCoef(mei_pc_son,tas_son(lat|:,lon|:,time|:)) /)
        delete(tas_son)
     end if 
     if (prreg_plot_flag.eq.0) then
        mei_pr_son = pr_son(0,:,:)
        mei_pr_son = (/ regCoef(mei_pc_son,pr_son(lat|:,lon|:,time|:)) /)
        delete(pr_son)
     end if         
     
     if (.not.ismissing(mei_son({-85},{5}))) then
        if (mei_son({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           mei_son = mei_son*-1.
           mei_pc_son = mei_pc_son*-1.
           if (meireg_plot_flag.eq.0) then
              mei_sst_son = mei_sst_son*-1.
           end if
           if (tasreg_plot_flag.eq.0) then
              mei_tas_son = mei_tas_son*-1.
           end if
           if (prreg_plot_flag.eq.0) then
              mei_pr_son = mei_pr_son*-1.
           end if
        end if
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(mei_pc_son),False)
     if (sig_pcv(0)) then    ; if True then significant
        mei_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        mei_son@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(mei_pc_djf,mei_pc_son) 
     delete([/evecv,pcts/])

     evecv = eofunc(arr_ann_CW({lat|:-20},lon|:,time|:),4,75)
     pcts = eofunc_ts(arr_ann_CW({lat|:-20},lon|:,time|:),evecv,False)  
     mei_pc_ann = dim_standardize(pcts(0,:),0)
     mei_ann = arr_ann(0,:,:)
     mei_ann = (/ regCoef(mei_pc_ann,arr_ann(lat|:,lon|:,time|:)) /)
     if (meireg_plot_flag.eq.0) then
        mei_sst_ann = sst_ann(0,:,:)
        mei_sst_ann = (/ regCoef(mei_pc_ann,sst_ann(lat|:,lon|:,time|:)) /)
        delete(sst_ann)
     end if  
     if (tasreg_plot_flag.eq.0) then
        mei_tas_ann = tas_ann(0,:,:)
        mei_tas_ann = (/ regCoef(mei_pc_ann,tas_ann(lat|:,lon|:,time|:)) /)
        delete(tas_ann)
     end if 
     if (prreg_plot_flag.eq.0) then
        mei_pr_ann = pr_ann(0,:,:)
        mei_pr_ann = (/ regCoef(mei_pc_ann,pr_ann(lat|:,lon|:,time|:)) /)
        delete(pr_ann)
     end if         
     
     if (.not.ismissing(mei_ann({-85},{5}))) then
        if (mei_ann({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           mei_ann = mei_ann*-1.
           mei_pc_ann = mei_pc_ann*-1.
           if (meireg_plot_flag.eq.0) then
              mei_sst_ann = mei_sst_ann*-1.
           end if
           if (tasreg_plot_flag.eq.0) then
              mei_tas_ann = mei_tas_ann*-1.
           end if
           if (prreg_plot_flag.eq.0) then
              mei_pr_ann = mei_pr_ann*-1.
           end if
        end if
     end if
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(mei_pc_ann),False)
     if (sig_pcv(0)) then    ; if True then significant
        mei_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        mei_ann@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     delete(sig_pcv)
     copy_VarCoords(mei_pc_djf,mei_pc_ann) 
     delete([/evecv,pcts/])
     
     if (COMPUTE_MODES_MON.eq."True") then     
        evecv = eofunc(arr_mon_CW({lat|:-20},lon|:,time|:),4,75)
        pcts = eofunc_ts(arr_mon_CW({lat|:-20},lon|:,time|:),evecv,False)  
        mei_pc_mon = dim_standardize(pcts(0,:),0)
        mei_mon = arr(0,:,:)
        mei_mon = (/ regCoef(mei_pc_mon,arr(lat|:,lon|:,time|:)) /)
        if (meireg_plot_flag.eq.0) then
           mei_sst_mon = sst(0,:,:)
           mei_sst_mon = (/ regCoef(mei_pc_mon,sst(lat|:,lon|:,time|:)) /)
           delete(sst)
        end if  
        if (tasreg_plot_flag.eq.0) then
           mei_tas_mon = tas(0,:,:)
           mei_tas_mon = (/ regCoef(mei_pc_mon,tas(lat|:,lon|:,time|:)) /)
           delete(tas)
        end if  
        if (prreg_plot_flag.eq.0) then
           mei_pr_mon = pr(0,:,:)
           mei_pr_mon = (/ regCoef(mei_pc_mon,pr(lat|:,lon|:,time|:)) /)
           delete(pr)
        end if  

        if (.not.ismissing(mei_mon({-85},{5}))) then
           if (mei_mon({-85},{5}).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
              mei_mon = mei_mon*-1.
              mei_pc_mon = mei_pc_mon*-1.
              if (meireg_plot_flag.eq.0) then
                 mei_sst_mon = mei_sst_mon*-1.
              end if
              if (tasreg_plot_flag.eq.0) then
                 mei_tas_mon = mei_tas_mon*-1.
              end if
              if (prreg_plot_flag.eq.0) then
                 mei_pr_mon = mei_pr_mon*-1.
              end if
           end if
        end if
        sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(mei_pc_mon),False)
        if (sig_pcv(0)) then    ; if True then significant
           mei_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
        else
           mei_mon@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
        end if
        delete(sig_pcv)
        mei_pc_mon!0 = "time"
        mei_pc_mon&time = arr&time   
        delete([/evecv,pcts,arr_mon_CW,arr/])
     end if
     delete([/arr_djf_CW,arr_mam_CW,arr_jja_CW,arr_son_CW,arr_ann_CW/])
     delete([/arr_djf,arr_mam,arr_jja,arr_son,arr_ann/])
;------------------------------------------------------------------------------------------------------
     if (meireg_frame.eq.1.and.meireg_plot_flag.eq.0) then    ; meireg_frame = flag to create regressions .ps/.png files 
        meireg_frame = 0
     end if
     if (tasreg_frame.eq.1.and.tasreg_plot_flag.eq.0) then    ; tasreg_frame = flag to create regressions .ps/.png files 
        tasreg_frame = 0
     end if  
     if (prreg_frame.eq.1.and.prreg_plot_flag.eq.0) then      ; prreg_frame = flag to create regressions .ps/.png files 
        prreg_frame = 0
     end if            
;------------------------------------------------------------------------------------------------------
     if (OUTPUT_DATA.eq."True") then
        modname = str_sub_str(names(ee)," ","_")
        bc = (/"/","'","(",")"/)
        do gg = 0,dimsizes(bc)-1
           modname = str_sub_str(modname,bc(gg),"_")
        end do
        fn = getenv("OUTDIR")+modname+".cvdp_data.enso.mei_5var."+syear(ee)+"-"+eyear(ee)+".nc"
        if (.not.isfilepresent2(fn)) then
           z = addfile(fn,"c")
           z@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
           z@notes = "Data from "+names(ee)+" from "+syear(ee)+"-"+eyear(ee)
           if (OPT_CLIMO.eq."Full") then
              z@climatology = syear(ee)+"-"+eyear(ee)+" climatology removed prior to all calculations (other than means)"
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
        z->mei_timeseries_djf = set_varAtts(mei_pc_djf,"SAM normalized principal component timeseries (DJF)","1","")
        z->mei_timeseries_mam = set_varAtts(mei_pc_mam,"SAM normalized principal component timeseries (MAM)","1","")
        z->mei_timeseries_jja = set_varAtts(mei_pc_jja,"SAM normalized principal component timeseries (JJA)","1","")
        z->mei_timeseries_son = set_varAtts(mei_pc_son,"SAM normalized principal component timeseries (SON)","1","")
        z->mei_timeseries_ann = set_varAtts(mei_pc_ann,"SAM normalized principal component timeseries (annual)","1","")
        
        z->mei_pattern_djf = set_varAtts(mei_djf,"SAM spatial pattern (DJF)","","")
        z->mei_pattern_mam = set_varAtts(mei_mam,"SAM spatial pattern (MAM)","","")
        z->mei_pattern_jja = set_varAtts(mei_jja,"SAM spatial pattern (JJA)","","")
        z->mei_pattern_son = set_varAtts(mei_son,"SAM spatial pattern (SON)","","")
        z->mei_pattern_ann = set_varAtts(mei_ann,"SAM spatial pattern (annual)","","")
        
        if (COMPUTE_MODES_MON.eq."True") then   
           z->mei_timeseries_mon = set_varAtts(mei_pc_mon,"SAM principal component timeseries (monthly)","","")
           z->mei_pattern_mon = set_varAtts(mei_mon,"SAM spatial pattern (monthly)","","")
        end if
        delete(z)
        delete([/modname,fn/])

        if (meireg_plot_flag.eq.0) then
           modname = str_sub_str(names_ts(ee)," ","_")
           bc = (/"/","'","(",")"/)
           do gg = 0,dimsizes(bc)-1
              modname = str_sub_str(modname,bc(gg),"_")
           end do
           fn = getenv("OUTDIR")+modname+".cvdp_data.enso.mei_5var.ts."+syear_ts(ee)+"-"+eyear_ts(ee)+".nc"
           if (.not.isfilepresent2(fn)) then
              z = addfile(fn,"c")
              z@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
              z@notes = "Data from "+names_ts(ee)+" from "+syear_ts(ee)+"-"+eyear_ts(ee)
              if (OPT_CLIMO.eq."Full") then
                 z@climatology = syear_ts(ee)+"-"+eyear_ts(ee)+" climatology removed prior to all calculations (other than means)"
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
           z->mei_sst_regression_djf = set_varAtts(mei_sst_djf,"sst regression onto SAM principal component timeseries (DJF)","","")    
           z->mei_sst_regression_mam = set_varAtts(mei_sst_mam,"sst regression onto SAM principal component timeseries (MAM)","","")    
           z->mei_sst_regression_jja = set_varAtts(mei_sst_jja,"sst regression onto SAM principal component timeseries (JJA)","","")    
           z->mei_sst_regression_son = set_varAtts(mei_sst_son,"sst regression onto SAM principal component timeseries (SON)","","")    
           z->mei_sst_regression_ann = set_varAtts(mei_sst_ann,"sst regression onto SAM principal component timeseries (annual)","","")    
        
           if (COMPUTE_MODES_MON.eq."True") then   
              z->mei_sst_regression_mon = set_varAtts(mei_sst_mon,"sst regression onto SAM principal component timeseries (monthly)","","")    
           end if
           delete(z)
           delete([/modname,fn/])
        end if
        if (tasreg_plot_flag.eq.0) then
           modname = str_sub_str(names_tas(ee)," ","_")
           bc = (/"/","'","(",")"/)
           do gg = 0,dimsizes(bc)-1
              modname = str_sub_str(modname,bc(gg),"_")
           end do
           fn = getenv("OUTDIR")+modname+".cvdp_data.enso.mei_5var.tas."+syear_tas(ee)+"-"+eyear_tas(ee)+".nc"
           if (.not.isfilepresent2(fn)) then
              z = addfile(fn,"c")
              z@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
              z@notes = "Data from "+names_tas(ee)+" from "+syear_tas(ee)+"-"+eyear_tas(ee)
              if (OPT_CLIMO.eq."Full") then
                 z@climatology = syear_tas(ee)+"-"+eyear_tas(ee)+" climatology removed prior to all calculations (other than means)"
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
           z->mei_tas_regression_djf = set_varAtts(mei_tas_djf,"tas regression onto SAM principal component timeseries (DJF)","","")    
           z->mei_tas_regression_mam = set_varAtts(mei_tas_mam,"tas regression onto SAM principal component timeseries (MAM)","","")    
           z->mei_tas_regression_jja = set_varAtts(mei_tas_jja,"tas regression onto SAM principal component timeseries (JJA)","","")    
           z->mei_tas_regression_son = set_varAtts(mei_tas_son,"tas regression onto SAM principal component timeseries (SON)","","")    
           z->mei_tas_regression_ann = set_varAtts(mei_tas_ann,"tas regression onto SAM principal component timeseries (annual)","","")    
        
           if (COMPUTE_MODES_MON.eq."True") then   
              z->mei_tas_regression_mon = set_varAtts(mei_tas_mon,"tas regression onto SAM principal component timeseries (monthly)","","")    
           end if
           delete(z)
           delete([/modname,fn/])
        end if
        if (prreg_plot_flag.eq.0) then
           modname = str_sub_str(names_pr(ee)," ","_")
           bc = (/"/","'","(",")"/)
           do gg = 0,dimsizes(bc)-1
              modname = str_sub_str(modname,bc(gg),"_")
           end do
           fn = getenv("OUTDIR")+modname+".cvdp_data.enso.mei_5var.pr."+syear_pr(ee)+"-"+eyear_pr(ee)+".nc"
           if (.not.isfilepresent2(fn)) then
              z = addfile(fn,"c")
              z@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
              z@notes = "Data from "+names_pr(ee)+" from "+syear_pr(ee)+"-"+eyear_pr(ee)
              if (OPT_CLIMO.eq."Full") then
                 z@climatology = syear_pr(ee)+"-"+eyear_pr(ee)+" climatology removed prior to all calculations (other than means)"
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
           z->mei_pr_regression_djf = set_varAtts(mei_pr_djf,"pr regression onto SAM principal component timeseries (DJF)","","")    
           z->mei_pr_regression_mam = set_varAtts(mei_pr_mam,"pr regression onto SAM principal component timeseries (MAM)","","")    
           z->mei_pr_regression_jja = set_varAtts(mei_pr_jja,"pr regression onto SAM principal component timeseries (JJA)","","")    
           z->mei_pr_regression_son = set_varAtts(mei_pr_son,"pr regression onto SAM principal component timeseries (SON)","","")    
           z->mei_pr_regression_ann = set_varAtts(mei_pr_ann,"pr regression onto SAM principal component timeseries (annual)","","")    
        
           if (COMPUTE_MODES_MON.eq."True") then   
              z->mei_pr_regression_mon = set_varAtts(mei_pr_mon,"pr regression onto SAM principal component timeseries (monthly)","","")    
           end if
           delete(z)
           delete([/modname,fn/])
        end if
     end if     
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
     res@gsnPolar = "SH"     
     res@mpMaxLatF    = -20.
     res@mpCenterLonF = 0.
     
     res@cnLevels = (/-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7./)
     res@gsnLeftString = syear(ee)+"-"+eyear(ee)
     res@gsnCenterString = names(ee)
 
     res4 = res    ; res4 = pr regression resources     
     if (COLORMAP.eq.0) then
        res4@cnLevels := fspan(-.7,.7,15)  
     else
        res4@cnLevels := fspan(-.5,.5,11)     
     end if

     res2 = True
     res2@gsnDraw      = False
     res2@gsnFrame     = False
     res2@cnLevelSelectionMode = "ExplicitLevels"
     res2@cnLevels = res@cnLevels

     res2@cnLineLabelsOn = False
     res2@cnFillOn        = True
     res2@cnLinesOn       = False
     res2@cnFillMode = "AreaFill"
     res2@lbLabelBarOn    = False
     res2@cnInfoLabelOn = False
     res2@gsnRightString = ""
     res2@gsnLeftString = "" 
     res2@gsnCenterString = ""   
     res2@gsnAddCyclic = True
    
     if (isfilepresent2("obs_psl").and.ee.eq.0) then    ; for pattern correlation table. Save entire lat/lon array
        patcor_mei_djf = new((/nsim,dimsizes(mei_djf&lat),dimsizes(mei_djf&lon)/),typeof(mei_djf))
        patcor_mei_djf!1 = "lat"
        patcor_mei_djf&lat = mei_djf&lat
        patcor_mei_djf!2 = "lon"
        patcor_mei_djf&lon = mei_djf&lon
        patcor_mei_jja = patcor_mei_djf
        patcor_mei_ann = patcor_mei_djf
        patcor_mei_djf(ee,:,:) = (/ mei_djf /)
        patcor_mei_jja(ee,:,:) = (/ mei_jja /)
        patcor_mei_ann(ee,:,:) = (/ mei_ann /)
     end if
     if (isfilepresent2("obs_psl").and.ee.ge.1.and.isvar("patcor_mei_djf")) then       
        patcor_mei_djf(ee,:,:) = (/ totype(linint2(mei_djf&lon,mei_djf&lat,mei_djf,True,patcor_mei_djf&lon,patcor_mei_djf&lat,0),typeof(patcor_mei_djf)) /)
        patcor_mei_jja(ee,:,:) = (/ totype(linint2(mei_jja&lon,mei_jja&lat,mei_jja,True,patcor_mei_jja&lon,patcor_mei_jja&lat,0),typeof(patcor_mei_jja)) /)
        patcor_mei_ann(ee,:,:) = (/ totype(linint2(mei_ann&lon,mei_ann&lat,mei_ann,True,patcor_mei_ann&lon,patcor_mei_ann&lat,0),typeof(patcor_mei_ann)) /)
        
     end if
      
     res@gsnLeftString = syear(ee)+"-"+eyear(ee)
     res@gsnCenterString = names(ee)
     res@gsnRightString = mei_djf@pcvar
     map_mei_djf(ee) = gsn_csm_contour_map_polar(wks_mei,mei_djf,res)
     res@gsnRightString = mei_mam@pcvar
     map_mei_mam(ee) = gsn_csm_contour_map_polar(wks_mei,mei_mam,res)
     res@gsnRightString = mei_jja@pcvar
     map_mei_jja(ee) = gsn_csm_contour_map_polar(wks_mei,mei_jja,res)
     res@gsnRightString = mei_son@pcvar
     map_mei_son(ee) = gsn_csm_contour_map_polar(wks_mei,mei_son,res)
     res@gsnRightString = mei_ann@pcvar
     map_mei_ann(ee) = gsn_csm_contour_map_polar(wks_mei,mei_ann,res)     
     delete([/mei_djf,mei_mam,mei_jja,mei_son,mei_ann/])
     if (COMPUTE_MODES_MON.eq."True") then                    
        res@gsnRightString = mei_mon@pcvar
        map_mei_mon(ee) = gsn_csm_contour_map_polar(wks_mei,mei_mon,res)
        delete([/mei_mon/])
     end if
     
     if (meireg_plot_flag.eq.0) then
        res@cnLevels := fspan(-.7,.7,15)
        if (tasreg_plot_flag.eq.0) then
           if (names_ts(ee).eq.names_tas(ee)) then
              res@gsnCenterString = names_ts(ee)
           else
              res@gsnCenterString = names_ts(ee)+" / "+names_tas(ee)
           end if    
        else
           res@gsnCenterString = names_ts(ee)
        end if
        res@gsnRightString = ""
        reg_mei_djf(ee) = gsn_csm_contour_map_polar(wks_mei,mei_sst_djf,res)
        reg_mei_mam(ee) = gsn_csm_contour_map_polar(wks_mei,mei_sst_mam,res)
        reg_mei_jja(ee) = gsn_csm_contour_map_polar(wks_mei,mei_sst_jja,res)
        reg_mei_son(ee) = gsn_csm_contour_map_polar(wks_mei,mei_sst_son,res)
        reg_mei_ann(ee) = gsn_csm_contour_map_polar(wks_mei,mei_sst_ann,res)     
        delete([/mei_sst_djf,mei_sst_mam,mei_sst_jja,mei_sst_son,mei_sst_ann/])
        if (tasreg_plot_flag.eq.0) then
           o_djf = gsn_csm_contour(wks_mei,mei_tas_djf,res2)
           o_mam = gsn_csm_contour(wks_mei,mei_tas_mam,res2)
           o_jja = gsn_csm_contour(wks_mei,mei_tas_jja,res2)
           o_son = gsn_csm_contour(wks_mei,mei_tas_son,res2)
           o_ann = gsn_csm_contour(wks_mei,mei_tas_ann,res2)
           delete([/mei_tas_djf,mei_tas_mam,mei_tas_jja,mei_tas_son,mei_tas_ann/])
           overlay(reg_mei_djf(ee),o_djf)
           overlay(reg_mei_mam(ee),o_mam)
           overlay(reg_mei_jja(ee),o_jja)
           overlay(reg_mei_son(ee),o_son)
           overlay(reg_mei_ann(ee),o_ann)
           delete([/o_djf,o_mam,o_jja,o_son,o_ann/])           
        end if
        if (COMPUTE_MODES_MON.eq."True") then                    
           reg_mei_mon(ee) = gsn_csm_contour_map_polar(wks_mei,mei_sst_mon,res)
           delete([/mei_sst_mon/])
           if (tasreg_plot_flag.eq.0) then
              o_mon = gsn_csm_contour(wks_mei,mei_tas_mon,res2)
              overlay(reg_mei_mon(ee),o_mon)
              delete([/o_mon,mei_tas_mon/])
           end if
        end if
     
     end if

     if (prreg_plot_flag.eq.0) then     ; PR regressions
        res4@gsnRightString = ""
        res4@gsnCenterString = names_pr(ee)
        reg_mei_pr_djf(ee) = gsn_csm_contour_map_polar(wks_mei_pr,mei_pr_djf,res4)
        reg_mei_pr_mam(ee) = gsn_csm_contour_map_polar(wks_mei_pr,mei_pr_mam,res4)
        reg_mei_pr_jja(ee) = gsn_csm_contour_map_polar(wks_mei_pr,mei_pr_jja,res4)
        reg_mei_pr_son(ee) = gsn_csm_contour_map_polar(wks_mei_pr,mei_pr_son,res4)
        reg_mei_pr_ann(ee) = gsn_csm_contour_map_polar(wks_mei_pr,mei_pr_ann,res4)     
        delete([/mei_pr_djf,mei_pr_mam,mei_pr_jja,mei_pr_son,mei_pr_ann/])
        if (COMPUTE_MODES_MON.eq."True") then                    
           reg_mei_pr_mon(ee) = gsn_csm_contour_map_polar(wks_mei_pr,mei_pr_mon,res4)
           delete([/mei_pr_mon/])
        end if
     
     end if

     xyres = True
     xyres@gsnDraw = False
     xyres@gsnFrame = False
     xyres@gsnXYBarChart = False
     xyres@gsnYRefLine = 0.0
     xyres@gsnYRefLineColor = "gray42"
     xyres@gsnAboveYRefLineColor = 185
     xyres@gsnBelowYRefLineColor = 35
     if (wks_type.eq."png") then  
        xyres@xyLineThicknessF = .5
     else
        xyres@xyLineThicknessF = .2
     end if
     xyres@xyLineColor = "gray52"
     xyres@tiYAxisString = ""
     xyres@tiXAxisString = ""
     if (nsim.le.5) then
        xyres@tmXBLabelFontHeightF = 0.0125
        xyres@tmYLLabelFontHeightF = 0.0125
        xyres@gsnStringFontHeightF = 0.017     
     else
        xyres@tmXBLabelFontHeightF = 0.018
        xyres@tmYLLabelFontHeightF = 0.018
        xyres@gsnStringFontHeightF = 0.024
     end if
     xyres@gsnCenterStringOrthogonalPosF = 0.025
     xyres@vpXF = 0.05
     xyres@vpHeightF = 0.15
     if (SCALE_TIMESERIES.eq."True") then
        xyres@vpWidthF = 0.9*((nyr(ee)*1.)/nyr_max)
     else
        xyres@vpWidthF = 0.9
     end if
     xyres@gsnLeftString = ""
     xyres@gsnRightString = ""
     xyres@trXMinF = syear(ee)-.5
     xyres@trXMaxF = eyear(ee)+1.5

     xyres@gsnCenterString = names(ee)
     
     xyresmon = xyres
     xyresmon@gsnXYBarChart = False            
     xyresmon@xyLineThicknessF = .1 

     xy_mei_djf(ee) = gsn_csm_xy(wks_mei_ts,fspan(syear(ee),eyear(ee),dimsizes(mei_pc_djf)),mei_pc_djf,xyres)   ; use standardized timeseries  
     xy_mei_mam(ee) = gsn_csm_xy(wks_mei_ts,fspan(syear(ee),eyear(ee),dimsizes(mei_pc_mam)),mei_pc_mam,xyres)   ; use standardized timeseries  
     xy_mei_jja(ee) = gsn_csm_xy(wks_mei_ts,fspan(syear(ee),eyear(ee),dimsizes(mei_pc_jja)),mei_pc_jja,xyres)   ; use standardized timeseries  
     xy_mei_son(ee) = gsn_csm_xy(wks_mei_ts,fspan(syear(ee),eyear(ee),dimsizes(mei_pc_son)),mei_pc_son,xyres)   ; use standardized timeseries  
     xy_mei_ann(ee) = gsn_csm_xy(wks_mei_ts,fspan(syear(ee),eyear(ee),dimsizes(mei_pc_ann)),mei_pc_ann,xyres)   ; use standardized timeseries  
     delete([/mei_pc_djf,mei_pc_mam,mei_pc_jja,mei_pc_son,mei_pc_ann/])
     if (COMPUTE_MODES_MON.eq."True") then   
        xy_mei_mon(ee) = gsn_csm_xy(wks_mei_ts,fspan(syear(ee),eyear(ee)+.91667,dimsizes(mei_pc_mon)),mei_pc_mon,xyresmon)   ; use standardized timeseries  
        delete([/mei_pc_mon/])
     end if

     delete(meireg_plot_flag)  
  end do
  
  if (isvar("clim_syear")) then
     delete(clim_syear)
  end if
  if (isvar("clim_eyear")) then
     delete(clim_eyear)
  end if
  
  if (isvar("patcor_mei_djf")) then    ; for pattern correlation table  
     clat = cos(0.01745329*patcor_mei_djf&lat)
     clat!0 = "lat"
     clat&lat = patcor_mei_djf&lat
     line3   = "                  "    ; Must be 18 characters long
     line4   = line3
     header = (/"","Pattern Correlations   Observations vs. Model(s)",""/)
     finpr_mei_djf  = "SAM (DJF)         "     
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
        if (all(ismissing(patcor_mei_djf(hh,{:-20},:)))) then
           finpr_mei_djf = finpr_mei_djf+sprintf(format2,9.99)+"/"+sprintf(format3,9.99)
        else
           finpr_mei_djf = finpr_mei_djf+sprintf(format2,(pattern_cor(patcor_mei_djf(0,{:-20},:),patcor_mei_djf(hh,{:-20},:),clat({:-20}),0)))+"/"+sprintf(format3,(wgt_arearmse(patcor_mei_djf(0,{:-20},:),patcor_mei_djf(hh,{:-20},:),clat({:-20}),1.0,0)))
        end if        
     end do
;     
     if (dimsizes(tochar(line4)).ge.8190) then   ; system or fortran compiler limit
        print("Metrics table warning: Not creating metrics table as size of comparison results in a invalid ascii row size.")   
     else           
        write_table(getenv("OUTDIR")+"metrics.enso.mei_5var.txt","w",[/header/],"%s")
        write_table(getenv("OUTDIR")+"metrics.enso.mei_5var.txt","a",[/line3/],"%s")
        write_table(getenv("OUTDIR")+"metrics.enso.mei_5var.txt","a",[/line4/],"%s")  
        write_table(getenv("OUTDIR")+"metrics.enso.mei_5var.txt","a",[/finpr_mei_djf/],"%s")
     end if
     delete([/line3,line4,format2,format3,nchar,ntc,clat,patcor_mei_djf,patcor_mei_jja,patcor_mei_ann,dimY,ntb,header/]) 
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
  
  panres@txString = "SAM (DJF)" 
  gsn_panel2(wks_mei,map_mei_djf,(/nrow,ncol/),panres)
  delete(map_mei_djf)
  panres@txString = "SAM (MAM)"
  gsn_panel2(wks_mei,map_mei_mam,(/nrow,ncol/),panres)
  delete(map_mei_mam)
  panres@txString = "SAM (JJA)"
  gsn_panel2(wks_mei,map_mei_jja,(/nrow,ncol/),panres)
  delete(map_mei_jja)
  panres@txString = "SAM (SON)"
  gsn_panel2(wks_mei,map_mei_son,(/nrow,ncol/),panres)
  delete(map_mei_son)
  panres@txString = "SAM (Annual)"
  gsn_panel2(wks_mei,map_mei_ann,(/nrow,ncol/),panres)
  delete(map_mei_ann)
  if (COMPUTE_MODES_MON.eq."True") then    
     panres@txString = "SAM (Monthly)"
     gsn_panel2(wks_mei,map_mei_mon,(/nrow,ncol/),panres)
     delete(map_mei_mon)
  end if
  
  if (meireg_frame.eq.0) then
     if (tasreg_frame.eq.0) then
        txt0 = "SST/TAS"
     else
        txt0 = "SST"
     end if
     panres@txString = "SAM "+txt0+" Regressions (DJF)" 
     gsn_panel2(wks_mei,reg_mei_djf,(/nrow,ncol/),panres)
     delete(reg_mei_djf)
     panres@txString = "SAM "+txt0+" Regressions (MAM)"
     gsn_panel2(wks_mei,reg_mei_mam,(/nrow,ncol/),panres)
     delete(reg_mei_mam)
     panres@txString = "SAM "+txt0+" Regressions (JJA)"
     gsn_panel2(wks_mei,reg_mei_jja,(/nrow,ncol/),panres)
     delete(reg_mei_jja)
     panres@txString = "SAM "+txt0+" Regressions (SON)"
     gsn_panel2(wks_mei,reg_mei_son,(/nrow,ncol/),panres)
     delete(reg_mei_son)
     panres@txString = "SAM "+txt0+" Regressions (Annual)"
     gsn_panel2(wks_mei,reg_mei_ann,(/nrow,ncol/),panres)
     delete(reg_mei_ann)
     if (COMPUTE_MODES_MON.eq."True") then    
        panres@txString = "SAM "+txt0+" Regressions (Monthly)"
        gsn_panel2(wks_mei,reg_mei_mon,(/nrow,ncol/),panres)
        delete(reg_mei_mon)
     end if
     delete(wks_mei)
  end if
  if (prreg_frame.eq.0) then
     panres@txString = "SAM PR Regressions (DJF)" 
     gsn_panel2(wks_mei_pr,reg_mei_pr_djf,(/nrow,ncol/),panres)
     delete(reg_mei_pr_djf)
     panres@txString = "SAM PR Regressions (MAM)"
     gsn_panel2(wks_mei_pr,reg_mei_pr_mam,(/nrow,ncol/),panres)
     delete(reg_mei_pr_mam)
     panres@txString = "SAM PR Regressions (JJA)"
     gsn_panel2(wks_mei_pr,reg_mei_pr_jja,(/nrow,ncol/),panres)
     delete(reg_mei_pr_jja)
     panres@txString = "SAM PR Regressions (SON)"
     gsn_panel2(wks_mei_pr,reg_mei_pr_son,(/nrow,ncol/),panres)
     delete(reg_mei_pr_son)
     panres@txString = "SAM PR Regressions (Annual)"
     gsn_panel2(wks_mei_pr,reg_mei_pr_ann,(/nrow,ncol/),panres)
     delete(reg_mei_pr_ann)
     if (COMPUTE_MODES_MON.eq."True") then    
        panres@txString = "SAM PR Regressions (Monthly)"
        gsn_panel2(wks_mei_pr,reg_mei_pr_mon,(/nrow,ncol/),panres)
        delete(reg_mei_pr_mon)
     end if
     delete(wks_mei_pr)  
  end if
  
  panres2 = True    
  if (nsim.le.5) then
     panres2@txFontHeightF = 0.024
  else
     panres2@txFontHeightF = 0.016
  end if  
  panres2@gsnMaximize = True
  panres2@gsnPaperOrientation = "portrait"
  if (SCALE_TIMESERIES.eq."True") then
     tt = ind(nyr.eq.nyr_max)
     panres2@gsnPanelScalePlotIndex = tt(0)
     delete(tt)  
  end if  
  if (nsim.le.12) then
     lp = (/nsim,1/)
  else
     lp = (/nrow,ncol/)  
  end if
  panres2@txString = "SAM (DJF)"
  gsn_panel2(wks_mei_ts,xy_mei_djf,lp,panres2)  
  delete(xy_mei_djf)
  panres2@txString = "SAM (MAM)"
  gsn_panel2(wks_mei_ts,xy_mei_mam,lp,panres2)  
  delete(xy_mei_mam)
  panres2@txString = "SAM (JJA)"
  gsn_panel2(wks_mei_ts,xy_mei_jja,lp,panres2)  
  delete(xy_mei_jja)
  panres2@txString = "SAM (SON)"
  gsn_panel2(wks_mei_ts,xy_mei_son,lp,panres2)  
  delete(xy_mei_son)
  panres2@txString = "SAM (Annual)"
  gsn_panel2(wks_mei_ts,xy_mei_ann,lp,panres2)  
  delete(xy_mei_ann)
  if (COMPUTE_MODES_MON.eq."True") then  
     panres2@txString = "SAM (Monthly)"
     gsn_panel2(wks_mei_ts,xy_mei_mon,lp,panres2)  
     delete(xy_mei_mon) 
  end if
  delete(wks_mei_ts)
    
;--------------------------------------------------------------------------------------------------
  OUTDIR = getenv("OUTDIR") 
  if (wks_type.eq."png") then       
     system("mv "+OUTDIR+"mei.000001.png "+OUTDIR+"mei.djf.png") 
     system("mv "+OUTDIR+"mei.000002.png "+OUTDIR+"mei.mam.png") 
     system("mv "+OUTDIR+"mei.000003.png "+OUTDIR+"mei.jja.png") 
     system("mv "+OUTDIR+"mei.000004.png "+OUTDIR+"mei.son.png") 
     system("mv "+OUTDIR+"mei.000005.png "+OUTDIR+"mei.ann.png")
     if (COMPUTE_MODES_MON.eq."True") then     
        system("mv "+OUTDIR+"mei.000006.png "+OUTDIR+"mei.mon.png")  
        if (meireg_frame.eq.0) then
           system("mv "+OUTDIR+"mei.000007.png "+OUTDIR+"mei.tempreg.djf.png") 
           system("mv "+OUTDIR+"mei.000008.png "+OUTDIR+"mei.tempreg.mam.png") 
           system("mv "+OUTDIR+"mei.000009.png "+OUTDIR+"mei.tempreg.jja.png") 
           system("mv "+OUTDIR+"mei.000010.png "+OUTDIR+"mei.tempreg.son.png") 
           system("mv "+OUTDIR+"mei.000011.png "+OUTDIR+"mei.tempreg.ann.png")
           system("mv "+OUTDIR+"mei.000012.png "+OUTDIR+"mei.tempreg.mon.png")     
        end if
     else
        if (meireg_frame.eq.0) then
           system("mv "+OUTDIR+"mei.000006.png "+OUTDIR+"mei.tempreg.djf.png") 
           system("mv "+OUTDIR+"mei.000007.png "+OUTDIR+"mei.tempreg.mam.png") 
           system("mv "+OUTDIR+"mei.000008.png "+OUTDIR+"mei.tempreg.jja.png") 
           system("mv "+OUTDIR+"mei.000009.png "+OUTDIR+"mei.tempreg.son.png") 
           system("mv "+OUTDIR+"mei.000010.png "+OUTDIR+"mei.tempreg.ann.png")
        end if
     end if

     if (prreg_frame.eq.0) then
        system("mv "+OUTDIR+"mei.prreg.000001.png "+OUTDIR+"mei.prreg.djf.png") 
        system("mv "+OUTDIR+"mei.prreg.000002.png "+OUTDIR+"mei.prreg.mam.png") 
        system("mv "+OUTDIR+"mei.prreg.000003.png "+OUTDIR+"mei.prreg.jja.png") 
        system("mv "+OUTDIR+"mei.prreg.000004.png "+OUTDIR+"mei.prreg.son.png") 
        system("mv "+OUTDIR+"mei.prreg.000005.png "+OUTDIR+"mei.prreg.ann.png")         
        if (COMPUTE_MODES_MON.eq."True") then     
           system("mv "+OUTDIR+"mei.prreg.000006.png "+OUTDIR+"mei.prreg.mon.png")         
        end if
     end if
     
     system("mv "+OUTDIR+"mei.timeseries.000001.png "+OUTDIR+"mei.timeseries.djf.png") 
     system("mv "+OUTDIR+"mei.timeseries.000002.png "+OUTDIR+"mei.timeseries.mam.png") 
     system("mv "+OUTDIR+"mei.timeseries.000003.png "+OUTDIR+"mei.timeseries.jja.png") 
     system("mv "+OUTDIR+"mei.timeseries.000004.png "+OUTDIR+"mei.timeseries.son.png") 
     system("mv "+OUTDIR+"mei.timeseries.000005.png "+OUTDIR+"mei.timeseries.ann.png")
     if (COMPUTE_MODES_MON.eq."True") then     
        system("mv "+OUTDIR+"mei.timeseries.000006.png "+OUTDIR+"mei.timeseries.mon.png")     
     end if
     
  else     
     system("psplit "+OUTDIR+"mei.ps "+OUTDIR+"psl_sp")
     system("mv "+OUTDIR+"psl_sp0001.ps "+OUTDIR+"mei.djf.ps") 
     system("mv "+OUTDIR+"psl_sp0002.ps "+OUTDIR+"mei.mam.ps") 
     system("mv "+OUTDIR+"psl_sp0003.ps "+OUTDIR+"mei.jja.ps") 
     system("mv "+OUTDIR+"psl_sp0004.ps "+OUTDIR+"mei.son.ps") 
     system("mv "+OUTDIR+"psl_sp0005.ps "+OUTDIR+"mei.ann.ps") 
     if (COMPUTE_MODES_MON.eq."True") then     
        system("mv "+OUTDIR+"psl_sp0006.ps "+OUTDIR+"mei.mon.ps") 
        if (meireg_frame.eq.0) then
           system("mv "+OUTDIR+"psl_sp0007.ps "+OUTDIR+"mei.tempreg.djf.ps") 
           system("mv "+OUTDIR+"psl_sp0008.ps "+OUTDIR+"mei.tempreg.mam.ps") 
           system("mv "+OUTDIR+"psl_sp0009.ps "+OUTDIR+"mei.tempreg.jja.ps") 
           system("mv "+OUTDIR+"psl_sp0010.ps "+OUTDIR+"mei.tempreg.son.ps") 
           system("mv "+OUTDIR+"psl_sp0011.ps "+OUTDIR+"mei.tempreg.ann.ps")
           system("mv "+OUTDIR+"psl_sp0012.ps "+OUTDIR+"mei.tempreg.mon.ps") 
        end if
     else
        if (meireg_frame.eq.0) then
           system("mv "+OUTDIR+"psl_sp0006.ps "+OUTDIR+"mei.tempreg.djf.ps") 
           system("mv "+OUTDIR+"psl_sp0007.ps "+OUTDIR+"mei.tempreg.mam.ps") 
           system("mv "+OUTDIR+"psl_sp0008.ps "+OUTDIR+"mei.tempreg.jja.ps") 
           system("mv "+OUTDIR+"psl_sp0009.ps "+OUTDIR+"mei.tempreg.son.ps") 
           system("mv "+OUTDIR+"psl_sp0010.ps "+OUTDIR+"mei.tempreg.ann.ps")     
        end if
     end if

     if (prreg_frame.eq.0) then
        system("psplit "+OUTDIR+"mei.prreg.ps "+OUTDIR+"pr_nn")
        system("mv "+OUTDIR+"pr_nn0001.ps "+OUTDIR+"mei.prreg.djf.ps") 
        system("mv "+OUTDIR+"pr_nn0002.ps "+OUTDIR+"mei.prreg.mam.ps") 
        system("mv "+OUTDIR+"pr_nn0003.ps "+OUTDIR+"mei.prreg.jja.ps") 
        system("mv "+OUTDIR+"pr_nn0004.ps "+OUTDIR+"mei.prreg.son.ps") 
        system("mv "+OUTDIR+"pr_nn0005.ps "+OUTDIR+"mei.prreg.ann.ps") 
        if (COMPUTE_MODES_MON.eq."True") then
           system("mv "+OUTDIR+"pr_nn0006.ps "+OUTDIR+"mei.prreg.mon.ps") 
        end if
     end if
     
     system("psplit "+OUTDIR+"mei.timeseries.ps "+OUTDIR+"psl_sp")
     system("mv "+OUTDIR+"psl_sp0001.ps "+OUTDIR+"mei.timeseries.djf.ps") 
     system("mv "+OUTDIR+"psl_sp0002.ps "+OUTDIR+"mei.timeseries.mam.ps") 
     system("mv "+OUTDIR+"psl_sp0003.ps "+OUTDIR+"mei.timeseries.jja.ps") 
     system("mv "+OUTDIR+"psl_sp0004.ps "+OUTDIR+"mei.timeseries.son.ps") 
     system("mv "+OUTDIR+"psl_sp0005.ps "+OUTDIR+"mei.timeseries.ann.ps") 
     if (COMPUTE_MODES_MON.eq."True") then     
        system("mv "+OUTDIR+"psl_sp0006.ps "+OUTDIR+"mei.timeseries.mon.ps") 
     end if
     
     system("rm "+OUTDIR+"mei.ps "+OUTDIR+"mei.timeseries.ps ")
  end if
  print("Finished: enso.mei_5var.ncl")
end  
