### Download plots and clip to tile extent

#devtools::install_github("Weecology/Neon-Utilities/neonUtilities",dependencies=F)
library(neonUtilities)
library(TreeSegmentation)
library(dplyr)

###Download RGB and LIDAR tiles
#c("MOAB","BONA","CLBJ","HARV","KONZ","NIWO","OSBS","SJER","WREF","JORN","MLBS","ORNL","SCBI","STEI","TALL",
site<-c("WOOD","UNDE","TOOL","SRER","PUUM","ONAQ","ORNL","GUAN","CPER")
for(x in 1:length(site)){
  fold<-paste("/orange/ewhite/NeonData/",site[x],sep="")
  byPointsAOP(dpID="DP1.30010.001",site=site[x],year="2017",check.size=F, savepath=fold,allSites=F)
  byPointsAOP(dpID="DP1.30003.001",site=site[x],year="2017",check.size=F, savepath=fold,allSites=F)
  ##Cut Tiles
  crop_rgb_plots(site[x])
  crop_lidar_plots(site[x])
}

