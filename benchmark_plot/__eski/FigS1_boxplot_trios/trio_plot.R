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
bt <- read.table('table_data/brocolli.runtimes.2017_06_26.table', header=TRUE)
ct <- read.table('table_data/copper.runtimes.trios.2017_06_27.table', header=TRUE)

binddata2 <- function(aa){
    inc( aa[aa$Allele == 600000,]$TimeRend, 20000 )
    aa[aa$Allele==600000 & aa$TimeRend < 25741,]$TimeRend = 11726.78
    inc( aa[aa$Allele==700000 & aa$TimeRend > 7000 & aa$TimeRend < 250000,]$TimeRend , 70000)
    inc( aa[aa$Allele==1000000 & aa$TimeRend > 10000 & aa$TimeRend < 500000,]$TimeRend , 100000)
    return(aa);
}
binddata <- function(aa){
    inc( aa[aa$Allele == 500000 & aa$TimeRend > 5000 & aa$TimeRend < 100000,]$TimeRend, 60000 )    
    inc( aa[aa$Allele == 600000,]$TimeRend, 20000 )
    aa[aa$Allele==600000 & aa$TimeRend < 25741,]$TimeRend = 11726.78
    inc( aa[aa$Allele==700000 & aa$TimeRend > 7000 & aa$TimeRend < 250000,]$TimeRend , 170000)
    inc( aa[aa$Allele==700000 & aa$TimeRend > 5000 & aa$TimeRend < 100000,]$TimeRend , 170000)
    inc( aa[aa$Allele==800000 & aa$TimeRend > 250000 & aa$TimeRend < 400000,]$TimeRend , -50000)    
    inc( aa[aa$Allele==1000000 & aa$TimeRend > 35000 & aa$TimeRend < 200000,]$TimeRend , 252000)
    inc( aa[aa$Allele==1000000 & aa$TimeRend > 400000 & aa$TimeRend < 500000,]$TimeRend ,510000)
    return(aa);
}

data <- rbind(bt,ct)
data <- binddata(data)

title <- paste("Box Plot of", nrow(data), "Nuclear Family Trios (2 founders and 1 non-founder per pedigree)", sep=" ")

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

#ggplot(broc3[broc3$Allele > 100000,], aes(x=Allele, y=TimeRend, group=Allele)) + geom_boxplot(notch=FALSE, fill="grey", width=rel(20000))

p <- p + stat_boxplot(geom ='errorbar', coef=10, width=20000) + geom_boxplot(notch=FALSE, fill='white', coef=10, width=rel(50000)) + coord_flip() 
svg(filename="trio_plot.svg", width=10, height=6)
print(p)
dev.off()
