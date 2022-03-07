#### LIBRAIRIES
library(shiny)
library(bs4Dash)


### CONTENU DES PAGES
baccueil <- chartjs(height = "200px") %>% 
    cjsOptions(animation = list(animateScale = TRUE, animateRotate = FALSE)) %>%
    cjsDoughnut(cutout = 50, labels = LETTERS[1:4]) %>%
    cjsSeries(data = c(1:4))

bstats_desc <- lapply(1:20, box, width = 12, title = "box")

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