# returns vector of cluster ids for clusters with internal
# complete-linkage correlation of min.cor
"cluster.by.correlation" <- function(x, min.cor=.75){
#     library('fastcluster')
    cc <- cor(x,use='pairwise.complete.obs',method='pear')
    if(ncol(x) == 379) browser()
    cc <- as.dist(1-cc)
    hc <- hclust(cc)
    res <- cutree(hc,h=1-min.cor)
    names(res) <- colnames(x)
    return(res)
}

# returns vector of cluster ids for clusters with internal
# complete-linkage correlation of min.cor
#
# by default, chooses cluster reps as highest-variance member
# if select.rep.fcn=mean
"collapse.by.correlation" <- function(x, min.cor=.5, select.rep.fcn=c('var','mean','lowest.mean',
			'longest.name', 'shortest.name')[2],
        verbose=FALSE){
    if(verbose) cat('Clustering',ncol(x),'features...')
    gr <- cluster.by.correlation(x, min.cor=min.cor)
    if(verbose) cat('getting means...')
    if(select.rep.fcn == 'mean'){
        v <- apply(x,2,function(xx) mean(xx,na.rm=TRUE))
    } else if(select.rep.fcn == 'lowest.mean'){
        v <- apply(x,2,function(xx) -mean(xx,na.rm=TRUE))
    } else if(select.rep.fcn == 'longest.name'){
        v <- nchar(colnames(x))
    } else if(select.rep.fcn == 'shortest.name'){
        v <- -nchar(colnames(x))
    } else {
        v <- apply(x,2,function(xx) var(xx,use='complete.obs'))
    }
    if(verbose) cat('choosing reps...')
    reps <- sapply(split(1:ncol(x),gr),function(xx) xx[which.max(v[xx])])
    if(verbose)
        cat(sprintf('collapsed from %d to %d.\n',ncol(x), length(reps)))
    return(list(reps=reps, groups=gr))
}
