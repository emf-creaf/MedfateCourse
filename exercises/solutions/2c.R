setwd("C:/Users/Rodrigo/Desktop/PostDoc/Docencia/Curso_Soria/prueba/2c")
## Exercise 2C 
####################### PREPARING INPUTS ######################################
fb<-readRDS("C:/Users/Rodrigo/Desktop/PostDoc/Docencia/Curso_Soria/MedfateCourse/exercises/StudentRdata/fontblanche.RDS")
fb$siteData <- NULL
fb$treeData
fb$customParams <- NULL
a<-fb$measuredData
fb$meteoData
fb$soilData
fb$terrainData
#Tivissa
tv<-fb
################## Soil procesiing
soil<-read.csv("soil2c.csv")
tv$soilData<-soil
#################### Terrain processing
tv$terrainData$latitude<-41.053
tv$terrainData$elevation<-555
##################### Meteo
meteo <- read.csv("meteo_interpolator.csv")
meteo <- meteo[13881:14245,]
row.names(meteo)<-NULL
tv$meteoData<-meteo
###################### Shrub data
veget <- read.csv("shrubData_ALL.csv")
veget <- veget[c(9,15,21),1:5]
row.names(veget)<-NULL
############### v
tv$shrubData <- veget
tv$treeData <- NULL
tv$shrubData$Z50 <- c(100,350,300)
tv$shrubData$Z95 <- c(400,2000,1500)
tv$shrubData<-tv$shrubData[c(1,3),]
tv$shrubData$Cover <- c(50,30)
###################### Measured data
measuredData <- read.csv("measuredData.csv")
tv$measuredData<-measuredData
################ Save
saveRDS(tv, "tivissa.rds")

  
############################### EJERCICIO ######################################
library(medfate)
library(medfateland)
library(meteoland)
library(cowplot)
library(ggplot2)

#RDS
tv <- readRDS("tivissa.rds")

#Forest
tv_forest <- emptyforest()
tv_forest$shrubData <- tv$shrubData
data("SpParamsMED")
#Soil
tv_soil <- soil(tv$soilData)

#Control
tv_control <- defaultControl("Sureau")
tv_control$fireHazardResults <- TRUE
tv_control$fireHazardStandardWind <- 5
tv_control$fireHazardStandardDFMC <- 10

#Input
tv_x1 <- spwbInput(tv_forest, tv_soil, SpParamsMED, tv_control)

#Correct species names
tv_forest$shrubData$Species[tv_forest$shrubData$Species=="Rosmarinus officinalis"] <- "Salvia rosmarinus"


#Input 2
tv_x1 <- spwbInput(tv_forest, tv_soil, SpParamsMED, tv_control)

#Meteo
tv_meteo <- tv$meteoData

#Terrain
tv$terrainData

# Simulation
tv_spwb <- spwb(tv_x1, tv_meteo, elevation = 555, latitude = 41.053)


#Visualize LFMC simulated dynamics
g1<-plot(tv_spwb, type = "LFMC", bySpecies = T) +
  scale_x_date(date_breaks = "1 month", date_labels = "%m")+
  theme(legend.position = "inside", legend.position.inside =  c(0.1,0.7))
g1

#Ajustes con datos observados
tv_observed <- tv$measuredData
tv_observed <- dplyr::filter(tv_observed, !is.na(tv_observed$LFMC_S1_165))
names(tv_observed)[2]<-"LFMC_S2_165"
#Quercus
evaluation_metric(tv_spwb, tv_observed, cohort = "S2_165", type="LFMC")

g2a<-evaluation_plot(tv_spwb, tv_observed, cohort = "S2_165", type="LFMC", plotType = "dynamics")
g2b<-evaluation_plot(tv_spwb, tv_observed, cohort = "S2_165", type="LFMC", plotType = "scatter")
g2 <- plot_grid(g2a, g2b, ncol = 2)
#Rosmarinus
g3a<-evaluation_plot(tv_spwb, tv_observed, cohort = "S1_188", type="LFMC", plotType = "dynamics")
g3b<-evaluation_plot(tv_spwb, tv_observed, cohort = "S1_188", type="LFMC", plotType = "scatter")
g3 <- plot_grid(g3a, g3b, ncol = 2)
#Arrange
plot_grid(g2, g3, ncol = 1)





#Repetir con Suelo ajustado
tv$soilData$rfc <- c(17,57,97,97)
tv_soil2 <- soil(tv$soilData)


#Input 2
tv_x2 <- spwbInput(tv_forest, tv_soil2, SpParamsMED, tv_control)

# Simulation2
tv_spwb2 <- spwb(tv_x2, tv_meteo, elevation = 555, latitude = 41.053)

#Visualize LFMC simulated dynamics
g1<-plot(tv_spwb2, type = "LFMC", bySpecies = T) +
  scale_x_date(date_breaks = "1 month", date_labels = "%m")+
  theme(legend.position = "inside", legend.position.inside =  c(0.1,0.7))
g1

#Ver ajustes
#Quercus
g2a<-evaluation_plot(tv_spwb, tv_observed, cohort = "S2_165", type="LFMC", plotType = "dynamics")
g2b<-evaluation_plot(tv_spwb, tv_observed, cohort = "S2_165", type="LFMC", plotType = "scatter")
g2 <- plot_grid(g2a, g2b, ncol = 2)
#Rosmarinus
g3a<-evaluation_plot(tv_spwb, tv_observed, cohort = "S2_188", type="LFMC", plotType = "dynamics")
g3b<-evaluation_plot(tv_spwb, tv_observed, cohort = "S2_188", type="LFMC", plotType = "scatter")
g3 <- plot_grid(g3a, g3b, ncol = 2)
#Arrange
plot_grid(g2, g3, ncol = 1)


#################################################### Sacar Fire Hazard
FireHazard <- data.frame(
  Date = as.Date(tv_spwb$weather$dates),
  FireLineIntensity = tv_spwb$FireHazard$I_b_surface)

FireHazard$FireLineIntensity[FireHazard$FireLineIntensity=="NaN"]<-0

#Final super Plot con Fire Hazard
g0<-plot(tv_spwb)+
  scale_x_date(date_breaks = "1 month", date_labels = "%m")+
  theme(legend.position = "none")


g1<-plot(tv_spwb, type = "LFMC", bySpecies = T) +
  scale_x_date(date_breaks = "1 month", date_labels = "%m")+
  theme(legend.position = "inside", legend.position.inside =  c(0.1,0.7))


g2<-ggplot(FireHazard, aes(x=Date, y=FireLineIntensity, colour = "darkred"))+
  scale_x_date(date_breaks = "1 month", date_labels = "%m")+
  geom_line()+
  ylab("Fire Line Intensity (kW/m)")+
  theme_classic()+
  theme(legend.position = "none")

#Arrange  
plot_grid(g0, g1, g2, ncol = 1)







