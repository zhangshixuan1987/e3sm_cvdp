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
  scenarios  = (/"ssp245","ssp585"/)
  nsce       = dimsizes(scenarios)

  e3sm_vnam  = (/"SST_cpl","ice_cov"/)
  nvars      = dimsizes(e3sm_vnam)
  trange     = "2041-2060" 
  month      = ispan(1,12,1)
  nmons      = dimsizes(month)

  do is = 0,nsce-1,1

    scenario = scenarios(is)
    outfil   = outdir + "/out/CMIP6_delta_forcing_"+scenario+".nc"

    system("rm -rvf " + outfil)
    fout     = addfile(outfil,"c")

    do iv = 0,nvars-1,1

     varnam   = e3sm_vnam(iv) 
     datdir   = outdir + "/" + "out" +"/" + varnam+"_"+scenario

     fls      = systemfunc("cd "+ datdir+";ls *.nc") 
     stmp0    = str_split_csv(fls,".",0)
     fmlist   = stmp0(:,0)
     models   = get_unique_values(fmlist)
     nmods    = dimsizes(models)

     vf0      = varnam
     vf1      = varnam+"_prediddle"

     ;generate ensemble mean forcing 
     do im = 0,nmods-1,1

       indmm = ind(fmlist.eq.models(im))
       flx  = datdir+"/"+fls(indmm) 
       fin  = addfiles(flx,"r") 
       ListSetType (fin, "join")       

       vonm = "d"+varnam
       if(dimsizes(dimsizes(fin[:]->$vonm$)).ge.4) then 
         tmp = dim_avg_n_Wrap(fin[:]->$vonm$,0) 
       else
         tmp = fin[:]->$vonm$ 
       end if 
       delete([/indmm,flx,fin/])
       ;printVarSummary(tmp) 

       if(im.eq.0) then 
         dimx = dimsizes(tmp)
         vdat = new((/nmods,dimx(0),dimx(1),dimx(2)/),typeof(tmp))
         vdat = 1e+20
         vdat@_FillValue = 1e+20
         vdat!0     = "mmes"
         vdat!1     = "month"
         vdat!2     = "lat"
         vdat!3     = "lon"
         vdat&month = tmp&month
         vdat&lat   = tmp&lat
         vdat&lon   = tmp&lon
       end if 
       tmp = where(ismissing(tmp),vdat@_FillValue,tmp)
       tmp@_FillValue = vdat@_FillValue 
       if(varnam.eq."ice_cov") then 
         if(tmp@units.eq."%") then 
            tmp = tmp / 100.0 ; convert percent to fraction
         else if(max(abs(tmp)).gt.1.0) then 
            tmp = tmp / 100.0 ; convert percent to fraction
         end if 
         end if 
       end if 
       vdat(im,:,:,:) = (/tmp/) 
       delete([/tmp/])
     end do 
     printMinMax(vdat,False)
     venm = dim_avg_n_Wrap(vdat,0)
     printMinMax(venm,False)
     ;if(varnam.eq."ice_cov") then
     ;  exit
     ;end if 

     ;save the delta forcing 
     fout->$vf0$ = venm 
     delete([/stmp0,fmlist,models,fls,datdir/])
     delete([/venm,vdat/])
  end do 
  delete([/vf0,vf1/])

end do 
end
