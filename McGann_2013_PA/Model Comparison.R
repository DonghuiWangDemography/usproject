#This file generates the root mean squared residual and by item R squared measures for the irt model and the alternative models. See page 20 of text and Table 1.

# m.jagsfit is main irt model

jags.params=c("mu[1947:2005]", "sigma[1947:2005]", "lambda", "alpha", "b", "leftp.rep", "sqresid")
m.jagsfit<-jags(data=centerdomrevdata, inits=NULL, parameters.to.save=jags.params, n.iter=30000, model.file="jags main model code.txt", n.chains=1)
m.jagsfit$BUGSoutput$summary
m.res<-m.jagsfit$BUGSoutput$summary


#l.jagsfit is linear model

jags.params=c("theta[1947:2005]", "alpha", "beta", "tau", "leftp.rep", "sqresid")
l.jagsfit<-jags(data=centerdomrevdata, inits=NULL, parameters.to.save=jags.params, n.iter=30000, model.file="linear model.txt", n.chains=1)
l.jagsfit$BUGSoutput$summary
l.res<-l.jagsfit$BUGSoutput$summary


#p.jagsfit is simple probit model
jags.params=c("mu[1947:2005]", "lambda", "alpha", "b", "leftp.rep", "sqresid")
p.jagsfit<-jags(data=centerdomrevdata, inits=NULL, parameters.to.save=jags.params, n.iter=30000, model.file="probit model.txt", n.chains=1)
p.jagsfit$BUGSoutput$summary
p.res<-p.jagsfit$BUGSoutput$summary



#Generate replication datasets

#function priorslist is a utility function that extracts means and sds of parameters
priorslist<-function(thedata, varnames){
theresult<-vector("list", 2*length(varnames))
wholenames<-varnames
for (i in 1:length(varnames)){
#Following line added 11/23/12 to solve grepping whole words
wholenames[[i]]<-paste("\\b", varnames[[i]], "\\b", sep="")
theresult[[i]]<-thedata[grepl(wholenames[[i]], dimnames(thedata)[[1]]), "mean"]
theresult[[i+length(varnames)]]<-thedata[grepl(wholenames[[i]], dimnames(thedata)[[1]]), "sd"]	
}
thenames<-c(paste("m.", varnames, sep=""), paste("sd.", varnames, sep="") )
attributes(theresult)<-list(names=thenames)
return(theresult)
}


#Generate replicated predictions for main irt model
priors.irt<-priorslist(m.res, list("alpha", "mu", "lambda", "sigma", "b"))

rep.centerdomrevdata<-c(centerdomrevdata, priors.irt)

jags.params=c("mu[1947:2005]", "sigma[1947:2005]", "lambda", "alpha", "b", "leftp.sim", "sqresid")
rep.m.jagsfit<-jags(data=rep.centerdomrevdata, inits=NULL, parameters.to.save=jags.params, n.iter=30000, model.file="jags main model code rep.txt", n.chains=1, DIC=FALSE)
rep.m.jagsfit$BUGSoutput$summary
rep.m.res<-rep.m.jagsfit$BUGSoutput$summary

rep.m.leftp<-rep.m.res[grepl("leftp.sim", dimnames(rep.m.res)[[1]]), "mean"]


#Generate replicated predictions for probit model

priors.p<-priorslist(p.res, list("alpha", "mu", "lambda", "b"))


rep.centerdomrevdata<-c(centerdomrevdata, priors.p)

jags.params=c("mu[1947:2005]", "lambda", "alpha", "b", "leftp.sim", "sqresid")
rep.p.jagsfit<-jags(data=rep.centerdomrevdata, inits=NULL, parameters.to.save=jags.params, n.iter=30000, model.file="probit model rep.txt", n.chains=1, DIC=FALSE)
rep.p.jagsfit$BUGSoutput$summary
rep.p.res<-rep.p.jagsfit$BUGSoutput$summary

rep.p.leftp<-rep.p.res[grepl("leftp.sim", dimnames(rep.p.res)[[1]]), "mean"]


#Generate replicated predictions for linear model
priors.l<-priorslist(l.res, list("alpha", "beta", "theta", "tau"))

rep.centerdomrevdata<-c(centerdomrevdata, priors.l)

