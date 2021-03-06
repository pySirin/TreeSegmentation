% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_bounding_boxes.R
\name{get_bounding_boxes}
\alias{get_bounding_boxes}
\title{Generate bounding boxes for all segmented trees}
\usage{
get_bounding_boxes(df, expand = 1)
}
\arguments{
\item{df}{a list of objects exported by \code{\link{extract_trees}}}

\item{expand.}{Numeric. Multiply box size by a factor.}
}
\value{
A list of \code{\link[sp]{SpatialPolygonsDataFrame}} objects containing a bounding box for each defined tree.
}
\description{
\code{get_bounding_boxes} Iterates through a list of dataframes and returns bounding boxes based on the extent of XY points.
}
