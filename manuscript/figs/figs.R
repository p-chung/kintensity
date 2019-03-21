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
load(here("data","sim_data.RData"))

# historical growth rates (r), 1950-2010
hist_r = df_data %>% filter(year %in% c(1990,2010) & region != "WORLD") %>% group_by(year,region) %>% summarize(n = sum(pop)) %>% spread(year,n) %>% 
   mutate(r = (log(`2010`) - log(`1990`))/20) %>% arrange(r)
hist_r$x = c(.6,.85,1.15,1.6,1.50)
hist_r$y = c(.6,.47,.7,.83,1.0)

# prep sim data for plotting
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

plot.sim$r = rep(plot.sim_r,each=5)

plot.sim_r_1950 = NULL
for(i in 1:length(sims.b)){
  tt = sims.b[[i]]$sim.dat %>% filter(year %in% c(1950,2010)) %>% group_by(year) %>% summarize(n = sum(pop)) %>% summarize(r=(log(n[2])-log(n[1]))/60) %>% pull(r)
  plot.sim_r_1950 = c(plot.sim_r_1950,tt)
}

plot.sim$r_1950 = rep(plot.sim_r_1950,each=5)

# plot.sim$label_f = paste0(round((plot.sim$f-1)/5*100,1),"% (r = ",round(plot.sim$r*100,1),")")
# plot.sim$label_f = factor(plot.sim$label_f, levels = unique(plot.sim$label_f))
# plot.sim$label_m = paste0(round((plot.sim$m-1)/5*100,1),"% (r = ",round(plot.sim$r*100,1),")")
# plot.sim$label_m = factor(plot.sim$label_m, levels = unique(plot.sim$label_m))

plot.sim$label_f = paste0("Fertility change: ",round((plot.sim$f-1)/5*100,1),"%")
plot.sim$label_f = factor(plot.sim$label_f, levels = unique(plot.sim$label_f))
plot.sim$label_m = paste0("Mortality change: ",round((plot.sim$m-1)/5*100,1),"%")
plot.sim$label_m = factor(plot.sim$label_m, levels = unique(plot.sim$label_m))

plot.sim$label_f_simple = paste0(round((plot.sim$f-1)/5*100,1),"%")
plot.sim$label_f_simple = factor(plot.sim$label_f_simple, levels = unique(plot.sim$label_f_simple))
plot.sim$label_m_simple = paste0(round((plot.sim$m-1)/5*100,1),"%")
plot.sim$label_m_simple = factor(plot.sim$label_m_simple, levels = unique(plot.sim$label_m_simple))


##########
## FIGS ##
##########

## FIG 3 ##
# tadr over years (for select countries)
ggplot(tadr_data %>% filter(year %in% years),aes(x=year,y=tadr/100,col=region)) + geom_line() + geom_point() + theme_bw() + labs(title="Total age dependency ratios, 1990-2010",y="TADR")
# ggsave(here("manuscript/figs","tadr_ts.png"), width = 6, height = 4) 

## FIG 4 ##
# kdr over years (for select countries)
ggplot(kdr_data %>% filter(year %in% years),aes(x=year,y=kdr,col=region)) + geom_line() + geom_point() + theme_bw() + labs(title="Kin dependency ratios, 1990-2010",y="KDR")
# ggsave(here("manuscript/figs","kdr_ts.png"), width = 6, height = 4) 

## FIG 5 ## 
# kdr vs tadr over years (for select countries)
kdr_data %>% left_join(tadr_data) %>%
  ggplot(aes(x=kdr,y=tadr/100,col=region)) + 
  geom_point() + geom_path() +
  geom_text_repel(aes(label = year)) +
  labs(title = "Total and kin dependency ratios, 1990-2010",
           y = "TADR",
           x = "KDR") + 
  theme_bw(base_size=16) + ylim(.4,1.1) + xlim(.5,1.75)
# ggsave(here("manuscript/figs","kdr_tadr_scatter_all.png"), width = 10, height = 6)

## FIG 6 ## 
# kdr vs tadr over years (for select countries)
kdr_data %>% left_join(tadr_data) %>% filter(!(region %in% c("Peru","WORLD"))) %>%
  ggplot(aes(x=kdr,y=tadr/100,col=year)) + 
  geom_point(size=3) + geom_path() +
  labs(title = "Total and kin dependency ratios, 1990-2010",
           y = "TADR",
           x = "KDR") + 
    theme_bw(base_size = 16) + 
    facet_wrap(~region, scales="free") +
    scale_color_viridis_c(direction=-1) 
