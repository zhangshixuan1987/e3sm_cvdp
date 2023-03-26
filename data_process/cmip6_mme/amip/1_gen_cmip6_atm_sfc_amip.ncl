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
  exps       = "r1i1p1f1"
  scenario   = "amip" ;"ssp245";"ssp585"
  outdir     = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/CMIP6_MME"
  topdir     = "/global/cfs/projectdirs/m3522/cmip6/CMIP6"
  comdir     = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/run_script/data_process/cmip6_mme/share_file"

 ;get CMIP6 model name
  model_dirs = systemfunc("cd " + topdir+ "/"+cmipnam+"; ls -d */*")
  model_name = model_dirs 
  nmodel     = dimsizes(model_name)
  delete([/model_dirs/])
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

 ;indx = ind(model_name.eq."NCAR/CESM2-WACCM") ;"NIMS-KMA/KACE-1-0-G")
 ;do im = indx,indx
 ;print(model_name(indx))

  do im = 0,nmodel-1,1

    do iv = 0,nvars-1,1

     varnam   = cmip_vnam(iv)
     varout   = e3sm_vnam(iv)
     vardnm   = cmip_dnam(iv)
     modnam   = model_name(im)
     tmpnam   = str_split(modnam,"/")  
     if (tmpnam(0).eq."MPI-M") then
        modout = "DKRZ"+"_"+tmpnam(1)
     else 
        modout   = str_sub_str(modnam,"/","_")
     end if
     delete(tmpnam)

     cpath    = topdir+"/"+cmipnam+"/" + modnam 

     if (modnam.eq."NCAR/CESM2".and.(varout.eq."PRECT".or. varout.eq."PRECC".or.varout.eq."PRECL")) then
       fdrs   = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+vardnm+"/" + varnam+ "/*/v20190319")
     else if (modnam.eq."NCAR/CESM2-WACCM".and.(varout.eq."PRECT".or. varout.eq."PRECC".or.varout.eq."PRECL")) then
       fdrs   = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+vardnm+"/" + varnam+ "/*/v20190401")
     else 
       fdrs   = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+vardnm+"/" + varnam+ "/*/*")
     end if 
     end if 
     nens     = dimsizes(fdrs)

     ike = 0 
     do ie = 0,nens-1,1

      fdr  = fdrs(ie)
      strs = str_split(fdr, "/")

      if(.not.all(ismissing(strs))) then 

       print("working on " + modnam)

       fls  = systemfunc("ls -1 " + fdr + "/*.nc")

       if(.not.all(ismissing(fls))) then 

        f    = addfiles(fls,"r")
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
            odir = outdir + "/" + scenario+"/" + modout  
            system("if ! test -d " + odir +" ; then mkdir -p " + odir + " ; fi")
            enstr     = "en"+sprinti("%02d",ike)
            out_file  = odir+"/"+modout+"."+scenario+"."+enstr+"."+varout+"."+crange+".nc"
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
       delete([/fls/])
     end if 
     delete([/fdr,strs/])
    end do 
    delete([/cpath,fdrs/])
   end do 
 end do 
end
