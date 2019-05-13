# dependencies: pROC, reshape, ggplot2, cowplot, caret

BASEDIR='/Users/pvangay/MLRepo' # update to your containing folder

setwd(BASEDIR)
source(paste0(BASEDIR,'/example/lib/plot.rocs.r'))
source(paste0(BASEDIR,'/example/lib/run.cv.datasets.r'))

taskfn <- paste0(BASEDIR,'/web/data/tasks.txt')

# compare ml algorithms across all tasks
ret <- run.cv.datasets(taskfn=taskfn, n=10)
ml.colors <- c("#d80056", "#5cb8d7", "#ff8c01")
names(ml.colors) <- c("rf", "svmRadial", "svmLinear")
ml.legend <- c("Random Forest","SVM Radial","SVM Linear")
plot.rocs(ret, rown=6, coln=5, cols=ml.colors, legend.text=ml.legend, outputfn="ml.rocs.pdf")


# compare refseq and gg97 taxa tables as features
roc.list <- run.cv.datasets(taskfn=taskfn, n=10, mlmodels="rf", featuretable=c("otufn_refseq","otufn_gg"))
db.colors <- c("#d80056", "#5cb8d7")
names(db.colors) <- c("rf-otufn_refseq", "rf-otufn_gg")
db.legend <- c("refseq","gg97")
plot.rocs(roc.list, rown=6, coln=5, cols=db.colors, legend.text=db.legend, outputfn="db.rocs.pdf")


