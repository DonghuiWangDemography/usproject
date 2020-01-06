#Fit basic irt model

jags.params=c("mu[1947:2005]", "sigma[1947:2005]", "lambda", "alpha", "b", "leftp.rep", "sqresid")
jags.params=c("mu[1947:2005]", "sigma[1947:2005]", "lambda", "alpha", "b")
m.jagsfit<-jags(data=centerdomrevdata, inits=NULL, parameters.to.save=jags.params, n.iter=5000, model.file="JAGS code/DIF/center code 11.9.txt", n.chains=1)
m.res<-jagsfit$BUGSoutput$summary


#priorlist is utility function for reading from jags output

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

priors.irt<-priorslist(m.res, list("alpha", "mu", "lambda", "sigma", "b"))

rep.centerdomrevdata<-c(centerdomrevdata, priors.irt)

#Generate T statistic for goodness of fit of item applications (see page 25)

jags.params=c("t")
jagsfit<-jags(data=rep.centerdomrevdata, inits=NULL, parameters.to.save=jags.params, n.iter=5000, model.file="JAGS code/jags item selection code rep.txt", n.chains=1, DIC=FALSE)
jagsfit$BUGSoutput$summary
rep.m.res<-jagsfit$BUGSoutput$summary

#m.t gives the proportion of times each administration has a discrepancy greater than that produced stochastically by the model 95% of the time.
m.t<-rep.m.res[grepl("t", dimnames(rep.m.res)[[1]]), "mean"]

Select items with at least one admin that produce discrepancy that exceeds that generated stochastically 95% of time
a<-centerdomrevdata$q[(which(m.t>.95))]
highdiscrepancy.items<-unique(a)



#Test for DIF

difcenterdata<-c(centerdomrevdata,priors.irt)

jags.params=c("lambda", "dif")
dif.jagsfit<-jags(data=difcenterdata, inits=NULL, parameters.to.save=jags.params, n.iter=5000, model.file="jags dif code.txt", n.chains=1)
dif.jagsfit$BUGSoutput$summary
dif.res<-dif.jagsfit$BUGSoutput$summary
dif.m<-dif.res[grepl("dif", dimnames(dif.res)[[1]]), "mean"]
dif.lambda.m<-dif.res[grepl("lambda", dimnames(dif.res)[[1]]), "mean"]

#Administrations in which there is dif (p<0.05)
dif.admins<-which((dif.m<0.05)|(dif.m>.95))

#Questions where dif detected
a<-c$q[dif.admins]
dif.items<-unique(a)