# ggsave(here("manuscript/figs","kdr_tadr_scatter_facet.png"), width = 10, height = 6)

## FIG 7 ## 
# kdr vs tadr over years (for select countries) w/growth rates
kdr_data %>% filter(region != "WORLD") %>%left_join(tadr_data) %>%
  ggplot(aes(x=kdr,y=tadr/100,col=region)) + 
  geom_point() + geom_path() +
  labs(title = "Total and kin dependency ratios, 1990-2010",
           y = "TADR",
           x = "KDR") + 
  theme_bw(base_size=16) + ylim(.4,1.1) + xlim(.5,1.75) +
  geom_text(data=hist_r,aes(x=x,y=y,label=paste0("r = ",round(r*100,1),"%"),size=I(6)))
# ggsave(here("manuscript/figs","kdr_tadr_r_all.png"), width = 10, height = 6)

## FIG 8 ##
# ASFR and 5qx for World's population in 1950
# png(here("manuscript/figs","world_1950_summary.png"), width = 800, height = 400)
p1 = df_data %>% filter(region == "WORLD" & year == 1950) %>% 
  ggplot(aes(x=age,y=pop/1000)) + 
  geom_col() +
  labs(title = "World (1950): Age distribution",
           y = "Population (millions)",
           x = "Age") + 
  theme_bw(base_size=16)
p2 = df_data %>% filter(region == "WORLD" & year == 1950 & age %in% 14:45) %>% 
  ggplot(aes(y=Fx/1000,x=age)) + geom_line(size=1) + 
  labs(title = "Age-specific fertility rate",
           y = "ASFR-5",
           x = "Age") +
  theme_bw(base_size=14)
p3 = df_data %>% filter(region == "WORLD" & year == 1950) %>%
  ggplot(aes(y=qx,x=age)) + geom_line(size=1) + 
  labs(title = "Age-specific mortality risk",
           y = "5qx",
           x = "Age") +
  theme_bw(base_size=14)
gridExtra::grid.arrange(p1, p2, p3, 
                        layout_matrix = (rbind(c(1,2),c(1,3)))
                        )
# dev.off()

## FIG 9 ##
# kdr v. tadr (varying fertility and mortality rates) - faceted
# png(here("manuscript/figs","world_sim_facet.png"), width = 800, height = 1000)
p1=plot.sim %>% filter(m == 1) %>%
  ggplot(aes(x=kdr,y=tadr,col=year)) + geom_path() + geom_point() + facet_wrap(~label_f, scales="free") +
  labs(title="TADR vs. KDR, 1990 - 2010:\nVarying fertility, constant mortality",x="KDR",y="TADR") +
  scale_color_viridis_c(direction=-1) + theme_bw()
p2=plot.sim %>% filter(f == 1) %>%
  ggplot(aes(x=kdr,y=tadr,col=year)) + geom_path() + geom_point() + facet_wrap(~label_m, scales="free") +  
  labs(title="Varying mortality, constant fertility",x="KDR",y="TADR") +
  scale_color_viridis_c(direction=-1) + theme_bw()
gridExtra::grid.arrange(p1, p2, 
                    layout_matrix = matrix(1:2,nrow=2)
                    )
# dev.off()

## FIG 10 ##
# corr(kdr,tadr) w/ varying fertility and mortality rates
# png(here("manuscript/figs","world_sim_corr.png"), width = 800, height = 1000)
tt = plot.sim %>% group_by(m,f) %>% summarize(cor = cor(tadr,kdr), r = r_1950[1])
p1=tt %>% filter(m == 1) %>% 
  ggplot(aes(x=round((f-1)/5*100,1),y=cor)) + geom_point(size=2) + geom_line() + geom_hline(aes(yintercept=0,col=I("Red"),lty=I(2))) + labs(title="Correlation(KDR,TADR), 1950-2010:\nVarying fertility, constant mortality",y="corr(KDR,TADR)",x="Annual Fertility Change (%)") + ylim(-1,1.1) + 
  theme_bw(base_size=14) + geom_vline(aes(xintercept=0,col=I("blue"),lty=I(2)))
