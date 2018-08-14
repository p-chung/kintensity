
surviving_daughters_cohort <- function(df, # dataframe with LX and Fx
                                       year,
                                       age_a, # age of mother
                                       ffab = 0.4886 # fraction female at birth)
){
  mother_cohort <- year - age_a
  x_vec <- seq(15,age_a, by = 5)
  daughter_cohorts <- year - (age_a - x_vec)
  
  # calculate based on cohorts
  LF_prod <- c()
  for(i in 1:length(x_vec)){
    #this_L <- df %>% filter(age == age_a - x_vec[i], cohort == daughter_cohorts[i]) %>% select(Lx_cohort) %>% pull()
    this_L <- df %>% filter(age == age_a - x_vec[i], year==2010) %>% select(Lx) %>% pull()
    this_F <- df %>% filter(age == x_vec[i], cohort == mother_cohort) %>% select(Fx) %>% pull()
    LF_prod <- c(LF_prod, this_L/10^5*this_F/10^3*ffab)
  }
  
  sum(LF_prod)
}

surviving_daughters_mean_age <- function(df, # dataframe with LX and Fx
                                         year,
                                         age_a, # age of mother
                                         mean_age = 30, # assumed mean age at childbearing
                                         ffab = 0.4886 # fraction female at birth)
  
){
  this_year <- year
  mother_cohort <- year - age_a
  x_vec <- seq(15,age_a, by = 5)
  
  # calculate based on period of mean childbearing age = 30
  LF_prod <- c()
  for(i in 1:length(x_vec)){
    #this_L <- df %>% filter(age == age_a - x_vec[i], year == mother_cohort+30) %>% select(Lx) %>% pull()
    this_L <- df %>% filter(age == age_a - x_vec[i], year==this_year) %>% select(Lx) %>% pull()
    this_F <- df %>% filter(age == x_vec[i], year == mother_cohort+mean_age) %>% select(Fx) %>% pull()
    LF_prod <- c(LF_prod, this_L/10^5*this_F/10^3*ffab)
  }
  
  sum(LF_prod)
}

surviving_daughters_mean_age_adjustment <- function(df, # dataframe with LX and Fx
                                                    year,
                                                    age_a, # age of mother
                                                    mean_age = 30, # assumed mean age at childbearing
                                                    ffab = 0.4886 # fraction female at birth)
  
){
  this_year <- year
  mother_cohort <- year - age_a
  x_vec <- seq(15,age_a, by = 5)
  
  # calculate based on period of mean childbearing age = 30
  LF_prod <- c()
  for(i in 1:length(x_vec)){
    this_L <- df %>% filter(age == age_a - x_vec[i], year==this_year) %>% select(Lx) %>% pull()
    this_F <- df %>% filter(age == x_vec[i], year == mother_cohort+mean_age) %>% select(Fx) %>% pull()
    year_F <- df %>% filter(age == x_vec[i], year == mother_cohort+x_vec[i]) %>% select(Fx) %>% pull()
    adjustment_F <- ifelse(this_F==0,1,year_F/this_F)
    this_F_adjust <- this_F*(adjustment_F)
    LF_prod <- c(LF_prod, this_L/10^5*this_F_adjust/10^3*ffab)
  }
  
  sum(LF_prod)
}