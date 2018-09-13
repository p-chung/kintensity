library(tidyverse)

# read in data tables
	# Crude Birth Rate (per 1000)
	d.cbr = read_csv("CBR.csv",skip=4)[,1:61]
	d.cbr$`Indicator Code`="cbr"

	# Crude Death Rate (per 1000)
	d.cdr = read_csv("CDR.csv",skip=4)[,1:61] 
	d.cdr$`Indicator Code`="cdr"

	# Life Expectancy at Birth
	d.e0 = read_csv("e0.csv",skip=4)[1:61]
	d.e0$`Indicator Code`="e0"

	# Total Fertility Rate
	d.tfr = read_csv("TFR.csv",skip=4)[1:61]
	d.tfr$`Indicator Code`="tfr"

	# Old-Age Dependency Ratio
	d.oadr = read_csv("old_age_dependency.csv",skip=4)[1:61] 
	d.oadr$`Indicator Code`="oadr"
	
	# Total Age Dependency Ratio
	d.tadr = read_csv("age_dependency.csv",skip=4)[1:61]
	d.tadr$`Indicator Code`="tadr"
  
# stack tables
d.inds = rbind(d.cbr,d.cdr,d.e0,d.tfr,d.oadr,d.tadr)

# assign friendlier variable names
names(d.inds) = c("cntry_lab","cntry","ind_lab","ind",paste0(1960:2016))

# long-ify the data for easier plotting/tabling
d.inds = d.inds %>% gather(year,value,-cntry_lab,-cntry,-ind,-ind_lab) %>% mutate(year = as.integer(year))

# write data
saveRDS(d.inds,file="all_indicators.rds")

readRDS("all_indicators.rds")
