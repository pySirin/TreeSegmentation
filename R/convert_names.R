#' Get corresponding tile across data types
#'
#' \code{convert_names} uses the geocode from each NEON data product to find the corresponding tile in another sensor
#' @param from current sensor
#' @param to destination sensor
#' @param rgb Character. RGB pathname
#' @param lidar Character. Lidar pathname
#' @param hyperspectral hyerspectral pathname
#' @export
convert_names<-function(from,to,lidar=NULL,rgb=NULL,hyperspectral=NULL,site='OSBS'){

  if(from=="rgb" & to=="lidar"){
    #Get corresponding lidar tile
    geo_index<-stringr::str_match(rgb,"_(\\d+_\\d+)_image")[,2]
    indices<-strsplit(rgb,"_")
    site<-indices[[1]][[5]]
    domain<-indices[[1]][[4]]

    fn<-paste("NEON_",domain,"_",site,"_DP1_",geo_index,"_classified_point_cloud.laz",sep="")
    return(fn)
  }

  if(from=="lidar" & to == "rgb"){
    geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified")[,2]
    indices<-strsplit(lidar,"_")
    site<-indices[[1]][[5]]
    domain<-indices[[1]][[4]]

    if(site=="OSBS"){
      fn<-paste("2017",site,"_3_",geo_index,"_image.tif",sep="")
    }

    if(site=="SJER"){
      fn<-paste("NEON_",domain,"_",site,"_DP3_",geo_index,"_image.tif",sep="")
    }

    if(site=="GRSM"){
      fn<-paste("2016_GRSM_2",geo_index,"_image.tif",sep="")
    }


    return(fn)
  }

}
