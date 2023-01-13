# LOAD PACKAGES  ---------------------------------------------------------------

packages <-
  c(
    "dplyr",
    "reshape2",
    "forcats",
    "ggplot2",
    "sf"
  )

for (p in packages){ 
  if (! (p %in% installed.packages())){
    install.packages(p)
  }
}

library(dplyr)         
library(ggplot2)

# DERIVE COMMUTING ZONES -------------------------------------------------------

commdat <- readRDS(file = "./output/commdat.RDS")

commdat[["resworkers annual by LAD20X"]] <- 
  commdat[["undir annual by LAD20X"]] %>%
  filter(LAD20XCD_O == LAD20XCD_D) %>%
  select(Year, LAD20XCD_O, LAD20XNM_O, commuters) %>%
  rename(
    "LAD20XCD" = "LAD20XCD_O",
    "LAD20XNM" = "LAD20XNM_O",
    "resworkers" = "commuters"
  )

commdat[["minresworkers annual by LAD20X"]] <-
  commdat[["undir annual by LAD20X"]] %>%
  left_join(
    commdat[["resworkers annual by LAD20X"]],
    by = c("Year" = "Year", "LAD20XCD_O" = "LAD20XCD", "LAD20XNM_O" = "LAD20XNM")
  ) %>%
  left_join(
    commdat[["resworkers annual by LAD20X"]],
    by = c("Year" = "Year", "LAD20XCD_D" = "LAD20XCD", "LAD20XNM_D" = "LAD20XNM")
  ) %>%
  rowwise() %>%
  mutate(minresworkers = min(resworkers.x, resworkers.y)) %>%
  select(-resworkers.x, -resworkers.y)

commdat[["T-S annual by LAD20X"]] <-
  commdat[["minresworkers annual by LAD20X"]] %>%
  mutate(
    similarity = commuters/minresworkers,
    similarity_adj = case_when(
      similarity > 1 ~ 1,
      TRUE ~ similarity
    ),
    dissimilarity = 1 - similarity_adj
  )

commdat[["T-S average by LAD20X"]] <-
  commdat[["T-S annual by LAD20X"]] %>%
  group_by(LAD20XCD_O, LAD20XNM_O, LAD20XCD_D, LAD20XNM_D) %>%
  summarise(
    dissimilarity_avg = mean(dissimilarity)
  ) %>%
  ungroup()

diss_mx <- reshape2::acast(commdat[["T-S average by LAD20X"]], LAD20XCD_O ~ LAD20XCD_D, value.var = "dissimilarity_avg")
hclust_avg <- hclust(as.dist(diss_mx), method = "average")
cut_avg_98 <- cutree(hclust_avg, h = 0.98)

commdat[["T-S clusters by LAD20X"]] <-
  data.frame(
    LAD20XCD = names(cut_avg_98),
    CZ = as.vector(cut_avg_98)
    )



# Zone reordering by commuters accross years

commuters <-
  commdat[["undir annual by LAD20X"]] %>%
  group_by(LAD20XCD_O, LAD20XNM_O) %>%
  summarise(commuters = sum(commuters)) %>%
  ungroup() %>%
  rename(LAD20XCD = LAD20XCD_O) %>%
  select(-LAD20XNM_O) %>%
  left_join(commdat[["T-S clusters by LAD20X"]]) %>%
  group_by(CZ) %>%
  summarise(commuters = sum(commuters)) %>%
  ungroup() %>%
  arrange(desc(commuters)) %>%
  mutate(CZ_ord = 1:n()) %>%
  select(-commuters)

commdat[["T-S clusters by LAD20X"]] <-
  commdat[["T-S clusters by LAD20X"]] %>%
  left_join(commuters, by = "CZ") %>%
  select(-CZ) %>%
  rename(CZ = CZ_ord)

# Prepare geometries
lad20x_sf <- sf::st_read("./rawdata/geometries/lad20x.shp")

lad20x_sf <-
  lad20x_sf %>%
  left_join(
    commdat[["T-S clusters by LAD20X"]]
  )

lad20x_outline_sf <-
  lad20x_sf %>%
  summarise(geometry = sf::st_union(geometry))

cz_sf <-
  lad20x_sf %>%
  group_by(CZ) %>%
  summarise(geometry = sf::st_union(geometry)) %>%
  ungroup()


ggplot() +
  geom_sf(
    data = lad20x_sf,
    color = "white",
    size =.2
  ) +
  theme_void() +
  geom_sf(
    data= cz_sf,
    color="#800000",
    alpha = 0,
    size=.18
  ) +
  geom_sf(
    data= lad20x_outline_sf,
    color="lightgray",
    alpha = 0,
    size=.18
  ) +
  geom_sf_text(
    data = cz_sf, 
    aes(label=CZ),
    color="#800000", 
    size=2,
    fontface = "bold",
    family="sans"
  ) 
ggsave(filename = "./output/lad20x_cz.png", height=8, width=4.5, device='png', dpi=700)
  
# SAVE OUTPUT & CLEAN UP ENVIRONMENT -------------------------------------------

saveRDS(commdat, file="./output/commdat.RDS")
write.csv(commdat[["T-S clusters by LAD20X"]], file = "./output/lad20x_cz.csv", row.names = F)
sf::write_sf(cz_sf, dsn="./output/geometries/lad20x_cz.shp")

rm(list = ls()) 
gc()