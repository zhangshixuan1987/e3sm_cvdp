#!/bin/csh 
#Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=1
#SBATCH  --time=2:00:00
#SBATCH  --exclusive
#SBATCH -A condo
#SBATCH -p acme-small

##modules required (Argon machine) to load ncl 
#module load gcc/7.1.0-4bgguyp
#module load netcdf/4.6.1-6z2nuae
#module load ncl 
set script_name = ncl
set script_path = /soft/bebop/ncl/6.6.2/bin/
set path        = ( $script_path  $path )
set command     = $script_path/$script_name

setenv POST            "/lcrc/group/acme/ac.szhang/acme_scratch"
setenv WKROOT          "${POST}/polar_diag"
setenv DATA_ROOT       "/lcrc/group/acme/ac.szhang/acme_scratch/data"
setenv COMPARE         "Model_vs_OBS"

############################################################
#Set up the case name and the model output directories after
#the post-processing. The CTRL and TEST are the model run 
#case name, while the CTRL_NAME and TEST_NAME are the 
#short name for the figure string defined by users
###########################################################
setenv CTRL   "ERA_20C"
setenv TEST   "v2.LR.historical_0101"

##short name used for figure captions### 
setenv CNAME  "ERA20C"
setenv TNAME  "v2_LR_HIST"

##directory for the pos-processed data 
setenv CPATH  "${DATA_ROOT}/polar_diag"
setenv TPATH  "${DATA_ROOT}/polar_diag"
ls $CPATH
ls $TPATH


setenv CTTAG  "1981-2010" #climatological period for observations
setenv TTTAG  "1985-2014" #climatological period for model 

setenv DOUT_NAME "${TNAME}_${TTTAG}__vs__${CNAME}_${CTTAG}"

############################
#flag to control if significance test should be performed 
#for the bias plot 
############################
setenv DIFFERENCE_TEST  "TRUE"

###########################################################
#flag to control if significance test should be performed 
#for the bias plot 
###########################################################
setenv REGRESSION_TEST  "TRUE"

###########################################################
#flag to control if the time series from eof anaysis etc. 
#should be saved for the regression plot 
###########################################################
setenv L_SAVE_EOF_PC     "TRUE"
setenv L_SAVE_JET_INDEX  "TRUE"

###########################################################
#Weighting file used for the regridding required by the 
#scripts for jet location and strength, you may not need to 
#change the information below this line 
###########################################################
setenv DIAG_DATA_ROOT  "$WKROOT/data/${DOUT_NAME}"
if ( ! -d $DIAG_DATA_ROOT ) then
 mkdir -p $DIAG_DATA_ROOT
endif
setenv REF_PRE_LEV     "$WKROOT/data/pres_lev.txt"
setenv JET_RGDWGT_FILE "$WKROOT/data/1deg_to_0.1deg.nc"

############################
# END OF USER MODIFICATION #
############################
setenv CASEDIR "${WKROOT}/work/${DOUT_NAME}"

mkdir -p $CASEDIR

cp ${WKROOT}/figs.tar $CASEDIR/.
cd $CASEDIR
tar -xvf ./figs.tar 
rm -f figs.tar
cd $WKROOT

cd code

#first set of plots, the separation only used to speedup
#the post-processing 
foreach f ( lat_hgt_glb.ncl               \
            lon_hgt_glb.ncl               \
            lat_lon_glb.ncl               \
            lat_lon_sh_polar_sreg.ncl     \
            lat_lon_sh_polar_lreg.ncl     \
            lat_lon_plev_glb.ncl          \
            lat_lon_plev_sh_polar_lreg.ncl\
            lat_lon_plev_sh_polar_sreg.ncl\
            lat_lon_vec_sh_polar_sreg.ncl \
            lat_lon_vec_sh_polar_lreg.ncl \
            lat_lon_vec_glb.ncl )
echo "---------------------------------------------"
echo $f "is running!"
echo "---------------------------------------------"
$command<$f &
echo ""
echo ""
end

wait 

#second set: the eof analysis related figures 
foreach f ( eof_geopotential_hgt.ncl   \
            eof_surface_var.ncl        \
            polar_vortex_eof.ncl       \
            enso_index_global.ncl      \
            jet_index_zonal_wind.ncl   \
            sam_index_monthly.ncl      \
            jet_index_stress.ncl )
echo "---------------------------------------------"
echo $f "is running!"
echo "---------------------------------------------"
$command<$f &
echo ""
echo ""
end

#wait 

#third sets: the regression analysis 
#note: the data from second set are required to
#run this set of scripts 
foreach f ( eof_psl_regression_sfc.ncl     \
            enso_regression_sfc.ncl        \
            eof_z500_regression_sfc.ncl    \
            jet_tauind_regression_sfc.ncl  \
            jet_u850ind_regression_sfc.ncl \
            lat_hgt_hadley_cell.ncl)
echo "---------------------------------------------"
echo $f "is running!"
echo "---------------------------------------------"
$command<$f & 
echo ""
echo ""
end
#wait

##convert the figures and generate the link page 
cd $CASEDIR
echo "---------------------------------------------"
echo "Converting Figures"
echo "---------------------------------------------"

rm -rvf index.html

foreach f (*)
  cd $f

  ##remove the .png file if exist 
  rm -f ./*.png

  set line = `ls -trl | grep .eps | wc -l`

  if  ( $line != 0 ) then
      foreach ff (*.eps)
        convert -density 300 -trim -scale 100% $ff $ff.png
      end

      foreach ff (*.png)
        set base = `basename $ff .eps.png`
        mv $ff $base.png
      end
      rm -f ./*.eps
  endif

  echo ""
  echo ""
  echo "generate the www link!"
  setenv WWWDIR  "${DOUT_NAME}/$f"
  ls *.png >> list
  cp -r $WKROOT/code/create_html.ncl .
  $command<create_html.ncl
  rm -rvf create_html.ncl
  rm -rvf list
  echo ""
  echo ""

  cd ..

end

exit 0
