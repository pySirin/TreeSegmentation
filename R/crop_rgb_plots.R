### Clip RGB Data Based on Neon Plots ###
library(maptools)
library(raster)
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(parallel)
library(rgdal)
library(sf)
library(dplyr)
library(stringr)

crop_rgb_plots<-function(siteID="HARV"){
  #Take the centroid and 10m on either side of the bounding box.

  plots<-st_read("../data/NEONFieldSites/All_NEON_TOS_Plots_V5/All_Neon_TOS_Polygons_V5.shp")
  dat<-read.csv("../data/Terrestrial/field_data.csv")
  site<-dat %>% filter(siteID==siteID) %>% droplevels()
  site_plots<-plots[plots$plotID %in% site$plotID,]

  #Count trees, only keep basePlots
  Trees<-site %>% group_by(plotID) %>% summarize(Trees=n())
  site_trees<-site_plots %>% inner_join(Trees) %>% filter(subtype=="basePlot")

  #get lists of rasters
  inpath<-paste("/orange/ewhite/NeonData/",siteID,"/DP1.30010.001/",sep="")
  fils<-list.files(inpath,full.names = T,pattern=".tif",recursive = T)
  filname<-list.files(inpath,pattern=".tif",recursive = T)

  #grab the first raster for crs
  r<-stack(fils)

  ##TODO specify crs
  site_trees<-st_transform(site_trees,crs=crs(r))

  #projection

  #Crop lidar by plot extent and write to file
  #cl<-makeCluster(10)
  #registerDoSNOW(cl)

  foreach(x=1:nrow(site_trees),.packages=c("TreeSegmentation","sp","raster","sf","stringr"),.errorhandling = "pass") %do% {

    plotid<-site_trees[x,]$plotID
    plotextent<-extent(site_trees[x,])
    #Look for corresponding tile

    #drop summary image
    fils<-fils[!str_detect(fils,"all_5m")]
    #loop through rasters and look for intersections
    for (i in 1:length(fils)){

      #set counter for multiple tiles
      j=1
      #empty vector to hold tiles
      matched_tiles <- vector("list", 10)

      #load raster and check for overlap
      try(r<-stack(fils[[i]]))

      if(!exists("r")){
        paste(fils[[i]],"can't be read, skipping...")
        next
      }

      do_they_intersect<-raster::intersect(extent(r),plotextent)

      #Do they intersect?
      if(is.null(do_they_intersect)){
        next
      } else{
        matched_tiles[[j]]<-r
        j<-j+1

        #do they intersect completely? If so, go to next tile
        if(extent(do_they_intersect)==plotextent){
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
      tile_to_crop<-do.call(mosiac,matched_tiles)
    } else{
      tile_to_crop<-matched_tiles[[1]]
    }

    #Clip matched tile
    e<-as.vector(st_bbox(site_trees[x,]))[c(1, 3, 2, 4)]
    clipped_rgb<-raster::crop(tile_to_crop,e)

    #filename
    cname<-paste("/orange/ewhite/b.weinstein/NEON/",siteID,"/NEONPlots/Camera/L3/",plotid,".tif",sep="")
    print(cname)

    #rescale to
    writeRaster(clipped_rgb,cname,overwrite=T,datatype='INT1U')
    return(cname)
  }
}
