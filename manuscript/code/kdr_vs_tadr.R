library(here)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)

# load all the functions
source(here("code", "analysis_functions.R"))

# the years we want to examine KDR and TADR for
years <- c(1990, 1995, 2000, 2005, 2010)

###############
## Load Data ##
###############
df_data = readRDS(here("data", "main_data.RDS"))
tadr_data = readRDS(here("data", "tadr_data.RDS"))
kdr_data  = readRDS(here("data", "kdr_data.RDS"))


############################
## Plot Period TFR and e0 ##
############################

# historical e0
df_data %>% filter(age == 0) %>%
  ggplot(aes(x=year,y=ex,col=region)) + geom_line() + labs(title="Historical e0")

# historical tfr
df_data %>% group_by(region,year) %>% summarize(tfr = sum(Fx/1000,na.rm=T)*5) %>%
  ggplot(aes(x=year,y=tfr,col=region)) + geom_line() + labs(title = "Historical TFR")

# historical growth rate (r) 1950-2010
hist_r = df_data %>% filter(year %in% c(1950,2010)) %>% group_by(year,region) %>% summarize(n = sum(pop)) %>% spread(year,n) %>% 
   mutate(r = (log(`2010`) - log(`1950`))/60) %>% arrange(r)


##################################
## Plot TADR and KDR, 1990-2010 ##
##################################

# historical TADR (from World Bank)
tadr_data %>%
  ggplot(aes(x=year,y=tadr,col=region)) + geom_line()

# historical KDR
kdr_data %>% 
  ggplot(aes(x=year,y=kdr,col=region)) + geom_line()

# historical KDR v. TADR
hist_r$x = .75

tadr_data %>% filter(year %in% years) %>% left_join(kdr_data) %>%
  ggplot(aes(x=kdr,y=tadr,col=region,label=year)) + geom_path() + geom_text_repel() + 
  geom_text_repel(hist_rae)

tadr_data %>% filter(year %in% years) %>% left_join(kdr_data) %>% 
  ggplot(aes(x=kdr,y=tadr,label=year)) + geom_point() + geom_path() + geom_text_repel() + facet_wrap(~region, scale="free") 


############################################
## Simulation Study: the World Population ##
############################################

# subset world data
w.d = df_data %>% filter(region == "WORLD")

## Varying Fertility Sim ##
fert.s = list(
    s_95 = c(w.d$Fx[w.d$year == 1950],scale_rates(w.d$Fx[w.d$year == 1950],scale=.95,steps=12)),
    s_96 = c(w.d$Fx[w.d$year == 1950],scale_rates(w.d$Fx[w.d$year == 1950],scale=.96,steps=12)),
    s_97 = c(w.d$Fx[w.d$year == 1950],scale_rates(w.d$Fx[w.d$year == 1950],scale=.97,steps=12)),
    s_98 = c(w.d$Fx[w.d$year == 1950],scale_rates(w.d$Fx[w.d$year == 1950],scale=.98,steps=12)),
    s_99 = c(w.d$Fx[w.d$year == 1950],scale_rates(w.d$Fx[w.d$year == 1950],scale=.99,steps=12)),
    s_100 = c(w.d$Fx[w.d$year == 1950],scale_rates(w.d$Fx[w.d$year == 1950],scale=1.0,steps=12)),
    s_101 = c(w.d$Fx[w.d$year == 1950],scale_rates(w.d$Fx[w.d$year == 1950],scale=1.01,steps=12)),
    s_102 = c(w.d$Fx[w.d$year == 1950],scale_rates(w.d$Fx[w.d$year == 1950],scale=1.02,steps=12)),
    s_103 = c(w.d$Fx[w.d$year == 1950],scale_rates(w.d$Fx[w.d$year == 1950],scale=1.03,steps=12)),
    s_104 = c(w.d$Fx[w.d$year == 1950],scale_rates(w.d$Fx[w.d$year == 1950],scale=1.04,steps=12)),
    s_105 = c(w.d$Fx[w.d$year == 1950],scale_rates(w.d$Fx[w.d$year == 1950],scale=1.05,steps=12))
  )

# sims.f = NULL
# for(i in 1:length(fert.s)){
#   tt = sim_kdr(years = seq(1950,2010,5),
#           ages  = unique(w.d$age),
#           n     = 5,
#           nqx   = rep(w.d$qx[w.d$year == 1950],13),
#           nFx   = fert.s[[i]],
#           i.pop = w.d$pop[w.d$year == 1950]
#          )
#   sims.f = c(sims.f,list(tt))
# }

