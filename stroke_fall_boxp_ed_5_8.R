

rm(list=ls())
setwd("D:/r/chart_boxplot/split_day_time/")

library(tidyverse)

data_boxplot <- read_csv("boxp_ed_5-8.csv")


## ALL
# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Injuries Unknown' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Injuries Unknown (Aug21 to Jul22)') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Injuries_Unknown_ed_all_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Non Injury' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Non Injury (Aug21 to Jul22)') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Non_Injury_ed_all_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Stroke Neurological' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Stroke Neurological (Aug21 to Jul22)') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Stroke_Neurological_ed_all_5_8.png', height = 1400, width = 3000, units = "px") 


## -----------------------------------------------------------------------------
## DAY


ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Injuries Unknown' ) %>% 
       filter(is_day_night == 'day' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Injuries Unknown (Aug21 to Jul22) - Daytime only (08-18)') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Injuries_Unknown_ed_day_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Non Injury' ) %>% 
         filter(is_day_night == 'day' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Non Injury (Aug21 to Jul22) - Daytime only (08-18)') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Non_Injury_ed_day_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Stroke Neurological' ) %>% 
         filter(is_day_night == 'day' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Stroke Neurological (Aug21 to Jul22) - Daytime only (08-18)') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Stroke_Neurological_ed_day_5_8.png', height = 1400, width = 3000, units = "px") 


## -----------------------------------------------------------------------------
## NIGHT


ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Injuries Unknown' ) %>% 
         filter(is_day_night == 'night' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Injuries Unknown (Aug21 to Jul22) - Nighttime only (18-08)') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Injuries_Unknown_ed_night_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Non Injury' ) %>% 
         filter(is_day_night == 'night' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Non Injury (Aug21 to Jul22) - Nighttime only (18-08)') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Non_Injury_ed_night_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Stroke Neurological' ) %>% 
         filter(is_day_night == 'night' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Stroke Neurological (Aug21 to Jul22) - Nighttime only (18-08)') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Stroke_Neurological_ed_night_5_8.png', height = 1400, width = 3000, units = "px") 


## -----------------------------------------------------------------------------
## weekday


ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Injuries Unknown' ) %>% 
         filter(is_weekday == 'weekday' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Injuries Unknown (Aug21 to Jul22) - Weekday only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Injuries_Unknown_ed_weekday_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Non Injury' ) %>% 
         filter(is_weekday == 'weekday' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Non Injury (Aug21 to Jul22) - Weekday only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Non_Injury_ed_weekday_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Stroke Neurological' ) %>% 
         filter(is_weekday == 'weekday' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Stroke Neurological (Aug21 to Jul22) - Weekday only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Stroke_Neurological_ed_weekday_5_8.png', height = 1400, width = 3000, units = "px")


## -----------------------------------------------------------------------------
## weekday


ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Injuries Unknown' ) %>% 
         filter(is_weekday == 'weekend' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Injuries Unknown (Aug21 to Jul22) - Weekend only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Injuries_Unknown_ed_weekend_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Non Injury' ) %>% 
         filter(is_weekday == 'weekend' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Non Injury (Aug21 to Jul22) - Weekend only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Non_Injury_ed_weekend_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Stroke Neurological' ) %>% 
         filter(is_weekday == 'weekend' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Stroke Neurological (Aug21 to Jul22) - Weekend only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Stroke_Neurological_ed_weekend_5_8.png', height = 1400, width = 3000, units = "px")


## -----------------------------------------------------------------------------
## winter


ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Injuries Unknown' ) %>% 
         filter(is_winter == 'winter' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Injuries Unknown - Nov-Mar only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Injuries_Unknown_ed_winter_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Non Injury' ) %>% 
         filter(is_winter == 'winter' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Non Injury - Nov-Mar only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Non_Injury_ed_winter_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Stroke Neurological' ) %>% 
         filter(is_winter == 'winter' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Stroke Neurological - Nov-Mar only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Stroke_Neurological_ed_winter_5_8.png', height = 1400, width = 3000, units = "px")


## -----------------------------------------------------------------------------
## winter


ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Injuries Unknown' ) %>% 
         filter(is_winter == 'not_winter' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Injuries Unknown - Apr-Oct only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Injuries_Unknown_ed_not_winter_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Fall Non Injury' ) %>% 
         filter(is_winter == 'not_winter' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Fall Non Injury - Apr-Oct only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Fall_Non_Injury_ed_not_winter_5_8.png', height = 1400, width = 3000, units = "px") 


# Fall Injuries Unknown
ggplot(data_boxplot %>% 
         filter(Amb_Complaint == 'Stroke Neurological' ) %>% 
         filter(is_winter == 'not_winter' ), aes(x = Cat, y = Vol)) +
  geom_boxplot(outlier.colour='red') +
  stat_summary(fun=mean, geom="point", shape=23, size=4) +
  # theme_classic() +
  xlab('Wait Type') +  # set x axis label, if removed the column heading name will be used.
  ylab('Hours') +  # set y axis label, if removed the column heading name will be used
  ggtitle('HWICB - Patients Waits For  Pathway Stroke Neurological - Apr-Oct only') +
  scale_x_discrete(labels = function(Cat) str_wrap(Cat, width = 10)) +
  facet_wrap(vars(County))
ggsave('Stroke_Neurological_ed_not_winter_5_8.png', height = 1400, width = 3000, units = "px")

