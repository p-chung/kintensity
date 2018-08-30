---
title: Kintensity (working title)
author: Pil H. Chung & Monica Alexander
bibliography: kintensity.bib
---

**Abstract**: We introduce a set of life table equations for estimating the number of living kin over ages using readily-available data on fertility and mortality. These equations extend the classic measurement strategy of Goodman et al. (1974, 1975) by offering a way to estimate kin counts under demographic conditions that may vary over time. To check the plausibility of our method's estimates, we compare them to kin counts reported in a set of large, nationally-representative surveys. We then demonstrate a practical application of this technique: the derivation of "kin dependency ratios"---a measure of expected kin support burden---which we compare to age dependency ratios, common measures of public support burden in aging populations. We end with a discussion about the strengths and limitations of our method, and ways that future work may improve it.

# Introduction
Starting in the mid-1960s a line of demographic research began to develop a formal measurement strategy for estimating the number of living kin (hereafter: kin availability) from fundamental demographic rates. Recognizing that kinship (biologically-defined) was heavily determined by rates of fertility and mortality, population researchers began to elaborate a set of methods to estimate kin availability from these quantities. This research culminated in a set of formal life table equations by @Goodman1974 that enabled this estimation under stable population assumptions. These equations represented the strongest effort, at that time, to formally relate the structure of kinship to its demographic determinants; and they opened up exciting new possibilities for systematically exploring the relationship between fertility, mortality, and kinship wherever data on such quantities could be found.^[For notable examples of work in this tradition see: @Goldman1978, @Uhlenberg1980, @Hagestad1986, @Watkins1987]

In recent years, interest in demographic measurements of kin availability has been increasingly driven by material concerns surrounding the aging of national populations. A 2015 report by the United Nations Population Division predicts that by the year 2050, the world's share of people aged 60 years or older will increase almost two-fold from one-in-eight persons to one-in-five [@UNPopDiv2015]. This unprecedented shift in the age distribution raises the question of how society will organize to materially support the post-retirement population as its growth outpaces that of the working-age population. 

A diverse literature has emerged surrounding this issue.^[For an extensive review, see @Lee2011] In general, researchers distinguish between public and private mechanisms of old-age support. Public support systems, in this context, refer to...

- example: social security/paygo systems

So-called "old age dependency ratios"---usually defined as the number of individuals 65 years or older divided by the number of "working-age" individuals (18-64 years old)---provide rough measures of the likely public support burden^[note the many adjustments to this basic OADR measure like the prospective old age dependency ratio POADR and disability adjusted OADR]  (esp. in many public pension/social security systems that rely on paygo style taxes levied on working age people)

With respect to private mechanisms of old-age support, intergenerational transfers within families is often seen as the primary form of private support. Even in economically-advanced nations, such as the United States, where there exist universal public pension systems, individuals continue to rely heavily on family members for material support (GSS) over the course of their lives.

Notably, there are no widely-reported metrics of family support burden---like the _age dependency ratios_, which are metrics for public support burden. The most direct roadblock to creating such a metric is the lack of data on kinship networks. While age dependency ratios derive entirely from readily-observed population age distributions, a "kin dependency ratio" would require information not only on age of individuals in a population, but information on how they are related to one another. This isn't to say that this challenge has caused research to halt on this topic. In fact, several studies have been published over the years that seek to characterize the likely family support burden for various populations. For example, Lee (2008). Another study by Murphy ().
    + but plenty of studies exist that have tried to measure this deficit/isolation:
        * Verdery's stuff on old age kin scarcity
        * Murphy's stuff on age distribution in Europe

In these latter studies... 

-In these recent works on population aging and family support... 
    + unique data that is hard to generalize
    + computationally-expensive microsimulation methods that do an impressive job of predicting observed kinship configurations, but difficult to implement and access by non-experts 
    + There is a space for simpler methods

