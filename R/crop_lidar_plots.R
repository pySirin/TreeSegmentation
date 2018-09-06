#' Clip Lidar Data Based on Neon Plots
#'
#' \code{crop_lidar_plots} overlays the polygons of the NEON plots with the RGB airborne data
#' @param siteID NEON site abbreviation (e.g. "HARV")
#' @return Saved tif files for each plot
#' @importFrom magrittr "%>%"
#' @export
#'
crop_lidar_plots<-function(siteID="HARV"){

  plots<-sf::st_read("../data/NEONFieldSites/All_NEON_TOS_Plots_V5/All_Neon_TOS_Polygons_V5.shp")
  dat<-read.csv("../data/Terrestrial/field_data.csv")
  site<-dat[dat$siteID %in% siteID,]
  site_plots<-plots[plots$plotID %in% site$plotID,]
  #Only baseplots
  site_plots<-site_plots[site_plots$subtype=="basePlot",]

  #get lists of rasters
  inpath<-paste("/orange/ewhite/NeonData/",siteID,"/DP1.30003.001/",sep="")
  fils<-list.files(inpath,full.names = T,pattern=".laz",recursive = T)
  filname<-list.files(inpath,pattern=".tif",recursive = T)

  #drop summary image
  fils<-fils[stringr::str_detect(fils,"_classified_")]

  #grab the first raster for crs
  r<-raster::stack(fils[1])
  #Project
  site_plots<-sf::st_transform(site_plots,crs=raster::projection(r))

  #Crop by plot extent and write to file

  for(x in 1:nrow(site_plots)){

    plotid<-site_plots[x,]$plotID

    plotextent<-raster::extent(site_plots[x,])

    #Create raster catalog
    ctg<-catalog(path_to_tiles)

    extent_polygon<-as(plotextent,"SpatialPolygons")
    extent_polygon<-extent_polygon@polygons[[1]]@Polygons[[1]]

    #clip to extent
    clipped_las<-lasclip(ctg,extent_polygon)

    #if null, return NA
    if(is.null("clipped_las")){
      return(NA)
    }

    #Make canopy model
    #canopy_model(clipped_las)

    #filename
    cname<-paste("/orange/ewhite/b.weinstein/NEON/HARV/NEONPlots/Lidar/",plotid,".laz",sep="")
    print(cname)
    writeLAS(clipped_las,cname)

  }
}
