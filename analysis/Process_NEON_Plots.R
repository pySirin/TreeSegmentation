### Download plots and clip to tile extent

#devtools::install_github("Weecology/Neon-Utilities/neonUtilities",dependencies=F)

library(foreach)

###Download RGB and LIDAR, HyperSpec tiles
#site<-c()
site<-c("TOOL","SRER","PUUM","ONAQ","ORNL","GUAN","CPER","BART","ABBY","DCFS","DSNY","HEAL","JERC","LAJA","LENO","NOGP","RMNP","SOAP","TEAK","TREE","UKFS","UNDE","MOAB","BONA","CLBJ","HARV","KONZ","NIWO","OSBS","SJER","WOOD","UNDE","WREF","JORN","MLBS","ORNL","SCBI","STEI","TALL")

cl<-makeCluster(10)
registerDoSNOW(cl)

foreach(x=1:length(site),.packages=c("neonUtilities","TreeSegmentation","dplyr"),.errorhandling = "pass") %dopar% {

  fold<-paste("/orange/ewhite/NeonData/",site[x],sep="")
  #byPointsAOP(dpID="DP1.30010.001",site=site[x],year="2017",check.size=F, savepath=fold,allSites=F)
  #byPointsAOP(dpID="DP1.30003.001",site=site[x],year="2017",check.size=F, savepath=fold,allSites=F)
  byPointsAOP(dpID="DP1.30006.001",site=site[x],year="2017",check.size=F, savepath=fold,allSites=F)

  ##Cut Tiles
  #crop_rgb_plots(site[x])
  #crop_lidar_plots(site[x])
}
