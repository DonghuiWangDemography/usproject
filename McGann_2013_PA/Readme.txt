Data and code files accompanying A.J.McGann, "Estimating the Political Center from Aggregate Data: An Item Response Theory Alternative to the Stimson Dyad Ratios Algorithm". Political Studies (forthcoming).


All files are plain text. Data files are tab delimited.

The files are divided as follows:

Data files

ukdata.txt	The complete data file. The data was kindly supplied by John Bartle.
Variable names:
variable:	name of question item
year		year question asked
topic		issue are of question (see list_of_topics.txt)
leftp		percentage of respondent answering in left wing manner
n		number of respondent in survey administration

ukecondata	This is a subset of the data file and only includes questions on economic issues.
Variable names: As ukdata.txt, except for qcdr. This is the corresponding item number of the question in the complete data set, ukdata.txt.

list_of_items.txt	This gives the text of the survey questions and their source
list_of_topics.txt	This gives the topics codes for the questions

---------------------------------------

Basic model files:

Main Model R code.R		This reads in the data and runs the basic irt model
jags main model code.txt	This is the JAGS code to run the basic irt model

--------------------------------------

Model Comparison files:

Model Comparison.R		R code for the comparison of models

The following files give the JAGS code used to run and evaluate the various alternative models:

jags main mode code rep.txt
linear model.txt
linear model rep.txt
probit model.txt
probit model rep.text
linear dyad model.txt
linear dyad model rep.txt
probit dyad model.txt
probit dyad model rep.txt
----------------------------------------

Item Selection and DIF files

Item Selection DIF.R		R files for discrepancy test of items and DIF
jags item selection code rep.text	JAGS code for discrepancy test
jags DIF code.txt	JAGS code for DIF test

