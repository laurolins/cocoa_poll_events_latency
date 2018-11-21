y.cap <- 16

table <- read.csv("ticks",sep="|")
y <- table$t / 1e6  # make it microseconds
y <- pmin(y,y.cap)

e <- table$e
x <- 1:nrow(table)
y.rng <- range(y)

filename <- sprintf("nextEventMatchingMask_%s.pdf", format(Sys.time(), "%Y%m%d%H%M%S"))
pdf(filename, width=20,height=12,pointsize=18)

par(mar=c(3,5,1,1))
par(mfrow=c(2,1))

plot(0,type="n",xlim=range(x),ylim=y.rng,xlab="",ylab="milliseconds",axes=F)
box()
xticks <- pretty(x)
yticks <- pretty(y.rng)
abline(h=yticks,col=gray(0.8))
abline(v=xticks,col=gray(0.8))
abline(h=16,col="red",lwd=2)
text(x, y, labels=e, adj=c(-0.5,-0.5), col="#00000088")
axis(1,xticks,las=2,cex.axis=1)
axis(2,yticks,las=1,cex.axis=1)

# log scale
y.rng.log<-c(0,2)
plot(0,type="n",xlim=range(x),ylim=y.rng.log,xlab="",ylab="milliseconds zoomed [0 to 2ms]",axes=F)
box()
xticks <- pretty(x)
yticks.log <- pretty(y.rng.log)
abline(h=yticks.log,col=gray(0.8))
abline(v=xticks,col=gray(0.8))
abline(h=16,col="red",lwd=2)
text(x, y, labels=e, adj=c(-0.5,-0.5), col="#00000088")
axis(1,xticks,las=2,cex.axis=1)
axis(2,yticks.log,las=1,cex.axis=1)
dev.off()

system(sprintf("ln -sf %s nextEventMatchingMask_latest.pdf",filename))

