library(tidyverse)
library(devtools)
library(TreeSegmentation)
library(neonUtilities)
library(downloader)
library(httr)
library(jsonlite)
library(sf)

#data products download
# chemical >>  DP1.10026.001
# isotopes >> DP1.10053.001
#get_data(10026)
#get_data(10053)
# vegetation structure >> DP1.10098.001
#get_TOS_data(10098)

#harmonize the three data products to make a single database
#stack_chemical_leaf_products(10026)
#stack_isotopes_leaf_products(10053)

# get coordinates and position of the vegetation structure trees
get_vegetation_structure()

dat<-read.csv("data/Terrestrial/field_data.csv")

OSBS<-dat %>% filter(siteID=="OSBS") %>% droplevels()
