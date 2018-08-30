## Detection network training
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(dplyr)
library(stringr)

testing=F
site="HARV"

if(testing){
  path<-"../data/2017/Lidar/OSBS_006.laz"
  #path<-"../data/training/NEON_D03_OSBS_DP1_407000_3291000_classified_point_cloud.laz"
  detection_training(path)
 } else{


  #Lidar dir
  lidar_dir<-"/orange/ewhite/NeonData/HARV/DP1.30003.001/2017/FullSite/D01/2017_HARV_4/L1/DiscreteLidar/ClassifiedPointCloud"
  lidar_files<-list.files(lidar_dir,full.names = T,pattern=".laz")
  lidar_files<-lidar_files[!str_detect(lidar_files,"colorized")]

  #lidar_dir<-"/orange/ewhite/NeonData/2017_Campaign/D03/OSBS/L1/DiscreteLidar/Classified_point_cloud/"
  rgb_dir<-"/orange/ewhite/NeonData/HARV/DP1.30010.001/2017/FullSite/D01/2017_HARV_4/L3/Camera/Mosaic/V01"
  rgb_files<-list.files(rgb_dir,pattern=".tif")
  #itcs_path<-"/orange/ewhite/b.weinstein/ITC"

  cl<-makeCluster(10)
  registerDoSNOW(cl)

  results<-foreach::foreach(x=1:length(lidar_files),.packages=c("TreeSegmentation"),.errorhandling="pass") %dopar%{

    #check if tile can be processed
    rgb_path<-convert_names(from="lidar",to="rgb",lidar=lidar_files[x],site=site)

    flag<-rgb_path %in% rgb_files

    if(flag){
      detection_training(path=lidar_files[x],site=site)
    } else{
      return("Failed check_tile")
    }
  }
 }
