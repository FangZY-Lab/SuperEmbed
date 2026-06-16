#' @title Generate a supervised distance matrix with a fixed shift value
#' @description Generate an adjusted distance matrix when the shift value `s` has already been selected.
#'
#' @param mat A data frame or matrix to be processed. Rows are variables and columns are samples.
#' @param dmat A precomputed distance matrix. Used as an alternative input to `mat`.
#' @param class.labels A vector of class labels
#' @param s Shift value added to distances between samples from different classes.
#'
#' @returns A distance matrix
#' @importFrom Rfast Dist
#' @export
#'
aux_get_dist_super = function(mat=NULL, dmat=NULL, class.labels, s=10){
  #mat: gene x cell
  #dmat: alternative input instead of mat
  if(!is.null(mat)){
    require(Rfast)
    stopifnot(ncol(mat)==length(class.labels))
    dmat = Rfast::Dist(t(as.matrix(mat)))
  }else{
    if(class(dmat)[1]=='dist'){
      dmat = as.matrix(dmat)
    }
    stopifnot(nrow(dmat)==ncol(dmat))
    stopifnot(ncol(dmat)==length(class.labels))
  }
  inds = outer(class.labels, class.labels, '==')
  print('Some stat for dmat within and between classes:')
  print(quantile(dmat[inds]))
  print(quantile(dmat[!inds]))
  dmat2 = ifelse(inds, dmat, dmat+s)
  return(as.dist(dmat2))
}
