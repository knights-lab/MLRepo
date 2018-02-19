setwd("/Users/pvangay/Dropbox/UMN/KnightsLab/MLRepo/datasets")

# overwrite the colnames
write.mapping <- function(filename, map)
{
    if(ncol(map)==1)  header <- "#SampleID\tVar\n"
    else if(ncol(map)==2)  header <- "#SampleID\tVar\tControlVar\n"
    else stop("Number of mapping file columns not supported")
    
    cat(header, file=filename)
    write.table(map, file=filename, sep="\t", quote=F, col.names=F, append=T)
}

load.data <- function(mapfile, otufile)
{
    m <- read.table(mapfile, sep="\t", comment="", head=T, row=1, quote="", as.is=T)
    o <- read.table(otufile, sep="\t", comment="", head=T, row=1, quote="", check.names=F)    
    return(list(m=m, o=o))
}

filter.data <- function(m, o, min.depth=1000)
{
    o <- o[,colSums(o) > min.depth] # drop low depth samples     
    valid <- intersect(colnames(o), rownames(m))
    m <- m[valid,]
    return(list(m=m, o=o))
}

# sokol
    # this dataset has 1 sample per person -- across body sites and disease states --
    # Although there are a variety of sample sites, only one sample per person is actually present in this dataset!
    # PARTICIPANT_ID and HOST_SUBJECT_ID appear to be meaningless!

    ret <- load.data("sokol/mapping-orig.txt", "sokol/gg/otutable.txt")
    ret2 <- filter.data(ret$m, ret$o) # filter samples at 1000 depth
    m <- ret2$m
    o <- ret2$o
    
    x <- reshape(data.frame(SAMPLEID=rownames(m), m[,c("BODY_SITE", "ULCERATIVE_COLIT_OR_CROHNS_DIS")], value=1), direction="wide", 
            idvar=c("SAMPLEID", "ULCERATIVE_COLIT_OR_CROHNS_DIS"), timevar="BODY_SITE")
    x[is.na(x)] <- 0
    
    table(m[,c("BODY_SITE","ULCERATIVE_COLIT_OR_CROHNS_DIS")])
    
    out <- m[m$BODY_SITE == "UBERON:feces" & m$ULCERATIVE_COLIT_OR_CROHNS_DIS %in% c("Crohn's disease", "Healthy", "Ulcerative Colitis"), "ULCERATIVE_COLIT_OR_CROHNS_DIS", drop=F]
    write.mapping("sokol/task-uc-cd-healthy.txt", out)

    out <- m[m$BODY_SITE == "UBERON:feces" & m$ULCERATIVE_COLIT_OR_CROHNS_DIS %in% c("Healthy", "Ulcerative Colitis"), "ULCERATIVE_COLIT_OR_CROHNS_DIS", drop=F]
    write.mapping("sokol/task-healthy-uc.txt", out)

    out <- m[m$BODY_SITE == "UBERON:feces" & m$ULCERATIVE_COLIT_OR_CROHNS_DIS %in% c("Healthy", "Crohn's disease"), "ULCERATIVE_COLIT_OR_CROHNS_DIS", drop=F]
    write.mapping("sokol/task-healthy-cd.txt", out)
    

# cho
    ret <- load.data("cho/mapping-orig.txt", "cho/gg/otutable.txt")
    sort(colSums(ret$o)) 
    ret2 <- filter.data(ret$m, ret$o) # no samples dropped
    m <- ret2$m
    o <- ret2$o
    
    dim(m[m$Source=="cecal",])
    write.mapping("cho/task-control-ct-cecal.txt", m[m$Source=="cecal" & m$Abx %in% c("Control", "Chlortetracycline"),"Abx", drop=F])

    write.mapping("cho/task-control-ct-fecal.txt", m[m$Source=="fecal" & m$Abx %in% c("Control", "Chlortetracycline"),"Abx", drop=F])

    write.mapping("cho/task-penicillin-vancomycin-cecal.txt", m[m$Source=="cecal" & m$Abx %in% c("Vancomycin", "Penicillin"),"Abx", drop=F])

    write.mapping("cho/task-penicillin-vancomycin-fecal.txt", m[m$Source=="fecal" & m$Abx %in% c("Vancomycin", "Penicillin"),"Abx", drop=F])

