#### LIBRAIRIES
library(shiny)
library(bs4Dash)
library(tidyverse)
library(DT)
library(chartjs)

# code dans le fichier Rmd du projet econometrie pour sauvegarder les donnees traitees et pouvoir les utiliser directement dans shiny
# setwd("C:/Users/Amélie/Documents/TRAVAIL/M1 MAS/VISUALISATION DES DONNEES/R/Projet_Shiny/criminalite/www")
# save(delits_fr_2016_final,homicide_final,cambriolage_final, file="donnees_criminalite.RData")


### CONTENU DES PAGES
## page d'accueil
baccueil <- fluidPage(
    box(
        title ="Présentation des données", 
        status = "info", 
        solidHeader = TRUE, 
        width = 12,
        collapsible = TRUE, 
        align="justify",
        "
        Primi igitur omnium statuuntur Epigonus et Eusebius ob nominum gentilitatem oppressi. 
        praediximus enim Montium sub ipso vivendi termino his vocabulis appellatos fabricarum culpasse 
        tribunos ut adminicula futurae molitioni pollicitos.
        Haec igitur prima lex amicitiae sanciatur, ut ab amicis honesta petamus, 
        amicorum causa honesta faciamus, ne exspectemus quidem, dum rogemur; studium semper adsit, 
        cunctatio absit; consilium vero dare audeamus libere. Plurimum in amicitia amicorum bene suadentium
        valeat auctoritas, eaque et adhibeatur ad monendum non modo aperte sed etiam acriter, 
        si res postulabit, et adhibitae pareatur.
        Illud tamen te esse admonitum volo, primum ut qualis es talem te esse omnes existiment ut, 
        quantum a rerum turpitudine abes, tantum te a verborum libertate seiungas; 
        deinde ut ea in alterum ne dicas, quae cum tibi falso responsa sint, erubescas. 
        Quis est enim, cui via ista non pateat, qui isti aetati atque etiam isti dignitati non possit 
        quam velit petulanter, etiamsi sine ulla suspicione, at non sine argumento male dicere? 
        Sed istarum partium culpa est eorum, qui te agere voluerunt; laus pudoris tui, 
        quod ea te invitum dicere videbamus, ingenii, quod ornate politeque dixisti.
        "
    ),
    box(
        title ="Nos données", 
        status = "info", 
        solidHeader = TRUE, 
        width = 12,
        collapsible = TRUE, 
        align="justify",
        selectInput("which_data", 
                    "Sélectionne la table que tu souhaites voir", 
                    choices = c("Tout" = "delits_fr_2016_final",
                                "Criminalité" = "criminalite",
                                "Cambriolage" = "criminalite_cambriolage",
                                "Homicide" = "criminalite_homicide"),
                    selected = "data 1"
        ),
        DT::dataTableOutput("DTtable")
    )
)
    
    
## page cartographie
bcarte <- chartjs(height = "200px") %>% 
    cjsOptions(animation = list(animateScale = TRUE, animateRotate = FALSE)) %>%
    cjsDoughnut(labels = LETTERS[1:4]) %>%
    cjsSeries(data = c(1:4))
    
## page statistiques
bstats_desc <- chartjs(height = "200px") %>% 
    cjsOptions(animation = list(animateScale = TRUE, animateRotate = FALSE)) %>%
    cjsDoughnut(labels = LETTERS[1:4]) %>%
    cjsSeries(data = c(1:4))

## page regression
bregression <- lapply(getAdminLTEColors(), function(color) {
    box(status = color)
})

## page sources
bsources <- lapply(getAdminLTEColors(), function(color) {
    box(status = color)
})


### UI
ui <- dashboardPage(
    #options = list(sidebarExpandOnHover = FALSE),
    
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
                "Statistiques", icon = icon("chart-pie", lib = "font-awesome"),
                menuSubItem(" Carte", tabName = "carte", icon = icon("map-marked-alt", lib="font-awesome")),
                menuSubItem(" Statistiques", tabName = "stats_desc")
            ),
            menuItem(
                "Régression", tabName = "regression", icon = icon("line-chart", lib="font-awesome")
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
            
            # page carte
            tabItem(tabName = "carte", bcarte
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
        collapsed = TRUE,
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