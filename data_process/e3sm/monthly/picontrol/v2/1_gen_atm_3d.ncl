;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;This script used to calculate and plot the zonal mean variables from CAM;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;The terms zonal and meridional are used to describe directions on a globe;;;;;;;
;;;;;;;Zonal means "along a latitudinal circle" or "in the west–east direction";;;;;;;;
;;;;;;;while meridional means "along a longitudinal circle" (a.k.a. meridian) ;;;;;;;;;
;;;;;;;or "in the north–south direction" [2];;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

run_dir   = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/zstash"
out_dir   = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
data_dir  = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
ensnum    = (/"en00"/)
exp_name  = (/"v2.LR.piControl"/)
out_name  = (/"v2.LR.piControl"/)
nexps     = dimsizes(exp_name)

ystr      = 1
yend      = 350
time_tag  = (/sprinti("%04d01",ystr)+"-"+sprinti("%04d12",yend)/)
ntags     = dimsizes(time_tag)
grid_tag  = "1x1"

nsegs    = (yend - ystr + 1)/50
if(((nsegs+1)*50+ystr).gt.yend) then
  nsegs  = nsegs+1
end if
segs_tag = new(nsegs,string)
do i = 0,nsegs-1
 yst = i*50+ystr
 yed = (i+1)*50+ystr-1
 if(yst.lt.ystr) then
   yst = ystr
 end if
 if(yed.gt.yend) then
   yed = yend
 end if
 segs_tag(i) = (/sprinti("%04d01",yst)+"-"+sprinti("%04d12",yed)/)
end do
;print(segs_tag)

;define reons for eof analysis
latS     = -90.  ;negative for southern hemisphere
latN     =  90.  ;negative for southern hemisphere
lonW     =  0.0
lonE     = 360.0

fili    = "./share_var_info_3d.txt"
dstr    = asciiread(fili, -1, "string")
delim   = ","
varList = str_squeeze(str_get_field(dstr, 1, delim))
untList = str_squeeze(str_get_field(dstr, 2, delim))
facList = stringtofloat(str_get_field(dstr, 3, delim))
nvars = dimsizes(varList)

;reference pressure level;;;;
fera5      = "/lcrc/group/acme/ac.szhang/acme_scratch/e3sm_cvdp/pobs/reference_pressure.nc"
fin        = addfile (fera5,"r")
plev       = tofloat(fin->lev({50:1000}))
plev!0     = "lev"
plev&lev   = plev
plev@units = "hPa"
delete([/fera5,fin/])

