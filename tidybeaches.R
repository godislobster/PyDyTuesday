

nstall.packages('janitor')
install.packages('here')

library(tidyverse)
library(tidyr)
library(tidytuesdayR)
library(janitor)
library(here)

tuesdata <-tidytuesdayR::tt_load('2025-05-20')

water_quality <-tuesdata$water_quality
weather <-tuesdata$weather

weather <- weather |>
  dplyr::select(date = latitude, 
                max_temp_C = longitude, 
                min_temp_C  = elevation, 
                precipitation_mm = utc_offset_seconds) |>
  dplyr::slice(-(1:2)) |>
  dplyr::mutate(date = ymd(date)) |>
  dplyr::mutate(latitude = -33.848858, 
                longitude = 151.19551) 

# Water quality data for Sydney beaches provided by https://www.beachwatch.nsw.gov.au/waterMonitoring/waterQualityData

water_quality <- water_quality |>
  janitor::clean_names() |>
  rename(enterococci_cfu_100ml = enterococci_cfu_100m_l, conductivity_ms_cm = conductivity_m_s_cm) |>
  dplyr::mutate(date = dmy(date)) |>
  dplyr::mutate(
    dplyr::across(
      c("enterococci_cfu_100ml", "water_temperature_c", "conductivity_ms_cm"),
      as.integer
    )
  )

View(water_quality)
View(weather)

h20_and_weather <-inner_join(water_quality, weather, by = 'date')
View(h20_and_weather)


#checking for nas 

h20_and_weather %>% 
  count(is.na(h20_and_weather$enterococci_cfu_100ml))

h20_and_weather %>% 
  count(is.na(h20_and_weather$water_temperature_c))

h20_and_weather %>% 
  count(is.na(h20_and_weather$precipitation_mm))

h20_and_weather %>% 
  count(is.na(h20_and_weather$max_temp_C))
h20_and_weather %>% 
  count(is.na(h20_and_weather$min_temp_C))

h20_and_weather_nona <-h20_and_weather %>% 
  drop_na(enterococci_cfu_100ml)

summary(h20_and_weather_nona)

nrow(h20_and_weather_nona)

x <-h20_and_weather_nona$enterococci_cfu_100ml

#I wanted to do a histogram to see the distrubtion. However, I couldn't get the code to work right and then I realized I was dealing with massive outliers

summary(x)

outlier_values <-boxplot.stats(x)$out
boxplot(x, main = "Enterococci per 100ml", boxwex =0.1)
mtext(paste("Outliers:", paste(outlier_values, collapse = ",")),cex=0.6)

#Okay, I have two major outliers and need to determine the IQR which for me is the upper bound

19+(1.5*50)
#94

df_under94 <-subset(h20_and_weather_nona, x >= 95)
#Okay this would remove 10,301 rows outside of the normal disbution
nrow(df_under94)

df <-h20_and_weather_nona %>% 
  filter(x <=95)


nrow(df)
#left with 112946 rows

hist(df$enterococci_cfu_100ml, main="Histogram of Enterococci", xlab= "Variable")
#long right tail so we don't want to use pearson's corrolation and want to use Spearman's, but I need to shape the data a bit

#a bit of a problem the number of beaches make this data hard to measure by the single tempature

df$date <-as.Date(df$date)


df_summary <-df %>% 
  group_by(date) %>% 
  summarise(
    coccoi = mean(enterococci_cfu_100ml)
  )

df_summary

df_temp_date <-inner_join(df_summary, weather, by = 'date')

View(df_temp_date)

#okay got the dataframe nice and neat

#checking for linerity

ggplot(df_temp_date, aes(x = max_temp_C, y = coccoi)) +
  geom_point(color = '#2980B9', size = 1) +
  geom_smooth(method = lm, se = FALSE, fullrange = TRUE, color = '#2c3e50') +
  labs(
    x = 'Temp in °C',
    y = 'Number of Enterococci in 100/mL',
    title = 'Assessing Linearity'
  )



#vaugely postive but largely flat, but there is a linear relationship

# are these variable corralated
corr_spear <-cor.test(x = df_temp_date$max_temp_C, y= df_temp_date$coccoi, method = "spearman")$estimate
corr


#Spearman's rank correlation rho

#S = 2.1298e+10, p-value = 0.0001495
#       rho 
#0.05292208 
 #there is a weak and significant increase, shrug

corr <-cor.test(x = df_temp_date$max_temp_C, y= df_temp_date$coccoi, test = "pearson")$estimate
corr



#Pearsons product-moment correlation

#t = 1.5696, df = 5127, p-value = 0.1166

#95 percent confidence interval:
# -0.005455472  0.049255171

#       cor 
#0.02191626

df<-data.frame(x = df_temp_date$max_temp_C, y = df_temp_date$coccoi)

ggplot(df, aes(x=x, y=y)) +
  geom_point(color = '#2980B9', alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE, color ='#2c3e50') +
  labs(
    title = paste0(
                   'Spearman corr =', round(corr_spear, 3)),
    x = 'Temp in C',
    y = 'Number of E.coli in 100 mL'
  )












