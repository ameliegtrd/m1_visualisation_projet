#### LIBRAIRIES
library(shiny)
library(bs4Dash)
library(tidyverse)
library(DT)
library(chartjs)
library(leaflet)
library(RColorBrewer)
library(rAmCharts)

# code dans le fichier "traitements_donnees" pour sauvegarder les donnees traitees et pouvoir les utiliser directement dans shiny
# save(delits_fr_2016_final,homicide_final,cambriolage_final, file="www/donnees_criminalite.RData")


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
       L’objectif de cette application est de présenter à l‘utilisateur une interface qui lui permet d’identifier et d’analyser le taux de criminalité en France métropolitaine en 2016. 
        ", br(), 
    "
       L'utilisateur aura le choix de prendre une base parmi les quatre proposées ci-dessous :
        ", br(), br(),
    column(width=6,
    box(title ="Base totale",
        status="primary",
        solidHeader = TRUE,
        align="left",
        "Cette base comprend tous les déterminants de tous les délits recensés en France métropolitaine en 2016. 
        "), 
    box(title ="Criminalité",
        status="primary",
        solidHeader = TRUE,
        align="left",
        "Cette base se concentre sur les déterminants de tous les délits recensés en France métropolitaine en 2016. 
       Ici, nous avons conservé 8 variables expliquant la criminalité par département (cf le dictionnaire de données dans le Rapport).
        ")),  
    column(width=6,
    box(title ="Cambriolage",
        status="primary",
        solidHeader = TRUE,
        align="left",
      "Les données relatives aux cambriolages désignent la violation de lieu privé, l'entrée dans un lieu sans autorisation, généralement par effraction, dans l'intention d'y commettre un vol.
       Cet indicateur additionne les cambriolages de résidences principales et les cambriolages de résidences secondaires car ces deux types d’infractions relèvent des mêmes modes opératoires.
       Les infractions de tentatives de cambriolages sont également enregistrées dans cet indicateur.
        "), 
    box(title ="Homicide",
        status="primary",
        solidHeader = TRUE,
        align="left", 
      "Cette base regroupe les 4 catégories de crimes suivantes :",
    br(), "- les règlements de comptes entre malfaiteurs",
    br(), "- les homicides pour voler et à l’occasion de vols",
    br(), "- les homicides pour d’autres motifs",
    br(), "- les coups et blessures volontaires suivis de mort",
    br(), "Même si les coups et blessures volontaires suivis de mort ne sont pas des homicides au sens juridique, nous avons décidé de les intégrer dans cet indicateur.
       Un homicide est l'action de tuer un autre être humain, qu’elle soit volontaire ou non.
        "))
  ),
    box(
        title ="Nos données", 
        status = "purple", 
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
                    selected = "Tout"
        ),
        DT::dataTableOutput("DTtable")
    )
)


## page cartographie
bcarte <- fluidPage(
    tags$head(
        # pour avoir la map en full screen
        tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}")
    ),
    # on affiche la map
    leafletOutput("map"),
    # panneau de controle sur la map et deplacable (option draggable=TRUE)
    absolutePanel(
      top = 70, left = "auto", right = 30, bottom = "auto",
      height = "auto", width = "40vw", draggable = TRUE,
      wellPanel(
        selectInput("which_map",
                    "Sélectionne les données que tu souhaites représenter", 
                    choices = c("Criminalité" = "criminalite",
                                "Cambriolage" = "criminalite_cambriolage",
                                "Homicide" = "criminalite_homicide"),
                    selected = "Criminalité"
        ),
        amChartsOutput(outputId = "graph_map")
      ),
      # on met le panneau de controle devant la map (z-index), 
      # on modifie la transparence puis la couleur, la forme et les espacements
      style = "background: #D9EAD5; opacity: 0.8; z-index: 10; 
               padding: 20px 20px 20px 20px; border-radius: 5pt;
               box-shadow: 0pt 0pt 6pt 0px rgba(61,59,61,0.48);
               padding-bottom: 2mm; padding-top: 1mm; margin:auto;",
    )
)
    
## page statistiques
bstats_desc <- chartjs(height = "200px") %>% 
    cjsOptions(animation = list(animateScale = TRUE, animateRotate = FALSE)) %>%
    cjsDoughnut(labels = LETTERS[1:4]) %>%
    cjsSeries(data = c(1:4))

## page regression
bregression <- fluidRow(
    column(
        width = 6,
        box(
            title = tagList(icon("tools")," Choix de la régression"), 
            width = NULL,
            status = "info", 
            solidHeader = TRUE, 
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
            title = tagList(shiny::icon("pencil-alt"), "  Interprétation des résultats"), 
            width = NULL,
            status = "purple", 
            solidHeader = TRUE, 
            collapsible = TRUE, 
            align="justify",
              "
              Nous allons interpréter la régression de la base (nom de la base choisie par l'utilisateur). 
              ", br(),
              "
              La qualité d’ajustement du modèle R2 vaut (Ajusted R-squared). 
              C’est-à-dire que (Ajusted R-squared*100)% de la variance du nombre (nom de la base) pour 100 000 habitants est expliquée par le modèle donc par les variables suivantes : (le nom des x variables explicatives). 
              ", br(),
              "
              Le test de Fisher teste la qualité globale du modèle. 
              L’hypothèse nulle H0 teste la nullité de tous les coefficients, sauf la constante, contre l’hypothèse alternative H1 au moins un des coefficients est non nul. 
              Ici, la statistique du test vaut (F-statistic) et la p-value est égale à (p-value) donc (inférieure/supérieure) à 0.05 alors (on rejette/on ne rejette pas) H0 au seuil de 5%. 
              Le modèle est globalement satisfaisant puisqu’il est mieux avec les variables, que sans (inverse si on ne rejette pas).
              ", br(),
              "
              Au seuil de significativité de (en fonction du nb d’asterisque)%, lorsque le (nom de la variable) augmente d’une unité alors le nombre de (nom de la base) pour 100 000 habitants(arrondi de Estimate) unités. 
              "
        )
    ),
    column(
        width = 6,
        tabBox(
            title = tagList(shiny::icon("calculator"), "  Résultats"), 
            width = NULL,
            status = "purple", 
            # solidHeader = TRUE, 
            collapsible = TRUE, 
            # align="justify",
            id = "tabset1" ,
            side = "right",
            tabPanel("Summary",
              "Bla bla"
            ),
            tabPanel("Plots",
              "Blabla"
            )
        )
    )
)

## page sources
bsources <- lapply(getAdminLTEColors(), function(color) {
    box(status = color)
})

### UI
ui <- dashboardPage(
    options = list(sidebarExpandOnHover = FALSE),
    
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
                "Régression", tabName = "regression", icon = icon("fas fa-chart-line", lib="font-awesome")
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
