#### LIBRAIRIES
library(shiny)
library(bs4Dash)
library(tidyverse)
library(DT)

# code dans le fichier Rmd du projet econometrie pour sauvegarder les donnees traitees et pouvoir les utiliser directement dans shiny
# setwd("C:/Users/Amélie/Documents/TRAVAIL/M1 MAS/VISUALISATION DES DONNEES/R/Projet_Shiny/criminalite/www")
# save(delits_fr_2016_final,homicide_final,cambriolage_final, file="donnees_criminalite.RData")

### CONTENU DES PAGES
baccueil <- box(title ="Nos données", status = "info", solidHeader = TRUE, width = 6,
collapsible = TRUE, align="justify", DT::dataTableOutput("mytable"))


bstats_desc <- chartjs(height = "200px") %>% 
    cjsOptions(animation = list(animateScale = TRUE, animateRotate = FALSE)) %>%
    cjsDoughnut(labels = LETTERS[1:4]) %>%
    cjsSeries(data = c(1:4))
    

bregression <- lapply(1:20, box, width = 12, title = "box")

bsources <- lapply(1:20, box, width = 12, title = "box")


### PAGE
ui <- dashboardPage(
    options = list(sidebarExpandOnHover = TRUE),
    
    ## en-tete de la page
    dashboardHeader(
        title = "Criminalité",
        status = "teal"
    ),
    
    ## contenu de la barre de navigation
    dashboardSidebar(
        minified = TRUE,
        collapsed = TRUE,
        status = "teal",
        sidebarMenu(
            menuItem(
                "Données", tabName = "accueil", icon = icon("folder-open", lib="font-awesome")
            ),
            menuItem(
                "Statistiques descriptives", tabName = "stats_desc", icon = icon("chart-pie", lib = "font-awesome")
            ),
            menuItem(
                "Régression", tabName = "regression", icon = icon("chart-line", lib="font-awesome")
            ),
            menuItem(
                "Sources", tabName = "sources", icon = icon("file")
            )
        )
    ),
    
    ## contenu des pages
    dashboardBody(
        tabItems(
            # page donnees
            tabItem(tabName = "accueil", baccueil
            ),
            
            # page statistiques descriptives
            tabItem(tabName = "stats_desc", bstats_desc
            ),
            
            # page regression
            tabItem(tabName = "regression", bregression
            ),
            
            # page sources
            tabItem(tabName = "sources", bsources
            )
        )
    ),
    
    ## parametres generaux
    dashboardControlbar(
        collapsed = FALSE,
        div(class = "p-3", skinSelector()),
        pinned = FALSE
    ),
    
    ## pied de page
    dashboardFooter(
        left = "Elisa FLOCH, Amélie GOUTARD, Violette MARMION",
        right = "2022"
    ),
    
    ## titre de la page dans le navigateur
    title = "Criminalité"
)