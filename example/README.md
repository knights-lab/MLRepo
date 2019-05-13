# Help with example/run.r

## Dependencies:
* pROC
* caret
* kernlab
* randomForest
* ggplot2
* cowplot

If you did not clone the entire MLRepo, make sure to download [tasks.txt](../web/data/tasks.txt) and place in your base directory (where you downloaded MLRepo to).

In R, set `BASEDIR = your/local/path/MLRepo`

Run cross validation with default settings, bootstrapped 10 iterations
```R
roc.list <- run.cv.datasets(n=10)
```

Set custom colors and custom legend text for plotting ROCs
```R
ml.colors <- c("#d80056", "#5cb8d7", "#ff8c01")
names(ml.colors) <- c("rf", "svmRadial", "svmLinear")
ml.legend <- c("Random Forest","SVM Radial","SVM Linear")
```

Plot and save the rocs
```R
plot.rocs(roc.list, rown=6, coln=4, cols=ml.colors, legend.text=ml.legend, outputfn="ml.rocs.pdf")
```
