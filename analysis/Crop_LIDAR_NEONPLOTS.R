### Clip Lidar Data Based on ITCS ###
library(maptools)
library(raster)
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(lidR)
library(parallel)
library(rgdal)
library(sf)

plots<-st_read("data/NEONFieldSites/All_NEON_TOS_Plots_V4/All_Neon_TOS_Polygon_V4.shp")
dat<-read.csv("data/Terrestrial/field_data.csv")
OSBS<-dat %>% filter(siteID=="OSBS") %>% droplevels()
OSBS_plots<-plots[plots$plotID %in% OSBS$plotID,]

#Count trees, only keep basePlots
Trees<-OSBS %>% group_by(plotID) %>% summarize(Trees=n())
OSBS_trees<-OSBS_plots %>% inner_join(Trees) %>% filter(subtype=="basePlot")

#Crop lidar by plot extent and write to file
#cores<-detectCores()
cl<-makeCluster(10)
registerDoSNOW(cl)

foreach(x=1:nrow(OSBS_trees),.packages=c("lidR","TreeSegmentation","sp"),.errorhandling = "pass") %dopar% {

  #path_to_tiles<-"/Users/ben/Dropbox/Weecology/NEON/"
  path_to_tiles<-"/orange/ewhite/NeonData/2017_Campaign/D03/OSBS/L1/DiscreteLidar/Classified_point_cloud/"

  #Create raster catalog
  ctg<-catalog(path_to_tiles)

  #create extent polygon
  e<-extent(OSBS_trees[x,])

  extent_polygon<-as(e,"SpatialPolygons")
  extent_polygon<-extent_polygon@polygons[[1]]@Polygons[[1]]

  #clip to extent
  clipped_las<-lasclip(ctg,extent_polygon)

  #if null, return NA
  if(is.null("clipped_las")){
    return(NA)
  }

  #Make canopy model
  canopy_model(clipped_las)

  #filename
  plotid<-OSBS_trees[x,]$plotID
  cname<-paste("/orange/ewhite/b.weinstein/NEON/OSBS/NEONPlots/Lidar/",plotid,".laz",sep="")
  print(cname)
  writeLAS(clipped_las,cname)

  return(cname)
}
