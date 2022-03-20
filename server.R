#### LIBRAIRIES
library(shiny)
library(bs4Dash)
library(tidyverse)
library(leaflet)
library(RColorBrewer)
library(udunits2)
library(sf)
library(sp)
library(foreign)
library(raster)
library(rAmCharts)
library(ggcorrplot)
library(plotly)

## on recupere les donnees stockees au prealable
load("www/donnees_criminalite.RData")
load("www/objet_polygon.RData")
# objet obtenu avec : 
# FranceFormes <- getData(name="GADM", country="FRA", level=2)
# objet = st_as_sf(FranceFormes)
# save(objet, file="www/objet_polygon.RData")


shinyServer(function(input, output) {
  
  ### table des donnees sur la page "Donnees"
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
  
  ### cartographie
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
                  popup=~paste(NAME_2, br(),
                               "Population : ", as.character(Population), br(),
                               "Nombre de délits pour 100 000 habitants : ",as.character(round(Nb_delits_100000hab,2)),
                               sep=""),
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
              main = paste("Boxplot du nombre de délits pour 100 000 habitants \n", 
                           "en France en 2016 (table ",data(), ")"),
              xlab = data(),
              ylab = "Nombre pour 100 000 habitants",
              col = "#6faf5f"
              )
  })
  
  # ### comparaison des departements
  # ## on recupere les donnees
  # bdd <- reactive({
  #   input$which_bdd
  # })
  # 
  # ## on recupere le numero des departements
  # dpt <- reactive({
  #   pull(bdd()$Departement)
  # })
  # 
  # observe({
  #   updateSelectInput(session = getDefaultReactiveDomain(), inputId = "which_dep1", 
  #                     choices = dpt ) 
  # })
  # 
  # ## boxplot1
  # bdd.react <- eventReactive({
  #     get(bdd()) %>% filter(Departement = input$which_dep1)
  #   })
  # 
  # # on genere le boxplot1
  # output$boxplot_box1 <- renderAmCharts({
  #   amBoxplot(object = get(bdd())[input$which_dep1,]$Nb_delits_100000hab, 
  #             main = paste("Boxplot du nombre de délits pour 100 000 habitants \n", "(table ",bdd(), ")"),
  #             xlab = bdd(),
  #             ylab = "Nombre pour 100 000 habitants",
  #             col = "#6faf5f"
  #   )
  # })
  # 
  # 
  # ## boxplot2
  # bdd.react <- eventReactive(
  #   input$button_boxp, {
  #     get(bdd())[,input$which_dep2]
  #   })
  # # on genere le boxplot2
  # output$boxplot_box2 <- renderAmCharts({
  #   amBoxplot(object = get(bdd())[input$which_dep2,]$Nb_delits_100000hab, 
  #             main = paste("Boxplot du nombre de cambriolages pour 100 000 habitants \n", "(table ",bdd(), ")"),
  #             xlab = bdd(),
  #             ylab = "Nombre pour 100 000 habitants",
  #             col = "#6faf5f"
  #   )
  # })
  # 
  ### regression 
  # on recupere le choix de table de l'utilisateur 
  tab <- reactive({
    input$which_tab_reg
  })
  # on genere les donnees issues du choix de la table et des variables de l'utilisateur
  data.react <- eventReactive(
    input$button_reg, {
      get(tab())[,input$which_var_reg]
  })
  # pop-up affichant un avertissement au regard des resultats de la regression
  observeEvent(input$button_reg, {
    showModal(modalDialog(
      align = "justify",
      title = tagList(icon("exclamation-triangle")," Attention"),
      style = "color : red;",
      "Nous avons appliqué une régression linéaire avec le modèle que vous avez choisit.
      Cependant, nous n'avons pas vérifié s'il est bien spécifié (test de Ramsey), 
      s'il n'y a pas de problème d'autocorrélation (test de Durbin-Watson) et 
      d'hétéroscédasticité (test de White). 
      Ainsi, les résultats concernant la régression linéaire avec le modèle que vous avez choisis
      sont les résultats sans correction s'il était nécéssaire.", br(),
      easyClose = TRUE,
      footer = "Nous vous invitons à être prudent à l'égard des résultats obtenus."
    ))
  })
  
  ## resultats de la regression
  lm_reg <-  function(data){
    lm_criminalite <- lm(Nb_delits_100000hab~., data=data)
    summary <- summary(lm_criminalite)
    summary
  }
  # summary du modele lm genere
  output$res_reg <- renderPrint({
    lm_reg(data.react())
  })
  # r2 ajuste
  output$r2 <- renderPrint({
    lm_reg(data.react())$adj.r.squared
  })
  # r2 en pourcentage
  output$r2x100 <- renderPrint({
    (lm_reg(data.react())$adj.r.squared)*100
  })
  # Y var expliquee
  output$y <- renderPrint({
    lm_reg(data.react())$terms[[2]]
  })
  # X var explicatives
  output$x <- renderPrint({
    lm_reg(data.react())$terms[[3]]
  })
  # statistique de fisher
  output$fstat <- renderPrint({
    lm_reg(data.react())$fstatistic[[1]]
  })
  # p-valeur associe a la statistique de fisher
  output$pval_fisher <- renderPrint({
    summary <- lm_reg(data.react())
    pf(summary$fstatistic[1],summary$fstatistic[2],summary$fstatistic[3],lower.tail=FALSE)[[1]]
  })
  # nom de la variable du premier coefficient
  output$var_coef <- renderPrint({
    rownames(lm_reg(data.react())$coefficients)[2]
  })
  # coefficient associe a la premiere variable
  output$coef <- renderPrint({
    lm_reg(data.react())$coefficients[2,1]
  })
  # p-value du test de nullite sur le coefficient associe a la premiere variable
  output$pval_coef <- renderPrint({
    lm_reg(data.react())$coefficients[2,4]
  })
  
  ## corrplot et scatterplot 
  # la heatmap
  output$corr <- renderPlotly({
    matcorr <- data.react()
    # matrice de correlation
    mcor <- cor(matcorr) 
    # pour ne garder que le triangle superieur de la matrice (car symetrique)
    mcor[upper.tri(mcor)] <- NA
    # la heatmap
    plot_ly(source = "heat_plot") %>% 
      add_heatmap(
        x = colnames(matcorr), 
        y = colnames(matcorr), 
        z = mcor
      )
  })
  # le scatterplot en fonction du clique sur la heatmap    
  output$scatterplot <- renderPlotly({
    # si on ne clique par sur la heatmap, renvoie rien
    clickData <- event_data("plotly_click", source = "heat_plot")
    if (is.null(clickData)) return(NULL)
    
    # droite de regression avec les variables x/y cliquees sur la heatmap
    vars <- c(clickData[["x"]], clickData[["y"]])
    d <- setNames(data.react()[vars], c("x", "y"))
    yhat <- fitted(lm(y ~ x, data = d))
    
    # nuage de points avec ligne d'ajustement (modele lineaire)
    plot_ly(d, x = ~x) %>%
      add_markers(y = ~y) %>%
      add_lines(y = ~yhat) %>%
      layout(
        title = paste("Nuage de points entre",clickData[["x"]],"et",clickData[["y"]]) ,
        xaxis = list(title = clickData[["x"]]), 
        yaxis = list(title = clickData[["y"]]), 
        showlegend = FALSE
      )
  })
})