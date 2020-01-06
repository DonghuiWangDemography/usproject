#Load package R2jags
library("R2jags")

#Read in data

a<-read.table("ukdata.txt", header=TRUE, sep="\t")

#Convert question names from R factors to numeric
a$q<-as.numeric(a$variable)

b<-list(
#
len=2377, nquest=362, startyear=1947, endyear=2005
#
)
centerdomrevdata<-c(a, b)

#Run model

jags.params=c("mu[1947:2005]", "sigma[1947:2005]", "lambda", "alpha", "b", "sqresid")
jagsfit<-jags(data=centerdomrevdata, inits=NULL, parameters.to.save=jags.params, n.iter=90000, model.file="jags main model code.txt", n.chains=3)

jagsfit$BUGSoutput$summary