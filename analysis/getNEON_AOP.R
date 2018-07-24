#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = FALSE)


library(devtools)
library(neonUtilities)

print(args)

#neon product id
prd = args[7]
#neon site to download the product for
ste = args[8]
#year to download
yr = args[9]
byFileAOP(prd, site = ste, year = yr, check.size=F, savepath = paste("/orange/ewhite/NeonData/",  ste, sep=""))
