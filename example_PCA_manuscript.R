############################################### 
# An example of using rearrange_merge()
# -- reproduce figure 3 of the array paper 
###############################################

load("fijisub.Rdata")
load("fijirastertime.Rdata")

library(ggplot2)
library(lattice)
library(reshape2)

#' rearrange_merge: merge two or more dimensions of an array and reorder resulting dimensions at the same time.
#' @param original_array arbitrary R array
#' @param flatten a vector of dimension indexes which will be merged to a single dimension
#' @param position the position of the merged dimension in the output array 
#' @return an array with the same data as the original array but with rearranged dimensionality
#' @example 
#' X=array(c(1:360), c(3,4,5,6))
#' X2<-rearrange_array(X, flatten=c(2,4)) 
#' dim(X2)
rearrange_merge <- function(original_array, flatten = c(1), position = min(flatten)) {
  flatten1 <- sort(flatten)
  a <- 1:length(dim(original_array))
  a <- a[-flatten1]
  apermarray <- aperm(original_array, c(flatten1, a))
  
  arrschema <- c(prod(dim(original_array)[flatten1]), dim(original_array)[a])
  dim(apermarray) <- arrschema
  # now the new dimension is at the front i.e. the first dimension of an array.
  # the following codes put the new dimension at spicified or default position
  
  if (position > 1) {
    index.permute = append(2:length(dim(apermarray)), values = 1, after = position-1)
    apermarray = aperm(apermarray, index.permute)
  }
  return(apermarray)
} 

# plotloading: plot PC loading using ggplot: reproduce figure 2, 3, and 4 of the array paper
#' @param PCfit results of prcomp
#' @param plotw PC loadings from which matrix to plot: time as variable, band are variable, or spectral time as variable
#' @param nl number of PC loadings to plot, by defaut 4
#' @param rastertime the dates of each raster, only useful when time is variable.
#' @param addline locations to add vertical lines
#' @param varname name of variable 
#' @param obsname name of observation
#' @param tax the size of the font for x-axis and y-axis
#' @return  plots of pc loadings

plotloading <- function(PCfit,plotw=c("time", "bands", "bandsts"), nl=4, rastertime, addline = 0, varname="", obsname="", xaxisname="",tax=16) {
  re <- length(PCfit$rotation[, 1]) 
  variable.groups <- rep(1:nl, each=re)
  if (plotw=="time") {
    T1 <- rep(rastertime, nl)
    melted <- cbind(variable.groups, melt(PCfit$rotation[, 1:nl]), T1)
    names(melted) <- c("variable.groups", "X1", "X2", "value", "T1")
    barplot <- ggplot(data = melted) + 
      geom_bar(aes(x = T1, y = value, fill = variable.groups),
               position = "identity", show.legend = T, stat = "identity") + 
      facet_wrap(~X2) + 
      theme(legend.position = "none") + 
      xlab(xaxisname) + 
      ylab("PC loadings") + 
      theme(strip.text.x = element_text(size = tax*0.8), 
            axis.title=element_text(size=tax),
            axis.text.x = element_text(angle = 45, hjust = 1)) +
      geom_vline(xintercept = as.numeric(as.Date(addline)), 
                 linetype = 4, colour = "brown")  
      plot(barplot) 
    } else if (plotw=="bandstime") {
      melted <- cbind(variable.groups, melt(PCfit$rotation[, 1:nl]))
      names(melted) <- c("variable.groups", "X1", "X2", "value")
      barplot <- ggplot(data = melted) +
      geom_bar(aes(x = X1, y = value, fill = variable.groups), 
               position = "identity", show.legend = F, stat = "identity") + 
      facet_wrap(~X2) + 
      theme( strip.text.x = element_text(size = tax*0.8), 
             axis.title=element_text(size=tax),legend.position = "none", 
             plot.title = element_text(size = 18, colour = "black", vjust = -1)) + 
      xlab(xaxisname) + 
      ylab("PC loadings") + 
      geom_vline(xintercept = addline, linetype = "dashed", colour = "gray")  
      plot(barplot)  
    }else if (plotw=="bands"){
      melted <- cbind(variable.groups, melt(PCfit$rotation[, 1:nl]))
      names(melted) <- c("variable.groups", "X1", "X2", "value")
      barplot <- ggplot(data = melted) + 
      geom_bar(aes(x = X1, y = value, fill = variable.groups), position = "identity", 
               show.legend = F, stat = "identity") + facet_wrap(~X2) + 
      theme( strip.text.x = element_text(size = tax*0.8), axis.title=element_text(size=tax),
             legend.position = "none", plot.title = element_text(size = 18, colour = "black", vjust = -1)) +
      xlab(xaxisname) + 
      ylab("PC loadings")                                                                                                                                                                                       
      plot(barplot)
    }
}


#' rm_sparse: remove images with too few spatial points (e.g. only keep images with na values less than fifth of data)
#' points)
#' output a new set of images and book-keeping time.
#' not a general function
#' @param arr_original array with dimensions (space, time, spectral band)
#' @param time_original a vector of dates for all images
#' @param threshold maximum acceptable amount of missing values as a fraction relative to the amount of total image pixels 
#' @return a list with elements \code{arraysub} and \code{datesub} with very sparse images removed and corresponding dates respectively.
rm_sparse <- function(arr_original, time_original, threshold = 0.2) {
  a <- sapply(1:dim(arr_original)[2], function(j) length(which(is.na(arr_original[, j, 1]))))
  # a is the number of missing pixels per image
  th1 <- dim(arr_original)[1]*threshold
  fijisub_s <- arr_original[, which(a < th1), ]
  rastertime_s <- time_original[which(a < th1)]
  return(list(arraysub=fijisub_s, datesub=rastertime_s))
}




#  reproduce study case 

# preprocess the data, i.e. remove very sparse images
fi <- rm_sparse(arr_original = fijisub, time_original = fijirastertime)
fijisub_s <- fi$arraysub # arrays with very sparse image removed
rastertime_s <- fi$dates # time of fijisub_s

#############
#bands as variables

# rearrange
fijibandvar <- rearrange_merge(fijisub_s, flatten = c(1, 2))
# compute PCA
fitband <- prcomp(na.omit(fijibandvar), scale. = TRUE)
# plot pc loading
plotloading(PCfit = fitband, varname = "bands", obsname = "temporal spatial points", xaxisname="bands",
            addline = 0, nl=4, plotw="bands")

####################
# time as variables

# rearrange 
fijitimevar <- rearrange_merge(fijisub_s, flatten = c(1, 3))
# compute PCA
fittime <- prcomp(na.omit(fijitimevar), scale. = TRUE)
# plot pc loading
plotloading(PCfit = fittime, varname = "times", obsname = "specatral spatial points", xaxisname="time",
            rastertime = rastertime_s, plotw="time", addline = "2010-06-27", nl=4)

#####################
#specral times as variables

#rearrange
fijistvar <- rearrange_merge(fijisub_s, flatten = c(2, 3))
# compute PCA
fitst <- prcomp(na.omit(fijistvar), scale. = TRUE)
# plot pc loading
plotloading(PCfit = fitst, varname = "spectral times", obsname = "spatial points", xaxisname="spectral temporal points",
            addline = seq(0, 270, by = 45),plotw="bandstime" )

# that's it!
