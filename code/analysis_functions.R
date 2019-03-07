##########################
## Scale Rate Schedules ##
##########################
#
# rates = vector of age-specific rates
# scale = multiplicative scaling factor to apply to rates
# steps = how many times the rates should be scaled (returns one vector for every scaling step)
# mult  = indicates whether scaling should be multiplicative or additive	

scale_rates = function(rates,scale,steps=1,mult=T){
	
	res = cbind(rates)

	if(mult == T){
		for(i in 1:steps) {
			res = cbind(res, res[,i] * scale) 
		}
	}

	if(mult == F){
		for(i in 1:steps) {
			res = cbind(res,res[,i] + scale)
		}
	}

	return(res[,-1])
}


#########################################
## Generate Lifetable: given qx column ##
#########################################
# 
# nqx   = probabilities of dying over interval n
# ages  = vector of ages (lower-bounds)
# n     = age interval
# l0    = radix

gen_lt = function(nqx,ages,n,l0=1){
	px = 1-nqx
	
	lx = l0
	for(i in 1:length(nqx)){
		lx=c(lx,lx[i]*px[i])
	}

	Lx = lx[2:length(lx)]*n + .5*(lx[1:(length(lx)-1)]-lx[2:length(lx)])

	return(data.frame(x=ages,lx=lx[-length(lx)],px=px,qx=nqx,Lx=Lx))
}


####################
## Calculate TADR ##
####################
# 
# pop = population vector
# age = vector of age lower-bounds (must be same length as pop)

get_tadr = function(pop, age){
	return(sum(pop[age < 15 | age > 64])/sum(pop[age >= 15 & age <= 64]))
}


###################
## Calculate KDR ##
###################
# (These functions requires Monica's kin functions)
#
# dat   = data with Lx, Fx, age, and year
# years = years to calculate KDR for

