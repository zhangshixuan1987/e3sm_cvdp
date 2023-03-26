;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This script used to generate SST and Seaice ensemble forcing from CMIP6 scenario mip;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "./function.ncl"

begin

  exps       = "r1i1p1f1"
  outdir     = "/global/cscratch1/sd/zhan391/DARPA_project/cmip6_forcing_" + exps
  topdir     = "/global/cfs/projectdirs/m3522/cmip6/CMIP6"

  cmipnams   = (/"CMIP","ScenarioMIP"/)
  ncmp       = dimsizes(cmipnams)
  
 ;get CMIP6 model name
  model_excl = (/""/)
  model_dirs = systemfunc("cd " + topdir+ "/" + cmipnams(1)+"; ls -d *")  
  do i = 0,dimsizes(model_dirs)-1
    do j = 0,dimsizes(model_excl)-1
      if(model_dirs(i).eq.model_excl(j)) then 
        model_dirs(i) = "xxxx"
      end if 
    end do 
  end do
  indxx      = ind(model_dirs.ne."xxxx")
  model_name = model_dirs(indxx)
  nmodel     = dimsizes(model_name)
  delete([/model_dirs,indxx/])
  print(model_name)

  scenarios  = (/"ssp245","ssp585"/)
  nsce       = dimsizes(scenarios)

  cmip_vnam  = (/"siconc"/)
  e3sm_vnam  = (/"ice_cov"/)
  nvars      = dimsizes(cmip_vnam)

 ;time range for climo forcing 
  csym           = 199101
  ceym           = 201012
  fsym           = 204101
  feym           = 206012
  nyrs           = feym/100 - fsym/100 + 1
  nmon           = nyrs * 12

  crange         = csym/100 + "-" + ceym/100
  frange         = fsym/100 + "-" + feym/100

  do is = 0,nsce-1,1

   do im = 0,nmodel-1,1

    do iv = 0,nvars-1,1

     varnam   = cmip_vnam(iv)
     varout   = e3sm_vnam(iv)
     scenario = scenarios(is) 
     modnam   = model_name(im)

     cpath0   = topdir+"/"+cmipnams(0)+"/" + modnam
     fdrs0    = systemfunc("ls -d " + cpath0 + "/*/historical/"+exps+"/SImon/" + varnam+ "/*/*")
     nens0    = dimsizes(fdrs0)

     cpath    = topdir+"/"+cmipnams(1)+"/" + modnam 
     fdrs     = systemfunc("ls -d " + cpath + "/*/"+scenario+"/"+exps+"/SImon/" + varnam+ "/*/*")
     nens     = dimsizes(fdrs)

     ike = 0 
     do ie = 0,nens-1,1

      fdr1      = fdrs(ie)
      strs0     = str_split(fdr1, "/")
      if (modnam.eq."DKRZ") then 
         strs0(7) = "MPI-M"
      end if 

      if(.not.all(ismissing(strs0))) then 

       strs0(6)  = cmipnams(0) 
       strs0(9)  = "historical" 
       fdr0      = "/"+str_join(strs0,"/")

       fls0  = systemfunc("ls -1 " + fdr0 + "/*.nc")
       if(.not.isfilepresent(fls0(0))) then
         delete(fls0)
         strs0(14) = ""
         fdr0      = "/"+str_join(strs0,"/") 
         tmpd0     = systemfunc("cd " + fdr0 + ";ls -d *")
         strs0(14) = tmpd0(0)
         fdr0      = "/"+str_join(strs0,"/")
         fls0      = systemfunc("ls -1 " + fdr0 + "/*.nc")
         delete([/tmpd0/])
       end if 
       fls1  = systemfunc("ls -1 " + fdr1 + "/*.nc")
     
       print(fls0)
       print(fls1)

       if(.not.all(ismissing(fls1)).and..not.all(ismissing(fls0))) then

        f0    = addfiles(fls0,"r")
        f1    = addfiles(fls1,"r")

        yymm0 = cd_calendar(f0[:]->time, 1)
        yymm1 = cd_calendar(f1[:]->time, 1)
        indp  = ind(yymm0.ge.csym.and.yymm0.le.ceym)
        indf  = ind(yymm1.ge.fsym.and.yymm1.le.feym)
       ;print(yymm0(indp) + " " + yymm1(indf))
       ;exit

        if(num(.not.ismissing(indp)).eq.nmon.and.num(.not.ismissing(indf)).eq.nmon) then 

          dimx = dimsizes(f1[:]->$varnam$) 
          if(dimsizes(dimx).eq.2) then 
            sst0  = f0[:]->$varnam$(indp,:)
            sst1  = f1[:]->$varnam$(indf,:)
           ;calculate monthly climatology
            tmp0      = reshape(sst0,(/nmon,dimx(1),1/))
            tmp1      = reshape(sst1,(/nmon,dimx(1),1/))
            tmp0!0    = "time"
            tmp1!0    = "time"
            tmp0!1    = "cells"
            tmp1!1    = "cells"
            tmp0!2    = "dum"
            tmp1!2    = "dum"
            tmp0&time = sst0&time
            tmp1&time = sst1&time
            xtmp0     = clmMonTLL(tmp0)
            xtmp1     = clmMonTLL(tmp1)
            sstm0     = xtmp0(:,:,0)
            sstm1     = xtmp1(:,:,0)
           ;calculate differences between future and current 
            dsst      = sstm0 ;sst0(0:11,:)
            dsst      = (/sstm1-sstm0/)
            dsst@long_name = "sst difference between " + frange + " and " + crange
            delete([/sst0,sst1,tmp0,tmp1,xtmp0,xtmp1/])
          else 
            sst0      = f0[:]->$varnam$(indp,:,:)
            sst1      = f1[:]->$varnam$(indf,:,:)
           ;calculate monthly climatology
            sstm0     = clmMonTLL(sst0)
            sstm1     = clmMonTLL(sst1)
           ;calculate differences between future and current
            dsst      = sstm0 
            dsst      = (/sstm1-sstm0/)
            dsst@long_name = "sst difference between " + frange + " and " + crange
            delete([/sst0,sst1/])
          end if 
 
          ;;regrid the data to target grid 
          dstFileName = "./sst_ice_CMIP6_DECK_E3SM_1x1_c20180213.nc" 
          srcFileName = fls1(0)
          InterpMethod= "bilinear" ;"conserve" 
          voc        = regrid_to_reference_grid(sstm0,modnam,InterpMethod,srcFileName,dstFileName)
          vof        = regrid_to_reference_grid(sstm1,modnam,InterpMethod,srcFileName,dstFileName)
          vod        = regrid_to_reference_grid(dsst,modnam,InterpMethod,srcFileName,dstFileName)

         ;strs  = str_split(fdrs(ie), "/")
         ;print(strs)
         ;exit
         ;printVarSummary(dsst)
         ;printVarSummary(vout)
          if(.not.all(ismissing(vod))) then 
            odir = outdir + "/" + "out" +"/" + varout+"_"+scenario  
            system("if ! test -d " + odir +" ; then mkdir " + odir + " ; fi")
            enstr     = "en"+sprinti("%02d",ike)
            out_file  = odir+"/"+modnam+"."+enstr+"."+varout+"."+frange+"."+scenario+".nc"
            setfileoption("nc", "Format",  "NetCDF4")
            system("rm " + out_file)
            fout = addfile(out_file,"cw")
            vonm = "d"+varout
            fout->$vonm$  = vod
            vonm = "c"+varout 
            fout->$vonm$  = voc
            vonm = "f"+varout
            fout->$vonm$  = vof
            delete([/enstr,vonm,fout/])
            ike = ike + 1
           end if
           delete([/dimx,f0,f1,voc,vof,vod,sstm0,sstm1,dsst,srcFileName,dstFileName/])
        end if  
        delete([/yymm0,yymm1,indp,indf/])
       end if 
       delete([/fdr0,fls0,fls1/])
     end if 
     delete([/fdr1,strs0/])
    end do 
    delete([/cpath0,cpath,fdrs0,fdrs/])
   end do 
  end do 
end do 
end
