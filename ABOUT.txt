# multibandsBFAST

Contains:

* R package multibandsBFAST, to combine PCA and BFAST Monitor 
* Tasseled cap transformation, PC loading plotting, time series plotting and checking of seasonality are included in the multibandsBFAST. 
* Seasonality folder contains data and functions to check seasonality
* reproduce.R` to reproduce the result of the paper _Deforestation monitoring using multi-spectral Landsat time series"_

Rdata:

fijisub.Rdata: the small sub-array of fiji array. the longitude and latitude are flattened into one dimension. The arry size is (259 * 150 * 6), which corresponds to (number of pixels * time * spectral bands)
dim(fijisub)
[1] 259 150   6
The "fijisub" in paper refers to this array after removing images with too few pixels. 


fijirastertime.Rdata: (book keeping) time of the rasters of fiji area. In total there are 150 time steps. 


R files:


rearrange: contains rearrange_flatten() to  flatten an array. 

example_PCA: reproduce figure 2, 3, and 4 of the paper using rearrange_flatten().

fijiscidb: SciDB codes for the study case.
