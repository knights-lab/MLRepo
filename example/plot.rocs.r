require(pROC)
require(reshape)
require(ggplot2)
require(cowplot)

plot.rocs <- function(task.stats, rown, coln, main, outputfn="roc.pdf")
{
    cols <- c("#d80056", "#5cb8d7", "#ff8c01")
    names(cols) <- c("rf", "svmR", "svmL")
    cols_trans <- alpha(cols, .7)
    names(cols_trans) <- names(cols)

    pdf(outputfn, width=15, height=15)
    par(mfrow=c(rown, coln))

    for(i in 1:length(task.stats))
    {
        this.task <- task.stats[[i]]
        par(pty="s")
        
        # start with empty plot first
        plot(this.task[[1]]$ROC, type="n", main=names(task.stats)[i], legacy.axis=T, xlab="", ylab="")
        for(j in 1:length(this.task))
        {
             plot(this.task[[j]]$ROC, legacy.axis=T, add=T, col=cols_trans[names(this.task)[j]], lwd=6-j)
             
#             plot(this.task$rf$ROC, main=names(task.stats)[i], legacy.axis=T, col=cols_trans["RF"], lwd=5, xlab="", ylab="")
#             plot(this.task$svmR$ROC, legacy.axis=T, add=T, col=cols_trans["SVMR"], lwd=4)
#             plot(this.task$svmL$ROC, legacy.axis=T, add=T, col=cols_trans["SVML"], lwd=3)
        }
        
        aucs <- unlist(lapply(this.task, '[[', 'AUC'))

        legend("bottomright", legend=aucs, text.col = cols[names(aucs)], bty="n", pt.cex = 1, cex=1.5)
    }

    # plot legend only    
    plot(task.stats[[1]][[1]]$ROC, axes=FALSE, xlab="", ylab="", type="n", identity.col="white")
    legend("center", legend=c("Random Forest","SVM Radial","SVM Linear"), text.col = cols, bty="n", pt.cex=1, cex = 1.65)

    dev.off()
}

# add accuracies somewhere???

#setwd('/Users/pvangay/Dropbox/UMN/KnightsLab/MLRepo')
#load("rocs.n100.RData")
#source('./bin/plot.rocs.r')
#plot.rocs(ret100, rown=6, coln=4, main=ret100$mains)
