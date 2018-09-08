

calculate_inner_integral_meanage <- function(df, # dataframe with Lx and Fx
                                     year, # year being considered
                                     age_a, # age of mother
                                     x, # current fertility age being considered
                                     mean_age = 30, # assumed mean age at childbearing
                                     ffab = 0.4886 # fraction female at birth
){
  this_year <- year
  
  if(age_a - x < 15){ # age of daughter is too young to have children
    LFL_prod <- 0
  }
  else{
    daughter_z_vec <- seq(15, age_a - x, by = 5)
    LFL_prod <- c()
    for(z in daughter_z_vec){
      daughter_cohort <- this_year - z
      this_L <- df %>% filter(age == z, year == this_year) %>% select(Lx) %>% pull()
      this_F <- df %>% filter(age == z, year == daughter_cohort+mean_age) %>% select(Fx) %>% pull()
      this_L_2 <- df %>% filter(age == age_a - x - z, year == this_year) %>% select(Lx) %>% pull()
      LFL_prod <- c(LFL_prod, this_L/10^5*this_F/10^3*ffab*this_L_2/10^5)
    }
  }
  return(sum(LFL_prod))
}



surviving_granddaughters_mean_age <- function(df, # dataframe with Lx and Fx
                                            year, # year being considered
                                            age_a, # age of mother
                                            mean_age = 30, # assumed mean age at childbearing
                                            ffab = 0.4886 # fraction female at birth
){
  this_year <- year
  mother_cohort <- year - age_a
  
  x_vec <- seq(15,age_a, by = 5)
  IF_prod <- c()
  for(x in x_vec){
    Ix <- calculate_inner_integral_meanage(df, year, age_a, x, mean_age)
    Ixp5 <- calculate_inner_integral_meanage(df, year, age_a, x+5, mean_age)
    Ix_bar <- 0.5*(Ix + Ixp5)
    this_F <- df %>% filter(age == x, year == mother_cohort+mean_age) %>% select(Fx) %>% pull()
    IF_prod <- c(IF_prod, Ix_bar*this_F/10^3*ffab)
  }
  return(sum(IF_prod))
}