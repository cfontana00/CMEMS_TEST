**The routine _withoutCMEMS loops through all variables described in the JSON file:**

CONFIGURATION : motu_downloader.json

LIST_PROD 

cmems_mod_med_phy-cur_anfc_4.2km_P1D-m

cmems_mod_med_phy-sal_anfc_4.2km_P1D-m

cmems_mod_med_phy-temp_anfc_4.2km_P1D-m

PRODUCT:cmems_mod_med_phy-cur_anfc_4.2km_P1D-m

PRODUCT:cmems_mod_med_phy-sal_anfc_4.2km_P1D-m

PRODUCT:cmems_mod_med_phy-temp_anfc_4.2km_P1D-m

LIST_PROD 

cmems_mod_med_bgc-nut_anfc_4.2km_P1D-m

cmems_mod_med_bgc-bio_anfc_4.2km_P1D-m

cmems_mod_med_bgc-car_anfc_4.2km_P1D-m

PRODUCT:cmems_mod_med_bgc-nut_anfc_4.2km_P1D-m

PRODUCT:cmems_mod_med_bgc-bio_anfc_4.2km_P1D-m

PRODUCT:cmems_mod_med_bgc-car_anfc_4.2km_P1D-m






**In _withCMES, the copernicusmarine command breaks the loop after download and thus download only 2 files:**


CONFIGURATION : motu_downloader.json

LIST_PROD

cmems_mod_med_phy-cur_anfc_4.2km_P1D-m

cmems_mod_med_phy-sal_anfc_4.2km_P1D-m

cmems_mod_med_phy-temp_anfc_4.2km_P1D-m

PRODUCT:cmems_mod_med_phy-cur_anfc_4.2km_P1D-m

username: INFO - 2024-03-04T11:41:07Z - Dataset version was not specified, the latest one was selected: "202311"

INFO - 2024-03-04T11:41:07Z - Dataset part was not specified, the first one was selected: "default"

INFO - 2024-03-04T11:41:08Z - Service was not specified, the default one was selected: "arco-geo-series"

INFO - 2024-03-04T11:41:09Z - Downloading using service arco-geo-series...

INFO - 2024-03-04T11:41:11Z - Estimated size of the dataset file is 15.411 MB.

INFO - 2024-03-04T11:41:11Z - Writing to local storage. Please wait...

INFO - 2024-03-04T11:41:47Z - Successfully downloaded to cmems_mod_med_phy-cur_anfc_4.2km_P1D-m-_(1).nc

LIST_PROD

cmems_mod_med_bgc-nut_anfc_4.2km_P1D-m

cmems_mod_med_bgc-bio_anfc_4.2km_P1D-m

cmems_mod_med_bgc-car_anfc_4.2km_P1D-m

PRODUCT:cmems_mod_med_bgc-nut_anfc_4.2km_P1D-m

username: INFO - 2024-03-04T11:41:49Z - Dataset version was not specified, the latest one was selected: "202211"

INFO - 2024-03-04T11:41:49Z - Dataset part was not specified, the first one was selected: "default"

INFO - 2024-03-04T11:41:51Z - Service was not specified, the default one was selected: "arco-geo-series"

INFO - 2024-03-04T11:41:53Z - Downloading using service arco-geo-series...

INFO - 2024-03-04T11:41:56Z - Estimated size of the dataset file is 30.823 MB.

INFO - 2024-03-04T11:41:56Z - Writing to local storage. Please wait...

INFO - 2024-03-04T11:42:37Z - Successfully downloaded to cmems_mod_med_bgc-nut_anfc_4.2km_P1D-m-_(1).nc