jags.params=c("theta[1947:2005]", "alpha", "beta", "tau", "leftp.sim")
rep.l.jagsfit<-jags(data=rep.centerdomrevdata, inits=NULL, parameters.to.save=jags.params, n.iter=5000, model.file="linear model rep.txt", n.chains=1, DIC=FALSE)
rep.l.jagsfit$BUGSoutput$summary
rep.l.res<-rep.l.jagsfit$BUGSoutput$summary

rep.l.leftp<-rep.l.res[grepl("leftp.sim", dimnames(rep.l.res)[[1]]), "mean"]




#Bartles et al dyad ratio predictions

dyadr<-c(59.5, 59.5, 59.5, 57, 56.8, 58, 55.5, 53.5, 54.6, 58, 60.8, 54.7, 55, 54.8, 49.5, 48.6, 50, 50.8, 52.2, 50, 49.8, 51.8, 47.5, 46.8, 46.2, 43.5, 44.6, 43.4, 43.5, 42.5, 43, 45.8, 46, 46.2, 47.4, 49.4, 50.8, 52.8, 54.6, 54, 53.8, 56.2, 54.2, 56.5, 57, 57.5, 57.9, 58.5, 56.5, 55.2, 53.7, 54.2, 53.2, 52, 49, 47)
dyaddata<-c(centerdomrevdata, data.frame(dyadr))

a<-dyaddata$year>=1950
dyaddata2<-dyaddata
for(i in 1:5){
	dyaddata[[i]]<-dyaddata[[i]][a]
}

#Generate linear predictions for Bartles et al. dyad ratio measure

jags.params=c("alpha", "beta", "tau", "leftp.rep")
dl.jagsfit<-jags(data=dyaddata, inits=NULL, parameters.to.save=jags.params, n.iter=5000, model.file="linear dyad model.txt", n.chains=1)
dl.jagsfit$BUGSoutput$summary
dl.res<-dl.jagsfit$BUGSoutput$summary

priors.dl<-priorslist(dl.res, list("alpha", "beta", "tau"))
rep.centerdomrevdata<-c(dyaddata, priors.dl)

jags.params=c("alpha", "beta", "tau", "leftp.sim")
rep.dl.jagsfit<-jags(data=rep.centerdomrevdata, inits=NULL, parameters.to.save=jags.params, n.iter=5000, model.file="linear dyad model rep.txt", n.chains=1, DIC=FALSE)
rep.dl.jagsfit$BUGSoutput$summary
rep.dl.res<-rep.dl.jagsfit$BUGSoutput$summary

rep.dl.leftp<-rep.dl.res[grepl("leftp.sim", dimnames(rep.dl.res)[[1]]), "mean"]

sqrt(mean((dyaddata$leftp-rep.dl.leftp)^2))
#R squared measure based on mean prediction only
1-sum((dyaddata$leftp-rep.dl.leftp)^2)/(var(dyaddata$leftp)*length(dyaddata$leftp))
#Adjusted R squared
1-sum((dyaddata$leftp-rep.dl.leftp)^2)/(var(dyaddata$leftp)*length(dyaddata$leftp))*(2369/(2369-786))


#Generate probit predictions for Bartles et al. dyad ratio measure

jags.params=c("alpha", "lambda", "b", "leftp.rep")
dp.jagsfit<-jags(data=dyaddata, inits=NULL, parameters.to.save=jags.params, n.iter=5000, model.file="probit dyad model.txt", n.chains=1)
dp.jagsfit$BUGSoutput$summary
dp.res<-dp.jagsfit$BUGSoutput$summary

priors.dp<-priorslist(dp.res, list("alpha", "b","lambda"))
priors.dp$m.b<-priors.dp$m.b[1]
priors.dp$sd.b<-priors.dp$sd.b[1]
rep.dp.centerdomrevdata<-c(dyaddata, priors.dp)

jags.params=c("alpha", "lambda", "leftp.sim")
rep.dp.jagsfit<-jags(data=rep.dp.centerdomrevdata, inits=NULL, parameters.to.save=jags.params, n.iter=5000, model.file="probit dyad model rep.txt", n.chains=1, DIC=FALSE)
rep.dp.jagsfit$BUGSoutput$summary
rep.dp.res<-rep.dp.jagsfit$BUGSoutput$summary

rep.dp.leftp<-rep.dp.res[grepl("leftp.sim", dimnames(rep.dp.res)[[1]]), "mean"]

