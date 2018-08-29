library(doSNOW)
library(foreach)
library(TreeSegmentation)

## Classification training

#Testing flag
testing<-F

if(testing){
  #generate_training(lidar = "../data/training/NEON_D03_OSBS_DP1_398000_3280000_classified_point_cloud.laz" ,algorithm = c("silva"),expand=2)
  generate_training(lidar = "../data/2017/Lidar/OSBS_003.laz" ,algorithm = c("silva"),expand=1.1)
} else{

  #lidar data dir
  lidar_dir<-"/orange/ewhite/NeonData/HARV/DP1.30003.001/2017/FullSite/D01/2017_HARV_4/L1/DiscreteLidar/ClassifiedPointCloud"
  #rgb_dir<-"/orange/ewhite/b.weinstein/NEON/D03/OSBS/DP1.30010.001/2017/FullSite/D03/2017_OSBS_3/L3/Camera/Mosaic/V01/"
  #itcs_path<-"/orange/ewhite/b.weinstein/ITC"
  lidar_files<-list.files(lidar_dir,full.names = T,pattern=".laz")

  cl<-makeCluster(20)
  registerDoSNOW(cl)

  results<-foreach::foreach(x=1:length(lidar_files),.packages=c("TreeSegmentation")) %dopar%{

    #check if tile can be processed
    #flag<-check_tile(itcs_path=itcs_path,lidar_path = lidar_files[[x]],rgb_dir=rgb_dir)
    flag<-TRUE

    if(flag){
      generate_training(lidar = lidar_files[[x]] ,algorithm = c("silva"),expand=1)
        } else{
          return("Failed check_tile")
        }
  }
}
