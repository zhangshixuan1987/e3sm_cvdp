  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  lat=asciiread("/lustre/mapo092/plot_aeronet/data/lat.dat",-1,"float")
  lon=asciiread("/lustre/mapo092/plot_aeronet/data/lon.dat",-1,"float")
  aod=asciiread("/lustre/mapo092/plot_aeronet/data/aod.obs.dat",-1,"float")
  ssa=asciiread("/lustre/mapo092/plot_aeronet/data/ssa.obs.dat",-1,"float")

  lata=aod
  lona=aod
  moma=aod
  mom=floattoint(moma)
  aaa=ispan(1,12,1)
  do i=0,dimsizes(lat)-1
   lata(i*12:i*12+11)=lat(i)
   lona(i*12:i*12+11)=lon(i)
   mom(i*12:i*12+11) =aaa
  end do

  lines =  sprinti("%6.0i",mom)+sprintf("%13.3f",lata) + sprintf("%13.3f",lona) +sprintf("%13.3f",aod)+ sprintf("%13.3f",ssa)
  asciiwrite("/home/mapo092/work/aerodiag/obs/aeronet.txt",lines)

end
