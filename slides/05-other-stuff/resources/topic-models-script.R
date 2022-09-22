## Fit a Topic Model to the Abernethy Forest data set

#install.packages("remotes")
remotes::install_github("gavinsimpson/ggvegan")

# install.packages("servr")

## Packages
library("topicmodels")
library("stm")
library("readr")
library("ggplot2")
library("tidyr")
library("cowplot")
theme_set(theme_bw())
library("analogue")
library("LDAvis")
library("ggvegan")
library('DirichletReg')
library('splines')

## Load data
aber <- read_rds('abernethy-count-data.rds')
## take a subset of spp
take <- c("BETULA", "PINUS_SYLVESTRIS", "ULMUS", "QUERCUS", "ALNUS_GLUTINOSA",
          "CORYLUS_MYRICA", "SALIX", "JUNIPERUS_COMMUNIS", "CALLUNA_VULGARIS",
          "EMPETRUM", "GRAMINEAE", "CYPERACEAE", "SOLIDAGO_TYPE",
          "COMPOSITAE_LIGULIFLORAE", "ARTEMISIA", "CARYOPHYLLACEAE_UNDIFFERENTIATED",
          "SAGINA", "SILENE_CF_S_ACAULIS", "CHENOPODIACEAE", "EPILOBIUM_TYPE",
          "PAPILIONACEAE_UNDIFFERENTIATED", "ANTHYLLIS_VULNERARIA",
          "ASTRAGALUS_ALPINUS", "ONONIS_TYPE", "ROSACEAE_UNDIFFERENTIATED",
          "RUBIACEAE", "RANUNCULACEAE_UNDIFFERENTIATED", "THALICTRUM",
          "RUMEX_ACETOSA_TYPE", "OXYRIA_TYPE", "PARNASSIA_PALUSTRIS",
          "SAXIFRAGA_GRANULATA", "SAXIFRAGA_HIRCULUS_TYPE", "SAXIFRAGA_NIVALIS",
          "SAXIFRAGA_OPPOSITIFOLIA", "SAXIFRAGA_UNDIFFERENTIATED", "SEDUM",
          "URTICA", "VERONICA")
## Don't do this!
##take <- c(1,2,3,4,6,10,11,12,14,15,39,40,41,42,43,46,49,50,53,54,57,58,59,60,67,
##          69,70,72,74,75,83,85,86)
aber <- aber[, take]
## are any columns now all zeroes?
allMissing <- unname(vapply(aber, function(x) all(is.na(x)), logical(1)))
## drop those with all NA
aber <- aber[, !allMissing]
## change all the NA to 0s
aber <- tran(aber, method = "missing")
## check that all remaining values are numeric
stopifnot(all(vapply(aber, data.class, character(1), USE.NAMES = FALSE) == "numeric"))
## check all columns still have at least 1 positive count
cs <- colSums(aber) > 0L
aber <- aber[, cs]
names(aber) <- tolower(names(aber))
## aber ages
aberAge <- read_rds('abernethy-sample-age.rds')

## Models to fit
k <- 2:10 # 2, 3, ... 10 associations / groups
## setting the same random seed for each model
reps <- length(k)
ctrl <- replicate(reps, list(seed = 42), simplify = FALSE)
## repeat the data n times to facilitate `mapply`
aberrep <- replicate(reps, aber, simplify = FALSE)
# fit the sequence of topic models
tms <- mapply(LDA, k = k, x = aberrep, control = ctrl)

## extract model fit in terms of BIC and plot
plot(k, sapply(tms, AIC, k = log(nrow(aber))))

## so 5 groups looks OK
k.take <- 5
## which is the 5 group model?
k.ind <- which(k == k.take)
## could also selected purely on BIC terms...
k.bic <- which.min(sapply(tms, AIC, k = log(nrow(aber))))
## but we'll take the model with 5 groups
aberlda <- tms[[k.ind]]

## extract the posteriorfitted distribution of the model
aberPosterior <- posterior(aberlda)
## topic proportions
aberTopics <- aberPosterior$topics
## term proportions
aberTerms <- aberPosterior$terms

## Visualise with LDAvis package

## LDAvis
## Need a wrapper to automate this process
wrapper <- function(lda, data, ...) {
    phi   <- as.matrix(posterior(lda)$terms)
    theta <- as.matrix(posterior(lda)$topics)
    vocab <- colnames(phi)
    doc.length <- unname(rowSums(data))
    term.frequency <- unname(colSums(data))
    LDAvis::createJSON(phi = phi, theta = theta, vocab = vocab,
                       doc.length = doc.length,
                       term.frequency = term.frequency,
                       ...)
}

## and wrappers to apply different ordination methods for display
caWrapper <- function(phi) {
    scores(cca(phi), choices = 1:2, display = "sites", scaling = "sites")
}

pcaWrapper <- function(phi) {
    scores(rda(phi), choices = 1:2, display = "sites", scaling = "sites")
}

