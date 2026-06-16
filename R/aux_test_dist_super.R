#' @title Supervised distance matrix adjustment for dimensionality reduction
#'
#' @param mat A data frame or matrix to be processed. Rows are variables and columns are samples.
#' @param dmat A precomputed distance matrix. Used as an alternative input to `mat`.
#' @param class.labels A vector of class labels
#' @param s Shift value added to distances between samples from different classes.
#' @param nn.purity The purity of the nearest neighbors, 0~1
#' @param k Number of nearest neighbors
#' @param n Number of points used to interpolate the relationship between `s` and nearest-neighbor purity.
#' @param ret.stat Return the n point of the correspondence between "s" and purity. Choose FALSE to return the distance matrix
#'
#' @returns A distance matrix or a data frame containing the correspondence between "s" and purity
#' @importFrom Rfast Dist
#' @export
#'
aux_test_dist_super = function(mat=NULL, dmat=NULL, class.labels, s=NULL, nn.purity=NULL,
                               k=20, n=50, ret.stat=FALSE){
  #mat: gene x cell
  #dmat: alternative input instead of mat
  stopifnot(!is.null(s)||!is.null(nn.purity))
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
  N = length(class.labels)
  inds = outer(class.labels, class.labels, '==')
  within.max = max(dmat[inds])
  between.min = min(dmat[!inds])
  between.mid = mean(dmat[!inds])
  if(!is.null(s)){
    dmat2 = ifelse(inds, dmat, dmat+s)
    return(as.dist(dmat2))
  }
  #确定最大移动max.s
  if(within.max<=between.min){
    max.s = between.mid-between.min
  }else{
    max.s = (within.max-between.min) + (between.mid-between.min)
  }
  #细化不同移动对最近邻结构的影响
  ss = seq(0,max.s,length.out=n)
  fracs.between.knn = c()
  for(s in ss){
    dmat.s = ifelse(inds, dmat, dmat+s)
    qcut = matrixStats::rowQuantiles(dmat.s, probs=k/N)
    n.between.knn = sum((dmat.s<=qcut) & !inds)
    frac.between.knn = n.between.knn/(N*k)
    fracs.between.knn = c(fracs.between.knn, frac.between.knn)
    rm(dmat.s); gc()
  }
  #names(fracs.between.knn) = ss

  fil = !duplicated(fracs.between.knn) #优先保留前面的（对应于小的shift）
  ss = ss[fil]
  fracs.between.knn = fracs.between.knn[fil]

  fitted.fun = approxfun(fracs.between.knn,ss,rule=2) #rule=2 to return safe estimates
  s.est = fitted.fun(1-nn.purity)
  print(s.est)
  s.est = pmax(s.est,0)
  if(ret.stat){
    return(cbind(s=ss,nn.purity=1-fracs.between.knn))
  }else{
    dmat2 = ifelse(inds, dmat, dmat+s.est)
    return(as.dist(dmat2))
  }
}