In this paper, we present an extended version of Goodman and Colleague's classic method of calculating kin availability as a reasonable alternative when actual data on kinship networks is absent and the microsimulation methods discussed above are determined to be too impractical or costly to implement. Our method relies on readily-available age-specific fertility and mortality data and a set of easily-calculable life table equations. We then extend this original method by dropping the stable population assumption, thus allowing for the estimation of kin availability as a function of demographic rates that need not be constant over time. As a validation check, we compare the results of this procedure against kin network estimates from a set of nationally-representative surveys. Then, as a demonstration of the practical applicability of this type of estimation, we define _kin dependency ratios_ as a measure of expected kin support burden. We end with a discussion about the strengths and limitations of this technique in modern populations, and future opportunities for improvements to kinship measurement in demographic research.

# Measuring Kin Availability
The formal demography of kinship estimation has had a long history. Perhaps the earliest example is work published in 1931 by Alfred Lotka, which derived estimates of orphanhood rates from data on mortality and the mean of childbearing [@Lotka1931]. Subsequent work by @Fourastié...

- Ref: BURCH(1979) & PULLUM(1987) for summary of early history
    - Lotka was the first working in parallel with cultural anthropologists
    - The first formal life-table based investigations of kin availability were conducted in the early 1960s by Coale

- Goodman provided perhaps the most complete formalization of these methods.
    - go deep-ish into Goodman's method/logic (maybe even include a figure or diagram)

- The major weaknesses of these methods (PULLUM1987):
    + fertility and mortality not allowed to vary over time
    + parity progression not accounted for so lead to wider dispersion of kin counts than observed
    + single sex model

- These weaknesses were eventually remedied by a line of computational demography via demographic microsimulators...
    - See Ruggles/Wachter's history of demographic microsim: from among these (CAMSIM,etc.), SOCSIM, has seen the most productive use and active development (Ken's validation studies). Examples of microsim work (just cite, no need to elaborate):
        + Murphy study
        + Verdery study
        + Chung study

# Re-introducing a Lifetable Approach to Kinship Measurement

- Today, there remains plenty of uses for measurements of kin availability. However, computationally intensive microsimulation methods, which are the current state of the art, have not yet been fully developed for mainstream use.

- Outside of these computational methods, the two most common methods for estimating kin availability include direct measurement via household surveys and specialized social network questionnaires (often embedded as occasional modules in larger social surveys). 
    - describe strengths and weaknesses of household surveys (e.g. Census):
        + household boundaries: CITE Ruggles and others in Burch (1979)
        + growing institutionalized populations: CITE prison studies re: black families
    - describe strengths and weaknesses of social network questionnaires:
        + infrequently administered (limited time points observed)
        + dependent on respondent recall (list methods can also impose artificial limits on number of kin)

- to this set, we hope to add a third viable alternative that has the advantage of (a) not being constrained by household boundaries and (b) relying solely on already existing and (in most cases) publicly-accessible data covering a much wider range of years than existing social survey data. 

## The original method
- a quick description of the logic behind Goodman's method and a presentation of some key equations

## The extended method
- a discussion of how the original equations may be modified/generalized to allow for time-varying fertility and survivorship terms
- plot age-specific kin counts using both the stable population method and the extended method to demonstrate the gain
    + talk about the implications of the observed difference

# Outcomes of Interest
- total kin availability(x): the number of living kin at age x
- kin availability~i~(x): the number of living kin of relation i at age x
    - e.g. the number of living daughters at age 50
- working-age kin availability(x): the number of living kin aged 18-65 at age x
- working-age kin availability~i~(x): the number of living kin of relation i aged 18-65 at age x
- "kin dependency ratio" (the inverse is "kin support ratio"):
    + KDR(x) = # of dependent kin types at age x / # supportive kin types at age x 
        * what "dependent" and "supportive" kin types are will have to be decided

# Results
- contrast "age dependency ratio" with "kin dependency ratio"
    + interpret this as the public v. private capacity to support aging populations
- when does each ratio reach it's minimum? assuming stable population rates v. NOT assuming stable population rates

-Replication/Validation:
    + GSS
    + NSFH
    + HRS
    + International Sources?

# References