## Varying Mortality Sim ##
mort.s = list(
    s_95 = c(w.d$qx[w.d$year == 1950],scale_rates(w.d$qx[w.d$year == 1950],scale=.95,steps=12)),
    s_96 = c(w.d$qx[w.d$year == 1950],scale_rates(w.d$qx[w.d$year == 1950],scale=.96,steps=12)),
    s_97 = c(w.d$qx[w.d$year == 1950],scale_rates(w.d$qx[w.d$year == 1950],scale=.97,steps=12)),
    s_98 = c(w.d$qx[w.d$year == 1950],scale_rates(w.d$qx[w.d$year == 1950],scale=.98,steps=12)),
    s_99 = c(w.d$qx[w.d$year == 1950],scale_rates(w.d$qx[w.d$year == 1950],scale=.99,steps=12)),
    s_100 = c(w.d$qx[w.d$year == 1950],scale_rates(w.d$qx[w.d$year == 1950],scale=1.0,steps=12)),
    s_101 = c(w.d$qx[w.d$year == 1950],scale_rates(w.d$qx[w.d$year == 1950],scale=1.01,steps=12)),
    s_102 = c(w.d$qx[w.d$year == 1950],scale_rates(w.d$qx[w.d$year == 1950],scale=1.02,steps=12)),
    s_103 = c(w.d$qx[w.d$year == 1950],scale_rates(w.d$qx[w.d$year == 1950],scale=1.03,steps=12)),
    s_104 = c(w.d$qx[w.d$year == 1950],scale_rates(w.d$qx[w.d$year == 1950],scale=1.04,steps=12)),
    s_105 = c(w.d$qx[w.d$year == 1950],scale_rates(w.d$qx[w.d$year == 1950],scale=1.05,steps=12))
  )

# sims.m = NULL
# for(i in 1:length(mort.s)){
#   tt = sim_kdr(years = seq(1950,2010,5),
#           ages  = unique(w.d$age),
#           n     = 5,
#           nqx   = mort.s[[i]],
#           nFx   = w.d$Fx[w.d$year == 1950],
#           i.pop = w.d$pop[w.d$year == 1950]
#          )
#   sims.m = c(sims.m,list(tt))
# }

# Varying both Fertility and Mortality
sims.b = NULL
for(i in 1:length(mort.s)){
  for(j in 1:length(fert.s)){
    tt = sim_kdr(years = seq(1950,2010,5),
            ages  = unique(w.d$age),
            n     = 5,
            nqx   = mort.s[[i]],
            nFx   = fert.s[[j]],
            i.pop = w.d$pop[w.d$year == 1950]
           )
    sims.b = c(sims.b,list(tt))
  }
}

# save(sims.f,sims.m,sims.b,file=here("data","sim_data.RData"))


###########################
## Plot simulation data  ##
###########################
load(here("data","sim_data.RData"))

# stack sim data into tidier dataframes for plotting
plot.sim = NULL
for(i in 1:length(sims.b)){
  tt = sims.b[[i]]$inds
  plot.sim = rbind(plot.sim,tt)
}
plot.sim$m = rep(seq(.95,1.05,.01),each=11*5)
plot.sim$f = rep(rep(seq(.95,1.05,.01),each=5),11)

plot.sim_r = NULL
for(i in 1:length(sims.b)){
  tt = sims.b[[i]]$sim.dat %>% filter(year %in% c(1990,2010)) %>% group_by(year) %>% summarize(n = sum(pop)) %>% summarize(r=(log(n[2])-log(n[1]))/20) %>% pull(r)
  plot.sim_r = c(plot.sim_r,tt)
}

plot.sim$r = paste0(as.factor(round(rep(plot.sim_r,each=5)*100,1)),"%")

# plot: non-faceted
plot.sim %>% filter(m == 1) %>%
  ggplot(aes(x=kdr,y=tadr,col=r)) + geom_path() + geom_point() + 
  theme_bw(base_size = 14) + scale_color_viridis_d(direction = -1) + 
  guides(color = guide_legend(reverse=T)) + 
  labs(title="Scaling ASFR-5 (-1%/yr to +1%/yr) + Fixed 5qx")
ggsave(here("manuscript/figs","world_kdr_tadr_nf_fert.png"),width=8,height=6)

plot.sim %>% filter(f == 1) %>%
  ggplot(aes(x=kdr,y=tadr,col=r)) + geom_path() + geom_point() + 
  theme_bw(base_size = 14) + scale_color_viridis_d(direction = -1) + 
  guides(color = guide_legend(reverse=T)) + 
  labs(title="Scaling 5qx (-1%/yr to +1%/yr) + Fixed ASFR-5")
ggsave(here("manuscript/figs","world_kdr_tadr_nf_mort.png"),width=8,height=6)

# plot: faceted
plot.sim %>% filter(m == 1) %>%
  ggplot(aes(x=kdr,y=tadr,col=year)) + geom_path() + geom_point() + facet_wrap(~paste0("r = ",r), scales="free") +
  labs(title="Scaling ASFR-5 (-1%/yr to +1%/yr) + Fixed 5qx") +
  scale_color_viridis_c(direction=-1) + theme_bw()
ggsave(here("manuscript/figs","world_kdr_tadr_f_fert.png"),width=8,height=6)

plot.sim %>% filter(f == 1) %>%
  ggplot(aes(x=kdr,y=tadr,col=year)) + geom_path() + geom_point() + facet_wrap(~paste0("r = ",r), scales="free") +  
  labs(title="Scaling 5qx (-1%/yr to +1%/yr) + Fixed ASFR-5") +
  scale_color_viridis_c(direction=-1) + theme_bw()
ggsave(here("manuscript/figs","world_kdr_tadr_f_mort.png"),width=8,height=6)

