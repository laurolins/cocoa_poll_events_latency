t <- read.csv("ticks",sep="|")
print(quantile(t$t/1e6,probs=seq(0,1,0.05)))
