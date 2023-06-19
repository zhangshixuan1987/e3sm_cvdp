load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "writets.ncl"
begin  

UTC = systemfunc("date -u '+%H%M UTC %e %b %Y'| awk '{print toupper($0)}'")

   
; tpi.create.ncl -- NCL (v6.3.0) script used to generate TPI
; C. Smith, NOAA/ESRL/PSD, 4/2016
;
; SSTA = SST anomaly, where first the SST monthly climatology is removed
;
; Output available at http://www.esrl.noaa.gov/psd/tpi, where all TPIs are defined from 1920-2014 data

; TO APPLY THIS CODE YOURSELF, YOU WILL NEED TO MODIFY THE FIRST SECTION, 
; BUT THIS SHOULD WORK IF NOTHING BELOW THE DASHED LINE IS MODIFIED

; NCL is available for download from https://www.ncl.ucar.edu/Download/

;;;;;;;;;
; CAN MODIFY BELOW HERE:
;;;;;;;;;

; location of SST dataset(s) and land mask

 paths_ts = (/"/Datasets/noaa.ersst.v5/sst.mnmean.nc"/)

years=(/1854/)
;
; dataset names and associated plot labels

 ps_name=(/"ersstv5"/)
 top_lab=(/"ERSST V5"/)

;
; Time period for TPI 

 ymStrt = 197101 ; year-month start 
 ymLast = 200012 ; year-month last 

;----------------------------------------------------------------------------------------
; SHOULD NOT NEED TO MODIFY BELOW HERE
;----------------------------------------------------------------------------------------


; initalize variables

 TimeDate = systemfunc("date")
 DATE = str_split(TimeDate, " ")
 UTC= DATE(1)+" "+ DATE(2)+" "+ DATE(5)

 nsim   = dimsizes(paths_ts)
 rad    = 4*atan(1.0)/180
 re     = 6371220.0
 rr     = re*rad


 description=new( 12 , "string")
 psd_txt_out=new(nsim,"string")
 psd_txt_out_filt=new(nsim,"string")
 psd_csv_out=new(nsim,"string")
 psd_csv_out_filt=new(nsim,"string") 
 ts_out=new(nsim,"string")
 ts_out_filt=new(nsim,"string") 

; ======================================
; loop through sst datasets
; ======================================

 do nameind=0,0
   psd_txt_out(nameind)="tpi.new.timeseries."+ps_name(nameind)+".data"
   psd_txt_out_filt(nameind)="tpi.new.timeseries."+ps_name(nameind)+".filt.data"   
   psd_csv_out(nameind)="tpi.new.timeseries."+ps_name(nameind)+".csv"
   psd_csv_out_filt(nameind)="tpi.new.timeseries."+ps_name(nameind)+".filt.csv"   

; read this sst dataset
   print(paths_ts(nameind)+" ")
   sstdatafile   = addfile(paths_ts(nameind),"r")
   sstall        = sstdatafile->sst     ; all of data
   TIME          = sstdatafile->time    
   lat           = sstdatafile->lat
   rad           = 4*atan(1.0)/180.
   clat          = cos(rad*lat)
   clat!0        = "lat"
   clat&lat      = lat
   sstall@missing_value=sstall@_FillValue
;
; get time variables, index for start and end

   YYYYMM  = cd_calendar(TIME, -1) ; convert
   YYYYMM1 = cd_calendar(TIME, 0) ; convert    
   numtimes=dimsizes(TIME)
   
   iStrt = ind(ymStrt.eq.YYYYMM) ; index of start time 
   iLast = ind(ymLast.eq.YYYYMM) ; last time

   year_all   = tointeger(YYYYMM1(:,0)) 
   date_start_yr=year_all(0)
   date_end_yr=year_all(numtimes-1)
;
; subset of sst, over the climo 

   sst_baseperiod = sstall(iStrt:iLast,:,:)

; Now get SSTA (SST with annual cycle removed and then global mean SST each month removed)

; First, remove annual cycle, defined only over base period, from SSTs

   sstClm = clmMonTLL( sst_baseperiod )                 ; get climo
   
;; now subtract to get whole file

   sst_baseperiod = calcMonAnomTLL (sst_baseperiod,sstClm)         ; anomalies

; remove same annual cycle from all ssts

   kmm=0
   do it=0,numtimes-1
     sstall(it,:,:)=sstall(it,:,:)-sstClm(kmm,:,:)
     kmm=kmm+1
     if(kmm.eq.12)then
       kmm=0
     end if
   end do

; calculate T1, T2, T3
;T1 =  [25°N–45°N, 140°E–145°W] 
;T2 = [10°S–10°N, 170°E–90°W] 
;T3 = [50°S–15°S, 150°E–160°W]
;TPI = T2 - (T1+T3)/2

T1=wgt_areaave_Wrap(sstall(:,{25:45},{140:215}),clat({25:45}),1.0,0)
T2=wgt_areaave_Wrap(sstall(:,{-10:10},{170:270}),clat({-10:10}),1.0,0)
T3=wgt_areaave_Wrap(sstall(:,{-50:-15},{150:200}),clat({-50:-15}),1.0,0)

tpi               = T2 - (T1+T3)/2.
tpi@missing_value = T1@missing_value
tpi@_FillValue    = T1@missing_value

; ********
; smooth data here

  ihp       = 0
  sigma     = 1
  nWgt      = 157                          ; loose 156 months each end
  fca       = 1./156                       ; decadal- 13*12
  wgtt      = filwgts_lanczos (nWgt, ihp, fca, -999., sigma )
  tpi_filt  = wgt_runave ( tpi, wgtt, 0 )   ; 10 year
  
  tpi_filt@missing_value=tpi@missing_value

  description(0)="TPI unfiltered (IPO Tripole Index) of Henley et al. (2015)"
  description(1)=top_lab(nameind)
  description(2)="Henley, B.J., Gergis, J., Karoly, D.J., Power, S.B., Kennedy, J., & Folland, C.K. (2015)."
  description(3)="A Tripole Index for the Interdecadal Pacific Oscillation. Climate Dynamics, 45(11-12), 3077-3090. doi:10.1007/s00382-015-2525-1"
  description(4)="See http://www.esrl.noaa.gov/psd/data/timeseries/IPOTPI/"
  description(5)="Produced "+UTC
	    

  ierr=writets(tpi,1,12,years(nameind),2017,psd_txt_out(nameind),psd_csv_out(nameind),description)

  tpi_filt@missing_value=tpi@missing_value
  description(0)="TPI filtered (IPO Tripole Index) of Henley et al. (2015)"
  ierr=writets(tpi_filt,1,12,years(nameind),2017,psd_txt_out_filt(nameind),psd_csv_out_filt(nameind),description)


; now write time series out in various formats.

   mon1=1
   mon2=12
   
   year1=date_start_yr
   year2=date_end_yr

   filename= psd_txt_out(nameind)
   filenamecsv=psd_csv_out(nameind)

   delete(sstall)
   delete(sst_baseperiod)     
   delete(TIME)
   delete( YYYYMM)
   delete( YYYYMM1)
   delete(year_all)
   delete([/tpi/])
   delete([/tpi_filt/])
   delete(lat)
   delete(clat)
   delete(sstClm)
   delete(T1)
   delete(T2)
   delete(T3)
 end do

end
     
     
