# COVID-19 data

This data is a subset of the data provided by Johns Hopkins University Center for Systems Science and Engineering
at their [github repository](https://github.com/CSSEGISandData/COVID-19).
Here is their original README: [README_orig.md](README_orig.md).

Downloaded as follows on 3/11/20:
```
git clone git@github.com:CSSEGISandData/COVID-19.git
mv COVID-19/README.md README_orig.md
mv COVID-19/csse_covid_19_data/README.md README_csse.md
mv COVID-19/csse_covid_19_data/* .
rf -rf COVID-19
git add README_orig.md csse_covid_19_daily_reports csse_covid_19_time_series
``
