# Running the example

## Dependencies
* pROC
* reshape
* ggplot2
* cowplot
* caret


## Diet

roc.list <- run.cv.datasets(n=10)
ml.colors <- c("#d80056", "#5cb8d7", "#ff8c01")
names(ml.colors) <- c("rf", "svmRadial", "svmLinear")
ml.legend <- c("Random Forest","SVM Radial","SVM Linear")
plot.rocs(roc.list, rown=6, coln=4, cols=ml.colors, legend.text=ml.legend, outputfn="ml.rocs.pdf")

