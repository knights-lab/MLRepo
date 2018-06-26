require(pROC)
require(reshape)
require(ggplot2)
require(cowplot)

# given a list of roc objects generated by run.cv.datasets(), plots them in a grid
# cols = named vector of colors, names must match roc object vars exactly
# legend.text = readable names of roc comparisons
plot.rocs <- function(roc.list, rown, coln, cols, legend.text, outputfn="roc.pdf")
{
    cols_trans <- alpha(cols, .7)
    names(cols_trans) <- names(cols)

    pdf(outputfn, width=15, height=15)
    par(mfrow=c(rown, coln))

    for(i in 1:length(roc.list))
    {
        this.task <- roc.list[[i]]
        par(pty="s")
        
        # start with empty plot first
        plot(this.task[[1]]$ROC, type="n", main=names(roc.list)[i], legacy.axis=T, xlab="", ylab="")
        for(j in 1:length(this.task))
        {
             plot(this.task[[j]]$ROC, legacy.axis=T, add=T, col=cols_trans[names(this.task)[j]], lwd=6-j)
        }
        
        aucs <- unlist(lapply(this.task, '[[', 'AUC'))

        legend("bottomright", legend=aucs, text.col = cols[names(aucs)], bty="n", pt.cex = 1, cex=1.5)
    }

    # plot legend only    
    plot(roc.list[[1]][[1]]$ROC, axes=FALSE, xlab="", ylab="", type="n", identity.col="white")
    legend("center", legend=legend.text, text.col = cols, bty="n", pt.cex=1, cex = 1.65)

    dev.off()
}

