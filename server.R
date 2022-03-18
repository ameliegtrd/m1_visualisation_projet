#### LIBRAIRIES
library(shiny)
library(bs4Dash)
library(tidyverse)
library(DT)
library(chartjs)
library(leaflet)
library(RColorBrewer)

## on recupere les donnees stockees au prealable
load("www/donnees_criminalite.RData")


shinyServer(function(input, output) {
  
  ## table de toutes les donnees sur la page acceuil
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
  
  ## carte pour visualisation des donnees
  output$map <- renderLeaflet({
    # define the leaflet map object
    leaflet() %>%  
      addProviderTiles("OpenStreetMap.Mapnik") %>%
      setView(lng = 15, lat = 46.80, zoom = 5)
  })
  
})