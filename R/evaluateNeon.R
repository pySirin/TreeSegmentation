#' Wrapper for calculating recall statistics for NEON tree centroids.
#'
#' \code{evaluateRecall} computes an lidar based segmentation, assigns polygons to closest match and calculates recall statistic
#' @param ground_truth SpatialPolygonDataFrame of ground truth polygons
#' @param algorithm  Character. A vector of lidar unsupervised classification algorithm(s). Currently "silva","dalponte","li" and "watershed" are implemented. See \code{\link[lidR]{lastrees}}
#' @param path_to_tiles Character. Location of lidar tiles on system.
#' @param plot_results Logical. Generate a plot of ground truth and predicted polygons
#' @param basemap Character Directory of rgb images for basemap
#' @param extra Logical. Return a list of segmented lidar tiles, predicted convex hull polygons, and the calculated evaluation statistics.
#' @return dataframe of the jaccard overlap among polygon pairs for each selected method. If extra=T, \code{evaluate} will return a list object of results, predicted polygons, as well as output lidR tiles. See e.g. \code{\link{silva2016}}
#' @export
#'
evaluateNeon<-function(site,plotID,algorithm="silva",path_to_tiles=NULL,extra=F,plot_results=F,basemap=""){

  dat<-read.csv("../data/Terrestrial/field_data.csv")

  sites<-dat %>% filter(siteID==site) %>% droplevels()

  #accepted species list
  species<-read.csv("../data/NEONPlots/AcceptedSpecies.csv")
  species<-species %>% filter(siteID %in% sites$siteID)

  #filter data by species
  sites <- sites %>% filter(scientificName %in% species$scientificName)

  #search for duplicates, ending in a letter
  sites<-sites %>% filter(!is.na(as.numeric(str_sub(individualID,-1))))

  #Individual trees
  trees<-sites  %>% filter(!is.na(UTM_E))

  pts<-trees[trees$plotID %in% plotID,]
  inpath<-paste(path_to_tiles,plotID,".laz",sep="")

  #Sanity check, does the file exist?
  if(!file_test("-f",inpath)){
    warning(inpath,"does not exist")
    return(NULL)
  }

  #Run segmentation methods
  predictions<-list()
  tiles<-list()
  if("silva" %in% algorithm){
    print("Silva")
    silva<-silva2016(path=inpath)
    predictions$silva<-silva$convex
    tiles$silva<-silva$tile
  }

  if("dalponte" %in% algorithm){
    print("Dalponte")
    dalponte<-dalponte2016(path=inpath)
    predictions$dalponte<-dalponte$convex
    tiles$dalponte<-dalponte$tile
  }

  if("li" %in% algorithm){
    print("li")
    li<-li2012(path=inpath)
    predictions$li<-li$convex
    tiles$li<-li$tile
  }

  if("watershed" %in% algorithm){
    print("Watershed")
    watershed_result<-watershed(path=inpath)
    predictions$watershed<-watershed_result$convex
    tiles$watershed<-watershed_result$tile
  }


  #For each method compute result statistics
  statdf<-list()
  for(i in 1:length(predictions)){
    plot(predictions[[i]])
    points(SpatialPoints(cbind(pts$UTM_E,pts$UTM_N)))
  }

  statdf<-dplyr::bind_rows(statdf)

  #if plot, overlay ground truth and predictions
  if(plot_results){
    #which was the best performing method
    best_method<-statdf %>% group_by(Method) %>% summarize(m=mean(IoU)) %>% arrange(desc(m))
    ortho<-raster::stack(paste(basemap,unique(ground_truth$Plot_ID),".tif",sep=""))
    png(paste("plots/evaluation/",unique(ground_truth$Plot_ID),".png",sep=""))
    par(oma=c(0,0,2,0))
    raster::plotRGB(ortho,main=paste(unique(ground_truth$Plot_ID),":",best_method$Method[1],"=",round(best_method$m[1],2)),axes=T)
    plot(pts,border="red",add=TRUE)
    plot(predictions[[best_method$Method[1]]],add=T,border="black")
    title()
    dev.off()
  }
  if(extra){
    return(list(results=statdf,predictions=predictions,tiles=tiles))
  } else{
    return(statdf)
  }
}
