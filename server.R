#### LIBRAIRIES
library(shiny)
library(bs4Dash)
library(tidyverse)
library(DT)
library(chartjs)

## on recupere les donnees stockees au prealable
load("www/donnees_criminalite.RData")




shinyServer(function(input, output) {
  
  ## table des donnees
  output$DTtable <- DT::renderDataTable(
    server = FALSE,
    datatable( data = delits_fr_2016_final,
               style = "bootstrap4",
               callback=JS('$("button.buttons-copy").css("background","#00c0ef"); 
                    $("button.buttons-csv").css("background","#00c0ef");
                    return table;'),
               extensions = 'Buttons',
               options = list( 
                 dom = "Blfrtip",
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
  
  ## 
  
})