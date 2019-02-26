library(here)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

# load kinship functions
source(here("code", "kin_functions.R"))	
source(here("code", "alternative_daughters.R"))
source(here("code", "alternative_granddaughters.R"))


# select countries and years
countries <- c("United States of America", 
               "Japan", 
               "Nigeria", 
               "Kenya")

years <- c(1990, 1995, 2000, 2005, 2010)


# read lifetable, fertility schedule, and age distribution
lt = read_csv(here("data", "wpp_lt.csv"))
fx = read_csv(here("data", "wpp_fx.csv"))
pop = read_csv(here("data", "wpp_pop.csv"))


# combine into a single dataset
df_mort <- lt %>% 
  # tidy up names
  rename(year = Period,
         region = `Region, subregion, country or area *`,
         age = `Age (x)`, 
         Lx = `Number of person-years lived L(x,n)`) %>% 
  rename(period = year) %>% 
  mutate(year = as.numeric(substring(period, 1,4))) %>% 
  # just keep the columns we need
  select(year, region, age, Lx)

df_fert <- fx %>% 
  # tidy up names
  rename(year = Period,
         region = `Region, subregion, country or area *`) %>% 
  # only keep years/ages/countries we want
  select(year, region, `15-19`:`45-49`) %>% 
  # change to long format
  gather(age_group, Fx, -year, -region) %>% 
  rename(period = year) %>% 
  mutate(year = as.numeric(substring(period, 1,4))) %>% 
    # make an age column 
  mutate(age = as.numeric(substring(age_group, 1, 2)))

df_pop <- pop %>% 
  # tidy up names
  rename(year = `Reference date (as of 1 July)`,
         region = `Region, subregion, country or area *`) %>% 
  select(year, region, `15-19`:`45-49`) %>% 
  # change to long format
  gather(age_group, pop, -year, -region) %>% 
  # make an age column 
  mutate(age = as.numeric(substring(age_group, 1, 2)))

df <- df_mort %>% 
  left_join(df_fert) %>% 
  left_join(df_pop) %>% 
  mutate(age_group = paste(age, age+4, sep = "-"),
         pop = ifelse(is.na(pop), 0, pop),
         Fx = ifelse(is.na(Fx), 0, Fx)) 

df <- df %>% 
  group_by(year, region) %>% 
  mutate(prop = pop/sum(pop))


# filter data
df_data <- df %>% 
  filter(region %in% countries)

Ws <- df %>% ungroup() %>% filter(region %in% countries) %>% select(region, age, prop, year)


# Calculate Kin Counts
df_res <- c()

for(i in 1:length(countries)){
  df_country <- c()
  for(j in 1:length(years)){
    this_df_data <- df_data %>% ungroup() %>% filter(region == countries[i])
    this_d_for_mothers <- df_data %>% ungroup() %>% filter(region == countries[i], year == years[j])
    this_W <- Ws %>% filter(region == countries[i])
    df_direct <- tibble(mother_age = seq(15, 60, by = 5),
                        country = countries[i],
                        year = years[j])
    df_direct <- df_direct %>% 
      rowwise() %>% 
      mutate(daughters = surviving_daughters_mean_age(df = this_df_data,
                                                                 year = years[j], 
                                                                 age_a = mother_age, 
                                                                 mean_age = 25),
             granddaughters = surviving_granddaughters_mean_age(df = this_df_data,
                                                                 year = years[j], 
                                                                 age_a = mother_age, 
                                                                 mean_age = 25),
             mothers = surviving_mothers_notstable(this_d_for_mothers, this_W, age_a = mother_age, years[j]),
             grandmothers = surviving_grandmothers_notstable(this_d_for_mothers, this_W, age_a = mother_age, years[j])
             
             )
    
    df_country <- rbind(df_country, df_direct)
  }
  df_res <- rbind(df_res, df_country)
}


# read in ADRs
wb = readRDS(here("data/world_bank","all_indicators.rds"))

p.tadr = wb %>% filter(cntry_lab %in% c("United States","Japan","Kenya","Nigeria") & year %in% seq(1990,2010,5) & ind == "tadr") %>% select(country = cntry_lab, year, tadr = value)

ggplot(p.tadr,aes(x=year,y=tadr,col=country)) + geom_line() + geom_point() + theme_bw() + labs(title="Total age dependency ratios, 1990-2010")

ggsave(here("manuscript/figs","tadr_ts.png"), width = 6, height = 4) 