# claesson
    # this dataset has residence location in a suppl table - but unfortunately, most host IDs don't match with mapping 
    # so although the paper shows separation based on residence type, we'll only provide mapping for elderly vs young here

    # this is a special case because we need host characteristics from a supplementary table
    #    sup <- read.table("claesson/mapping-suppl.txt", sep="\t", comment="", head=T, quote="", as.is=T)
    #   rownames(sup) <- toupper(rownames(sup))
    #    m <- read.table("claesson/mapping-orig.txt", sep="\t", comment="", head=T, row=1, quote="", as.is=T)
    #    o <- read.table("claesson/gg/otutable.txt", sep="\t", comment="", head=T, row=1, check.names=F)    
    #    m <- data.frame(Row.names=rownames(m), m)
    #    m_sup <- merge(m, sup, by.x="HOST_SUBJECT_ID", by.y=0)
    #    rownames(m_sup) <- m_sup$Row.names
    
    ret <- load.data("claesson/mapping-orig.txt", "claesson/gg/otutable.txt")
    sort(colSums(ret$o)) 
    ret2 <- filter.data(ret$m, ret$o) # one sample dropped
    m <- ret2$m
    o <- ret2$o
    
    m$AGE <- as.character(m$AGE)
    # recode ages as Young and Elderly
    m[m$AGE!="None","AGE"] <- "Elderly"
    m[m$AGE=="None","AGE"] <- "Young"
    colnames(m) <- "Var"
    
    write.mapping("claesson/task.txt", m[,"AGE", drop=F])

