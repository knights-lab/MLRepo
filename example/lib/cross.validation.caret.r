require(randomForest) # required for rf
require(kernlab) # required for svm
require(caret) 

# runs cross-validation 
# if nfolds > length(y) or nfolds==-1, uses leave-one-out cross-validation
# ...: additional parameters for train.fun
#
# value:
# y: true values
# predicted: cv predicted values
# probabilities: cv predicted class probabilities (or NULL if unavailable)
# confusion.matrix: confusion matrix (true x predicted)
# nfolds: nfolds, use -1 for leave-one-out cv
# params: list of additional parameters
# importances: importances of features as predictors
# regression: does both regression or classification (RMSE and r_squared will be meaningless here)
# modelfun: valid model available in caret package
# group.var = vector of values, to group samples by (e.g. multiple samples per subject id)
"cross.validation.caret" <- function(x, y, nfolds=10, verbose=FALSE, regression=FALSE, modelfun, group.var=NULL, ...){
    if(regression==FALSE)
   	{
		if(class(y) != 'factor') stop('y must be factor for classification\n')
		y <- droplevels(y)
   	}

    folds <- balanced.group.folds(y, nfolds, group.var)
    
    result <- list()
    result$y <- y
    result$predicted <- result$y
    # initialize class probs as an empty data frame
    result$classprob <- data.frame(matrix(vector(), 0, length(unique(result$y))+1))
    
    # K-fold cross-validation
    for(fold in sort(unique(folds))){
        if(verbose) cat(sprintf('Fold %d...\n',fold))
        foldix <- which(folds==fold)    
        newx <- x[foldix,,drop=F] # make sure df structure is kept even for 1-row newx

        fitControl <- trainControl(method = "none", classProbs = TRUE)
        #set.seed(825)
        model <- train(x=x[-foldix,], y=result$y[-foldix],
                         method = modelfun, 
                         trControl = fitControl, 
                         verbose = FALSE, 
                         metric = "ROC")
                         
        # class
        result$predicted[foldix] <- predict(model, newdata = newx) # class
        # probability
        result$classprob[foldix,] <- cbind(predict(model, newx, type="prob"), fold=fold)

    }
	result$nfolds <- nfolds
    result$params <- list(...)
    return(result)    
}

# assign samples to folds so that classes are balanced AND groups samples are in the same fold 
# (avoid training and predicting with samples from the same group)
# note: LOO for groups samples will never truly be LOO
"balanced.group.folds" <- function(y, nfolds, group.var=NULL)
{
    if(nfolds==-1) nfolds <- length(y)   

    if(is.null(group.var)){
        folds <- balanced.folds(y, nfolds)
    } else {
        group <- data.frame(y, group.var, sample.id=1:length(y))

        # order by group, num response, then response level - then grab first sample as group rep
        # this should work fine for discordant samples (e.g. 1 tumor 1 healthy per subject)
        groupfreq <- as.data.frame(table(group[c("group.var", "y")]))
        # Freq is important because we always pick the class level where there are the most samples for one group.var
        # e.g. 4 tongue samples and 2 tongue samples for a subject assigns it as tongue
        groupfreq_ord <- groupfreq[order(groupfreq$group.var, -groupfreq$Freq, groupfreq$y),]
        groupfreq_uniq <- groupfreq_ord[!duplicated(groupfreq_ord$group.var),]
        
        # assign folds based on group rep responses
        folds <- balanced.folds(groupfreq_uniq$y, nfolds)
        groupfreq_uniq$folds <- folds

        # reassign original samples to folds, so that all grouped samples remain in the same fold
        group_folds <- merge(group, groupfreq_uniq[,c("group.var", "folds")], by="group.var", all.x=T)        
        
        # preserve original sample order
        folds <- group_folds[order(group_folds$sample.id),"folds"]
    }
    return(folds)
}

"balanced.folds" <- function(y, nfolds=10){
	y <- droplevels(as.factor(y))
    folds = rep(0, length(y))
    classes = levels(y)
    # size of each class
    Nk = table(y)
    # -1 or nfolds = len(y) means leave-one-out
    if (nfolds == -1 || nfolds == length(y)){
        invisible(1:length(y))
    }
    else{
    # Can't have more folds than there are items per class
    nfolds = min(nfolds, max(Nk))
    # Assign folds evenly within each class, then shuffle within each class
        for (k in 1:length(classes)){
            ixs <- which(y==classes[k])
            folds_k <- rep(1:nfolds, ceiling(length(ixs) / nfolds))
            folds_k <- folds_k[1:length(ixs)]
            folds_k <- sample(folds_k)
            folds[ixs] = folds_k
        }
        invisible(folds)
    }
}
