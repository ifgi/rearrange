##########################
# rearrange_array() 
#implemented functionality: rearrange array from n-d to m-d, with m < n 

#rearrange_array (original_array=X,   flatten=c(2,3), position=1)
#flatten: dimensions to be flattened. position: place /order/position of the new dimension

rearrange_array <- function (original_array, flatten = c(1), position=min(flatten)) 
{
  flatten1 <- sort(flatten)
  a <- c(1:length(dim(original_array)))
  a <- a[-flatten1] 
  apermarray <- aperm( original_array, c(flatten1,a ))
  
  arrschema <- c(prod(dim(original_array)[flatten1]), dim(original_array)[a])
  dim(apermarray) <- arrschema
  # now the new dimension is at the front i.e. the first dimension of an array.
  # the following codes put the new dimension at spicified or default position
  
  if(position == 1) # if position is at 1, same as newarr1 
    newarr = apermarray
  else {
    b <- c(1: length(dim(apermarray)))
    if (position+1 > length(dim(apermarray))) #if position is at the last dimension
      s <- c(2:position, 1)
	else
      s <- c(2:position, 1, (position + 1):length(b)) 
    # new schema 
    newarr<-aperm(apermarray, s)
  }
  return(newarr)
}

##########################


#Detail: 
#rearrange_array() rearranges an array by specifying the dimensions of the array to be rearranged.
#the dimensions that are to be rearranged became the t-th dimension of the rearranged array 
#t can be specified by the "position" variable. If "position" is not specified, the new dimension 
#is at the original dimention of the first dimension to be arranged. other dimensions follow the same order.
#a Warning message is given if position is unspecified

#for example,
#array X has 4 dimensions with the length d1=3, d2=4, d3=5, d4=6
d1=3
d2=4
d3=5
d4=6 
X=array(c(1:360), c(d1,d2,d3,d4))
#we rearrange array X to a new array that has 3 dimensions, with d2 and d4 become one dimension.  

X2<-rearrange_array(X, flatten=c(2,4)) 
dim(X2)
#[1]  3    24   5 
#    d1, d2*d4, d3

#position is not specified, 
#which in this case is equal to 
X2<-rearrange_array(X, flatten=c(2,4), position = 2) 
dim(X2) 
#[1]  3 24  5

#make dimension 2, 3, and 4 a new dimension
X2<-rearrange_array(X, flatten=c(2,3, 4)) 
dim(X2) 
#[1]   3 120


#make dimension 3, and 4 a new dimension
X2<-rearrange_array(X, flatten=c(3, 4)) 
dim(X2) 
#[1]  3  4 30
#which is the same as x3<-array(X, c(d1,d2,d3*d4))
#x3-X2

#make dimension 1, and 4 a new dimension, put at dimension 2
X2<-rearrange_array(X, flatten=c(1, 4), position =2) 
dim(X2) 
#[1]  4 18  5











 
