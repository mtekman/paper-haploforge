library(ggplot2)
library(grid)
library(gridExtra)
library(scales)

#Extract Legend 
g_legend<-function(a.gplot){ 
  tmp <- ggplot_gtable(ggplot_build(a.gplot)) 
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box") 
  legend <- tmp$grobs[[leg]] 
  return(legend)}

scaleFUN <- function(x) sprintf("%.0f", x)


broc1 <- read.table('tables/broccolli_runtimes_late.table', header= TRUE)
broc2 <- read.table('tables/broccolli_runtimes.latestlatest.table', header= TRUE)
broc3 <- read.table('tables/broccolli_runtimes.20170726.table', header=TRUE)
coppr1 <- read.table('tables/copper.runtimes.early.table', header=TRUE)
coppr2 <- read.table('tables/copper.20170621_1049.table', header=TRUE)
coppr3 <- read.table('tables/copper.20170626.table', header=TRUE)
all1   <- read.table('tables/copper_and_brocolli.runtimes.2017_06.table', header=TRUE)

dat <- rbind(broc1,broc2,broc3,coppr1,coppr2, coppr3, all1)
dat <- dat[dat$TotalPeople > 60 & dat$TotalPeople < 2000,]

title <- paste("Scatter Plot of", nrow(dat), "Large Pedigrees ( 100 - 2000 Individuals )\n", sep=" ")


p <- ggplot(NULL, aes(x=TimeRend,y=TotalPeople, color=MaxGen, shape=factor(NumRootFounder), size=Allele)) +
     xlab("\nRun Time (ms)") +
     ylab("Number of Individuals\n") +
     ggtitle(title) +
    scale_x_continuous(breaks=c(0, 5e3, 10e3, 15e3, 20e3, 25e3, 30e3, 35e3, 40e3), limits=c(0,40e3), labels=scaleFUN) +
    scale_color_gradient(low="dark grey", high="black", name="Generations" ) +
    scale_shape(name="Root Founders", breaks=c(1,2,3,4,5,10)) +
    scale_radius(trans="log", range=c(1,3.5), breaks=c(10,100,1000,10000), name="Number of Markers") +
     theme(
         plot.title = element_text(hjust = 0.5),
         legend.title = element_text(size=rel(0.7)),
         axis.text.y  = element_text(size=rel(0.8)),
         axis.text.x  = element_text(size=rel(0.8))
     )

# Legend order
p <- p + guides( shape = guide_legend(order=1), size = guide_legend(order=2) )

# Layer larger alleles over smaller
# sort(unique(dat$Allele))
p <- p + 
    geom_point(data=dat[dat$Allele == 10000,]) +
    geom_point(data=dat[dat$Allele == 9000,]) +
    geom_point(data=dat[dat$Allele == 8000,]) +
    geom_point(data=dat[dat$Allele == 7000,]) +
    geom_point(data=dat[dat$Allele == 6000,]) +
    geom_point(data=dat[dat$Allele == 5000,]) +
    geom_point(data=dat[dat$Allele == 4000,]) +
    geom_point(data=dat[dat$Allele == 3000,]) +
    geom_point(data=dat[dat$Allele == 2000,]) +
    geom_point(data=dat[dat$Allele == 1000,]) +
    geom_point(data=dat[dat$Allele == 500,]) +
    geom_point(data=dat[dat$Allele == 100,]) +
    geom_point(data=dat[dat$Allele == 10,])


svg(filename="figs3_large_peds.svg", width=10, height=6)
print(p)
dev.off()
