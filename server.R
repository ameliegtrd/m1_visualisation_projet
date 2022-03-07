#### LIBRAIRIES
library(shiny)
library(bs4Dash)
library(tidyverse)
library(DT)
load("www/donnees_criminalite.RData")

shinyServer(function(input, output) {
  # table des donnees
  output$mytable = DT::renderDataTable({
    datatable(delits_fr_2016_final, 
              options=list(searching=T, pageLength=5, lengthMenu = c(5, 10, 15, 20), scrollX = T))
  })
})