pcahWrapper <- function(phi) {
    scores(rda(decostand(phi, method = "hellinger")), choices = 1:2,
           display = "sites", scaling = "sites")
}

nmdsWrapper <- function(phi) {
    scores(metaMDS(phi, distance = "manhattan", trace = FALSE, try = 10, trymax = 20),
           choices = 1:2, display = "sites", scaling = "sites")
}

## apply our wrapper, here with PCA on Hellinger transformed topic proportions
aberJSON <- wrapper(aberlda, aber, mds.method = pcahWrapper)

## run the shiny app to explore the data
serVis(aberJSON)

visArea <- function(topics, data) {
    Nk <- as.vector(t(topics) %*% rowSums(data))
    names(Nk) <- colnames(topics)
    Nk / sum(Nk)
}

## get "time" WA optima to sort topics
aberPosterior <- posterior(aberlda)
aberTopics <- aberPosterior$topics
aberTerms <- aberPosterior$terms
colnames(aberTopics) <- seq_len(k.take)[rank(-visArea(aberTopics, aber))]
aberTopics <- aberTopics[, as.character(seq_len(k.take))]
lda_waopt <- optima(as.data.frame(aberTopics), env = aberAge$Age)
## tidy the Topic proportions
topicsDF <- transform(setNames(as.data.frame(aberTopics),
                               paste0("Assoc", seq_len(k.take)[rank(-visArea(aberTopics, aber))])),#seq_len(ncol(aberTopics)))),
                      Age = aberAge$Age)
topicsDF <- gather(topicsDF, Assoc, Proportion, - Age)
## reorder the topics in increasing order of WA optims for "time"
topicsDF <- transform(topicsDF,
                      Assoc = factor(Assoc, levels = paste0("Assoc", names(sort(lda_waopt)))))

ggplot(topicsDF, aes(x = Age, y = Proportion, group = Assoc, colour = Assoc)) +
    geom_line(size = 1) + labs(x = "Radiocarbon years BP") +
    theme(legend.position = "none") + facet_grid(Assoc ~ .) +
    scale_x_reverse()

## Dirichlet regression
y_response <- DR_data(aberTopics)
topicm_dirch <- DirichReg(y_response ~ ns(-Age, df = 10), data = aberAge)

topicm_dirch

## predict from the model
newAge <- with(aberAge, data.frame(Age = seq(min(Age), max(Age), length = 200)))
topicm_dirch_p <- predict(topicm_dirch, newdata = newAge,
                          alpha = FALSE, mu = TRUE)
names(topicm_dirch_p) <- paste('Assoc', 1:5)
dirreg_pred <- cbind(newAge, topicm_dirch_p)

dirreg_pred <- gather(dirreg_pred, Association, Proportion, -Age)

ggplot(dirreg_pred, aes(x = Age, y = Proportion, colour = Association)) +
    geom_line() +
    scale_x_reverse()

ggplot(dirreg_pred, aes(x = Age, y = Proportion, fill = Association)) +
    geom_area(position = 'stack', colour = 'black') +
    scale_x_reverse()

## Fit a Structural Topic Model to the Abernethy Forest data set
## With no coavriates this is a correlated topic model

## convert to a corpus
corpus <- readCorpus(aber, type = "dtm")

## how many topics
stms <- searchK(documents = corpus$documents,
               vocab = corpus$vocab,
               K = 2:10,
               max.em.its = 200,
               init.type = "Spectral")

## plot
plot(stms)

## fit the STM
system.time({
fit <- stm(documents = corpus$documents,
           vocab = corpus$vocab,
           K = 5,
           max.em.its = 200,
           init.type = "Spectral")
})

## what taxa characterise each topic?
labelTopics(fit)

## Model the topic proportions using Dirichlet regression
aberTopics <- fit$theta
y_response <- DR_data(aberTopics)
topicm_dirch <- DirichReg(y_response ~ ns(-Age, df = 10), data = aberAge)

newAge <- with(aberAge, data.frame(Age = seq(min(Age), max(Age), length = 200)))
topicm_dirch_p <- predict(topicm_dirch, newdata = newAge,
                          alpha = FALSE, mu = TRUE)
names(topicm_dirch_p) <- paste('Assoc', 1:5)
dirreg_pred <- cbind(newAge, topicm_dirch_p)

dirreg_pred <- gather(dirreg_pred, Association, Proportion, -Age)

ggplot(dirreg_pred, aes(x = Age, y = Proportion, colour = Association)) +
    geom_line() +
    scale_x_reverse()

ggplot(dirreg_pred, aes(x = Age, y = Proportion, fill = Association)) +
    geom_area(position = 'stack', colour = 'black') +
    scale_x_reverse()

## Could use brms package to fit the Dirichlet regression using penalised splines
## so selecting how wiggly or smoothly over time the proportions change
