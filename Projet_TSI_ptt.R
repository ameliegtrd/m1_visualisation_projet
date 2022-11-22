##### Script pré-traitement des données - Projet TSI ##### 

# Chargement des packages
library(tidyverse)
library(janitor)
library(lubridate)


# Jeu de données déjà modifié par deltalite :

# Importation des données
amazon <- read.csv("data/amazon_deltalite.csv")

summary(amazon)
sum(is.na(amazon))

# Union année et moi + sélection de colonnes
amazon <- amazon %>% 
  unite(col = "YearMonth", year, month, sep = "-", remove = FALSE) %>% 
  dplyr::select(state, year, month, YearMonth, fires)

# Vérification unicité du couple
amazon %>% 
  get_dupes(state, YearMonth)

# Suppression du seul doublon restant
amazon <- amazon %>% 
  distinct(state, YearMonth, .keep_all = T)

# Regardons alors le nombre de points de mesures dont nous disposons pour chaque état :
res <- amazon %>% 
  group_by(state) %>% 
  summarise(
    n = n()
  )


# La quantité mesurée étant le nombre de feux de forêts, elle est forcément biaisée
# car elle est proportionnelle avec la taille de l'état ! Nous allons donc créer une 
# qui associe chaque état à sa taille en km2, puis faire la jointure.
superficie <- data.frame(state = unique(amazon$state),
                         area = c(152581, 27768, 142815,
                                  1570746, 564693, 
                                  148827, 5802, 46078,
                                  340087, 331983, 
                                  903358, 357125, 586528, 
                                  1247689, 56440,
                                  199315, 98312, 251529,
                                  43696, 52797,
                                  281748, 237576, 224299,
                                  95312, 248209,
                                  21910, 277621
                         ))

# Jointure
amazon <- amazon %>% left_join(superficie, by='state')

# Création de notre quantité d'intérêt, pour 100000km2
amazon <- amazon %>% 
  mutate(fires_km2 = (ceiling((fires/area) * 100000)))

summary(amazon$fires_km2)


# Ajout du climat pour chaque état
amazon_climate <- amazon %>% 
  distinct(state) %>% 
  mutate(
    climate = c(
      "Tropical humide", # ACRE
      "Semi-aride", # ALAGOAS
      "Tropical humide", # AMAPÁ
      "Equatorial", # AMAZONAS
      "Semi-aride", # BAHIA
      "Tropical de savane", # CEARÁ
      "Tropical de savane", # DISTRITO FEDERAL
      "Tropical humide", # ESPÍRITO SANTO
      "Tropical de savane", # GOIÁS
      "Tropical de savane", # MARANHÃO
      "Tropical de savane", # MATO GROSSO
      "Tropical de savane", # MATO GROSSO DO SUL
      "Tropical de savane", # MINAS GERAIS
      "Tropical humide", # PARÁ
      "Tropical de savane",  # PARAÍBA
      "Subtropical", # PARANÁ
      "Tropical de savane", # PERNAMBUCO
      "Semi-aride", # PIAUÍ
      "Equatorial", # RIO DE JANEIRO
      "Semi-aride", # RIO GRANDE DO NORTE
      "Subtropical", # RIO GRANDE DO SUL
      "Tropical de savane", # RONDÔNIA
      "Tropical de savane", # RORAIMA
      "Subtropical", # SANTA CATARINA
      "Altitude Tropicale", # SÃO PAULO
      "Semi-aride", # SERGIPE
      "Tropical de savane" #TOCANTINS
    )
  )

# amazon_climate$climate <- as.factor(amazon_climate$climate)

amazon <- left_join(amazon, amazon_climate, by="state")


# Export du jeu de données modifié
save(amazon, file="data/amazon_deltalite_mod.RData")
# write.csv(amazon, "data/amazon_deltalite_mod.csv", row.names=FALSE)
