require(pROC)

source('./lib/cross.validation.r')
source('./lib/collapse-features.r')
source('./lib/cross.validation.stats.r')

run.cv.datasets <- function(task.ids=NULL, n=100)
{
    tasks <- read.table("tasks.txt", sep="\t", head=T, quote="", as.is=T)

    # ROC for binary tasks only
    tasks_binary <- tasks[tasks$data_type=="binary",]

    data.ix <- 1:nrow(tasks_binary)
    if(length(task.ids) > 0)  data.ix <- which(tasks_binary$task_id %in% task.ids)
    tasks_binary <- tasks_binary[data.ix,] 

    roc.list <- list()

    mlmodels <- c("rf", "svmR", "svmL")
    
    for(i in 1:nrow(tasks_binary))
    {
        print(paste0("Starting dataset ", i, ", ", tasks_binary[i, "task_name"], "..."))
    
        otu <- read.table(tasks_binary[i, "otufn_refseq"], sep="\t", comment="", row=1, head=T, check.names=F, quote="")
        task <- read.table(tasks_binary[i, "taskfn"], sep="\t", comment="", row=1, head=T, quote="", check.names=F, colClasses="factor")

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
                
        stats <- NULL
        for(j in 1:length(mlmodels))
            stats[[j]] <- cross.validation.stats(x=otu, y=task$Var, nfolds=nfolds, modelfun=mlmodels[j], group.var=task$Group.Var, n=n)
        names(stats) <- mlmodels
            
        roc.list[[tasks_binary[i, "task_name"]]] <- stats
    
        # save intermediate roc.list objects, in case one dataset craps out
        save(roc.list, file="ret.temp.RData")
    }
    return(roc.list)
}

