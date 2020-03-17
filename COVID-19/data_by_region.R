#!/usr/bin/env Rscript

# This script makes some exploratory graphs of the data
# (number of cases plotted against time since a threshold number was passed)
# and produces cases_by_country_region.csv which contains
# the total number of cases by country, along with the number of days since the
# number of cases first passed 100.

library(ggplot2)
library(lubridate)
library(reshape2)
library(dplyr)

data_dir <- "../../datasets/COVID-19"
d <- read.csv(file.path(data_dir, "csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"), header=TRUE, check.names=FALSE)
names(d)[1:2] <- gsub("/", "_", names(d)[1:2], fixed=TRUE)
# exclude Diamond Princess
d <- subset(d, Province_State != "Diamond Princess cruise ship")
cols <- as.character(colnames(d[,5:length(d)]))
d$loc_name <- factor(paste0(as.character(d$Province_State), ifelse(nchar(as.character(d$Province_State)) == 0, "", ", "), as.character(d$Country_Region)))
locations <- d[, setdiff(colnames(d), cols)]
thresh_date_d <- function (thresh) {
    first_index <- 1 + rowSums(d[,cols] < thresh)
    first_index[first_index > length(cols)] <- NA
    return(mdy(cols[first_index]))
}
locations$first_date <- thresh_date_d(1)
locations$ten_date <- thresh_date_d(10)

covid <- melt(d,
              id.vars = c("Province_State","Country_Region","loc_name"),
              measure.vars = cols)
names(covid)[match(c("variable", "value"), names(covid))]  <- c("Date","Case_Count")
covid$Date <- mdy(as.character(covid$Date))
covid <- covid[order(covid$Province_State, covid$Country_Region, covid$Date),]

thresh_date <- function (df, thresh, group="loc_name") {
    use_these <- (df$Case_Count >= thresh)
    first_date <- as.Date(rep(NA, nlevels(df[[group]])))
    names(first_date) <- levels(df[[group]])
    for (g in levels(df[[group]])) {
        if (any(df$Case_Count >= thresh & df[[group]] == g)) {
            first_date[g] <- min(df$Date[df$Case_Count >= thresh & df[[group]] == g])
        }
    }
    return(first_date)
}
days_since <- function (df, thresh, group="loc_name") {
    return(df$Date - thresh_date(df, thresh, group=group)[match(df[[group]], levels(df[[group]]))])
}
covid$days <- days_since(covid, 100)

if (interactive()) {
    (ggplot(covid, aes(x=days, y=Case_Count, group=loc_name, col=Country_Region))
        + geom_line()
        + theme(legend.position = "none")
        + xlim(c(0, 50)) + scale_y_log10() + facet_wrap( ~ ifelse(Country_Region == "Mainland China", "China", "Not China")) )
}

covid_by_country <- (covid %>% group_by(Country_Region, Date) %>% summarise(Case_Count=sum(Case_Count)))
covid_by_country$days_since_100 <- days_since(covid_by_country, 100, "Country_Region")
covid_by_country <- droplevels(subset(covid_by_country, !is.na(days_since_100)))

if (interactive()) {
    (ggplot(covid_by_country, aes(x=days_since_100, y=Case_Count, col=Country_Region))
        + geom_line()
        + xlim(c(0, 50)) + scale_y_log10())
}

write.csv(covid_by_country, file="cases_by_region.csv", row.names=FALSE)
