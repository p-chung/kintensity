
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
    this_L <- df %>% filter(age == age_a - x_vec[i], cohort == daughter_cohorts[i]) %>% select(Lx_cohort) %>% pull()
    this_F <- df %>% filter(age == x_vec[i], cohort == mother_cohort) %>% select(Fx) %>% pull()
    LF_prod <- c(LF_prod, this_L/10^5*this_F/10^3*ffab)
  }
  
  sum(LF_prod)
}

surviving_daughters_mean_age <- function(df, # dataframe with LX and Fx
                                         year,
                                         age_a, # age of mother
                                         ffab = 0.4886 # fraction female at birth)
  
){
  mother_cohort <- year - age_a
  x_vec <- seq(15,age_a, by = 5)
  
  # calculate based on period of mean childbearing age = 30
  LF_prod <- c()
  for(i in 1:length(x_vec)){
    this_L <- df %>% filter(age == age_a - x_vec[i], year == mother_cohort+30) %>% select(Lx) %>% pull()
    this_F <- df %>% filter(age == x_vec[i], year == mother_cohort+30) %>% select(Fx) %>% pull()
    LF_prod <- c(LF_prod, this_L/10^5*this_F/10^3*ffab)
  }
  
  sum(LF_prod)
}