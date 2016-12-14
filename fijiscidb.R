install.packages("gdalUtils") # to call gdal_translate without system()
devtools::install_github("Paradigm4/SciDBR", ref="laboratory")  # this experimental version one seems to work...

library(raster)
library(gdalUtils)
library(scidb) # this is not neccessary to load the data but to rearrange to 4d afterwards

SCIDB_ARRAYNAME = "fiji" # <-- this is the 3d array to be created
SCIDB_HOST = "gis-bigdata.uni-muenster.de"
SCIDB_PORT = 51511
SCIDB_USER = "menglu"
SCIDB_PW = "EvaQuT6vUa6Gf27L"


######################################################################################
# 1. convert R raster to temporal snapshot files readable by GDAL (e.g. GeoTIFF, .img, ...)
######################################################################################


load("allbandsfigi2.Rdata")
landsat.stacked = stack(allbandsfigi)

# subset dataset by day (all bands of specific dates in one stack) and store as files
# this might take some minutes for 150 files...
datestrings = unique(substr(names(landsat.stacked ),10,16))
raster.subsets.bydate = lapply(datestrings,function(d) {
  writeRaster(subset(landsat.stacked, grep(d,x=names(landsat.stacked))), format="GTiff", filename=paste(d,sep=""),NAflag=-1, dataType="INT2S",overwrite=TRUE) # use whatever format  works best, fastest
})

######################################################################################
# 2. apply gdal_translate on temporal snapshot files (as they also come originally from data providers)
######################################################################################



files = list.files(pattern="*.tif")


# We don't want to pass this information in every single gdal_translate call und thus set it
# as environment variables
Sys.setenv(SCIDB4GDAL_HOST=SCIDB_HOST, 
           SCIDB4GDAL_PORT=SCIDB_PORT, 
           SCIDB4GDAL_USER=SCIDB_USER,
           SCIDB4GDAL_PASSWORD=SCIDB_PW)


# load first image to SciDB
cat (paste(format(Sys.time()),"Loading first image to SciDB ... "))
gdal_translate(src_dataset = files[1],
               dst_dataset = paste("SCIDB:array=",SCIDB_ARRAYNAME, sep = ""),
               of = "SciDB",
               co = list("t=2000-05-15","type=STS","dt=P381H", "CHUNKSIZE_SP=1000", "CHUNKSIZE_T=1"))
cat("Done.\n")              


# OPTIONAL: test, whether this works
#library(scidb)
#scidbconnect(protocol="https", auth_type="digest", host = "gis-bigdata.uni-muenster.de",username = "scidb",password = "xaf62bv9d3qvske3xe78h2tue4g66ktu",port = 51511)
#x = scidb(SCIDB_ARRAYNAME)
### END TEST



# load other images to scidb and add to existing based on date
for (i in 2:length(files)) {
  cat (paste(format(Sys.time()),"Loading image", i, "of", length(files), "~", round(100*i / length(files) ), "% ... "))
  d = strptime(substr(files[i],1,7), format="%Y%j")
  # dt=381H
  
  gdal_translate(src_dataset = files[i],
                 dst_dataset = paste("SCIDB:array=",SCIDB_ARRAYNAME, sep = ""),
                 of = "SciDB",
                 co = list("CHUNKSIZE_SP=1000", "CHUNKSIZE_T=1", "type=ST", "dt=P381H", paste("t=",format(d),sep="")), verbose = TRUE)
  cat("Done.\n")
}

cat("\nSciDB load done.\n")




# rearrange to 4d
scidbconnect(auth_type="digest", protocol = "https", host=SCIDB_HOST,port = SCIDB_PORT,username = SCIDB_USER,password = SCIDB_PW)
fiji=scidb(SCIDB_ARRAYNAME)



  
iquery("store(unfold(fiji),fiji4d)",return=T)
iquery("store(cast(fiji4d, <reflectance:double NULL DEFAULT null> [y=0:659,1000,0,x=0:659,1000,0,t=0:*,1,0,band=0:5,6,0]), fiji4d1)")
iquery("show(fiji4d1)",return=T)


iquery("store(subarray(figi4d, 0, 0,0,0, 99, 99,149, 5), fijisub)")
iquery("store(reshape(figi4dsub, <band1:double>
       [xy=0:9999,512,0, t=0:149,512,0,unfold_3=0:5,6,0]), fijisub3d)")
 


#array3d_schema= <reflectance:double>[xy=0:258,512,0, t=0:149,512,0,band=0:5,6,0]
#array2d_schema= <reflectance:double>[xyt=0:38851,512,0 ,band=0:5,6,0]

(349 - 312 + 1) * (200 - 184 + 1) * (150)
iquery("store(
       reshape(
       subarray(fiji4d1, 312, 184, 0,0, 349, 200, 149, 5 ),  
       <reflectance:double>[xyt=1:96900,512,0 ,band=0:5,6,0]), 
       d2array)")
iquery("show(d2array)",return=T)




#\#\#\# Centering and scaling the data  

# Average on column (band as variable), standard deviation on column
iquery("store(aggregate(d2array,avg(reflectance), band),b_ave)")
iquery("store(aggregate(d2array,stdev(reflectance), band),b_var)")

iquery("show(b_ave)",return=T)
iquery("show(b_var)",return=T)

## Cross join the mean to the array

iquery("store(cross_join(d2array,b_ave, d2array.band, b_ave.band),bjoin)")
iquery("show(bjoin)",return=T)

iquery("store(cross_join(bjoin, b_var, bjoin.band, b_var.band),b_join_mean_var)")
iquery("show(b_join_mean_var)",return=T)

## Center the data by substracting the average, scale the data by dividing the standard deviation

iquery("store(apply(b_join_mean_var, censcale, (reflectance - reflectance_avg)/reflectance_stdev), censcale_arr)")
iquery("show(censcale_arr)",return=T)

## Project the centered data
iquery("store(project(censcale_arr, censcale), censcale_p)")

#Migrate the coordinate to (0,0)
#iquery('store(subarray(censcale_pro, subschema),censcapro1)')



## Transpose the array
iquery('store(transpose(censcale_p),b_censcale_p)')
iquery("show(b_censcale_p)",return=T)

## Compute PCA (1)


iquery("store(repart(subarray(b_censcale_p,0,1,5,96900),<censcale:double NULL DEFAULT null> [band=0:5,32,0,xyt=0:96899,32,0]),b_censcale_p_zero_repart)")
iquery("store(gesvd(b_censcale_p_zero_repart,'U'), b_svd_U)")



iquery("scan(b_svd_U)", return = T)

svd("b_censcale_p_zero") 

fiji.svd = scidb("b_svd_U")[]


fit<-prcomp(na.omit( d2array ),center=TRUE,scale.=TRUE)

re<-length(fit$rotation[,1])
variable.groups <- c(rep(1, re), rep(2, re), rep(3, re),rep(4,re))

str(melted)
T1<-rep(time1[which(a<50)], 4)

melted <- cbind(variable.groups, melt(fit$rotation[,1:4]), T1)

barplot <- ggplot(data=fiji.svd) +
  geom_bar(aes(x=band, y=u, fill=i),position = "identity", show_guide=F,stat="identity") +
  facet_wrap(~i)+ theme(legend.position="none")+
  ggtitle(paste("Variable: time, Observation: spectral spatial points" ))+
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 


plot(barplot )
     


\end{alltt}