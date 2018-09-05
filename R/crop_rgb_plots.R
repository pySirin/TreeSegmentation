### Clip RGB Data Based on Neon Plots ###
library(maptools)
library(raster)
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(parallel)
library(rgdal)
library(dplyr)
library(stringr)

crop_rgb_plots<-function(siteID="HARV"){
  #Take the centroid and 10m on either side of the bounding box.

  plots<-sf::st_read("../data/NEONFieldSites/All_NEON_TOS_Plots_V5/All_Neon_TOS_Polygons_V5.shp")
  dat<-read.csv("../data/Terrestrial/field_data.csv")
  site<-dat %>% filter(siteID==siteID) %>% droplevels()
  site_plots<-plots[plots$plotID %in% site$plotID,]


  #get lists of rasters
  inpath<-paste("/orange/ewhite/NeonData/",siteID,"/DP1.30010.001/",sep="")
  fils<-list.files(inpath,full.names = T,pattern=".tif",recursive = T)
  filname<-list.files(inpath,pattern=".tif",recursive = T)
  #drop summary image
  fils<-fils[!stringr::str_detect(fils,"all_5m")]

  #grab the first raster for crs
  r<-raster::stack(fils[[1]])
  #Project
  site_plots<-sf::st_transform(site_plots,crs=raster::projection(r))

  #Crop lidar by plot extent and write to file
  #cl<-makeCluster(10)
  #registerDoSNOW(cl)

  for(x in 1:nrow(site_trees)){

    plotid<-site_plots[x,]$plotID
    plotextent<-raster::extent(site_plots[x,])
    #Look for corresponding tile


    #loop through rasters and look for intersections
    for (i in 1:length(fils)){

      #set counter for multiple tiles
      j=1
      #empty vector to hold tiles
      matched_tiles <- vector("list", 10)

      #load raster and check for overlap
      try(r<-raster::stack(fils[[i]]))

      if(!exists("r")){
        paste(fils[[i]],"can't be read, skipping...")
        next
      }

      do_they_intersect<-raster::intersect(raster::extent(r),plotextent)

      #Do they intersect?
      if(is.null(do_they_intersect)){
        next
      } else{
        matched_tiles[[j]]<-r
        j<-j+1

        #do they intersect completely? If so, go to next tile
        if(raster::extent(do_they_intersect)==plotextent){
          break
        }
      }
    }

    #bind together tiles if matching more than one tile
    matched_tiles<-matched_tiles[!sapply(matched_tiles,is.null)]

    #If no tile matches, exit.
    if(length(matched_tiles)==0){
      return(paste("No matches ",plotid))
    }

    if(length(matched_tiles)>1){
      tile_to_crop<-do.call(raster::mosiac,matched_tiles)
    } else{
      tile_to_crop<-matched_tiles[[1]]
    }

    #Clip matched tile
    e<-as.vector(sf::st_bbox(site_trees[x,]))[c(1, 3, 2, 4)]
    clipped_rgb<-raster::crop(tile_to_crop,e)

    #Create directory if needed
    fold<-paste("/orange/ewhite/b.weinstein/NEON/",siteID,"/NEONPlots/Camera/L3/",sep="")
    if(!dir.exists(fold)){
      dir.create(fold)
    }

    #construct filename
    cname<-paste(fold,plotid,".tif",sep="")
    print(cname)

    #rescale to
    raster::writeRaster(clipped_rgb,cname,overwrite=T,datatype='INT1U')
    return(cname)
  }
}