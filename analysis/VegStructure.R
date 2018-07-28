#parsing NEON veg structure data
library(tidyverse)

f<-list.files("/Users/ben/Dropbox/Weecology/NEON/WoodyPlant",full.names = T,pattern="mapping")
rf<-lapply(f,read.csv)

rf<-lapply(rf,function(x){
  x$supportingStemIndividualID<-as.character(x$supportingStemIndividualID)
  x$previouslyTaggedAs<-as.character(x$previouslyTaggedAs)
  return(x)
  })

df<-bind_rows(rf)

OSBS<-df %>% filter(siteID=="OSBS") %>% select(-c(measuredBy,recordedBy,dataQF,remarks,cfcOnlyTag,supportingStemIndividualID,samplingProtocolVersion,identificationReferences,previouslyTaggedAs))
