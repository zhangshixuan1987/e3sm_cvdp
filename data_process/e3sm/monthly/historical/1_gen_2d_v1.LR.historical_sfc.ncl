;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This script used to generate SST and Seaice ensemble forcing from CMIP6 scenario mip;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "./function.ncl"

begin

  cmipnam    = (/"CMIP"/)
  scenario   = "historical" ;"ssp245";"ssp585"
  outdir     = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD"
  topdir     = "/global/cfs/projectdirs/m3522/cmip6/CMIP6"
  comdir     = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/run_script/data_process/cmip6_mme/share_file"

 ;get CMIP6 model name
  model_name = (/"E3SM-Project/E3SM-1-0"/)
  nmodel     = dimsizes(model_name)
  out_name   = "v1.LR." + scenario
  exps       = (/"r1i1p1f1","r2i1p1f1","r3i1p1f1","r4i1p1f1","r5i1p1f1"/)
  ttag       = (/"v20190913","v20190729","v20190729","v20190916","v20190731"/)
  nexps      = dimsizes(exps)
 ;print(model_name)

  var_lev    = "sfc"
  cmip_vnam  = (/"psl",  "ts", "tas",   "pr",   "prc",  \
                 "prsn", "ps", "prw",   "huss", "tauu", \
                 "tauv", "clt", "hfls", "hfss", "evspsbl",\
                 "clivi", "clwvi", "sfcWind", "uas", "vas",\ 
                 "rlut","rlutcs","rlds","rldscs","rsds", \
                 "rsdscs", "rsus", "rsuscs","rlus","rsdt",\
                 "rsut","rsutcs","rtmt"/)
  e3sm_vnam  = (/"PSL",   "TS", "TREFHT","PRECT","PRECC", \
                 "PRECST","PS", "TMQ",   "QREFHT","TAUX", \
                 "TAUY", "CLDTOT","LHFLX", "SHFLX", "QFLX",\
                 "TGCLDIWP", "TGCLDCWP", "S10", "U10", "V10", \
                 "rlut","FLUTC","FLDS","rldscs","FSDS", \
                 "FSDSC","rsus","rsuscs","rlus","SOLIN",\
                 "FSUTOA","FSUTOAC","rtmt"/) 
  cmip_dnam  = cmip_vnam
  cmip_dnam  = "Amon"
  nvars      = dimsizes(cmip_vnam)

 ;time range for climo forcing 
  csym       = 197901
  ceym       = 201412
  nyrs       = ceym/100 - csym/100 + 1
  nmon       = nyrs * 12
  crange     = csym + "-" + ceym

  do im = 0,nmodel-1,1

    do iv = 19,nvars-1,1

     varnam   = cmip_vnam(iv)
     varout   = e3sm_vnam(iv)
     vardnm   = cmip_dnam(iv)
     modnam   = model_name(im)
     tmpnam   = str_split(modnam,"/")  
     modout   = out_name 

     ike = 0 
     do kk = 0,nexps-1,1 
       ike = kk 
       print("working on " + modnam)
       cpath = topdir+"/"+cmipnam+"/" + modnam
       fdrs  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps(kk)+"/"+vardnm+"/" + varnam+ "/gr")
       fdr   = systemfunc("ls -d " + fdrs+"/"+ttag(kk))
       fls   = systemfunc("ls -1 " + fdr + "/*.nc")

       print(fls)

       if(all(isfilepresent(fls))) then

        f    = addfiles(fls,"r")

        if(isfilevar(f[0],"time")) then 

          yymm = cd_calendar(f[:]->time, 1)
          indp = ind(yymm.ge.csym.and.yymm.le.ceym)
         ;print(yymm(indp))

          if(num(.not.ismissing(indp)).eq.nmon) then 

           dimx = dimsizes(f[:]->$varnam$) 
           if(dimsizes(dimx).eq.2) then 
             var   = f[:]->$varnam$(indp,:)
             var!0 = "time"
             var!1 = "cells"
           else 
             var   = f[:]->$varnam$(indp,:,:)
             var!0 = "time"
             var!1 = "lat"
             var!2 = "lon" 
           end if 

           var@_FillValue = -9999. 
           var = where(var.ge.1e20,var@_FillValue,var)

           if (varout.eq."PRECT".or. varout.eq."PRECC".or.varout.eq."PRECL" \
               .or.varout.eq."PRECST".or.varout.eq."QFLX") then    
            ; convert (if necessary) to mm/day
            printVarSummary(var)
            printMinMax(var,False)
            if (var@units.eq."m/s".or.var@units.eq."m s-1") then
              var = var*86400000.
            end if
            if (var@units.eq."kg m-2 s-1".or.var@units.eq."kg/m2/s".or.var@units.eq."kg/m^2/s"\
                .or.var@units.eq."kg/(s*m2)".or.var@units.eq."mm/s") then
              var = var*86400.
            end if
            if (var@units.eq."m".or.var@units.eq."m/month".or.var@units.eq."cm".or.var@units.eq."cm/month"\
                .or.var@units.eq."mm".or.var@units.eq."mm/month") then
              yr = toint(var&time)/100
              mo = toint(var&time - (yr*100))
              days = days_in_month(yr,mo)
              do gg = 0,dimsizes(var&time)-1
                  var(gg,:,:) = (/ var(gg,:,:) / var(gg) /)
              end do
              if (var@units.eq."cm".or.var@units.eq."cm/month") then
                var = var*10.   ; convert from cm/day to mm/day
              end if
              if (var@units.eq."m".or.var@units.eq."m/month") then
                var = var*1000.   ; convert from m/day to mm/day
              end if
            end if
            if (var@units.eq."m/day".or.var@units.eq."m day-1") then
             var = var*1000.
            end if
            var@units = "mm/day"
           end if

           if (varout.eq."QREFHT") then 
            if (var@units.eq."kg kg-1".or.var@units.eq."kg/kg".or.var@units.eq."kg/kg^1"\
                .or.var@units.eq."kg/(kg)") then
               var = var*1000.
             end if
             var@units = "g/kg"
           end if 
           if (varout.eq."TMQ".or.varout.eq."TGCLDIWP".or.varout.eq."TGCLDCWP".or.varout.eq."TGCLDLWP") then
             if (var@units.eq."kg m-2".or.var@units.eq."kg/m2".or.var@units.eq."kg/m^2"\
                 .or.var@units.eq."kg/(m2)") then
               var = var*1000.
             end if 
             var@units = "g/m2"
           end if

          ;note: we convert TAUX and TAUY in E3SM by * -1.0
          ;if (varout.eq."TAUX".or.varout.eq."TAUY") then
          ;  var = var*-1.
          ;end if

          if (varout.eq."rlut") then 
            var@notes = "rlut = FSNTOA - FSNT + FLNT"
          end if
          if (varout.eq."rsus") then
            var@notes = "rsus = FSDS - FSNS"
          end if
          if (varout.eq."rlus") then
            var@notes = "rlus = FLDS + FLNS" 
          end if
          if (varout.eq."rsuscs") then 
            var@notes = "rsuscs = FSDSC - FSNSC"
          end if
          if (varout.eq."rldscs") then
            var@notes = "rldscs = FLDS + FLNS - FLNSC"
          end if
          if (varout.eq."rtmt") then
            var@notes = "rtmt = FSNT - FLNT"
          end if          
          ;;regrid the data to target grid 
          dstFileName  = comdir + "/sample_out_grid.nc"
          srcFileName  = fls(0)
          keystring    = var_lev + "_" + scenario
          InterpMethod = "bilinear" ;"conserve" 
          vout         = regrid_to_reference_grid(var,keystring, modout,InterpMethod,srcFileName,dstFileName)
          if(.not.all(ismissing(vout))) then 
            odir = outdir + "/" + modout 
            system("if ! test -d " + odir +" ; then mkdir -p " + odir + " ; fi")
            enstr     = "en"+sprinti("%02d",ike)
            out_file  = odir+"/"+modout+"."+enstr+"."+varout+"."+crange+".nc"
            setfileoption("nc", "Format",  "NetCDF4")
            system("rm " + out_file)
            fout = addfile(out_file,"cw")
            vonm = varout
            fout->$vonm$  = vout
            delete([/enstr,vonm,fout/])
            ike = ike + 1
           end if
           delete([/dimx,f,var,srcFileName,dstFileName/])
        end if  
        delete([/yymm,indp/])
       end if 
     end if 
     delete([/fls,fdr,cpath,fdrs/])
   end do ;;end of exp loop
  end do 
 end do 
end
