# Multivariate analysis of biological data using R

### Aarhus University PhD Course

* Autumn 2022 running: September 19<sup>th</sup> &ndash; 23<sup>rd</sup>

### Slides

* [Monday](https://gavinsimpson.github.io/au-multivariate-stats/slides/01-dissimilarity-clustering-diversity/slides.html)

* [Tuesday](https://gavinsimpson.github.io/au-multivariate-stats/slides/02-unconstrained-ordination/slides.html)

* [Wednesday](https://gavinsimpson.github.io/au-multivariate-stats/slides/02-constrained-ordination/slides.html)

### Computing

* [Monday](https://gavinsimpson.github.io/au-multivariate-stats/computing/01-cluster-analysis/cluster-analysis.html)

* [Tuesday](https://gavinsimpson.github.io/au-multivariate-stats/computing/02-unconstrained-ordination/unconstrained-ordination.html)

## Objectives of the course

The aim of the course is to provide an introduction to the analysis of multivariate data arising from observation and experimental studies with the R statistical software.

## Learning outcomes and competences

After completing the course, participants will

1. have a good introductory understanding of the main approaches used in the analysis of multivariate data sets
2. be able to choose an appropriate method to use to analyse a data set
3. understand how to use restricted permutation tests with constrained ordination methods to test the effects of predictor variables or experimental treatments
4. be able to use the R statistical software to analyse multivariate data

## Compulsory programme

Active participation in the course including attendance at lectures and completion of computer-based classes and exercises. A learn-by-teaching approach will be used for the computer-based assessments, where each participant will be expected to, as part of a small group, demonstrate their approach to the analysis of a problem data set from the previous day. Completion of short, computer-based assessments testing their understanding of a topic and the practical skills taught.

## Course content

The course is based on a series of lectures and computer based practical classes led by an international expert in the analysis of multivariate data, who is also one of the senior developers of the vegan R package and the creator of the permute R package.

The course covers the following topics:

* An introduction to multivariate data and their analysis
* Dissimilarity and dissimilarity coefficients
* Cluster Analysis
* Unconstrained ordination
    - Principal Components Analysis
    - Correspondence Analysis
    - Principal Coordinates Analysis
    - Non-metric Multidimensional Scaling
* Constrained ordination
    - Redundancy Analysis
    - Canonical Correspondence Analysis
    - Distance-based Redundancy Analysis
    - PERMANOVA and PERMDISP
* Statistical testing using permutation tests
* The future of multivariate data analysis
* Introduction to recently-developed latent variable approaches to ordination

## Prerequisites

This course is suitable for Phd students (including senior thesis-based masters students) and researchers working with multivariate data sets in biology (inter alia animal science, ecology, agriculture, microbial ecology/microbiology). Some basic prior knowledge of R is required.

## Computing requirements

Participants need to bring their own laptop with the latest version of R installed (version 4.2.0 or later), as well as the current version of RStudio. If you use another editor for your R code feel free to use it instead of Rstudio, but we cannot help you if you encounter problems with it.

You can download R from [cloud.r-project.org](https://cloud.r-project.org/) and select from the three links at the top of the page as required for your operating system.

You can download RStudio from [www.rstudio.com](https://www.rstudio.com/products/rstudio/download/#download) and choose from the list of **installers** as appropriate for your operating system.

If you have already installed R and RStudio, please check that they are both up-to-date. Within R you can run:

```r
version
```

and look at the entry next to `version.string`:

```
r$> version                                                                     
               _                           
platform       x86_64-pc-linux-gnu         
arch           x86_64                      
os             linux-gnu                   
system         x86_64, linux-gnu           
status                                     
major          4                           
minor          2.1                         
year           2022                        
month          06                          
day            23                          
svn rev        82513                       
language       R                           
version.string R version 4.2.1 (2022-06-23)
nickname       Funny-Looking Kid
```

This should include `4.2.1` if you are running the latest release, but should be no lower than `4.2.0`. If the installed version of R is < 4.2.0, install a newver version of R by downloading and running one of the installers from [cloud.r-project.org](https://cloud.r-project.org/) as mentioned above.

To check that RStudio is up-to-date, open RStudio, open the Help menu, and choose *Check for Updates*. RStudio will then check to see if there is a newer version available and if there is it will give you the option to download the newer version.

Prior to arriving at AU Viborg on the 19th of September, make sure you have updated your installed R packages and that you have installed the following packages: tidyverse, vegan, mvabund, boral, ecoCopula, and cocorresp. To do this, open RStudio (or R) and in the console window (usually lower left, with a prompt that looks like `>`) run

```r
parallel::detectCores(logical = FALSE)
```

This checks to see how many CPU cores you have available, which we use in the next chunk. 

```r
update.packages(ask = FALSE, checkBuilt = TRUE, Ncpus = 4)
```

Change the value of `Ncpus` to the number cores you have on your computer as this will speed up package updates if you have many packages installed that require updating. If you want to work while this is being done, set `Ncpus` to a number less than that returned by `parallel::detectCores(logical = FALSE)`.

Now we can install the required packages

```r
install.packages(c("tidyverse", "vegan", "mvabund", "boral", "ecoCopula", "cocorresp"))
```

## Name of course leader

Gavin Simpson, Assistant Professor, Department of Animal Science, Aarhus University gavin@anivet.au.dk
