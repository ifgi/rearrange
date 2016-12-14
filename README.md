# array rearrange

###Contains
*General function*:
* *rearrange.R*:  consists rearrange_flatten() to flatten an array. 

*Codes and data to reproduce figure 2(a,b,c) of the paper _"Multidimensional arrays for analysing big geoscientific data"_* in R and SciDB:
* *example_PCA.R*:  reproduce figure 2(a,b,c) of the paper _"Multidimensional arrays for analysing big geoscientific data"_
* *fijiscidb.R*:  SciDB codes for the study case.
* *fijisub.Rdata*: a small array. The "fijisub" in the paper refers to this array after removing images with too few pixels. the longitude and latitude are flattened into one dimension. The array dimensions are subsequently pixels, time, spectral bands.  The array size is:

```r
dim(fijisub)
[1] 259 150   6
```
* *fijirastertime.Rdata*: (book keeping) time of the rasters of fiji area. In total there are 150 time steps. 
  
