require(pROC)

source(paste0(BASEDIR,'/example/lib/cross.validation.stats.r'))
source(paste0(BASEDIR,'/example/lib/cross.validation.caret.r'))
source(paste0(BASEDIR,'/example/lib/collapse-features.r'))

# task.ids (optional) only run on specific task ids 
# n = number of bootstrap iterations
# mlmodels = type of algorithms supported by caret
# featuretable = type of OTU-type table to use (single item or vector) otufn_refseq, otufn_gg, taxafn_refseq, taxafn_gg
# debug.mode = print status to screen and save intermediate roc objects
run.cv.datasets <- function(taskfn="tasks.txt", task.ids=NULL, n=100, mlmodels = c("rf", "svmRadial", "svmLinear"), 
                            featuretable="otufn_refseq", debug.mode=FALSE)
{
    tasks <- read.table(taskfn, sep="\t", head=T, quote="", as.is=T)

    # ROC for binary tasks only
    tasks_binary <- tasks[tasks$data_type=="binary",]

    # include only tasks where all featuretables have valid values
    tasks_binary <- tasks_binary[rowSums(is.na(tasks_binary[,featuretable,drop=F])) == 0,]
    
    data.ix <- 1:nrow(tasks_binary)
    if(length(task.ids) > 0)  data.ix <- which(tasks_binary$task_id %in% task.ids)
    tasks_binary <- tasks_binary[data.ix,] 

    roc.list <- list()
    
    for(task.ix in 1:nrow(tasks_binary))
    {
        if(debug.mode) print(paste0("Starting dataset ", task.ix, ", ", tasks_binary[task.ix, "task_name"], "..."))

        # read in grouping vars, but make sure that they're compatible with variable naming due to caret package requirements
        task <- read.table(tasks_binary[task.ix, "taskfn"], sep="\t", comment="", row=1, head=T, quote="", check.names=F, colClasses="character")
        task$Var <- as.factor(make.names(task$Var))

        rocs <- NULL
        for(ftable.ix in 1:length(featuretable))
        {
            otu <- read.table(tasks_binary[task.ix, featuretable[ftable.ix]], sep="\t", comment="", row=1, head=T, check.names=F, quote="")
            otu <- t(otu)
            otu <- sweep(otu, 1, rowSums(otu), '/')
            prevalences <- apply(otu, 2, function(bug.col) mean(bug.col > 0))
            otu <- otu[, prevalences >= .10]
            ret <- collapse.by.correlation(otu, .95)
            otu <- otu[, ret$reps]

            valid_samples <- intersect(rownames(otu), rownames(task))
            otu <- otu[valid_samples,]
            task <- task[valid_samples,, drop=F]

            if(nrow(task) < 100) nfolds = -1 else nfolds = 5 # LOO for small sample sizes    
                            
            for(model.ix in 1:length(mlmodels))
            {
                roc.name <- mlmodels[model.ix]
                if(length(featuretable) > 1) # if more than 1 otu table, multiplex mlmodel and otutable names
                    roc.name <- paste(mlmodels[model.ix], featuretable[ftable.ix], sep="-")
                rocs[[roc.name]] <- cross.validation.stats(x=otu, y=task$Var, nfolds=nfolds, modelfun=mlmodels[model.ix], group.var=task$Group.Var, n=n)
            }
        }
        
        # name each list items as a task name, save roc objects to compare under that
        roc.list[[tasks_binary[task.ix, "task_name"]]] <- rocs
    
        # save intermediate roc.list objects, in case one dataset errors out
        if(debug.mode) save(roc.list, file="roc.list.autosave.RData")
    }
    invisible(roc.list)
}

