# Description

The paper
[Host-pathogen coevolution increases genetic variation in susceptibility to infection](https://elifesciences.org/articles/46440)
provides raw data on viral loads of around 1000 "families"
responding to infection from three different sigma viruses,
for four different Drosophila species.
The paper fits linear models for each species for log viral load
with virus as a main effect and family and day as random effects.
The main goal is to estimate genetic variance,
which is the variance of the family effect.
For *D. melanogaster*, genotypes of the parents of each family
at two known resistance loci are also given,
and included in the random effects model.

Attached are these data, from [figshare](https://doi.org/10.6084/m9.figshare.6743339):

- [D. melanogaster](Dmel_full_data_out.csv), and [genotype data](Dmel_genotype_data_out.csv)
- [D. obscura](Dobs_data_out.csv)
- [D. immigrans](Dimm_data_out.csv)
- [D. affinis](Daff_data_out.csv)


# Other information

Below is the R script provided with the data, verbatim:

```{.r}
### R code to run models to estimate Vg in susceptibility ###

library(MCMCglmm)

#### Parameter expanded prior ###

prior1<-list(G=list(G1=list(V=diag(3),nu=3, alpha.mu=rep(0,3), alpha.V=diag(3)*1000), G2=list(V=diag(3),nu=3, alpha.mu=rep(0,3), alpha.V=diag(3)*1000)), R=list(V=diag(3),nu=0.002))

### model1 - general model for all species ###

model1<-MCMCglmm(viral_load~virus-1, random=~us(virus):family+us(virus):day, rcov=~idh(virus):units, prior=prior1, data=data1, nitt=13000*10000, thin=10*10000, burnin=3000*10000, pr=TRUE)

### model2 - with genotype as fixed effect, using data for D.mel families with genotype info - "Dmel_genotype_data_out.csv"###

model2<-MCMCglmm(viral_load~virus-1+chkov_sum*virus+ref2p_sum*virus, random=~us(virus):family+us(virus):day, rcov=~idh(virus):units, prior=prior1, data=data1, nitt=13000*10000, thin=10*10000, burnin=3000*10000, pr=TRUE)

### Alternate priors ###

### Inverse Wishart prior ###
prior2<-list(G=list(G1=list(V=diag(3)*(0.002/2.002),n=2.002), G2=list(V=diag(3)*(0.002/2.002),n=2.002)),R=list(V=diag(3),nu=0.002))

### Flat prior ###
prior3<-list(G=list(G1=list(V=diag(3)*1e-2,nu=1e-2),G2=list(V=diag(3)*1e-2,nu=1e-2)), R=list(V=diag(3)*1e-2,n=1e-2))
```
