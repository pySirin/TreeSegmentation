### Download AOP data tiles in parallel

#devtools::install_github("Weecology/Neon-Utilities/neonUtilities",dependencies=F)

library(neonUtilities)

ParallelFileAOP(dpID = "DP3.30010.001",site = "SJER",year="2018",check.size=F, savepath=fold,cores=5)
ParallelFileAOP(dpID = "DP1.30003.001",site = "SJER",year="2018",check.size=F, savepath=fold,cores=5)
