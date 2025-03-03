#' @title Calibrate distance matrix
#' @description Calibrate distance matrix to better suit t-SNE
#'
#' @param dmat Distance matrix
#'
#' @returns Calibrated distance matrix
#' @export
#'
aux_calibrate_dmat = function(dmat){
  if(class(dmat)[1]=='dist'){
    dmat = as.matrix(dmat)
  }
  aux._calibrate = function(x){
    x = ecdf(x)(x)/2+0.5
    x[x>=1] = max(x[x<1])
    qnorm(x,lower.tail=T)
  }
  dmat2 = t(apply(dmat,1,aux._calibrate))
  return(as.dist((dmat2+t(dmat2))/2))
}
