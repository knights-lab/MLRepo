cross.validation.stats <- function(x, y, nfolds, modelfun, group.var, n=100)
{
    # repeat model building, then take average of class probs to construct ROC
    classprob.df <- NULL
    accuracy <- NULL
    for(i in 1:n)
    {   
        mfit <- cross.validation.caret(x=x, y=y, nfolds=nfolds, modelfun=modelfun, group.var=group.var)
        classprob.df <- cbind(classprob.df, mfit$classprob[,1])        
        accuracy[i] <- sum(mfit$predicted == mfit$y)/length(mfit$y)
    }
    
    # plot.roc takes in observed values and the class probabilities 
    # second param is class probabilities of one of the classes (doesn't actually matter which one you pass in)
    roc.obj <- roc(y, rowMeans(classprob.df))
    
    return(list(ROC=roc.obj, AUC=signif(as.numeric(gsub(".*: ", "", roc.obj$auc)), 2), accuracy=mean(accuracy)))
}
