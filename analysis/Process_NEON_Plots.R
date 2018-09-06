### Download plots and clip to tile extent

#devtools::install_github("Weecology/Neon-Utilities/neonUtilities",dependencies=F)
library(neonUtilities)
library(TreeSegmentation)
library(dplyr)

###Download tiles
#site="HARV"
#fold<-paste("/orange/ewhite/NeonData/",site,sep="")
#byPointsAOP(dpID="DP1.30010.001",site=site,year="2017",check.size=F, savepath=fold,allSites=F)
#byPointsAOP(dpID="DP1.30003.001",site=site,year="2017",check.size=F, savepath=fold,allSites=F)

##Cut Tiles
crop_rgb_plots(site)
crop_lidar_plots(site)
