# 4+1
4+1
4-2
4*2
4/3
b <- 0
2* b 
d <- c (2, 3,4 ,4 ,5)
3* d
#set computer folder 
setwd("~/Desktop/SIOC209C")
setwd("~/Desktop/Lab2")
data1 <- read.csv("Lab_2_data.csv")
data2 <- read.csv("plots1.csv")
View(data2)
View(data1)
head(data1)
summary(data2)
data2$tide <- as.factor(data2$tide)
data2$Age2 <- as.factor(data2$Age2)
plot(x=data2$Age2, y =data2$tide )
summary(data1$Elephant.Herd.Size)
data_Fish_size <- data2[data2$Fish_size=="Fish_size", 1:4 ]
data_Age2 <- data2[data2$Age2=="old",  ]
data_Sample <- c(112, 128, 108, 129, 125, 153, 155, 132, 137)
summary(data_Sample)
var(data_Sample)
sd(data_Sample)
data_waxbill <- c(8,8,8,8,8,8,8,8,8,8,6,7,7,7,7,7,7)
data_finch <- c(16,16,16,16,16,16,12,15,15,15,15,17)
data_weaver <- c(40,43,37,38,43,33,35,37,36,42,36,36,39,37,34,41)
summary(data_finch)
summary(data_waxbill)
summary(data_weaver)
var(data_finch)
var(data_waxbill)
var(data_weaver)
sd(data_finch)/15.42
sd(data_weaver)/37.94
sd(data_waxbill)/7.529
4.6/sqrt(6228)
6.7/sqrt(4620)
