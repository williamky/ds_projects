setwd("/Users/williamyau/ds_projects/GeoLift")
library("devtools")
#install.packages("remotes", repos='http://cran.us.r-project.org')
devtools::install_github("ebenmichael/augsynth", dependencies = TRUE)
devtools::install_github("facebookincubator/GeoLift", dependencies = TRUE)
library(GeoLift)
library(ggplot2)

data(GeoLift_PreTest)
head(GeoTestData_PreTest)

GeoTestData_PreTest <- GeoDataRead(data = GeoLift_PreTest,
                                   date_id = "date",
                                   location_id = "location",
                                   Y_id = "Y",
                                   X = c(), #empty list as we have no covariates
                                   format = "yyyy-mm-dd",
                                   summary = TRUE)

head(GeoTestData_PreTest)

GeoPlot(GeoTestData_PreTest,
        Y_id = "Y",
        time_id = "time",
        location_id = "location")
#GeoTest
#summary(GeoTest)
#plot(GeoTest, type = "Lift")
--------------------------------------------------------------------------------------------------------
  MarketSelections <- GeoLiftMarketSelection(data = GeoTestData_PreTest,
                                             treatment_periods = c(10,15),
                                             N = c(2,3,4,5),
                                             Y_id = "Y",
                                             location_id = "location",
                                             time_id = "time",
                                             effect_size = seq(0, 0.5, 0.05),
                                             lookback_window = 1,
                                             include_markets = c("chicago"),
                                             exclude_markets = c("honolulu"),
                                             holdout = c(0.5, 1),
                                             cpic = 7.50,
                                             budget = 100000,
                                             alpha = 0.1,
                                             Correlations = TRUE,
                                             fixed_effects = TRUE,
                                             side_of_test = "two_sided")

# Plot for chicago, cincinnati, houston, portland for a 15 day test
plot(MarketSelections, market_ID = 1, print_summary = FALSE)

market_id = 2 #selected the 2nd market of chicago,portland
market_row <- MarketSelections$BestMarkets %>% dplyr::filter(ID == market_id)
treatment_locations <- stringr::str_split(market_row$location, ", ")[[1]]
treatment_duration <- market_row$duration
lookback_window <- 7

power_data <- GeoLiftPower(
  data = GeoTestData_PreTest,
  locations = treatment_locations,
  effect_size = seq(-0.25, 0.25, 0.01),
  lookback_window = lookback_window,
  treatment_periods = treatment_duration,
  cpic = 7.5,
  side_of_test = "two_sided"
)
#> Setting up cluster.
#> Importing functions into cluster.

plot(power_data, show_mde = TRUE, smoothed_values = FALSE, breaks_x_axis = 5) + labs(caption = unique(power_data$location))

# Plot for chicago, cincinnati, houston, portland for a 15 day test
plot(MarketSelections, market_ID = 2, print_summary = TRUE)

GeoTest <- GeoLift(Y_id = "Y",
                   data = GeoTestData_Test,
                   locations = c("chicago", "portland"),
                   treatment_start_time = 91,
                   treatment_end_time = 105)

data(GeoLift_Test)
GeoTestData_Test <- GeoDataRead(data = GeoLift_Test,
                                date_id = "date",
                                location_id = "location",
                                Y_id = "Y",
                                X = c(), #empty list as we have no covariates
                                format = "yyyy-mm-dd",
                                summary = TRUE)
GeoTest <- GeoLift(Y_id = "Y",
                   data = GeoTestData_Test,
                   locations = c("chicago", "portland"),
                   treatment_start_time = 91,
                   treatment_end_time = 105)
GeoTest
