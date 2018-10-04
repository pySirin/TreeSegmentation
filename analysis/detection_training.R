## Detection network training
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(dplyr)
library(stringr)
library(raster)

testing=F
site="SJER"
year="2018"

if(testing){
  path<-"/Users/ben/Downloads/2018/FullSite/D17/2018_SJER_3/L1/DiscreteLidar/ClassifiedPointCloud/NEON_D17_SJER_DP1_262000_4107000_classified_point_cloud_colorized.laz"
  #path<-"../data/training/NEON_D03_OSBS_DP1_407000_3291000_classified_point_cloud.laz"
  detection_training(path,site,year)
 } else{


  #Lidar dir
  lidar_dir<-"/orange/ewhite/NeonData/SJER/DP1.30003.001/2018/FullSite/D17/2018_SJER_3/L1/DiscreteLidar/ClassifiedPointCloud"
  lidar_files<-list.files(lidar_dir,full.names = T,pattern=".laz")
  #lidar_files<-lidar_files[!str_detect(lidar_files,"colorized")]

  rgb_dir<-"/orange/ewhite/NeonData/SJER/DP3.30010.001/2018/FullSite/D17/2018_SJER_3/L3/Camera/Mosaic/V01"
  rgb_files<-list.files(rgb_dir,pattern=".tif")
  #itcs_path<-"/orange/ewhite/b.weinstein/ITC"

  cl<-makeCluster(32,outfile="")
  registerDoSNOW(cl)

  results<-foreach::foreach(x=1:length(lidar_files),.packages=c("TreeSegmentation","raster"),.errorhandling="pass") %dopar%{

    #check if tile can be processed
    rgb_path<-convert_names(from="lidar",to="rgb",lidar=lidar_files[x],site=site)

    flag<-rgb_path %in% rgb_files

    if(!flag){
      print(paste(lidar_files[x],"Failed Tile Check, can't be read"))
      return("Failed Tile Check - does not exist")
    }
    #check file are almost all edge black.
    try(r<-raster(paste(rgb_dir,rgb_path,sep="/")))

    if(!exists("r")){
      print(paste(lidar_files[x],"Failed Tile Check, can't be read"))
      return("Failed Tile Check, can't be read")
    }

    #check if its black
    if(sum(getValues(r)==0)/length(r) > 0.2){
      print(paste(lidar_files[x],"Failed Tile Check, mostly a blank black edge"))
      return("Failed Tile Check, mostly a blank black edge")
    }

    #Passed checks
    print(paste(lidar_files[x],"Running"))
    detection_training(path=lidar_files[x],site=site,year)
  }
 }
