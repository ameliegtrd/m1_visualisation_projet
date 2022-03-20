#### LIBRAIRIES
library(shiny)
library(bs4Dash)
library(tidyverse)
library(DT)
library(chartjs)
library(leaflet)
library(RColorBrewer)
library(udunits2)
library(sf)
library(sp)
library(foreign)
library(raster)
library(rAmCharts)

## on recupere les donnees stockees au prealable
load("www/donnees_criminalite.RData")
load("www/objet_polygon.RData")
# objet obtenu avec : 
# FranceFormes <- getData(name="GADM", country="FRA", level=2)
# objet = st_as_sf(FranceFormes)
# save(objet, file="www/objet_polygon.RData")


shinyServer(function(input, output) {
  
  ## table des donnees sur la page "Donnees"
  output$DTtable <- DT::renderDataTable(
    server = FALSE,
    datatable( data = get(input$which_data),
               style = "bootstrap4",
               # personnalisation de la couleur des boutons
               callback=JS('$("button.buttons-copy").css("background","#6f42c1"); 
                    $("button.buttons-csv").css("background","#6f42c1");
                    return table;'),
               extensions = 'Buttons',
               options = list( 
                 dom = "Blfrtip", 
                 # dom pour gerer la disposition des boutons autour de la table
                 # l pour le controle d’affichage du nombre de lignes
                 # f pour le widget de recherche / filtre des donnees
                 # r pour permet l’application des filtres, tri ... 
                 # t pour la table
                 # i pour le resume du nombre d'entrees
                 # p pour le choix du nombre de page affichee
                 autoWidth = TRUE,
                 columnDefs = list(list(width = '200px', targets = "_all")),
                 buttons = 
                   list("copy", list(
                     extend = "csv",
                     charset = "utf-8",
                     bom = TRUE,
                     text = paste(icon("download", style = "color:#292b2c;"),"Download")
                   ) ), 
                 # personnalisation du menu
                 lengthMenu = list( c(5, 10, -1) 
                                    , c(5, 10, "All") 
                 ),
                 pageLength = 10,
                 scrollX = TRUE
               ) 
  )) 
  
  ## carte pour la visualisation des donnees
  output$map <- renderLeaflet({
    
    # jointure des donnees geometriques pour les delimitations des departements avec nos donnees
    donnees_sf <- objet %>% left_join(get(input$which_map), by=c("CC_2" = "Departement"))
    
    # palette de couleur 
    pal <- colorNumeric(scales::seq_gradient_pal(low = "#e4c9cf", high = "#5b2d36",
                                                 space = "Lab"), domain = donnees_sf$Nb_delits_100000hab)
    # on genere la carte
    leaflet() %>%  
      addProviderTiles("OpenStreetMap.Mapnik") %>%
      setView(lng = 15, lat = 46.80, zoom = 5) %>% 
      addPolygons(data = donnees_sf ,color=~pal(Nb_delits_100000hab),
                  fillOpacity = 0.6, 
                  stroke = TRUE, 
                  weight=1,
                  popup=~paste(NAME_2,as.character(round(Nb_delits_100000hab,2)),sep=" : "),
                  highlightOptions = highlightOptions(color = "black", weight = 3,bringToFront = TRUE)) %>% 
      addLayersControl(options=layersControlOptions(collapsed = FALSE))
  })
  
  ## graphiques de la page carte
  # on recupere les donnees
  data <- reactive({
    input$which_map
  })
  # on genere le boxplot
  output$graph_map <- renderAmCharts({
    amBoxplot(object = get(data())$Nb_delits_100000hab, 
              main = paste("Boxplot du nombre de délits pour 100 000 habitants \n", "(table ",data(), ")"),
              xlab = data(),
              ylab = "Nombre pour 100 000 habitants",
              col = "#6faf5f"
              )
  })
  
  # if (data() == "criminalite_cambriolage" | data() == "criminalite_homicide"){
  #   output$graph_map <- renderAmCharts({
  #     # on genere le boxplot
  #     amBoxplot(object = get(data())$Nb_delits_100000hab)
  #   })
  # } else{
  #   output$graph_map <- renderAmCharts({
  #     # on genere le boxplot
  #     amBoxplot(object = get(data())$Nb_delits_100000hab)
  #   })
  # }
  # 
  
})