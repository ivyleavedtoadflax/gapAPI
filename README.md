# gapAPI

This repository is home to a small [R](http://cran.r-project.org/) 
package for accessing the [GAP REST 
API](https://developer.globalalerting.com/API), and largely relies on 
functions from the package 
[httr](http://cran.r-project.org/package=httr).

This package will only be of use to clients using 
[CoSignal](http://www.cosignal.com/) GPS trackers, and with access to 
the GAP REST API. The main purpose of the package is to overcome the 
1000 row download constraint by automatically determining the next 1000 
rows to be downloaded based on the earliest value from the preceding 
chunk.

## Initial release 0.1

Initial release of the package includes the following functions:

|name|function|
|---|---|
|`get_devices`|Returns the full list of devices available to a user in a character vector.|
|`get_GPS`|The main function of the package. This function repeatedly calls `get_messages` having determined the correct dates to be queried from the server.|
|`get_messages`|Makes a GET call to the server and returns a response object (from `httr`) containing the requested data.|
|`simplify_cattle`|Converts JSON object returned in `get_messages` and returns a `data.frame`.|
|`save_records`|Wrapper function for `readr::write_csv` which saves `data.frame` specified folder.|

## Typical usage


```r
devtools::install_github("ivyleavedtoadflax/gapAPI/")
library(gapAPI)

my_tenant = 1234
my_username = "user@name.com"
my_password = "53CUR3P455"
```




```r
my_device_list <- get_devices(
  tenant = my_tenant,
  username = my_username,
  password = my_password
)

print(my_device_list)
```

```
## [1] "351564050232917" "351564050233204" "351564050233493" "351564050233501"
## [5] "351564050233550" "351564050233840" "351564050272756" "351564050278795"
## [9] "351564050283548"
```

```r
GPS_data <- get_GPS(
  tenant = my_tenant,
  username = my_username,
  password = my_password,
  device_list = my_device_list[1]
)
```


```r
head(GPS_data)
```

```
## Source: local data frame [6 x 13]
## 
##            device           timestamp       date     time SequenceNumber
## 1 351564050232917 2015-07-08 17:53:14 2015-07-08 17:53:14           1610
## 2 351564050232917 2015-07-08 17:23:03 2015-07-08 17:23:03           1609
## 3 351564050232917 2015-07-08 16:53:13 2015-07-08 16:53:13           1608
## 4 351564050232917 2015-07-08 16:23:31 2015-07-08 16:23:31           1607
## 5 351564050232917 2015-07-08 15:53:37 2015-07-08 15:53:37           1606
## 6 351564050232917 2015-07-08 15:00:55 2015-07-08 15:00:55           1604
## Variables not shown: SentFromDevice (time), MessageType (chr), lon (dbl),
##   lat (dbl), speed (dbl), heading (dbl), alt (dbl), accuracy (chr)
```

```r
str(GPS_data)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	4409 obs. of  13 variables:
##  $ device        : chr  "351564050232917" "351564050232917" "351564050232917" "351564050232917" ...
##  $ timestamp     : POSIXct, format: "2015-07-08 17:53:14" "2015-07-08 17:23:03" ...
##  $ date          : chr  "2015-07-08" "2015-07-08" "2015-07-08" "2015-07-08" ...
##  $ time          : chr  "17:53:14" "17:23:03" "16:53:13" "16:23:31" ...
##  $ SequenceNumber: int  1610 1609 1608 1607 1606 1604 4 1603 1602 3 ...
##  $ SentFromDevice: POSIXct, format: "2015-07-08 17:53:16" "2015-07-08 17:23:05" ...
##  $ MessageType   : chr  "GTFRI_POSITIONREPORT" "GTFRI_POSITIONREPORT" "GTFRI_POSITIONREPORT" "GTFRI_POSITIONREPORT" ...
##  $ lon           : num  0.425 0.425 0.423 0.423 0.423 ...
##  $ lat           : num  51.6 51.6 51.6 51.6 51.6 ...
##  $ speed         : num  2.1 0.5 2.8 0.8 1.1 1 NA 2.8 0.5 NA ...
##  $ heading       : num  298 0 0 0 0 0 NA 0 0 NA ...
##  $ alt           : num  84.1 65.4 84.8 72.3 88.9 ...
##  $ accuracy      : chr  "DOP 12" "DOP 11" "DOP 18" "DOP 14" ...
```




