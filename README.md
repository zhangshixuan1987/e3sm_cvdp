# E3SM Climate Varibility Diagnostics 
This diagnostic package is an extension of NCAR's CVDP (https://github.com/NCAR/CVDP-ncl), which is developed to facillate the tracking and model intercomparison of large-scale climate varibilities in E3SM climate simulations. The enhancements incldued 
in this package include 
1. New diagnostics for Hadley cell, polar Jet stream and ENSO teleconections 
2. New climate indices for the Amuden Sea Low (ASL) diagnostics 
3. the regression on selected 
Atmospheric diagnostics package used to facillitate the analysis of the large-scale circlulation 
over the Southern Polar region (NCL). 

# The struction of the diagnostic package:
1. ncl_code_sig: the directory contains ncl scripts for this diagnostic package package. 

2. ncl_code_ens: the same as ncl_code_sig, but with modifications to generate figures for large ensemble simulations 

3. run_script: the directory contains sample run scripts to process data, generate namelist and run diagnostic package, 

4. pobs: the directory saves the real observational data to be used by the diagnostic script in this package.
         this is currently underdevelopment 
  
# Planned extensions
1. Weather regime analysis, including Atmospheric Rivers, Blockings, Extratropical cyclones and polar vortex.
2. AMOC diagnostics 