p2=tt %>% filter(f == 1) %>% 
  ggplot(aes(x=round((m-1)/5*100,1),y=cor)) + geom_point(size=2) + geom_line() + geom_hline(aes(yintercept=0,col=I("Red"),lty=I(2))) + labs(title="Varying mortality, constant fertility",y="corr(KDR,TADR)",x="Annual Mortality Change (%)") + ylim(-1,1.1) + 
  theme_bw(base_size=14) + geom_vline(aes(xintercept=0,col=I("blue"),lty=I(2)))
gridExtra::grid.arrange(p1, p2, 
                    layout_matrix = matrix(1:2,nrow=2)
                    )
# dev.off()

############
## SCRAPS ##
############

# ASFR and nqx in Japan, 1950 v. 2010
# png(here("manuscript/figs","jpn_asfr_qx.png"), width = 800, height = 400)
# p1 = df_data %>% filter(region == "Japan") %>% group_by(year) %>% summarize(tfr = sum(Fx/1000,na.rm=T)*5) %>% 
#   ggplot(aes(y=tfr,x=year)) + geom_line(size=1) + 
#   labs(title = "Japan: Total fertility rate, 1950-2010",
#            y = "",
#            x = "Age") +
#   theme_bw(base_size=14) +
#   guides(col=F)
# p2 = df_data %>% filter(region == "Japan" & age==0) %>%
#   ggplot(aes(y=ex,x=year)) + geom_line(size=1) + 
#   labs(title = "Japan: Life expectancy at birth, 1950-2010",
#            y = "",
#            x = "Age") +
#   theme_bw(base_size=14)
# gridExtra::grid.arrange(p1, p2, nrow = 1)
# dev.off()


# kdr vs. tadr over years (for the World)
# png(here("manuscript/figs","kdr_tadr_world.png"), width = 800, height = 400)
# p1 = kdr_data %>% left_join(tadr_data) %>% filter(region == "WORLD") %>% 
#   ggplot(aes(x=kdr,y=tadr/100)) + 
#   geom_point() + geom_path() +
#   geom_text_repel(aes(label = year)) +
#   labs(title = "World: Total and kin dependency ratios",
#            y = "TADR",
#            x = "KDR") + 
#   theme_bw(base_size=16)
# p2 = df_data %>% filter(region == "WORLD") %>% group_by(year) %>% summarize(tfr = sum(Fx/1000,na.rm=T)*5) %>% 
#   ggplot(aes(y=tfr,x=year)) + geom_line(size=1) + 
#   labs(title = "Total fertility rate, 1950-2010",
#            y = "",
#            x = "Year") +
#   theme_bw(base_size=14)
# p3 = df_data %>% filter(region == "Japan" & age==0) %>%
#   ggplot(aes(y=ex,x=year)) + geom_line(size=1) + 
#   labs(title = "Life expectancy at birth, 1950-2010",
#            y = "",
#            x = "Year") +
#   theme_bw(base_size=14)
# gridExtra::grid.arrange(p1, p2, p3, 
#                         layout_matrix = (rbind(c(1,2),c(1,3)))
#                         )
# dev.off()


# kdr v. tadr (varying fertility and mortality rates)
# png(here("manuscript/figs","world_sim_nonfacet.png"), width = 600, height = 800)
# p1=plot.sim %>% filter(m == 1) %>% 
#   ggplot(aes(x=kdr,y=tadr,col=label_f_simple)) + geom_path() + geom_point() + 
#   theme_bw(base_size = 14) + scale_color_viridis_d(direction = -1) + 
#   guides(color = guide_legend(reverse=T)) + 
#   labs(title="TADR vs. KDR, 1990 - 2010:\nVarying fertility, constant mortality",x="KDR",y="TADR") + 
#   guides(col=guide_legend(title="fertility scalar (f)"))
# p2=plot.sim %>% filter(f == 1) %>% 
#   ggplot(aes(x=kdr,y=tadr,col=label_m_simple)) + geom_path() + geom_point() + 
#   theme_bw(base_size = 14) + scale_color_viridis_d(direction = -1) + 
#   guides(color = guide_legend(reverse=T)) + 
#   labs(title="Varying mortality, constant fertility",x="KDR",y="TADR") + 
#   guides(col=guide_legend(title="mortality scalar (m)"))
# gridExtra::grid.arrange(p1, p2, 
#                     layout_matrix = matrix(1:2,nrow=2)
#                     )
# dev.off()