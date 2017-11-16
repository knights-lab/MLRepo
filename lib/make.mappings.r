setwd("/Users/pvangay/Dropbox/UMN/KnightsLab/MLRepo/datasets")

write.mapping <- function(filename, map)
{
    cat("#SampleID\t", file=filename)
    write.table(map, file=filename, sep="\t", quote=F, append=T)
}

load.data <- function(mapfile, otufile)
{
    m <- read.table(mapfile, sep="\t", comment="", head=T, row=1, quote="", as.is=T)
    o <- read.table(otufile, sep="\t", comment="", head=T, row=1, check.names=F)    
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
    
    write.mapping("sokol/mapping.txt", out)
    

# cho
    ret <- load.data("cho/mapping-orig.txt", "cho/gg/otutable.txt")
    sort(colSums(ret$o)) 
    ret2 <- filter.data(ret$m, ret$o) # no samples dropped
    m <- ret2$m
    o <- ret2$o
    
    dim(m[m$Source=="cecal",])
    write.mapping("cho/mapping-cecal.txt", m[m$Source=="cecal","Abx", drop=F])

    dim(m[m$Source=="fecal",])
    write.mapping("cho/mapping-fecal.txt", m[m$Source=="fecal","Abx", drop=F])

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

    write.mapping("claesson/mapping.txt", m[,"AGE", drop=F])

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

    write.mapping("gevers/mapping-pcdai-ileum.txt", m_pcdai[m_pcdai$BODY_SITE=="UBERON:ileum", "PCDAI", drop=F])
    write.mapping("gevers/mapping-pcdai-rectum.txt", m_pcdai[m_pcdai$BODY_SITE=="UBERON:rectum", "PCDAI", drop=F])
    
    rectum <- m[m$BODY_SITE=="UBERON:rectum",]
    sum(rectum$DIAGNOSIS == "CD" & !duplicated(rectum$HOST_SUBJECT_ID))
    sum(rectum$DIAGNOSIS == "no" & !duplicated(rectum$HOST_SUBJECT_ID))

    ileum <- m[m$STEROIDS != "yes" & m$IMMUNOSUP != "yes" & m$COLLECTION=="RISK" & m$BODY_SITE=="UBERON:ileum",]
    sum(ileum$DIAGNOSIS == "no" & !duplicated(ileum$HOST_SUBJECT_ID))
    sum(ileum$DIAGNOSIS == "CD" & !duplicated(ileum$HOST_SUBJECT_ID))
    
    write.mapping("gevers/mapping-ileum.txt", ileum[ileum$DIAGNOSIS %in% c("CD", "no"),"DIAGNOSIS", drop=F])
    write.mapping("gevers/mapping-rectum.txt", rectum[rectum$DIAGNOSIS %in% c("CD", "no"),"DIAGNOSIS", drop=F])
    
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
    
    write.mapping("hmp/mapping-sex.txt", feces[,"SEX", drop=F])
    # this needs to be controlled for host id
    write.mapping("hmp/mapping-gastro-oral.txt", m[m$HMPBODYSUPERSITE %in% c("Gastrointestinal_tract", "Oral"),c("HMPBODYSUPERSITE","HOST_SUBJECT_ID")])

    # this has been filtered to more specific gastro/oral sites, with only 1 sample per person
    m_s <- m[m$HMPBODYSUBSITE =="Stool",c("HMPBODYSUBSITE", "HOST_SUBJECT_ID")]    
    m_t <- m[m$HMPBODYSUBSITE =="Tongue_dorsum", c("HMPBODYSUBSITE", "HOST_SUBJECT_ID")]
    m_st_subjects <- intersect(m_s$HOST_SUBJECT_ID, m_t$HOST_SUBJECT_ID)
    m_st <- rbind(m_s[m_s$HOST_SUBJECT_ID %in% m_st_subjects,], m_t[m_t$HOST_SUBJECT_ID %in% m_st_subjects,])
    write.mapping("hmp/mapping-stool-tongue-paired.txt", m_st)    
    
    m_s <- m[m$HMPBODYSUBSITE =="Subgingival_plaque",c("HMPBODYSUBSITE", "HOST_SUBJECT_ID")]    
    m_t <- m[m$HMPBODYSUBSITE =="Supragingival_plaque", c("HMPBODYSUBSITE", "HOST_SUBJECT_ID")]
    m_st_subjects <- intersect(m_s$HOST_SUBJECT_ID, m_t$HOST_SUBJECT_ID)
    m_st <- rbind(m_s[m_s$HOST_SUBJECT_ID %in% m_st_subjects,], m_t[m_t$HOST_SUBJECT_ID %in% m_st_subjects,])
    write.mapping("hmp/mapping-sub-supragingivalplaque-paired.txt", m_st)    

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
    write.mapping("kostic/mapping.txt", m[m$HOST_SUBJECT_ID %in% ids, c("HOST_SUBJECT_ID", "DIAGNOSIS")])
    
# david
    ret <- load.data("david/mapping-orig.txt", "david/gg/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o, 100) 
    m <- ret2$m
    o <- ret2$o

    # animal vs plant on Day 5 (first washout day, immediately after animal or plant diet intervention)
    write.mapping("david/mapping.txt", m[!is.na(m$Day) & m$Day=="5", "Diet", drop=F])
    
# turnbaugh
    ret <- load.data("turnbaugh/mapping-orig.txt", "turnbaugh/gg/otutable.txt")
    sort(colSums(ret$o), decreasing=T) 
    ret2 <- filter.data(ret$m, ret$o, 100) 
    m <- ret2$m
    o <- ret2$o
    m <- m[!duplicated(m$HOST_SUBJECT_ID),] # some subjects have multiple timepoints, so let's just get rid of them
    
    m_ol <- m[m$OBESITYCAT %in% c("Obese","Lean"), c("OBESITYCAT", "ZYGOSITY")]
    m_ol$ZYGOSITY[is.na(m_ol$ZYGOSITY)] <- "Mom"
    write.mapping("turnbaugh/mapping-obese-lean-all.txt", m_ol)
    
    write.mapping("turnbaugh/mapping-obese-lean-MZ.txt", m_ol[m_ol$ZYGOSITY=="MZ", "ZYGOSITY", drop=F])
    
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
    
    write.mapping("yatsunenko/mapping-baby-age.txt", m[m$COUNTRY=="GAZ:United States of America" & m$AGE < 3, "AGE", drop=F])

    write.mapping("yatsunenko/mapping-usa-malawi.txt", m[m$COUNTRY %in% c("GAZ:United States of America", "GAZ:Malawi") & m$AGE > 3, "COUNTRY", drop=F])

    write.mapping("yatsunenko/mapping-malawi-venezuela.txt", m[m$COUNTRY %in% c("GAZ:Malawi", "GAZ:Venezuela") & m$AGE > 3, "COUNTRY", drop=F])
    
    write.mapping("yatsunenko/mapping-sex.txt", m[m$SEX != "unknown" & m$COUNTRY=="GAZ:United States of America" & m$AGE > 3, "SEX", drop=F])