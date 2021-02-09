#!/bin/tcsh 

setenv POST   "/compyfs/zhan391/run_e3sm_cryosphere"
setenv WKROOT "${POST}/diag_package"

setenv COMPARE "Model_vs_Model" #"Model_vs_OBS"

setenv CTRL   "20201027.alpha5_v1p-1.amip.ne30pg2_r05_oECv3.compy"
setenv TEST   "20201102.alpha5_55.amip.ne30pg2_r05_oECv3.compy"
 
setenv CTRL_NAME "v1p-1"
setenv TEST_NAME "alpha5_55"

setenv CPATH "${WKROOT}/data/$CTRL/climo"
setenv TPATH "${WKROOT}/data/$TEST/climo"

############################
# END OF USER MODIFICATION #
############################

setenv CASEDIR "${WKROOT}/work/$TEST-$CTRL"
setenv WWW_NAME "$TEST-$CTRL"

mkdir -p $CASEDIR

cp ${WKROOT}/figs.tar $CASEDIR/.
cd $CASEDIR
tar -xvf ./figs.tar 
rm -f figs.tar
#sed "s/XXXYYY/$TEST/" aerosol.html >a1.html
#sed "s/XXXZZZ/$CTRL/" a1.html >aerosol.html
#rm -f a1.html
cd $WKROOT

cd code
foreach f (lat_hgt.ncl lat_lona.ncl) #(*.ncl)
echo "---------------------------------------------"
echo $f "is running!"
echo "---------------------------------------------"
ncl<$f 
echo ""
echo ""
end

cd $CASEDIR
echo "---------------------------------------------"
echo "Converting Figures"
echo "---------------------------------------------"

foreach f (*)
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

echo ""
echo ""
echo "generate the www link!"
cp -r $WKROOT/code/create_html.ncl .
ncl create_html.ncl
rm -rvf create_html.ncl
echo ""
echo ""

exit 0
