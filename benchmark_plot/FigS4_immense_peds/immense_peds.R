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

dat1 <- rbind(broc1,broc2,broc3,coppr1,coppr2, coppr3, all1)
dat <- dat1[dat1$TotalPeople >= 2000,]

title <- paste("Scatter Plot of", nrow(dat), "Immense Pedigrees ( > 2000 Individuals )\n", sep=" ")


p <- ggplot(NULL, aes(x=TimeRend,y=TotalPeople, color=MaxGen, shape=factor(NumRootFounder), size=Allele)) +
    xlab("\nRun Time (ms)") +
    ylab("Number of Individuals\n") +
    ggtitle(title) +
    #scale_x_continuous(breaks=c(0, 5e3, 10e3, 15e3, 20e3, 25e3, 30e3, 35e3, 40e3), limits=c(0,40e3), labels=scaleFUN) +
    scale_y_continuous(breaks=c(0,2000,4000,6000,8000,10000,12000,14000), limits=c(1500,14000)) +
    scale_color_gradient(low="dark grey", high="black", name="Generations", breaks=c(8,9)) +
    scale_shape(name="Root Founders") +
    scale_radius(trans="log", range=c(1,4.5), breaks=c(10,100,1000), name="Number of Markers") +
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
p <- p + geom_point(data=dat)

svg(filename="figs4_immense_peds.svg", width=10, height=6)
print(p)
dev.off()
