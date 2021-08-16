;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;this scripts save the setups for the color levels for the cross plot ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   facsfm         = 1e-9
   leftstring     = "Meridional mean stream fuction (10~S~9~N~ kg s~S~-1~N~)"
   XBValues       = ispan(toint(lonW),toint(lonE),60)
   XBLabels       = (/"0","60W","120W","180","60E","120E","0"/)
   XBMinorValues  = ispan(toint(lonW),toint(lonE),60)
   YLValues       = (/ 1000, 850, 700, 500, 300, 200, 100, 10, 1/)

   Contour_color_bar = "MPL_PRGn"
   Diff_corlor_bar   = "GreenMagenta16"

   s1                = (/-200,-100,-50,-30,-10,-1,0,1,10,30,50,100,200/)
   s2                = (/-10.,-8.0,-5.,-3.,-1.,0,1.,3.,5.,8.,10./)
   s3                = (/-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50/)

