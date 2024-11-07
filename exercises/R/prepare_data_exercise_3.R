# Prepares Alepo pine data for exercise #3

library(medfateland)

# Load inputs from GrowthCalibration
cal_dir  <- "~/OneDrive/mcaceres_work/model_development/medfate_parameterization/GrowthCalibration"
sf_ifn_meteo <- readRDS(file.path(cal_dir, "data", "SpParamsMED", "input", "sf_IFN_meteo.rds"))
sf_plot_obs <- readRDS(file.path(cal_dir, "data", "SpParamsMED", "input", "plot_desc_observed.rds"))

# Retrieve topography, IFN3, IFN4 and soil data
sf_plot <- sf_ifn_meteo |>
  dplyr::filter(ID=="432105_A1") |>
  dplyr::select(id, elevation, slope, aspect, forest3, forest4, soil, meteo)
sf_topo <- sf_plot |>
  dplyr::select(id, elevation, slope, aspect)
lat_lon <- sf_topo |>
  sf::st_transform(crs = 4326) |>
  sf::st_coordinates()
forest_IFN3 <- sf_plot$forest3[[1]]
forest_IFN4 <- sf_plot$forest4[[1]]
soildesc <- sf_plot$soil[[1]]

# Retrieve observed data (dendrocronology)
sf_obs <- sf_plot_obs |>
  dplyr::filter(IDPARCELA=="432105")
obs <- sf_obs$observed[[1]]
  
# Remove Chamaerops humilis and Smilax aspera 
sp_to_remove <- c("Chamaerops humilis", "Smilax aspera")
forest_IFN3$treeData <-forest_IFN3$treeData |>
  dplyr::filter(!(Species %in% sp_to_remove))
forest_IFN4$treeData <-forest_IFN4$treeData |>
  dplyr::filter(!(Species %in% sp_to_remove))
forest_IFN3$shrubData <-forest_IFN3$shrubData |>
  dplyr::filter(!(Species %in% sp_to_remove))
forest_IFN4$shrubData <-forest_IFN4$shrubData |>
  dplyr::filter(!(Species %in% sp_to_remove))

# Remove shrub cohorts < 10% cover
forest_IFN3$shrubData <-forest_IFN3$shrubData |>
  dplyr::filter(Cover>5)
forest_IFN4$shrubData <-forest_IFN4$shrubData |>
  dplyr::filter(Cover>5)

# Historic weather
hist_weather <- sf_plot$meteo[[1]]
dates_hist <- seq(as.Date("2001-01-01"), as.Date("2014-12-31"), by= "day")
hist_weather <- hist_weather |>
  dplyr::mutate(dates = as.Date(dates)) |>
  dplyr::filter(dates %in% dates_hist)

#Future weather
climate_base <- "~/OneDrive/EMF_datasets/Climate/"
yearsIni <- c(2006,seq(2011, 2091, by=10))
yearsFin <- c(seq(2010, 2100, by=10))
met_list <- vector("list", length(yearsIni))
for(iy in 1:length(yearsIni)) {
  print(iy)
  interpolator_file <- paste0(climate_base,"Products/InterpolationData/Catalunya/Projections/", 
                              "mpiesm_rca4_rcp85_daily_interpolator_", yearsIni[iy], "_", yearsFin[iy],".nc")
  interpolator <- meteoland::read_interpolator(interpolator_file)
  sf_int <- meteoland::interpolate_data(sf_topo, interpolator)
  met_list[[iy]] <- sf_int$interpolated_data[[1]]
}
fut_weather <- dplyr::bind_rows(met_list)
dates_proj <- seq(as.Date("2015-01-01"), as.Date("2100-12-31"), by= "day")
fut_weather <- fut_weather |>
  dplyr::mutate(dates = as.Date(dates)) |>
  dplyr::filter(dates %in% dates_proj)

# table of tree growth
td3 <- forest_IFN3$treeData
td3 <- td3[!is.na(td3$OrdenIf3),c("Species", "N", "DBH", "Height", "OrdenIf3")]
names(td3) <- c("Species", "N_SNFI3", "DBH_SNFI3", "Height_SNFI3", "OIF3")
td4 <- forest_IFN4$treeData[,c("N", "DBH", "Height", "OrdenIf3")]
names(td4) <- c("N_SNFI4", "DBH_SNFI4", "Height_SNFI4", "OIF3")
snfi34_growth <- dplyr::left_join(td3, td4, by="OIF3")
snfi34_growth<-snfi34_growth[, c(5,1,2,6,3,7,4,8)]

# Remove codes
forest_IFN3$treeData = forest_IFN3$treeData[,2:7]
forest_IFN4$treeData = forest_IFN4$treeData[,2:7]

# Assemble list with data
alepo <- list()
alepo$latitude<- as.numeric(lat_lon[1,2])
alepo$elevation <- sf_topo$elevation
alepo$slope <- sf_topo$slope
alepo$aspect <- sf_topo$aspect
alepo$forest_snfi3 <- forest_IFN3
alepo$forest_snfi4 <- forest_IFN4
alepo$soildesc <- soildesc
alepo$historic_weather <- hist_weather
alepo$projected_weather <- fut_weather
alepo$observed_growth <- obs
alepo$snfi34_growth <- snfi34_growth

saveRDS(alepo, "exercises/StudentRdata/alepo.rds")
