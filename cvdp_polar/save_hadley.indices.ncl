  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a eof plot for AAO patterns 
;          Data is vertically interpolated to pressure levels
;          1st panel: EOFs for the first three modes
;          2nd panel: time series plot
; Author : Shixuan Zhang
; Date   : Dec 06, 2020

begin

  data_dir  = "/global/cfs/cdirs/e3sm/zhan391/local_diag/fig_data/hc_data"
  exp_name  = (/"ERA5"/)
  nexps     = dimsizes(exp_name)

  time_tag  = (/"1979-2014"/)
  tout_tag  = "1979-2014"
  time_str  = (/"Year 1981-2010"/)
  time_unt  = "hours since 1981-01-01 00:00:00.0"

  d2r       = get_d2r("float")
  seasons   = (/"MON"/) ;,"DJF","JJA","MOM","SON"/) 
  nseas     = dimsizes(seasons)

  varnam    = "SF"
  varfac    = 1e9
  varunt    = "10~S~9~N~ kg s~S~-1~N~" 

  do i = 0,nseas-1,1

   do j = 0,nexps-1,1 

     
    fl     = systemfunc("ls -1 "+ data_dir+"/"+exp_name(j)+"_HC_analysis_"+seasons(i)+"_en*_"+time_tag+".nc")
    nens   = dimsizes(fl)

    do ie = 0,nens-1,1

     print(fl(ie))
     f      = addfile(fl(ie),"r")
     time   = cd_convert(f->time,time_unt) 
     lat    = f->lat
     plev   = f->lev
     if(plev@units.eq."hPa") then 
       plev = plev * 100.0 
       plev@units = "Pa"
     end if 
     ptop = 0 
     psfc = 101800
     psfc@units = "Pa" 
     dp  = dpres_plevel_Wrap(plev, psfc, ptop, 0)
     wgt_dp = dp({900:200})
     delete([/ptop,dp,psfc,plev/])

    ;vertical average over 200-900hPa
     hc      = f->SF(:,{900:200},:)
     hc      = hc / varfac

     delete(hc&time)
     hc&time = time
 
     dimx   = dimsizes(hc)
     ntim   = dimx(0)
     nlev   = dimx(1)
     nlat   = dimx(2)
      
     hcin      = new((/ntim/),double)  
     hcin!0    = "time"
     hcin&time = hc&time
     hcin@_FillValue = 99999
     hcin@description = "HC intensity in NH"
     hcis   = hcin
     hcis@description = "HC intensity in SH"
     hpin   = hcin
     hpin@description = "latitude of HC in NH"
     hpis   = hcin
     hpis@description = "latitude of HC in SH"
     hcei   = hcin
     hcei@description = "HC SH to NH intersection (zero value of steam function)"
     hcen   = hcin
     hcen@description = "HC poleward extent in NH (zero value of steam function)"
     hces   = hcin
     hces@description = "HC poleward extent in SH (zero value of steam function)"
     hcwn   = hcin
     hcwn@description = "HC width in NH (NH extent - intersection)"
     hcws   = hcin
     hcws@description = "HC width in SH (SH extent intersection)"
     hcwa   = hcin
     hcwa@description = "HC width (SH extent - SH extent)"

     hcinm = hcin
     hcinm@description = "HC Max intensity in NH"
     hcism = hcin
     hcism@description = "HC Min intensity in SH"
     hpinm = hcin
     hpinm@description = "latitude of HC max in NH"
     hpism = hcin
     hpism@description = "latitude of HC min in SH"

     hcin0 = hcin
     hcin0@description = "HC Mean intensity in NH"
     hcis0 = hcin
     hcis0@description = "HC Mean intensity in SH"
     hpin0 = hcin
     hpin0@description = "latitude of HC max in NH"
     hpis0 = hcin
     hpis0@description = "latitude of HC min in SH"

     do ii  = 0, ntim -1

       ;;mean intensity 
       hctmp   = dim_avg_wgt_n_Wrap(hc(ii,:,:),wgt_dp,1,0)
       tmp1    = hctmp({-5:40})
       lat1    = lat({-5:40})
       tmp2    = hctmp({-40:5})
       lat2    = lat({-40:5})
       indx1      = dim_maxind(tmp1,0)
       indx2      = dim_minind(tmp2,0)
       hcin0(ii)  = (/tmp1(indx1)/)
       hcis0(ii)  = (/tmp2(indx2)/)
       hpin0(ii)  = (/lat1(indx1)/)
       hpis0(ii)  = (/lat2(indx2)/)
       delete([/indx1,indx2,tmp1,tmp2,lat1,lat2,hctmp/])

       ;;;maximum at each level
       xcin      = new((/nlev/),double)
       xcin!0    = "lev"
       xcin&lev  = hc&lev
       xcis      = xcin
       xpis      = xcin
       xpin      = xcin

       do jj  = 0, nlev -1
         tmp1    = hc(ii,jj,{-5:40})
         lat1    = lat({-5:40})
         ind1    = dim_maxind(tmp1,0)
         tmp2    = hc(ii,jj,{-40:5})
         lat2    = lat({-40:5})
         ind2    = dim_minind(tmp2,0)
         ;;HC intensity and max/min loction
         xcin(jj) = (/tmp1(ind1)/)
         xcis(jj) = (/tmp2(ind2)/)
         xpin(jj) = (/lat1(ind1)/)
         xpis(jj) = (/lat2(ind2)/)
        ;print(xcin(jj) + " " +xpin(jj))
        ;print(xcis(jj) + " " +xpis(jj))
        delete([/tmp1,tmp2,lat1,lat2,ind1,ind2/])
       end do 
       
       hcin(ii)   = dim_avg_wgt_n(xcin, wgt_dp, 1, 0) 
       hcis(ii)   = dim_avg_wgt_n(xcis, wgt_dp, 1, 0)
       hpin(ii)   = dim_avg_wgt_n(xpin, wgt_dp, 1, 0)
       hpis(ii)   = dim_avg_wgt_n(xpis, wgt_dp, 1, 0)

       indx1      = dim_maxind(xcin,0)
       indx2      = dim_minind(xcis,0)
       hcinm(ii)  = (/xcin(indx1)/)
       hcism(ii)  = (/xcis(indx2)/)
       hpinm(ii)  = (/xpin(indx1)/)
       hpism(ii)  = (/xpis(indx2)/)
       delete([/indx1,indx2/])
  
       ;print(hcin(ii) + " " +hpin(ii))
       ;print(hcis(ii) + " " +hpis(ii))

       ;;HC intersection and extents
       hctx = dim_avg_wgt_n_Wrap(hc(ii,{400:700},:),wgt_dp({400:700}),1,0)
       latx = lat
       tmp1 = hctx({-5:40})
       tmp2 = hctx({-40:5})
       lat1 = lat({-5:40})
       lat2 = lat({-40:5})
       ind1 = dim_maxind(tmp1,0)
       latx1 = lat1(ind1)
       ind2 = dim_minind(tmp2,0)
       latx2 = lat2(ind2)
       delete([/tmp1,tmp2,lat1,lat2,ind1,ind2/])

       ;;HC intersection and extents
       latx2 = latx2 - 1.0
       xi  = hctx({latx2:-90})
       yi  = latx({latx2:-90})
       loop = True
       do ix = 1,dimsizes(xi)-2,1
        if(xi(ix).lt.0.and.xi(ix+1).gt.0.0.and.loop) then
           kt = ix
           loop = False
        end if
       end do
       if(loop)then
         print("hces missing")
         hces(ii) = hcin@_FillValue 
       else 
         hces(ii) = yi(kt) - xi(kt)/(xi(kt+1)- xi(kt)) * (yi(kt+1) - yi(kt))
       end if
      ;print(xi + "  "+yi)
       print(hces(ii))
       delete([/xi, yi/])

       ;;HC intersection and extents
       latx2 = latx2 - 1.0
       xi  = hctx({latx2:90})
       yi  = latx({latx2:90})
       loop = True
       do ix = 1,dimsizes(xi)-2,1
        if((xi(ix).lt.0.and.xi(ix+1).gt.0).and.loop) then
           kt = ix
           loop = False
        end if
       end do
       if(loop)then
         print("hcei missing")
         hcei(ii) = hcin@_FillValue 
       else
         hcei(ii) = yi(kt) - xi(kt)/(xi(kt+1)- xi(kt)) * (yi(kt+1) - yi(kt))
       end if
      ;print(xi + "  "+yi)
       print(hcei(ii))
       delete([/xi, yi/])

       ;;HC intersection and extents
       latx1 = latx1 -1.0
       xi   = hctx({latx1:90})
       yi   = latx({latx1:90})
       loop = True
       do ix = 1,dimsizes(xi)-2,1
        if(xi(ix).gt.0.and.xi(ix+1).lt.0.0.and.loop) then
           kt = ix 
           loop = False
        end if 
       end do
       if(loop)then
         print("hcen missing")
         hcen(ii) = hcin@_FillValue 
       else
         hcen(ii) = yi(kt+1) - xi(kt+1)/(xi(kt)- xi(kt+1)) * (yi(kt) - yi(kt+1))
       end if
      ;print(xi + "  "+yi)
       print(hcen(ii))
       delete([/xi, yi/])

      end do 

      ;;HC width
      hcwn = hcen - hcei
      hcws = hces - hcei
      hcwa = hcen - hces
      print(num(ismissing(hcwn)) + " " + num(ismissing(hcws)) + " " + num(ismissing(hcwa)))

      ;======================================================================
      ;Save the data for eof analysis
      ;==================================================================
      setfileoption("nc", "Format",  "NetCDF4Classic")
      enstr = sprinti("en%02d",(ie+1)) 
      out_file1  = "./"+exp_name(j)+"_HC_index_"+seasons+"_"+enstr+"_"+tout_tag+".nc"
      system("rm " + out_file1)
      fout1       = addfile(out_file1,"cw")

      fout1->hcin = hcin(:)
      fout1->hcis = hcis(:)
      fout1->hpin = hpin(:)
      fout1->hpis = hpis(:)
      fout1->hcei = hcei(:)
      fout1->hcen = hcen(:)
      fout1->hces = hces(:)
      fout1->hcwn = hcwn(:)
      fout1->hcws = hcws(:)
      fout1->hcwa = hcwa(:)

      fout1->hcinm = hcinm(:)
      fout1->hcism = hcism(:)
      fout1->hpinm = hpinm(:)
      fout1->hpism = hpism(:)

      fout1->hcin0 = hcin0(:)
      fout1->hcis0 = hcis0(:)
      fout1->hpin0 = hpin0(:)
      fout1->hpis0 = hpis0(:)

      delete([/latx,hctx,hcin,hcis,hpin,hpis,hcei,hcen,hces,hcwn,hcws,hcwa/])
      delete([/time,hcinm,hcism,hpinm,hpism,wgt_dp/])

   end do 

  end do 
  end do 
  
end

