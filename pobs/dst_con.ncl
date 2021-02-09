  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  cdata=asciiread("/lustre/mapo092/aero_diag/data_rce/aerosol_eval/mahowald_dust/mahowald.dustconc01a",-1, "string")

  lat = stringtofloat(str_get_cols(cdata,61,66))
  lon = stringtofloat(str_get_cols(cdata,68,74))
  hgt = stringtofloat(str_get_cols(cdata,76,80))
  var = stringtofloat(str_get_cols(cdata,51,59))

  lines =  sprintf("%8.2f",lat) + sprintf("%8.2f",lon) +sprintf("%8.2f",hgt)+ sprintf("%8.2f",var)
  asciiwrite("/home/mapo092/work/aerodiag/obs/mahowald_dst_conc_ann.txt",lines)

end
