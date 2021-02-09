#!/bin/tcsh 

setenv POST    "/global/cfs/cdirs/e3sm/zhan391"
setenv WKROOT "${POST}/diagnostic_package"

setenv COMPARE "Model_vs_Model" #"Model_vs_OBS"

setenv CTRL   "20201027.alpha5_v1p-1.amip.ne30pg2_r05_oECv3.compy"
setenv TEST   "20201102.alpha5_51.amip.ne30pg2_r05_oECv3.compy"
 
setenv CTRL_NAME "v1p-1"
setenv TEST_NAME "alpha5_51"

setenv CPATH "${WKROOT}/data/$CTRL/climo"
setenv TPATH "${WKROOT}/data/$TEST/climo"

############################
# END OF USER MODIFICATION #
############################

setenv CASEDIR "${WKROOT}/work/$TEST-$CTRL"

mkdir -p $CASEDIR

cp ${WKROOT}/figs.tar $CASEDIR/.
cd $CASEDIR
tar -xvf ./figs.tar 
rm -f figs.tar
sed "s/XXXYYY/$TEST/" aerosol.html >a1.html
sed "s/XXXZZZ/$CTRL/" a1.html >aerosol.html
rm -f a1.html
cd $WKROOT

cd code
foreach f (lat_lon.ncl lat_lona.ncl) #(eof_hgt.ncl eof_sfc.ncl lat_hgt.ncl) #(*.ncl)
echo "---------------------------------------------"
echo $f "is running!"
echo "---------------------------------------------"
ncl<$f 
echo ""
echo ""
end

exit

cd $CASEDIR
echo "---------------------------------------------"
echo "Converting Figures"
echo "---------------------------------------------"

foreach f (set*)
  cd $f

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

  cd ..
end

exit 0