pred.dp.leftp<-array(0, 2369)
for (i in 1:2369){
# pred.dp.leftp[i]<-priors.dp$m.alpha[dyaddata$q[i]]*(dyaddata$dyadr[dyaddata$year[i]-1949]-priors.dp$m.lambda[dyaddata$q[i]])
pred.dp.leftp[i]<-100*pnorm((dyaddata$dyadr[dyaddata$year[i]-1949]-52.14)/4.988, priors.dp$m.lambda[dyaddata$q[i]], priors.dp$m.alpha[dyaddata$q[i]])
}



#Calculate mean response to each question
mean.q<-array(0,362)
for (i in 1:362){
	a<-c$q==i
	mean.q[i]<-mean(c$leftp[a])	
}

ss.mean.q<-array(0,2377)
for (i in 1:2377){
	ss.mean.q[i]<-(c$leftp[i]-mean.q[c$q[i]])^2
}


#Generate measures of fit

#Generate measures of fit for main irt model

rep.m.mu<-array(0, 2377)
rep.m.sigma<-array(0, 2377)
for (i in 1:2377){
rep.m.mu[i]<-priors.irt$m.mu[c$year[i]-1946]-priors.irt$m.lambda[c$q[i]]
rep.m.sigma[i]<-((priors.irt$m.alpha[c$q[i]])^2+(priors.irt$m.sigma[c$year[i]-1946])^2)^.5
}
pred.m.leftp<-pnorm(rep.m.mu/rep.m.sigma,0, 1)*100

#Root mean squared residual
sqrt(mean((c$leftp-pred.m.leftp)^2))
#By item R squared
1-sum((c$leftp-pred.m.leftp)^2)/sum(ss.mean.q)
#Adjudted By item R squared measure
1-sum((c$leftp-pred.m.leftp)^2)/sum(ss.mean.q)*((2377-362)/(2377-842))


#Generate measures of fit for linear predictions from Bartle et al, dyad model

pred.dl.leftp<-array(0, 2369)
for (i in 1:2369){
pred.dl.leftp[i]<-priors.dl$m.alpha[dyaddata$q[i]]+priors.dl$m.beta[dyaddata$q[i]]*dyaddata$dyadr[dyaddata$year[i]-1949]
}

#Root mean squared residual
sqrt(mean((dyaddata$leftp-pred.dl.leftp)^2))
#By item R squared
1-sum((dyaddata$leftp-pred.dl.leftp)^2)/sum(ss.mean.q)
#Adjudted By item R squared measure
1-sum((dyaddata$leftp-pred.dl.leftp)^2)/sum(ss.mean.q)*((2370-362)/(2370-780))


#Generate measures of fit for probit predictions from Bartle et al, dyad model

#Root mean squared residual
sqrt(mean((dyaddata$leftp-pred.dp.leftp)^2))
#By item R squared
#R squared measure based on mean prediction only, denom with question means
1-sum((dyaddata$leftp-pred.dp.leftp)^2)/sum(ss.mean.q)
#Adjudted By item R squared measure
1-sum((dyaddata$leftp-pred.dp.leftp)^2)/sum(ss.mean.q)*((2370-362)/(2370-780))


#Generate measures of fit for probit model

pred.p.mu<-array(0, 2377)
pred.p.sigma<-array(0, 2377)
for (i in 1:2377){
pred.p.mu[i]<-priors.p$m.mu[c$year[i]-1946]-priors.p$m.lambda[c$q[i]]
pred.p.sigma[i]<-(priors.p$m.alpha[c$q[i]])
}
pred.p.leftp<-pnorm(pred.p.mu/pred.p.sigma,0, 1)*100

#Root mean squared residual
sqrt(mean((c$leftp-pred.p.leftp)^2))
#By item R squared
1-sum((c$leftp-pred.p.leftp)^2)/sum(ss.mean.q)
#Adjudted By item R squared measure
1-sum((c$leftp-pred.p.leftp)^2)/sum(ss.mean.q)*((2737-362)/(2737-783))

#Generate measures of fit for linear model

pred.l.leftp<-array(0, 2377)
for (i in 1:2377){
pred.l.leftp[i]<-priors.l$m.alpha[c$q[i]]+priors.l$m.beta[c$q[i]]*priors.l$m.theta[c$year[i]-1946]
}
  
#Root mean squared residual
sqrt(mean((c$leftp-pred.l.leftp)^2))
#By item R squared
1-sum((c$leftp-pred.l.leftp)^2)/sum(ss.mean.q)
#Adjudted By item R squared measure
1-sum((c$leftp-pred.l.leftp)^2)/sum(ss.mean.q)*((2737-362)/(2737-783))