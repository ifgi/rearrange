# array rearrange

Contains:
R files
* rearrange  contains rearrange_flatten() to  flatten an array. 
* example_PCA  reproduce figure 2(a,b,c) of the paper _Multidimensional arrays for analysing big geoscientific data"_
* fijiscidb  SciDB codes for the study case.

Rdata:
* fijisub.Rdata: the small sub-array of fiji array. the longitude and latitude are flattened into one dimension. The arry size is (259 \times 150 \times 6), which corresponds to (number of pixels * time * spectral bands)
dim(fijisub)
[1] 259 150   6
The "fijisub" in paper refers to this array after removing images with too few pixels. 
*fijirastertime.Rdata: (book keeping) time of the rasters of fiji area. In total there are 150 time steps. 
  
