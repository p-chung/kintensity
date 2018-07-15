## function to calculate # daughters

surviving_daughters <- function(df, # dataframe with LX and Fx
                                age_a, # age of mother
                                ffab = 0.4886 # fraction female at birth
){
  
  x_vec <- seq(15,age_a, by = 5)
  LF_prod <- c()
  for(x in x_vec){
    this_L <- df %>% filter(age == age_a - x) %>% select(Lx) %>% pull()
    this_F <- df %>% filter(age == x) %>% select(Fx) %>% pull()
    LF_prod <- c(LF_prod, this_L/10^5*this_F/10^3*ffab)
  }
  
  return(sum(LF_prod))
}


## function to calculate inner integral of granddaughters

calculate_inner_integral <- function(df, # dataframe with LX and Fx
                                     age_a, # age of mother
                                     x, # current fertility age being considered
                                     ffab = 0.4886 # fraction female at birth
){
  if(age_a - x < 15){ # age of daughter is too young to have children
    LFL_prod <- 0
  }
  else{
    daughter_z_vec <- seq(15, age_a - x, by = 5)
    LFL_prod <- c()
    for(z in daughter_z_vec){
      this_L <- df %>% filter(age == z) %>% select(Lx) %>% pull()
      this_F <- df %>% filter(age == z) %>% select(Fx) %>% pull()
      this_L_2 <- df %>% filter(age == age_a - x - z) %>% select(Lx) %>% pull()
      LFL_prod <- c(LFL_prod, this_L/10^5*this_F/10^3*ffab*this_L_2/10^5)
    }
  }
  return(sum(LFL_prod))
}


## function to calculate # granddaughters

surviving_granddaughters <- function(df, # dataframe with LX and Fx
                                     age_a, # age of mother
                                     ffab = 0.4886 # fraction female at birth
){
  
  x_vec <- seq(15,age_a, by = 5)
  IF_prod <- c()
  for(x in x_vec){
    Ix <- calculate_inner_integral(df, age_a, x)
    Ixp5 <- calculate_inner_integral(df, age_a, x+5)
    Ix_bar <- 0.5*(Ix + Ixp5)
    this_F <- df %>% filter(age == x) %>% select(Fx) %>% pull()
    IF_prod <- c(IF_prod, Ix_bar*this_F/10^3*ffab)
  }
  return(sum(IF_prod))
}