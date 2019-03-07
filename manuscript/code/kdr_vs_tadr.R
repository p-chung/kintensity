library(here)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)

# load all the functions
source(here("code", "analysis_functions.R"))

# select countries and years
countries <- c("United States of America", 
               "Japan", 
               "Nigeria", 
               "Kenya")

years <- c(1990, 1995, 2000, 2005, 2010)


######################
## Prepare WPP Data ##
######################

# read in lifetable, fertility schedule, and age distribution
lt = read_csv(here("data", "wpp_lt.csv"))
fx = read_csv(here("data", "wpp_fx.csv"))
pop = read_csv(here("data", "wpp_pop.csv"))

# combine into a single dataset
top_agecats = c("80-84","85-89","90-94","95-99","100+")
df_pop <- pop %>% 
  # tidy up names
  rename(year = `Reference date (as of 1 July)`,
         region = `Region, subregion, country or area *`) %>% 
  select(year, region, `0-4`:`100+`) %>% 
  gather(age_group, pop, -year, -region) %>% 
  mutate(pop = as.numeric(pop))

# combine 80-100+ age counts into a single 80+ category
# (this only effects periods starting in 1990)
for(c in countries){
  for(y in seq(1990,2015,5)){
    df_pop$pop[df_pop$age_group == "80+" & df_pop$year == y & df_pop$region == c] = sum(df_pop$pop[df_pop$age_group %in% top_agecats & df_pop$year == y & df_pop$region == c])
  }
}

df_pop = df_pop %>% filter(!(age_group %in% top_agecats)) %>%
  mutate(age = as.numeric(substring(age_group, 1, 2)))
df_pop$age[df_pop$age_group == "0-4"] = 0
df_pop$age[df_pop$age_group == "5-9"] = 5  

df_fert <- fx %>% 
  rename(year = Period,
         region = `Region, subregion, country or area *`) %>% 
  select(year, region, `15-19`:`45-49`) %>% 
  gather(age_group, Fx, -year, -region) %>% 
  rename(period = year) %>% 
  mutate(year = as.numeric(substring(period, 1,4))) %>% 
  mutate(age = as.numeric(substring(age_group, 1, 2))) %>%
  arrange(region,year,age) %>% select(-period,-age_group)

df_mort <- lt %>% 
  rename(year = Period,
         region = `Region, subregion, country or area *`,
         age = `Age (x)`, 
         Lx = `Number of person-years lived L(x,n)`,
         px = `Probability of surviving p(x,n)`,
         qx = `Probability of dying q(x,n)`,
         ex = `Expectation of life e(x)`) %>% 
  rename(period = year) %>% 
  mutate(year = as.numeric(substring(period, 1,4))) %>% 
  select(year, region, age, Lx, px, qx, ex) %>% 
  arrange(region,year,age) %>% filter(age != 85) %>% 
  mutate(qx = as.numeric(qx), px = as.numeric(px))

# combine: 1p0 and 4p1 into 5p0 and flip it into 5q0
#          and 1L0 and 4L1 into 5L0
for(c in countries){
  for(y in unique(df_mort$year)){
    df_mort$px[df_mort$region == c & df_mort$year == y & df_mort$age == 0] = df_mort$px[df_mort$region == c & df_mort$year == y & df_mort$age == 0] * df_mort$px[df_mort$region == c & df_mort$year == y & df_mort$age == 1]
    df_mort$qx[df_mort$region == c & df_mort$year == y & df_mort$age == 0] = 1 - df_mort$px[df_mort$region == c & df_mort$year == y & df_mort$age == 0]

    df_mort$Lx[df_mort$region == c & df_mort$year == y & df_mort$age == 0] = df_mort$Lx[df_mort$region == c & df_mort$year == y & df_mort$age == 0] + df_mort$Lx[df_mort$region == c & df_mort$year == y & df_mort$age == 1]
  }
}

df_mort = df_mort %>% filter(age != 1)

# combine everything into a single data object
df_data = df_mort %>% left_join(df_fert) %>% left_join(df_pop) %>%
  filter(region %in% countries) %>% ungroup()

# calculate mean age of childbearing by region and year
mac_data = df_data %>% group_by(region,year) %>% summarize(mac = sum(Fx*age,na.rm=T)/sum(Fx,na.rm=T))


########################################
## Prepare Observed TADR and KDR Data ##
########################################

# read in world bank indicator data (TADRS)
tadr_data = readRDS(here("data/world_bank","all_indicators.rds"))

tadr_data = tadr_data %>% 
  filter(cntry_lab %in% c("United States","Japan","Kenya","Nigeria") & ind == "tadr") %>% 
  mutate(region = case_when(
    cntry_lab == "United States" ~ "United States of America", 
    TRUE ~ cntry_lab
  ))