get_kdr = function(dat, years){
	
	df_kin <- c()

	Ws = dat %>% mutate(prop = ifelse(!(age %in% 15:45),0,pop)) %>% group_by(year) %>% mutate(prop = prop/sum(prop)) %>% select(year,age,prop) %>% ungroup()

	for(j in 1:length(years)){
	  this_df_data <- dat %>% ungroup()
	  this_d_for_mothers <- dat %>% ungroup() %>% filter(year == years[j])
	  this_W <- Ws 
	  df_direct <- tibble(mother_age = seq(15, 80, by = 5),
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
	  
	  	df_kin <- rbind(df_kin, df_direct)

	  	cat(paste0(dat$region[1]," (",years[j],") done..."))
	}

	df_kin <- df_kin %>%
  	mutate(kdr = ifelse(mother_age<45,
                      (daughters + granddaughters)/(1+mothers+grandmothers),
                      ifelse(mother_age >= 45 & mother_age <= 64, 
                        (daughters + granddaughters + mothers + grandmothers),
                        (mothers+grandmothers)/(1+daughters+granddaughters))
                      ))

	kdrs <- df_kin %>% rename(age= mother_age) %>%
	left_join(dat) %>% 
	  group_by(year) %>% 
	  summarise(kdr = sum(kdr*pop/sum(pop)))

	return(kdrs)
}


########################################
## Leslie Matrix Projection Functions ##
########################################

	###########################
	# Construct Leslie Matrix #
	###########################
	# (Assumes last age category is open-ended)
	#
	# Lx   = Lx values
	# Fx   = Fx values (must be same length as Lx)
	# n    = age interval
	# l0   = radix
	# ffab = fraction female at birth

	gen_LM = function(Lx, Fx, n, l0, ffab=.4886){
		Fx = ifelse(is.na(Fx),0,Fx)

		sdiag = Lx[2:length(Lx)]/Lx[1:(length(Lx)-1)]

		frow  = (Lx[1]/(2*l0)) * (Fx[1:(length(Fx)-1)] + Fx[2:length(Fx)]*(Lx[2:length(Lx)]/Lx[1:(length(Fx)-1)])) * ffab

		frow = ifelse(Fx==0,0,frow)[1:(length(Lx)-1)]

		mat = rbind(frow,diag(sdiag))
		mat = cbind(mat,c(rep(0,length(Lx)-1),1-sdiag[length(sdiag)]))

		return(mat)
	}

	##################################
	# Projection Using Leslie Matrix #
	##################################
	#
	# LM   = leslie matrix
	# pop  = population vector
	# n    = number of projection steps

	project_LM = function(LM, pop, n=1){
		res = cbind(pop)
		for(i in 1:n){
			res = cbind(res, LM %*% res[,i])
		}
		return(res)
	}

	######################################
	# Get Annual Population Growth Rates #
	######################################
	#
	# pops = matrix of population vectors from project_LM()
	# n    = projection interval

	get_growthr = function(pops,n){
		pops.sum = apply(pops,2,sum)
		growth_rates = (log(pops.sum[2:length(pops.sum)]) - log(1:(length(pops.sum)-1)))/n

		return(growth_rates)
	}


#####################################
## KDR & TADR Simulation Functions ##
#####################################
# 
# years = vector of periods to simulate
# ages  = vector of ages (lower bounds)
# n     = age interval
# nqx   = single vector of nqx values across all 'years'
# nFx   = single vector of nFx values across all 'years'
# i.pop = initial population vector

sim_kdr = function(years, ages, n, nqx, nFx, i.pop){

	dat = data.frame(year = rep(years,each=length(nqx)/length(years)), 
		             qx   = nqx,
		             Fx   = nFx)

	# set up sim data
	s1 = NULL
  	for(y in years){
	    tt = gen_lt(dat$qx[dat$year == y],ages, n=n, l0=100000) %>% select(age = x,Lx)
	    tt$Fx = dat$Fx[dat$year == y]
	    tt$year = y

	    s1 = rbind(s1,tt)
  	}

  	# Get implied population age distributions and intrinsic r from Matrix Projection
	s1.pops = cbind(i.pop)
	rs = NULL
	for(i in 1:length(years)){
	  tt = gen_LM(s1$Lx[s1$year==years[i]],s1$Fx[s1$year==years[i]]/1000,n=5,l0=100000)
	  rs = c(rs,Re(log(eigen(tt)$values[1])/n))
	  s1.pops =  cbind(s1.pops, project_LM(tt,s1.pops[,i])[,2])
	}

	# Add simulated pops to sim data
	s1$pop = c(s1.pops)[1:(length(s1.pops)-length(unique(s1$age)))]

	# calculate TADR and KDRs
	tt.tadr = s1 %>% group_by(year) %>% summarize(tadr = get_tadr(pop,age))
	tt.kdr = get_kdr(s1,seq(1990,2010,5))

	tt = tt.kdr %>% left_join(tt.tadr) 

	return(list(inds = tt,sim.dat = s1,intr_rs=rs))

}


#################################
## Kin Functions (from Monica) ##
#################################

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
    this_F <- df %>% 
      filter(age == x_vec[i], 
                            year == ifelse(mother_cohort+mean_age<2010, 
                                           mother_cohort+mean_age, 2010)) %>% 
      select(Fx) %>% pull()
    LF_prod <- c(LF_prod, this_L/10^5*this_F/10^3*ffab)
  }
  
  sum(LF_prod,na.rm=T)
}

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
      this_F <- df %>% filter(age == z, year == ifelse(daughter_cohort+mean_age<2010, daughter_cohort+mean_age, 2010)) %>% select(Fx) %>% pull()
      this_L_2 <- df %>% filter(age == age_a - x - z, year == this_year) %>% select(Lx) %>% pull()
      LFL_prod <- c(LFL_prod, this_L/10^5*this_F/10^3*ffab*this_L_2/10^5)
    }
  }
  return(sum(LFL_prod,na.rm=T))
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
    this_F <- df %>% filter(age == x, year == ifelse(mother_cohort+mean_age<2010, 
                                                     mother_cohort+mean_age, 2010)) %>% select(Fx) %>% pull()
    IF_prod <- c(IF_prod, Ix_bar*this_F/10^3*ffab)
  }
  return(sum(IF_prod,na.rm=T))
}

surviving_mothers_notstable <- function(df, # dataframe with Lx 
                                        W, # age distribution of wra 
                                     age_a, # age of ego
                                     this_year # year of estimation
){
  
  x_vec <- seq(15,45, by = 5)
  LF_prod <- c()
  W_year <- W %>% filter(year == ifelse((this_year - age_a)<1950, 1950, this_year - age_a))
  for(x in x_vec){
    this_Lxa <- df %>% filter(age == age_a + x) %>% select(Lx) %>% pull()
    this_Lx <- df %>% filter(age == x) %>% select(Lx) %>% pull()
    this_W <- W_year %>% filter(age == x) %>% select(prop) %>% pull()
    LF_prod <- c(LF_prod, this_Lxa/this_Lx*this_W)
  }
  
  return(sum(LF_prod,na.rm=T))
}

surviving_grandmothers_notstable <- function(df, # dataframe with Lx and Fx
                                             W, # age distribution of wra 
                                          age_a, # age of ego
                                          this_year # year of estimation
){
  
  x_vec <- seq(15,45, by = 5)
  LF_prod <- c()
  W_year <- W %>% filter(year == ifelse((this_year - age_a)<1950, 1950, this_year - age_a))
  for(x in x_vec){
    M_1 <- surviving_mothers_notstable(df, W, age_a+x, this_year)
    this_W <- W_year %>% filter(age == x) %>% select(prop) %>% pull()
    LF_prod <- c(LF_prod, M_1*this_W)
  }
  
  return(sum(LF_prod,na.rm=T))
}