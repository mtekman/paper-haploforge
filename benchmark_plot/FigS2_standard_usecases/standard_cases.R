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

#dat <- rbind(broc3,coppr2)
dat <- rbind(broc1,broc2,broc3,coppr1,coppr2)
df <- dat[dat$TotalPeople <= 100 & dat$Allele <= 1000,]


title <- paste("Scatter Plot of", nrow(df), "Standard Use-case Pedigrees (", "\u2264"  ,"100 Individuals," , "\u2264", "1000 Markers)\n", sep=" ")


p <- ggplot(NULL, aes(x=TimeRend,y=TotalPeople, color=MaxGen, shape=factor(NumRootFounder), size=Allele)) +
    xlab("\nRun Time (ms)") +
    ylab("Number of Individuals\n") +
    ggtitle(title) +
    scale_x_continuous(breaks=c(0, 1e2, 2e2, 3e2, 4e2, 5e2, 6e2, 7e2, 8e2, 9e2, 1e3), labels=scaleFUN) +
    scale_color_gradient(low="dark grey", high="black", name="Generations", limits=c(2,10)) +
    scale_shape(name="Root Founders") +
    scale_radius(trans="log", range=c(1,5), breaks=c(10,100,1000), name="Number of Markers") +
    theme(
        plot.title = element_text(hjust = 0.5),
        legend.title = element_text(size=rel(0.7)),
        axis.text.y  = element_text(size=rel(0.8)),
        axis.text.x  = element_text(size=rel(0.8)),
        )

# Legend order
p <- p + guides( shape = guide_legend(order=1), size = guide_legend(order=2) )

# Layer larger alleles over smaller
p <- p +
    geom_point(data=df[df$Allele ==1000,]) +
    geom_point(data=df[df$Allele ==500,]) +
    geom_point(data=df[df$Allele ==100,]) +
    geom_point(data=df[df$Allele ==10,]) 


svg(filename="figs2_standard_usecase_plot.svg", width=10, height=6)
print(p)
dev.off()
