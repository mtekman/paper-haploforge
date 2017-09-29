library(ggplot2)

broc1 <- read.table('tables/broccolli_runtimes_late.table', header= TRUE)
broc2 <- read.table('tables/broccolli_runtimes_final.table', header= TRUE)
coppr <- read.table('tables/copper.runtimes.early.table', header=TRUE)

data <- rbind(broc1,broc2,coppr)

alleleplots <- split(data, data$Allele)

if (TRUE){
   print (names(alleleplots));
   print (names(alleleplots$`100`));
}


fmt_dcimals <- function(decimals=0){
   # return a function responpsible for formatting the 
   # axis labels with a given number of decimals 
   function(x) as.character(round(x,decimals))
}

scaleFUN <- function(x) sprintf("%d", x)

p <- ggplot(NULL, aes(x=TimeRend,y=TotalPeople, color=MaxGen, size=Allele));
p <- p + scale_color_gradient(low="light grey", high="black");
p <- p + scale_size(range = c(0.1,10) );
p <- p + xlab("Time (ms)") + ylab("Number of Individuals")
p <- p + scale_x_continuous(labels = scaleFUN);
p <- p + xlim(0,50000) + ylim(0,5000);


p <- p + geom_point(data=alleleplots$`10`); 
p <- p + geom_point(data=alleleplots$`100`); 
p <- p + geom_point(data=alleleplots$`1000`); 
p <- p + geom_point(data=alleleplots$`10000`); 
p <- p + geom_point(data=alleleplots$`100000`); 

p
