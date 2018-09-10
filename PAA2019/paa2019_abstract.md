---
title: 'Kin Dependency Ratios: An Extension and Application of the Goodman Method for Estimating the Availability of Kin'
author: 
- name: Pil H. Chung 
- affiliation: UC Berkeley
- name: Monica Alexander
- affiliation: University of Toronto
bibliography: kintensity.bib
abstract: 'We introduce a set of life table equations for estimating the number of living kin over ages using readily-available data on fertility and mortality. These equations extend the classic measurement strategy of Goodman et al. (1974, 1975) by offering a way to estimate kin counts under demographic conditions that need not be stationary over time. We demonstrate a practical application of this technique: the derivation of a _kin dependency ratio_ (KDR)---a measure of expected kin support burden---which we compare to the _old age dependency ratio_ (OADR), a commonly-reported measure of public support burden in aging populations. We end with an overview of the immediate next steps for this project.'
---

## Premise

Starting in the mid-1960s a line of demographic research began to develop a formal measurement strategy for estimating the number of living kin (hereafter: kin availability) from fundamental demographic rates. Recognizing that kinship (biologically-defined) was heavily determined by rates of fertility and mortality, population researchers began to elaborate a set of methods to estimate kin availability from these quantities. This research culminated in a set of formal life table equations by @Goodman1974 that enabled this estimation under stable population assumptions. These equations represented the strongest effort, at that time, to formally relate the structure of kinship to its demographic determinants; and they opened up exciting new possibilities for systematically exploring the relationship between fertility, mortality, and kinship wherever data on such quantities could be found.^[For notable examples of work in this tradition see: @Goldman1978, @Uhlenberg1980, @Hagestad1986, @Watkins1987]

In recent years, interest in demographic measurements of kin availability has been increasingly driven by material concerns surrounding the aging of national populations. A 2015 report by the United Nations Population Division predicts that by the year 2050, the world's share of people aged 60 years or older will increase almost two-fold from one-in-eight persons to one-in-five [@UNPopDiv2015]. This unprecedented shift in the age distribution raises the question of how society will organize to materially support the post-retirement population as its growth outpaces that of the working-age population. 

A diverse literature has emerged surrounding this issue.^[For an extensive review, see @Lee2011] Broadly speaking, researchers distinguish between public and private mechanisms of old-age support. Public support systems, in this context, typically refer to public pension programs (e.g. _Social Security_ in the United States) or other in-kind transfer programs that are largely funded by the working age population. The _old age dependency ratio_ (OADR)---usually defined as the number of individuals 65 years or older divided by the number of "working-age" individuals (15-64 years old)---provides a rough measure of the likely support burden faced by these public systems.^[It is worth noting that alternative versions of the basic _old age dependency ratio_ (OADR) measure have been proposed. Perhaps the most prominent of these is the _prospective old age dependency ratio_ (POADR) [@Sanderson2005], which further adjusts for future gains in life expectancy.]

As for private mechanisms of old-age support, the family is the principal vehicle [@Lee2011a]. Especially in nations where public old age support is scarce, the family is likely to be the primary source of material support for dependent elders. Curiously, there are no widely-reported measures of expected family support burden like there are for the expected public support burden (i.e. the OADR just mentioned). This is likely due to the general dearth of data on kinship structures. While the OADR derives entirely from readily-observed population age distributions, an analogous _kin dependency ratio_ (KDR) would require information, not only about the age of individuals in a population, but also about how those individuals are related to one another via familial ties.

In this paper, we present an extended version of Goodman and Colleague's classic method of calculating kin availability as a reasonable estimation strategy when actual data on kinship is absent. Our method relies solely on readily-available age-specific fertility and mortality data and a set of easily-calculable life table equations. We improve on Goodman's original method by dropping the stationary population assumption, thus allowing for the estimation of kin availability as a function of demographic rates that need not be constant over time. Then, as a demonstration of the practical applicability of this type of estimation, we define a _kin dependency ratio_ as a measure of expected kin support burden, which we compare to existing _old age support ratios_ across a sample of nations at different points in time. 

## The Original Method

In @Goodman1974, a method is laid out by which the expected number of living female relatives of different relations (e.g. mothers, daughters, etc.) is derived from age-specific rates of survival and fertility. For example, the number of surviving daughters to a woman of age $a$ ($a>{\alpha}$) at time $t$ is given by the formula:

$$
\int_{\alpha}^a l_{a-x} m_x dx
$$

Here, $m_x$ is the number of female births to a woman of age $x$ and $l_{a-x}$ is the proportion of girls surviving to age $a-x$ (i.e. alive when mother is age $a$). 

Applying the same logic recursively, a formula for the number of grand-daughters can be derived:

$$
\int_{\alpha}^a \left[\int_{\alpha}^{a-x}l_y m_y l_{a-x-y}dy \right] m_x dx
$$

Here, $y$ indexes the daughter's age (i.e. the age of the mothers of the grand daughters being counted).

Now moving _up_ generations, the probability of mother's survival can also be written in terms of age-specific survival and fertility:

$$
M_1(a) = \int_{\alpha}^{\beta} \frac{l_{x+a}}{l_x} W(x|t-a)dx
$$

Here, $\frac{l_{x+a}}{l_x}$ is the mean probability that a mother who gave birth to a girl who is now age $a$ when she was age $x$ is still alive; and $W(x|t-a)$ is the age distribution---at time $t-a$---of women who gave birth to a daughter at time $t-a$. 

The %M(a)% function can be recursively re-written to characterize the probability of grandmother's survival:

$$
M_2(a) = \int_{\alpha}^{\beta} M_1(a+x) W(x|t-a)dx
$$

[Monica, can you look over and let me know if I've screwed anything up or should include more description?]

## The Extended Method

[Monica, can you fill out this section?]

-PLOT: comparison of stable-rate/Goodman curves vs. non-stable/Monica curves of number of living kin (grandmother + mother + daughter + granddaughter) over ages

## The Kin Dependency Ratio (KDR)

We define a _kin dependency ratio_ (KDR) as the number of plausibly dependent kin types divided by the number of plausibly non-dependent kin types.^[Alternatively, we could take the inverse of the KDR as a measure of potential kin support---a _kin support ratio_ (KSR).] 

## KDR vs. OADR

-PLOT: KDR(at working ages) vs. OADR

## Next Steps
-Adding additional kin types: sibling, cousins, aunts, nieces?
-Validating kin counts using kinship modules in nationally representative surveys
-R Package? 

## References