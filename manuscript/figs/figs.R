library(here)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)

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
         lx = `Number of survivors l(x)`,
         Lx = `Number of person-years lived L(x,n)`,
         ex = `Expectation of life e(x)`) %>% 
  rename(period = year) %>% 
  mutate(year = as.numeric(substring(period, 1,4))) %>% 
  # just keep the columns we need
  select(year, region, age, lx, Lx, ex)

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


# Calculate Kin Counts
df_res <- c()

Ws <- df %>% ungroup() %>% filter(region %in% countries) %>% select(region, age, prop, year)

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
  cat(paste0(countries[i]," done..."))
}

df_res <- df_res %>% 
    #mutate(kdr = ifelse(mother_age<45,1,mothers+grandmothers))
  mutate(kdr = ifelse(mother_age<45,
                      (daughters + granddaughters)/(1+mothers+grandmothers),
                      ifelse(mother_age >= 45 & mother_age <= 64, 
                        (daughters + granddaughters +mothers+grandmothers),
                        (mothers+grandmothers/1+daughters+granddaughters))
                      ))

kdrs <- df_res %>% 
left_join(df_pop) %>% 
  group_by(country, year) %>% 
  summarise(kdr = sum(kdr*pop/sum(pop)))

# plot kdr over years (for select countries)
kdrs %>% 
  filter(country %in% c("Japan", "United States of America", "Kenya", "Nigeria") ) %>% 
  ggplot(aes(year, kdr, color = country)) + geom_line(lwd = 1.2) + geom_point(size = 2)+
  theme_bw(base_size = 14) + ggtitle("Kin dependency ratios, 1990-2010")


# read in TADRs
wb = readRDS(here("data/world_bank","all_indicators.rds"))

wb = wb %>% 
  filter(cntry_lab %in% c("United States","Japan","Kenya","Nigeria")) %>% 
  mutate(country = case_when(
    cntry_lab == "United States" ~ "United States of America", 
    TRUE ~ cntry_lab
  )) %>% 
  filter(year %in% years)

tadrs = wb %>% filter(ind == "tadr") %>% rename(tadr=value)


# plot tadr over years (for select countries)
ggplot(tadrs,aes(x=year,y=tadr,col=country)) + geom_line() + geom_point() + theme_bw() + labs(title="Total age dependency ratios, 1990-2010")

ggsave(here("manuscript/figs","tadr_ts.png"), width = 6, height = 4) 


# plot e0 over years (for select countries)
p.e0 = df %>% filter(region %in% c("United States of America","Japan","Kenya","Nigeria") & year %in% seq(1960,2010,5), age == 0)

tfr = df_fert %>% filter(region %in% c("United States of America","Japan","Kenya","Nigeria") & year %in% seq(1960,2010,5)) %>% group_by(year,region,age_group) %>% summarize(Fx=sum(Fx)*5/1000) %>% group_by(year,region) %>% summarize(TFR = sum(Fx))

p.e0 = p.e0 %>% left_join(tfr)

ggplot(p.e0,aes(x=TFR,y=ex,col=region,label=year)) + geom_line() + geom_point() + geom_text(nudge_y = 2)

ggplot(p.e0,aes(y=ex,x=year)) + geom_line() + geom_point() + facet_wrap(~region,scales="free")
ggplot(p.e0,aes(y=TFR,x=year)) + geom_line() + geom_point() + facet_wrap(~region,scales="free")


# plot kdr v. tadr
wb %>% 
  filter(ind=="tadr", year>1985, cntry %in% c("JPN", "KEN", "NGA", "USA")) %>% 
  left_join(kdrs) %>% 
  select(-ind, -ind_lab, -cntry_lab) %>% 
  rename(tadr = value) %>% 
  ggplot(aes(kdr, tadr, color = cntry, group = cntry)) + 
  geom_point(size = 3)  + geom_line() + 
  scale_color_viridis_d()  + geom_text_repel(aes(label = year)) + 
  ggtitle("Total (population level) and kin (individual level) dependency ratios \n1990-2010")+
  ylab("Total dependency ratio (%)") + xlab("Kin dependency ratio (number per person)") + 
  theme_bw(base_size = 16)+ ylim(c(35, 110))