do k  = 0,nexps-1,1
   
  do j = 0,nvars-1,1

   vars   = varList(j)
   varunt = untList(j)
   facmod = facList(j)
   enstr  = ensnum(k) 
   print("working on variable "+ vars)

   do it = 0,nsegs-1,1 ; loop each slice data, then combine to the required period 

    fl0      = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
    fl1      = data_dir+"/"+exp_name(k)+"/ATM_3D/"+exp_name(k)+"."+enstr+"."+vars+"."+segs_tag(it)+".nc"
    l_output = True 
    if (isfilepresent(fl0)) then
       l_output = False ; file already generated 
    else if (isfilepresent(fl1)) then 
      f1   = addfile(fl1,"r")
      if(isfilevar(f1,vars)) then 
        var0 = f1->$vars$
        if(.not.isatt(var0,"notes")) then
          var0 = var0 * facmod 
          var0@units = varunt
          var0@_FillValue = -9999.
          var0@notes = "modified: * " + facmod
        else 
          l_output = False 
        end if 
      end if 
    else if (vars.eq."Z500") then
      v3d  = "Z3"
      fl1  = data_dir+"/"+exp_name(k)+"/ATM_3D/"+exp_name(k)+"."+enstr+"."+v3d+"."+segs_tag(it)+".nc"
      f1   = addfile(fl1,"r")
      xtmp = vinth2p(f1->Z3,f1->hyam,f1->hybm,500.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(:,0,{latS:latN},{lonW:lonE})
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v3d,fl1,f1,xtmp/])
    else if (vars.eq."T850") then
      v3d  = "T"
      fl1  = data_dir+"/"+exp_name(k)+"/ATM_3D/"+exp_name(k)+"."+enstr+"."+v3d+"."+segs_tag(it)+".nc"
      f1   = addfile(fl1,"r")
      xtmp = vinth2p(f1->T,f1->hyam,f1->hybm,850.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(:,0,{latS:latN},{lonW:lonE})
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v3d,fl1,f1,xtmp/])
    else if (vars.eq."U850") then
      v3d  = "U"
      fl1  = data_dir+"/"+exp_name(k)+"/ATM_3D/"+exp_name(k)+"."+enstr+"."+v3d+"."+segs_tag(it)+".nc"
      f1   = addfile(fl1,"r")
      xtmp = vinth2p(f1->U,f1->hyam,f1->hybm,850.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(:,0,{latS:latN},{lonW:lonE})
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v3d,fl1,f1,xtmp/])
    else if (vars.eq."V850") then
      v3d  = "V"
      fl1  = data_dir+"/"+exp_name(k)+"/ATM_3D/"+exp_name(k)+"."+enstr+"."+v3d+"."+segs_tag(it)+".nc"
      f1   = addfile(fl1,"r")
      xtmp = vinth2p(f1->V,f1->hyam,f1->hybm,850.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(:,0,{latS:latN},{lonW:lonE})
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v3d,fl1,f1,xtmp/])
    else if (vars.eq."U200") then
      v3d  = "U"
      fl1  = data_dir+"/"+exp_name(k)+"/ATM_3D/"+exp_name(k)+"."+enstr+"."+v3d+"."+segs_tag(it)+".nc"
      f1   = addfile(fl1,"r")
      xtmp = vinth2p(f1->U,f1->hyam,f1->hybm,200.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(:,0,{latS:latN},{lonW:lonE})
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v3d,fl1,f1,xtmp/])
    else if (vars.eq."V200") then
      v3d  = "V"
      fl1  = data_dir+"/"+exp_name(k)+"/ATM_3D/"+exp_name(k)+"."+enstr+"."+v3d+"."+segs_tag(it)+".nc"
      f1   = addfile(fl1,"r")
      xtmp = vinth2p(f1->V,f1->hyam,f1->hybm,200.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(:,0,{latS:latN},{lonW:lonE})
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v3d,fl1,f1,xtmp/])
    else if (vars.eq."S10") then
      v3d  = (/"U","V"/)
      do iv = 0,dimsizes(v3d)-1
        vin  = v3d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/ATM_3D/"+exp_name(k)+"."+enstr+"."+vin+"."+segs_tag(it)+".nc"
        f1   = addfile(fl1,"r")
        nlev = dimsizes(f1->lev)
        if(iv.eq.0) then
           var0 = f1->$vin$(:,nlev-1,:,:)
           var0 = f1->$vin$(:,nlev-1,:,:) * f1->$vin$(:,nlev-1,:,:)
        else
          var0 = var0 + f1->$vin$(:,nlev-1,:,:) * f1->$vin$(:,nlev-1,:,:) 
        end if
      end do
      var0 = sqrt(var0)
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v3d,fl1,f1/])
    else if (vars.eq."U10") then
      v3d  = (/"U"/)
      fl1  = data_dir+"/"+exp_name(k)+"/ATM_3D/"+exp_name(k)+"."+enstr+"."+v3d+"."+segs_tag(it)+".nc"
      f1   = addfile(fl1,"r")
      nlev = dimsizes(f1->lev)
      var0 = f1->$v3d$(:,nlev-1,:,:)
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v3d,fl1,f1,nlev/])
    else if (vars.eq."V10") then
      v3d  = (/"V"/)
      fl1  = data_dir+"/"+exp_name(k)+"/ATM_3D/"+exp_name(k)+"."+enstr+"."+v3d+"."+segs_tag(it)+".nc"
      f1   = addfile(fl1,"r")
      nlev = dimsizes(f1->lev)
      var0 = f1->$v3d$(:,nlev-1,:,:)
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v3d,fl1,f1,nlev/])
    else if (vars.eq."SF") then
      v3d  = (/"V"/)
      fl1  = data_dir+"/"+exp_name(k)+"/ATM_3D/"+exp_name(k)+"."+enstr+"."+v3d+"."+segs_tag(it)+".nc"
      f1   = addfile(fl1,"r")
      lev           = tofloat(plev({50:1000}))
      lev           = lev * 100.0
      lev!0         = "lev"
      lev&lev       = lev
      lev@units     = "Pa"
      vmx           = vinth2p(f1->V,f1->hyam,f1->hybm,plev({50:1000}),f1->PS,1,f1->P0/100.0,1,False)
      vmi           = vmx(:,{50:1000},:,:)
      psm           = f1->PS
      vmi&lev       = lev
      vmi&lev@units = "Pa"
      if(psm@units.eq."hPa") then
        psm = psm * 100.0
        psm@units = "Pa"
      end if
      var0 = zonal_mpsi_Wrap(vmi,vmi&lat,lev,psm)
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v3d,fl1,f1,lev,vmx,vmi,psm/])
    end if 
    end if
    end if
    end if 
    end if 
    end if 

    end if 
    end if 
    end if 
    end if
    end if
    end if 

    if (l_output) then 
      setfileoption("nc", "Format",  "NetCDF4")
      out_file  = out_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+segs_tag(it)+".nc"
      system("rm " + out_file)
      fout = addfile(out_file,"cw")
      vs1 = vars
      fout->$vs1$  = var0
      delete([/fout/]) 
    end if 
    if(isvar("var0"))
      delete([/var0/])
    end if 
   end do 

  ;combine the file 
   out_file = out_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
   if (.not.isfilepresent(out_file)) then
     sig_file = new(nsegs,string)
     do it = 0,nsegs-1,1
       sig_file(it) = out_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+segs_tag(it)+".nc"
     end do
     ff = addfiles(sig_file,"r")
     time = ff[:]->time 
     time = time - 1

     year          = cd_calendar(time, 1)
     indy          = ind(year.ge.toint(sprinti("%04d01",ystr)).and.year.le.toint(sprinti("%04d12",yend)))
     obstime       = time(indy)
     obstime@units = time@units
     vdat          = ff[:]->$vars$(indy,:,:)
     out_file      = out_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
     system("rm " + out_file)
     fout          = addfile(out_file,"cw")
     fout->$vars$  = vdat
     delete([/fout,year,time,indy,obstime,vdat/])
     if (isfilepresent(out_file)) then
       do it = 0,nsegs-1,1
         system ("rm -rvf " + sig_file(it))
       end do
     end if
   end if 

  end do 
end do 

end
