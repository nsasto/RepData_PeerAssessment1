###########################################################
#                                                         #
# assignment.R                                            #
# contains rough workings for reproducible research       #
# assignment 1.                                           #
# Final outputs available in PA1_template.Rmd             #
#                                                         #
###########################################################

temp <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip",temp)
data <- read.csv(unz(temp, "activity.csv"), header=T)
unlink(temp)

summary(data$steps)

library(data.table)
dt<-data.table(data)
dt.agg <- dt[, sum(steps, na.rm=T), by=date]
hist(dt.agg$V1 , main="Histogram of Total Number of Steps /Day")

library(xtable)
# Transpose summary table to a format xtable can use
dt.sum <- summary(dt.agg$V1)
dt.t <- t(t(dt.sum))
xt <- xtable(dt.t)
#output results which include mean and median
print(xt, type='html')

#get rid of NA values for mean calcs
d<-na.omit(dt)
dt.ave <- d[, mean(steps, na.rm=T), by=interval]
setnames(dt.ave,c('interval','steps'))
plot(dt.ave$interval,dt.ave$steps, type="l")

maxInterval <- dt.ave[dt.ave$steps==max(dt.ave$steps)]

dt.noNA <- data[!is.na(data$steps),]
dt.na <- data[is.na(data$steps),]
dt.m <- merge(x=dt.na, y=dt.ave, by='interval')
dt.impute <- rbind(dt.noNA, data.table(interval=dt.m$interval, steps=dt.m$steps.y, date=dt.m$date), use.names=T)

dt.aggImpute <- dt.impute[, sum(steps, na.rm=T), by=date]
hist(dt.aggImpute$V1 , main="Histogram of Total Number of Steps /Day")

dt.sum <- summary(dt.aggImpute$V1)
dt.t2 <- t(t(dt.sum))
xt <- xtable(dt.t2)
#output results which include mean and median
print(xt, type='html')

dt.impute$date<- as.Date(dt.impute$date, format = "%Y-%m-%d")
#now we use the weekday function to add day
dt.impute[, day := weekdays(date)][,isWeekend:=day %in% c('Saturday','Sunday')][,dayType :=factor(isWeekend,levels=c(F,T),labels=c('Weekday','Weekend'))]

x <- dt.impute[,mean(steps), by=list(interval, dayType)]
setnames(x, c('interval','dayType','steps'))

plot(x$interval, x$avgsteps, type='l')

#plot panels with ggplot
p <- ggplot(x, aes(interval, steps)) + geom_line()
p+facet_grid(dayType~.)

#alternative plot with lattice
library(lattice)
xyplot(x$steps ~ x$interval |
         x$dayType, layout = c(1, 2), type = "l", xlab = "Interval", ylab = "Number of steps")

we<-x[x$dayType=='Weekend']
wd<-x[x$dayType=='Weekday']


plot(we$interval, we$avgsteps, type='l')
plot(wd$interval, wd$avgsteps, type='l')

summary(we)
summary(wd)
hist(we$steps)
hist(wd$steps)

knit('PA1_template.Rmd','PA1_template.md')