# gevers 
    # CD versus no CD
    # Task 1, 2: rectal and ileal samples compared between CD and controls - RISK collection only (pediatric)
    # Task 3, 4: predict PCDAI scores collected 6 months later in CD patients (using ileum or rectum)
    
    ret <- load.data("gevers/mapping-orig.txt", "gevers/gg/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o, 100) # 1359 down to 451 samples
    m <- ret2$m
    o <- ret2$o

    # use of steroids or immunosuppressants were excluded, and ones in this dataset are from RISK
    m <- m[m$STEROIDS != "yes" & m$IMMUNOSUP != "yes" & m$COLLECTION=="RISK",]    
    m$SUBJECT_ID <- gsub("1939:", "", m$HOST_SUBJECT_ID)
 
    # supplementary table - contains PCDAI scores taken at 6 months. Note that this table contains multiple samples, but the scores are the same since they're taken per person.
    #x <- reshape(data.frame(sup[,c("subject", "sample_location", "PCDAI")]), direction="wide", idvar=c("subject"), timevar="sample_location")
    sup <- read.table("gevers/mapping-suppl.txt", sep="\t", comment="", head=T, quote="", as.is=T)
    sup <- sup[!duplicated(sup$subject),] # scores are the same for the subject across samples
    m_sup_subjects <- intersect(unique(m[m$DIAGNOSIS != "no","SUBJECT_ID"]), sup$subject)
    m_ilrec <- m[m$SUBJECT_ID %in% m_sup_subjects & m$BODY_SITE %in% c("UBERON:ileum", "UBERON:rectum"),c("SUBJECT_ID", "DIAGNOSIS", "BODY_SITE")]
    m_pcdai <- merge(m_ilrec, sup[,c("subject","PCDAI")], by.x="SUBJECT_ID", by.y="subject", all.x=T)
    rownames(m_pcdai) <- rownames(m_ilrec)

    write.mapping("gevers/task-pcdai-ileum.txt", m_pcdai[m_pcdai$BODY_SITE=="UBERON:ileum", "PCDAI", drop=F])
    write.mapping("gevers/task-pcdai-rectum.txt", m_pcdai[m_pcdai$BODY_SITE=="UBERON:rectum", "PCDAI", drop=F])
    
    rectum <- m[m$BODY_SITE=="UBERON:rectum",]
    sum(rectum$DIAGNOSIS == "CD" & !duplicated(rectum$HOST_SUBJECT_ID))
    sum(rectum$DIAGNOSIS == "no" & !duplicated(rectum$HOST_SUBJECT_ID))

    ileum <- m[m$STEROIDS != "yes" & m$IMMUNOSUP != "yes" & m$COLLECTION=="RISK" & m$BODY_SITE=="UBERON:ileum",]
    sum(ileum$DIAGNOSIS == "no" & !duplicated(ileum$HOST_SUBJECT_ID))
    sum(ileum$DIAGNOSIS == "CD" & !duplicated(ileum$HOST_SUBJECT_ID))
    
    write.mapping("gevers/task-ileum.txt", ileum[ileum$DIAGNOSIS %in% c("CD", "no"),"DIAGNOSIS", drop=F])
    write.mapping("gevers/task-rectum.txt", rectum[rectum$DIAGNOSIS %in% c("CD", "no"),"DIAGNOSIS", drop=F])
    
# hmp
    # some people have multiple samples from the same sites on the same day. mitigate this by using COLLECTDAY==0, and picking the first sample (e.g. if 2 fecal samples on day 0)

    ret <- load.data("hmp/mapping-orig.txt", "hmp/gg/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o, 100) 
    m <- ret2$m
    o <- ret2$o
    
    m <- m[m$COLLECTDAY=="0",]
    feces <- m[m$SPECIFIC_BODY_SITE=="UBERON:feces", ]
    feces <- feces[!duplicated(feces$HOST_SUBJECT_ID),]
    
    write.mapping("hmp/task-sex.txt", feces[,"SEX", drop=F])
    # this needs to be controlled for host id
    write.mapping("hmp/task-gastro-oral.txt", m[m$HMPBODYSUPERSITE %in% c("Gastrointestinal_tract", "Oral"),c("HMPBODYSUPERSITE","HOST_SUBJECT_ID")])

    # this has been filtered to more specific gastro/oral sites, with only 1 sample per person
    m_s <- m[m$HMPBODYSUBSITE =="Stool",c("HMPBODYSUBSITE", "HOST_SUBJECT_ID")]    
    m_t <- m[m$HMPBODYSUBSITE =="Tongue_dorsum", c("HMPBODYSUBSITE", "HOST_SUBJECT_ID")]
    m_st_subjects <- intersect(m_s$HOST_SUBJECT_ID, m_t$HOST_SUBJECT_ID)
    m_st <- rbind(m_s[m_s$HOST_SUBJECT_ID %in% m_st_subjects,], m_t[m_t$HOST_SUBJECT_ID %in% m_st_subjects,])
    write.mapping("hmp/task-stool-tongue-paired.txt", m_st)    
    
    m_s <- m[m$HMPBODYSUBSITE =="Subgingival_plaque",c("HMPBODYSUBSITE", "HOST_SUBJECT_ID")]    
    m_t <- m[m$HMPBODYSUBSITE =="Supragingival_plaque", c("HMPBODYSUBSITE", "HOST_SUBJECT_ID")]
    m_st_subjects <- intersect(m_s$HOST_SUBJECT_ID, m_t$HOST_SUBJECT_ID)
    m_st <- rbind(m_s[m_s$HOST_SUBJECT_ID %in% m_st_subjects,], m_t[m_t$HOST_SUBJECT_ID %in% m_st_subjects,])
    write.mapping("hmp/task-sub-supragingivalplaque-paired.txt", m_st)    

# kostic
    ret <- load.data("kostic/mapping-orig.txt", "kostic/gg/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o, 100) #dropped a few samples
    m <- ret2$m
    o <- ret2$o

    # not all hosts have paired samples. include only those that do.
    x <- reshape(data.frame(m[,c("HOST_SUBJECT_ID", "DIAGNOSIS")], value=1), direction="wide", idvar="HOST_SUBJECT_ID", timevar="DIAGNOSIS")
    rownames(x) <- x$HOST_SUBJECT_ID
    ids <- rownames(x[!is.na(x$value.Healthy) & !is.na(x$value.Tumor),])
    write.mapping("kostic/task.txt", m[m$HOST_SUBJECT_ID %in% ids, c("DIAGNOSIS", "HOST_SUBJECT_ID")])
    
# david
    # cross over study design
    # Diet: Plant, Animal; Day: -4 to -1 (baseline), 0 to 4 (diet), 5 to 10 (washout)
    ret <- load.data("david/mapping-orig.txt", "david/gg/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o, 100) 
    m <- ret2$m
    o <- ret2$o

    m <- m[!is.na(m$Day),] # remove food 
    m <- m[m$SubjectFood!="11",] # remove subject 11 because they appeared to dropped out
    
#     baseline <- m[m$Day < 0, ]
#     baseline.day <- aggregate(baseline$Day, by=list(baseline$SubjectFood, baseline$Diet), FUN=max)
#     colnames(baseline.day) <- c("Subject", "Diet", "Day")
   
    diet <- m[m$Day %in% 1:4,] 
    last.diet.day <- aggregate(diet$Day, by=list(diet$SubjectFood, diet$Diet), FUN=max)
    colnames(last.diet.day) <- c("SubjectFood", "Diet", "Day")
    
    m.last.diet <- merge(cbind(m,sample.id=rownames(m)), last.diet.day, by=colnames(last.diet.day))
    
    # just compare animal vs plant on Days 3 or 4 (whichever is the last day of the diet intervention)
    write.mapping("david/task.txt", m[m.last.diet$sample.id, "Diet", drop=F])
    
# turnbaugh
    ret <- load.data("turnbaugh/mapping-orig.txt", "turnbaugh/gg/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o, 100) 
    m <- ret2$m
    o <- ret2$o
    
    m_ol <- m[m$OBESITYCAT %in% c("Obese","Lean"), ]
    m_ol <- m_ol[!duplicated(m_ol$HOST_SUBJECT_ID),] # some subjects have multiple timepoints, so let's just get rid of them
    m_ol <- m_ol[, c("OBESITYCAT", "FAMILY", "ZYGOSITY")]
    
    m_ol[, "ControlVar"] <- m_ol[, "FAMILY"]
    
    write.mapping("turnbaugh/task-obese-lean-all.txt", m_ol[, c("OBESITYCAT", "ControlVar")])

    
# bushman 
    # n=10 individuals, controlled feeding on high fat or low fat diets for 10 days. See pronounced
    # changes immediately after day 1 (day 1 samples are outliers). But let's grab the last day available for all subjects
    # in order to examine the effects of diet on the microbiome
    
    # Subset by DAY (subject ID B.2004.08.S1.405610, see the ".08" means day 7)
    ret <- load.data("bushman_cafe/mapping-orig.txt", "bushman_cafe/gg/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o) 
    m <- ret2$m
    o <- ret2$o
    
    m$SAMPLE_DAY <- as.numeric(gsub( "\\..+", "", gsub("B\\.[0-9]{4}\\.", "", rownames(m))))

    m_max <- aggregate(m$SAMPLE_DAY, list(m$HOST_SUBJECT_ID), max)
    colnames(m_max) <- c("HOST_SUBJECT_ID","LAST_SAMPLE_DAY")
    
    out <- merge(data.frame(m[,c("HOST_SUBJECT_ID","SAMPLE_DAY", "DIET")],Row.names=rownames(m)), m_max, by=c(1,2))
    rownames(out) <- out$Row.names
    
    write.mapping("bushman_cafe/mapping.txt", out[,"DIET",drop=F])
    
# yatsunenko    
    ret <- load.data("yatsunenko/mapping-orig.txt", "yatsunenko/gg/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o) 
    m <- ret2$m
    o <- ret2$o

    m["Amz9baby.418635","COUNTRY"] <- "GAZ:Venezuela"    # fix mislabeled baby
    
    # remove any with "None" as AGE 
    m <- m[m$AGE!="None",]
    m$AGE <- as.numeric(m$AGE)
    
    write.mapping("yatsunenko/task-baby-age.txt", m[m$COUNTRY=="GAZ:United States of America" & m$AGE < 3, "AGE", drop=F])

    write.mapping("yatsunenko/task-usa-malawi.txt", m[m$COUNTRY %in% c("GAZ:United States of America", "GAZ:Malawi") & m$AGE > 18, "COUNTRY", drop=F])
    
    write.mapping("yatsunenko/task-malawi-venezuela.txt", m[m$COUNTRY %in% c("GAZ:Malawi", "GAZ:Venezuela") & m$AGE > 18, "COUNTRY", drop=F])
    
    write.mapping("yatsunenko/task-sex.txt", m[m$SEX != "unknown" & m$COUNTRY=="GAZ:United States of America" & m$AGE > 18, "SEX", drop=F])
    
    
# ravel (BV)
    # combine both mapping files and write it out as mapping-orig first
    #     m1 <- read.table("ravel/mapping-orig1.txt", sep="\t", comment="", head=T, row=1, quote="", as.is=T)
    #     m2 <- read.table("ravel/mapping-orig2.txt", sep="\t", comment="", head=T, row=1, quote="", as.is=T)
    #     m <- merge(m1[,c("Run_s", "Sample_Name_s")], m2[,1:6], by.x="Sample_Name_s", by.y=0)
    #     colnames(m) <- c("Subject.ID", "Sample.ID", "Ethnic_Group", "pH", "Nugent_score", "Nugent_score_category", "Community_group", "Total_number_reads")
    #     m <- m[,c(2, 1, 3:ncol(m))]
    #     rownames(m) <- m$Sample.ID
    #     m <- m[,-1]
    #     write.mapping("ravel/mapping-orig.txt", m)

    # high nugent score means subject is diagnosed with Bacterial Vaginosis
    ret <- load.data("ravel/mapping-orig.txt", "ravel/gg/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o)
    m <- ret2$m
    o <- ret2$o
    
    write.mapping("ravel/task-white-black.txt", m[m$Ethnic_Group %in% c("White", "Black"), "Ethnic_Group", drop=F])
    
    write.mapping("ravel/task-black-hispanic.txt", m[m$Ethnic_Group %in% c("Black", "Hispanic"), "Ethnic_Group", drop=F])
    
    write.mapping("ravel/task-nugent-category.txt", m[m$Nugent_score_category %in% c("low", "high"), "Nugent_score_category", drop=F])
    
    write.mapping("ravel/task-nugent-score.txt", m[, "Nugent_score", drop=F])    
    
    write.mapping("ravel/task-ph.txt", m[, "pH", drop=F])    
    
# karlsson
    ret <- load.data("karlsson/mapping-orig.txt", "karlsson/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o)
    m <- ret2$m
    o <- ret2$o
    
    write.mapping("karlsson/task-normal-diabetes.txt", m[m$Classification %in% c("NGT", "T2D"), "Classification", drop=F])
    write.mapping("karlsson/task-impaired-diabetes.txt", m[m$Classification %in% c("IGT", "T2D"), "Classification", drop=F])

# qin 2012 (diabetes)
    ret <- load.data("qin2012/mapping-orig.txt", "qin2012/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o)
    m <- ret2$m
    o <- ret2$o
    write.mapping("qin2012/task-healthy-diabetes.txt", m[m$Diabetic %in% c("Y", "N"), "Diabetic", drop=F])

# qin 2014 (cirrhosis)
    ret <- load.data("qin2014/mapping-orig.txt.txt", "qin2014/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o)
    m <- ret2$m
    o <- ret2$o
    write.mapping("qin2014/task-healthy-cirrhosis.txt", m[m$Cirrhotic %in% c("Cirrhosis", "Healthy"), "Cirrhotic", drop=F])
