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

run_dir   = "/lcrc/group/e3sm/ac.forsyth2/E3SMv2/"
out_dir   = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
data_dir  = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
ensnum    = (/"en00","en01","en02","en03","en04"/)
exp_name  = ensnum
exp_name  = "v2.LR.historical"
out_name  = (/"v2.LR.historical"/)
nexps     = dimsizes(exp_name)

ystr      = 1850
yend      = 2014
time_tag  = (/sprinti("%04d01",ystr)+"-"+sprinti("%04d12",yend)/)
ntags     = dimsizes(time_tag)
grid_tag  = "1x1"

;define reons for eof analysis
latS     = -90.  ;negative for southern hemisphere
latN     =  90.  ;negative for southern hemisphere
lonW     =  0.0
lonE     = 360.0

fili    = "./share_var_info_fix.txt"
dstr    = asciiread(fili, -1, "string")
delim   = ","
varList = str_squeeze(str_get_field(dstr, 1, delim))
untList = str_squeeze(str_get_field(dstr, 2, delim))
facList = stringtofloat(str_get_field(dstr, 3, delim))
nvars = dimsizes(varList)

do k  = 0,nexps-1,1
   
  do j = 0,nvars-1,1

   vars   = varList(j)
   varunt = untList(j)
   facmod = facList(j)
   enstr  = ensnum(k) 
   print("working on variable "+ vars)

   fl0  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
   fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+".TS."+time_tag+".nc" 
   if (.not.isfilepresent(fl0)) then
     f1   = addfile(fl1,"r")
     var0 = f1->TS
     var0 = var0 * facmod 
     var0@units = varunt
     var0@_FillValue = -9999.
     var0@notes = "modified: * " + facmod
     var0 = var0@_FillValue

     setfileoption("nc", "Format",  "NetCDF4")
     out_file  = fl0
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
end do 

end
