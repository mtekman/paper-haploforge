library(ggplot2)
library(grid)
library(gridExtra)
library(scales)

                                        #Functions
g_legend<-function(a.gplot){ 
  tmp <- ggplot_gtable(ggplot_build(a.gplot)) 
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box") 
  legend <- tmp$grobs[[leg]] 
  return(legend)}

scaleFUN <- function(x) {sprintf("%.0f", x)}

inc <- function(obj,y){ eval.parent(substitute(obj <- obj + y)) }


#####
data <- read.table('table_data/copper_and_brocolli.runtimes.2017_06.table', header=TRUE)
#bt <- read.table('table_data/brocolli.runtimes.2017_06_26.table', header=TRUE)
#ct <- read.table('table_data/copper.runtimes.trios.2017_06_27.table', header=TRUE)

title <- paste("Box Plot of", nrow(data), "Nuclear Family Trios (2 Founders and 1 Non-Founder)\n", sep=" ")

p <- ggplot(data, aes(x=Allele, y=TimeRend, group=Allele)) +
    ylab("\nRun Time (ms)") +
    xlab("Number of Markers\n") +
    ggtitle(title) +
    scale_x_continuous(breaks=c(0, 1e5, 2e5, 3e5, 4e5, 5e5, 6e5, 7e5, 8e5, 9e5, 1e6), limits=c(6e4,1e6+50000), labels=scaleFUN) +
    scale_y_continuous(breaks=c(0, 1e5, 2e5, 3e5, 4e5, 5e5, 6e5, 7e5, 8e5, 9e5, 10e5, 11e5, 12e5), labels=scaleFUN) +    
    #scale_color_gradient(low="light grey", high="black", name="Recombinant Alleles" ) +
    scale_shape(name="Root Founders") +
    theme(
      legend.title = element_text(size=rel(0.7)),
      axis.text.y = element_text(size=rel(0.8)),
      axis.text.x = element_text(size=rel(0.8)),
      plot.title = element_text(hjust = 0.5),
 )

#ggplot(broc3[broc3$Allele > 100000 & broc3$TimeRend < 50000,], aes(x=Allele, y=TimeRend, group=Allele)) + geom_boxplot(notch=FALSE, fill="grey", width=rel(20000))

p <- p + stat_boxplot(geom ='errorbar', coef=10, width=20000) + geom_boxplot(notch=FALSE, fill='white', coef=10, width=rel(50000)) + coord_flip() 
svg(filename="figs1_trio_plot.svg", width=10, height=6)
print(p)
dev.off()
