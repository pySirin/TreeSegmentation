##Crop NEON plots###
library(sf)
library(raster)

plots<-st_read("data/NEONFieldSites/All_NEON_TOS_Plots_V4/All_Neon_TOS_Polygon_V4.shp")

dat<-read.csv("data/Terrestrial/field_data.csv")

OSBS<-dat %>% filter(siteID=="OSBS") %>% droplevels()

OSBS_plots<-plots[plots$plotID %in% OSBS$plotID,]

#Count trees, only keep basePlots
Trees<-OSBS %>% group_by(plotID) %>% summarize(Trees=n())
OSBS_trees<-OSBS_plots %>% inner_join(Trees) %>% filter(subtype=="basePlot")

for(x in 1:nrow(OSBS_trees)){
  row<-OSBS_trees[x,]
  crop()
}
