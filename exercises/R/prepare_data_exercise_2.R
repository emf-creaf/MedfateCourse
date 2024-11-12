# Prepares FontBlanche data for exercise #2a and 2b

fb <- readRDS("~/Rpackages/medfate/vignettes/workedexamples/fb_data.rds")

# Remove unnecessary datasets
fb$forest_object1 <- NULL
fb$shrubData <- NULL
fb$sp_params <- NULL
fb$remarks <- NULL
fb$miscData <- NULL

# Modify some params
fb$soilData$rfc[1] <- 55
fb$soilData$rfc[2] <- 75
 
saveRDS(fb, "exercises/StudentRdata/fontblanche.rds")
