#### LIBRAIRIES
library(shiny)
library(bs4Dash)
library(tidyverse)
library(DT)
library(leaflet)
library(RColorBrewer)
library(rAmCharts)
library(plotly)

# code dans le fichier "traitements_donnees" pour sauvegarder les donnees traitees et pouvoir les utiliser directement dans shiny
# save(delits_fr_2016_final,homicide_final,cambriolage_final, file="www/donnees_criminalite.RData")

df_list <- list("criminalite", "criminalite_homicide", "criminalite_cambriolage")

### CONTENU DES PAGES
## page d'accueil
baccueil <- fluidRow(
    box(
        title ="Présentation des données", 
        status = "info", 
        solidHeader = TRUE, 
        width = 12,
        collapsible = TRUE, 
        align="justify",
        "
        L’objectif de cette application est de présenter à l‘utilisateur une interface qui lui permet d’identifier et d’analyser le taux de criminalité en France métropolitaine en 2016. 
        Les données sont issues de l'INSEE et on été traitées pour obtenir les bases de données qui seront utilisées dans cette application.", br(), 
        "L'utilisateur pourra choisir une base parmi les quatres proposées ci-dessous : ", br(), 
        column( width = 6,
                box(
                  width = NULL,
                  status="maroon",solidHeader = FALSE, align="justify",
                  title = "Base totale",
                  "Cette base comprend les déterminants de tous les délits recensés en France métropolitaine en 2016."
                  
                ),
                box(
                  width = NULL,
                  status="maroon",solidHeader = FALSE,align="justify",
                  title = "Homicide",
                  "Cette base regroupe les 4 catégories de crimes suivantes :",
                  br(), "- les règlements de comptes entre malfaiteurs",
                  br(), "- les homicides pour voler et à l’occasion de vols",
                  br(), "- les homicides pour d’autres motifs",
                  br(), "- les coups et blessures volontaires suivis de mort",
                  br(), "Même si les coups et blessures volontaires suivis de mort ne sont pas des homicides au sens juridique, nous avons décidé de les intégrer dans cet indicateur.
          Un homicide est l'action de tuer un autre être humain, qu’elle soit volontaire ou non."
                )
        ),
        column( width = 6,
                box(
                  width = NULL,
                  status="maroon",solidHeader = FALSE,align="justify",
                  title = "Criminalité",
                  "Cette base se concentre sur les déterminants de tous les délits recensés en France métropolitaine en 2016. 
          Ici, nous avons conservé 8 variables expliquant la criminalité par département (cf le dictionnaire de données dans le Rapport)"
                ),
                box(
                  width = NULL,
                  status="maroon",solidHeader = FALSE,align="justify",
                  title = "Cambriolage",
                  "Les données relatives aux cambriolages désignent la violation de lieu privé, l'entrée dans un lieu sans autorisation, généralement par effraction, dans l'intention d'y commettre un vol.
          Cet indicateur additionne les cambriolages de résidences principales et les cambriolages de résidences secondaires car ces deux types d’infractions relèvent des mêmes modes opératoires.
          Les infractions de tentatives de cambriolages sont également enregistrées dans cet indicateur."
                ),
                
          
        ),
        "Bla bla"
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
                                "Criminalité" = df_list[1],
                                "Cambriolage" = df_list[3],
                                "Homicide" = df_list[2]),
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
                    choices = c("Criminalité" = df_list[1],
                                "Cambriolage" = df_list[3],
                                "Homicide" = df_list[2]),
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
bstats_desc <- lapply(getAdminLTEColors(), function(color) {
  box(status = color)
})
# bstats_desc <- fluidRow(
#   box(
#     title ="Choix de la table", 
#     status = "info", 
#     solidHeader = TRUE, 
#     width = 12,
#     collapsible = TRUE, 
#     align="justify",
#     selectInput("which_bdd",
#                 "Sélectionne la table que tu souhaites voir", 
#                 choices = c("Criminalité" = "criminalite",
#                             "Cambriolage" = "criminalite_cambriolage",
#                             "Homicide" = "criminalite_homicide"),
#                 selected = "Criminalité"
#     )
#   
#   ),
#   column(
#     width = 6,
#     box(
#       title ="Département 1", 
#       status = "info", 
#       solidHeader = TRUE, 
#       width = 12,
#       collapsible = TRUE, 
#       align="justify",
#       selectizeInput("which_dep1",
#                      "Sélectionne le département", 
#                       choices = c(),
#                       selected = "1"
#       ),
#       amChartsOutput(outputId = "boxplot_box1")
#     ),
#   ),
#   column(
#     width = 6,
#     box(title ="Département 2",
#         status = "info", 
#         solidHeader = TRUE, 
#         width = 12,
#         collapsible = TRUE, 
#         align="justify",
#         selectizeInput("which_dep2",
#                        "Sélectionne le département", 
#                         choices = c("01","02","03","04","05","06","07","08","09",10:19,"2A","2B",21:95),
#                         selected =  "2"
#         ),
#         amChartsOutput(outputId = "boxplot_box2")
#     )
#   )
# )

## page regression
bregression <- fluidRow(
    # premiere colonne comportant le choix de la regression et l'interpretation des resultats
    column(
        width = 6,
        box(
            title = tagList(icon("tools")," Choix de la régression"), 
            width = NULL,
            status = "info", 
            solidHeader = TRUE, 
            collapsible = TRUE, 
            align="justify",
            selectInput("which_tab_reg",
                        "Sélectionne les données que tu souhaites utiliser ", 
                        choices = c("Criminalité" = df_list[1],
                                    "Cambriolage" = df_list[3],
                                    "Homicide" = df_list[2]),
                        selected = "Criminalité"
            ),
            selectizeInput("which_var_reg",
                        "Sélectionne les variables que tu souhaites utiliser ", 
                        choices = c("Nb_delits_100000hab","Salaire_median","Tx_pauvrete_seuil60","Taux_chomage_moyen","Part_non_diplome","Indice_gini"),
                        multiple = TRUE,
                        selected = c("Nb_delits_100000hab","Salaire_median","Tx_pauvrete_seuil60","Taux_chomage_moyen","Part_non_diplome","Indice_gini")
            ),
            actionButton("button_reg", "OK" )
        ),
        box(
          title = tagList(icon("pencil-alt"), "  Interprétation des résultats"), 
          width = NULL,
          status = "purple", 
          solidHeader = TRUE, 
          collapsible = TRUE, 
          align="justify",
          h3("Summary"),
          icon("exclamation-triangle"), "Les résultats obtenus sont ceux issus d'une régression linéaire 
          sans vérification des conditions nécessaires pour une juste interprétation des résultats.
          L'interprétation des résultats ci-dessous est surtout pour expliquer comment interpréter
          la sortie R.", br(), br(),
          "La qualité d’ajustement (R2 ajusté) du modèle vaut", textOutput("r2", inline = TRUE), ".",
          "C’est-à-dire que", textOutput("r2x100", inline = TRUE) , "% de la variance du nombre de délits pour 100 000 habitants est expliquée par le modèle
          (donc par les variables suivantes :", textOutput("x", inline = TRUE), ")", br(),
          " Le test de Fisher teste la qualité globale du modèle. L’hypothèse nulle H0 teste la nullité de tous les coefficients, sauf la constante, contre l’hypothèse alternative H1 au moins un des coefficients est non nul. 
              Ici, la statistique du test vaut", textOutput("fstat", inline = TRUE), "et la p-value est égale à", textOutput("pval_fisher", inline = TRUE),
          "donc (inférieure/supérieure) à 0.05 alors (on rejette/on ne rejette pas) H0 au seuil de 5%. 
              Le modèle est globalement satisfaisant puisqu’il est mieux avec les variables, que sans (inverse si on ne rejette pas).", br(),
          " Au seuil de significativité de (en fonction du nb d’asterisque)%, lorsque le",textOutput("var_coef", inline = TRUE), 
          "augmente d’une unité alors le nombre de délits pour 100 000 habitants(arrondi de Estimate) unités.
          ",
          h3("Plots"),
          "
          Dans cet onglet est généré la Heatmap des corrélations entre les variables du modèle.
          Lorsque l'on clique sur une des cases, un deuxième graphique apparaît en dessous.
          Il représente le nuage de points des 2 variables en question et calcule la droite de régression associée à un modèle linéaire.
          ", br(),
          icon("exclamation-triangle"), "Attention, le graphe de corrélation ne permet pas d'affirmer un lien de causalité entre les variables. Les indicateurs de corrélations aident à formaliser le modèle mais on ne peut pas parler de lien de causalité."
        )
    ),
    # deuxieme colonne resultats
    column(
        width = 6,
        tabBox(
            title = tagList(icon("calculator"), "  Résultats"), 
            width = NULL,
            status = "purple", 
            collapsible = TRUE, 
            id = "tabset1" ,
            side = "right",
            tabPanel("Summary",
              verbatimTextOutput(outputId = "res_reg")
            ),
            tabPanel("Plots",
              icon("info-circle"), 
              "Cliquez sur la heatmap pour faire apparaître le nuage de points des variables correspondantes
              avec la droite de régression (modèle linéaire).",
              plotlyOutput(outputId ="corr"), br(),
              plotlyOutput("scatterplot")
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
