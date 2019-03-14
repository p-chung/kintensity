library(here)
library(readr)
library(dplyr)
library(tidyr)

# load all the functions
source(here("code", "analysis_functions.R"))

# select countries and years
countries <- c("United States of America", 
               "Japan", 
               "Nigeria", 
               "Kenya",
               "Peru",
               "WORLD"
               )

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

saveRDS(df_data,file=here("data", "main_data.RDS"))

########################################
## Prepare Observed TADR and KDR Data ##
########################################

# read in world bank indicator data (TADRS)
tadr_data = readRDS(here("data/world_bank","all_indicators.rds")) %>% rename(region = cntry_lab)

tadr_data = tadr_data %>% 
  mutate(region = case_when(
    region == "United States" ~ "United States of America", 
    TRUE ~ region)) %>% 
  filter(region %in% countries & ind == "tadr") %>% 
  rename(tadr = value)

tadr_world = df_pop %>% filter(region == "WORLD") %>% group_by(year) %>%
	summarize(region="WORLD", tadr = (sum(pop[1:3])+sum(pop[14:17]))/sum(pop[4:13])*100) %>%
	select(year,region,tadr)

tadr_data = tadr_data %>% bind_rows(tadr_world) %>% arrange(year,region)

saveRDS(tadr_data,file=here("data", "tadr_data.RDS"))

# calculate KDRs
kdr_data = NULL
for(r in unique(df_data$region)){
  tt = get_kdr(df_data %>% filter(region == r),years)
  tt$region = r
  kdr_data = rbind(kdr_data, tt)
}

saveRDS(kdr_data,file=here("data", "kdr_data.RDS"))