# calculate KDRs
kdr_data = NULL
for(r in unique(df_data$region)){
  tt = get_kdr(df_data %>% filter(region == r),years)
  tt$region = r
  kdr_data = rbind(kdr_data, tt)
}


############################
## Plot Period TFR and e0 ##
############################

# historical e0
df_data %>% filter(age == 0) %>%
  ggplot(aes(x=year,y=ex,col=region)) + geom_line()

# historical tfr
df_data %>% group_by(region,year) %>% summarize(tfr = sum(Fx/1000,na.rm=T)*5) %>%
  ggplot(aes(x=year,y=tfr,col=region)) + geom_line()


##################################
## Plot TADR and KDR, 1990-2010 ##
##################################

# historical TADR (self-calculated)
df_data %>% group_by(region,year) %>% filter(year %in% years) %>% summarize(tadr = get_tadr(pop,age)) %>%
  ggplot(aes(x=year,y=tadr,col=region)) + geom_line()

# historical TADR (from World Bank)
tadr_data %>% filter(region == "Japan", year %in% years) %>%
  ggplot(aes(x=year,y=value)) + geom_line()

# historical KDR
kdr_data %>% 
  ggplot(aes(x=year,y=kdr,col=region)) + geom_line()

# historical KDR v. TADR
tadr_data %>% filter(year %in% years) %>% left_join(kdr_data) %>%
  ggplot(aes(x=kdr,y=value,col=region,label=year)) + geom_path() + geom_text_repel()

tadr_data %>% filter(year %in% years) %>% left_join(kdr_data) %>% 
  ggplot(aes(x=kdr,y=value,label=year)) + geom_point() + geom_path() + geom_text_repel() + facet_wrap(~region, scale="free") 


################################################
## Use Japan to study kdr v. tadr association ##
################################################

# select Japan data
j.d = df_data %>% filter(region == "Japan")

# extract 1950 population (by age) vector
j.pop = j.d %>% filter(year == 1950) %>% select(pop)

## Simulate Japanese population 1950-2010 ##
## under different qx and Fx rate regimes ##

# Scenario #1: Observed fertility + Constant 1950 mortality
s1 = sim_kdr(years = seq(1950,2010,5),
        ages  = unique(j.d$age),
        n     = 5,
        nqx   = rep(j.d$qx[j.d$year == 1950],13),
        nFx   = j.d$Fx,
        i.pop = j.pop$pop
       )
s1$inds %>% ggplot(aes(x=kdr,y=tadr,label=year)) + geom_path() + geom_text_repel()

# Scenario #2: Constant 1950 fertility + Observed mortality
s2 = sim_kdr(years = seq(1950,2010,5),
        ages  = unique(j.d$age),
        n     = 5,
        nqx   = j.d$qx,
        nFx   = rep(j.d$Fx[j.d$year == 1950],13),
        i.pop = j.pop$pop
       )
s2$inds %>% ggplot(aes(x=kdr,y=tadr,label=year)) + geom_path() + geom_text_repel()

# Scenario #3: Constant 1950 fertility + Constant 1950 mortality
s3 = sim_kdr(years = seq(1950,2010,5),
        ages  = unique(j.d$age),
        n     = 5,
        nqx   = rep(j.d$qx[j.d$year == 1950],13),
        nFx   = rep(j.d$Fx[j.d$year == 1950],13),
        i.pop = j.pop$pop
       )
s3$inds %>% ggplot(aes(x=kdr,y=tadr,label=year)) + geom_path() + geom_text_repel()

# Scenario #4: Increasing fertility + Observed mortality
s.Fx = c(j.d$Fx[j.d$year == 1950],scale_rates(j.d$Fx[j.d$year == 1950],scale=1.05,steps=12))
s4 = sim_kdr(years = seq(1950,2010,5),
        ages  = unique(j.d$age),
        n     = 5,
        nqx   = j.d$qx,
        nFx   = s.Fx,
        i.pop = j.pop$pop
       )
s4$inds %>% ggplot(aes(x=kdr,y=tadr,label=year)) + geom_path() + geom_text_repel()

# Scenario #5: Observed fertility + Increasing mortality
s.qx = c(j.d$qx[j.d$year == 1950],scale_rates(j.d$qx[j.d$year == 1950],scale=1.05,steps=12))
s5 = sim_kdr(years = seq(1950,2010,5),
        ages  = unique(j.d$age),
        n     = 5,
        nqx   = s.qx,
        nFx   = j.d$Fx,
        i.pop = j.pop$pop
       )
s5$inds %>% ggplot(aes(x=kdr,y=tadr,label=year)) + geom_path() + geom_text_repel()



# plot: Historical KDR v. TADR
tadr_data %>% filter(year %in% years & region == "Japan") %>% left_join(kdr_data) %>% 
ggplot(aes(x=kdr,y=value,label=year)) + geom_point() + geom_path() + geom_text_repel() + labs(title="Historical")