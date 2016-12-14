# array rearrange

###Contains
R files:
* rearrange.R:  consists rearrange_flatten() to flatten an array. 
* example_PCA.R:  reproduce figure 2(a,b,c) of the paper _"Multidimensional arrays for analysing big geoscientific data"_
* fijiscidb.R:  SciDB codes for the study case.

Rdata:
* fijisub.Rdata: the small sub-array of fiji array. the longitude and latitude are flattened into one dimension. The arry size is (259* 150*6), which corresponds to (number of pixels*time*spectral bands). The "fijisub" in paper refers to this array after removing images with too few pixels. 

```r
dim(fijisub)
[1] 259 150   6
```
*fijirastertime.Rdata: (book keeping) time of the rasters of fiji area. In total there are 150 time steps. 
  
