<p align="justify">

# Commuting Zones of England and Wales

## Output data

- `./output/lad20x_cz.csv` contains a correspondence table matching harmonised local authority districts (LAD20X) covering the whole of England and Wales to Tolbert-Sizer commuting zones (CZ).
  
- `./output/commdat.RDS`  is a list containing the following data frames:
    - `commdat[["dir annual by LAD"]]`  contains directed commuting flows by UK Census year (1991, 2001, 2011) and 2001 Interaction District pair (for 1991, 2001) or Census Merged LAD pair (for 2011).
  
    - `commdat[["undir annual by LAD"]]`contains gross commuting flows by  UK Census year (1991, 2001, 2011) and 2001 Interaction District pair (for 1991, 2001) or Census Merged LAD pair (for 2011).
  
    -  `commdat[["dir annual by LAD20X"]]` contains directed commuting flows  by UK Census year (1991, 2001, 2011) and  LAD20X pair.
  
    - `commdat[["undir annual by LAD20X"]]` contains gross commuting flows by UK Census year (1991, 2001, 2011) and LAD20X pair.
  
    -  `commdat[["resworkers annual by LAD20X"]]` contains the resident workforce by UK Census year (1991, 2001, 2011) and LAD20X.
  
    -   `commdat[["minresworkers annual by LAD20X"]]` contains the minimum resident workforce UK Census year (1991, 2001, 2011)  and LAD20X pair.
  
    - `commdat[["T-S annual by LAD20X"]]` contains Tolbert-Sizer commuting dissimilarity measures  by Census year (1991, 2001, 2011) and LAD20X pair.
  
    - `commdat[["T-S average by LAD20X"]]` contains average Tolbert-Sizer commuting dissimilarity across Census years (1991, 2001, 2011)  by LAD20X pair.

- `./output/geometries/lad20x_cz.shp` contains CZ boundary data.

- `./output/lad20x_CZ.png` contains a map of LAD20X and CZ.  

## Method

- In harmonising commuting flows across Census years, the script `prep_commdat.R` converts the data to the harmonised local authority district classification (LAD20X) using the correspondence table `./rawdata/lad_lad20x.csv`.

- Commuting zones are then derived by the script `get_CZ.R` in the following steps:
   1. For LAD20X pairs $rr'$ and Census years $t$, compute the Tolbert-Sizer commuting dissimilarity measure:
     
  
       $$D_{rr't}=\frac{Commuters_{rr't} + Commuters_{r'rt}}{min(ResidentWorkers_{rt},ResidentWorkers_{r't})}$$

  
   2. Compute the mean commuting dissimilarity across Census years $D_{rr'}$.
  
   3. Cluster the LAD20X using agglomerative hierarchical clustering with average linkage, based on $D_{rr'}$.
  
      > **Note:** *This approach is identical to that of Tolbert and Sizer (1996) with the exception that commuting dissimilarity is averaged across years instead of being taken for a single year.*

## Input data

- `./rawdata/lad_lad20x.csv` is the correspondence table matching local authority district (LAD) codes that were live between 2001 and 2020 to a harmonised local authority district (LAD20X) equivalent or parent. The code and data used to produce this table are available in the  [Harmonised-Local-Authorities-EW](https://github.com/amastrosavvas/Harmonised-Local-Authorities-EW) repository.

- `./rawdata/geometries/lad20x.shp` contains LAD20X boundary data.

- `./rawdata/commuting` contains files downloaded from the the [UK Data Service WICID database](https://wicid.ukdataservice.ac.uk):

  - `./rawdata/commuting/UK DATA SERVICE - 1991 commuting flows by IDT01 (Set SWS C).csv` holds the directed commuting flow matrix from the 1991 UK Census by 2001 Interaction Data District pair.
  
  - `./rawdata/commuting/UK DATA SERVICE - 2001 commuting flows by IDT01 (Set SWS 1).csv` holds the directed commuting flow matrix from the 2001 UK Census by 2001 Interaction Data District pair.
  
  - `./rawdata/commuting/UK DATA SERVICE - 2011 commuting flows by CMLAD11 (Table WU02UK).csv` holds the directed commuting flow matrix from the 2011 UK Census by Census Merged LAD pair. 
  
## References

- Tolbert, C.M. and Sizer, M., 1996. _US commuting zones and labor market areas: A 1990 update_ (No. 1486-2018-6805). [[link]](https://ageconsearch.umn.edu/record/278812/)  

## Attribution statements
- Contains public sector information licensed under the Open Government Licence v3.0.
- Contains Ordnance Survey (OS) data © Crown copyright and database right 2022.


</p>
