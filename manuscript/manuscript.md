---
title: Kintensity (working title)
author: Pil H. Chung & Monica Alexander
bibliography: kintensity.bib
---

**abstract**: We introduce a set of life table equations for estimating the number of living kin over ages using readily-available data on fertility and mortality. These equations extend the classic measurement strategy of Goodman et al. (1974) by dropping the stable population assumption, thereby allowing estimation of kin counts under demographic conditions that may vary over time. To check the plausibility of our method's estimates, we compare them to kin counts reported in a set of large, nationally-representative surveys. We end with a discussion about the strengths and limitations of our method, and ways that future work may improve it.

# Introduction
Starting in the mid-1960s a line of demographic research began to develop a formal measurement strategy for estimating the number of living kin (hereafter: kin availability) from fundamental demographic rates. Recognizing that kinship (biologically-defined) was heavily determined by rates of fertility and mortality, population researchers began to elaborate a set of methods to estimate kin availability from these quantities. This research culminated in a set of formal life table equations by @Goodman1974 that enabled this estimation under stable population assumptions. These equations represented the strongest effort, at that time, to formally relate the structure of kinship to its demographic determinants; and they opened up exciting new possibilities for systematically exploring the relationship between fertility, mortality, and kinship wherever data on such quantities could be found.

- Examples of research either using the Goodman method or informed by the formal demographic logic behind the method: e.g. Watkins - "Demographic Foundations of Family Change"; Uhlenberg; Hagestad; Glick; etc.

<!-- NOT SURE WHETHER TO INCLUDE: However, this line of methodological development hit a lull beginning in the late-1980s. The exact cause is not clear, but some arguments could be made for: (a) the increasing heterogeneity of family arrangements across different geographic and socio-economic contexts [@Cherlin2010] {>>look into international citations, maybe?<<} that may render population-level estimates of kinship not particularly useful; (b) increasing heterogeneity in the socially-accepted definition of family [CITE?]that makes measurement of biological kinship less relevant; or simply waning interest in the formal demography of kinship among population researchers. -->

In recent years, there has been signs of increasing interest in demographic measurements of kin availability though the interest has been driven by more practical concerns rather than concerns about the measurement itself. For example...

- example: consanguinity/nepotism still mattering for social stratification processes and reproduction of socio-economic inequality
    + GSS/HRS survey Qs demonstrating that people still consider blood relations the most important across most domains
    + Intergenerational transmission of wealth studies linking family inheritance to reproduction of wealth inequality/gap

- example: population aging and its likely implications for intergenerational/old-age support
    + a major vehicle by which population aging will be managed is via intergenerational transfers (Ron Lee’s stuff)
    + Verdery's stuff on old age isolation
    + Murphy's stuff on age distribution

- the collateral consequences of the justice system expansion
    + Western & Wildeman's stuff on lifetime incarceration hazard
    + Chung's stuff on number of family members with prison records

-In many of these recent works, newer methods of measuring kinship have been leveraged... 
    + computationally-expensive microsimulation methods that do an impressive job of predicting observed kinship configurations, but difficult to implement and access by non-experts 
    + There is a space for simpler methods

In this paper, we present an extended version of Goodman and Colleague's classic method of calculating kin availability as a reasonable alternative when the microsimulation methods discussed above are deemed either inappropriate or impractical. The idea is relies on readily-available age-specific fertility and mortality data and a set of easily calculable life table equations. We then extend this original method by dropping the stable population assumption, thus allowing for the estimation of kin availability as a function of demographic rates that need not be constant over time. As a validation check, we compare the results of this procedure against kin network estimates from a set of nationally-representative surveys. We end with a discussion about the strengths and limitations of this technique in modern populations, and future opportunities for improvements to kinship measurement in demographic research.

# Measuring Kin Availability
The formal demography of kinship estimation has had a long but somewhat sparse history...

- Ref: BURCH(1979) for summary of early history
    - Lotka was the first working in parallel with cultural anthropologists
    - The first formal life-table based investigations of kin availability were conducted in the early 1960s by Coale

- Goodman provided perhaps the most complete formalization of these methods.
    - go deep-ish into Goodman's method/logic (maybe even include a figure or diagram)

- The basic logic of this method was eventually adopted by a line of computational demography to create demographic microsimulators...
    - From among these, SOCSIM, has seen the most productive use and active development (Ken's validation studies)
        + Murphy study
        + Verdery study
        + Chung study

# Extending the Goodman Method
- Today, there remains active interest in the accurate estimation of kin availability: academic interest (e,g, kin support literature), economic policy planning (dependency ratio literature), etc. However, computationally intensive microsimulation methods are not yet developed enough for mainstream use.
- Outside of these computational methods, the two most common methods for estimating kin availability include household surveys and specialized social network questionnaires (often embedded as occasional modules in larger social surveys). 
    - describe strengths and weaknesses of household surveys (e.g. Census):
        + household boundaries: CITE Ruggles and others in Burch (1979)
        + growing institutionalized populations: CITE prison studies re: black families
    - describe strengths and weaknesses of social network questionnaires:
        + infrequently administered (limited time points observed)
        + dependent on respondent recall (list methods can also impose artificial limits on number of kin)
- to this set, we hope to add a third viable alternative that has the advantage of (a) not being constrained by household boundaries and (b) relying solely on already existing and (in most cases) publicly-accessible data. 

## The original method
- a quick description of the logic behind Goodman's method and a presentation of some key equations

## An extended method
- a discussion of how the original equations may be modified/generalized to drop the stable population assumption 

# Outcomes of Interest
- total kin availability(x): the number of living kin at age x
- kin availability~i~(x): the number of living kin of relation i at age x
    - e.g. the number of living daughters at age 50
- working-age kin availability(x): the number of living kin aged 18-65 at age x
- working-age kin availability~i~(x): the number of living kin of relation i aged 18-65 at age x

# Results
- kin availability(x): the number of living kin at age x
    - do this for systematically varying fertility and mortality rates
        - create a log(GRR) plot-like thing where fertility and mortality indices are on the x and y axes and contour lines are drawn on the surface to indicate different combinations of x and y that is expected to lead to the same number of living kin for a particular model age.
    - do this for different birth cohorts
- kin availability~i~(x): the number of living kin of relation i at age x
- working-age kin availability(x): the number of living kin aged 18-65 at age x
    - create a "familial support ratio": (# working-age kin)/(# non-working-age kin)
    - inverse is "familial dependency ratio": (# non-working-age kin)/(# working-age kin)
- working-age kin availability~i~(x): the number of living kin of relation i aged 18-65 at age x

# References