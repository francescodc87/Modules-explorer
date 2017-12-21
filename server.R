"linMap" <- function(x, from, to){
  (x - min(x)) / max(x - min(x)) * (to - from) + from
}


library(shiny)
library(DT)



function(input, output, session) {
  
  # loading data I need
  load("data/modules_explorer_data.Rdata")
  ## creating the weights vector from the inputs
  weights<-reactive({c(input$W1, input$W2, input$W3, input$W4, input$W5, input$W6, input$W7, input$W8, input$W9,
                       input$W10, input$W11, input$W12, input$W13, input$W14, input$W15, input$W16)})
  
  
  ### computing the MIB score and scaling it in order to be from 0 to 100
  MIB.score <- reactive({
    linMap(apply(Ranks.Used.Metrics.shiny,1,weighted.mean, w=weights()),0,100)})
  
  Current.Module.rv <- reactiveValues(a=NULL)
  selected.module.rv <- reactiveValues(a = NULL)
  update.rv <- reactiveValues(a=TRUE)
  table1.names.rv <- reactiveValues(a=NULL)
  table2.names.rv <- reactiveValues(a=NULL)
  table3.names.rv <- reactiveValues(a=NULL)
  new.sel.rv <- reactiveValues(a=NULL)
  modules.plus1.rv <- reactiveValues(a=NULL)
  modules.minus1.rv <- reactiveValues(a=NULL)
  modules.swap1.rv <- reactiveValues(a=NULL)
  Current.mod.comp.rv <- reactiveValues(a=NULL)
  
  #### everything inside here gets updated when I press the button compute
  observeEvent(input$do,{
    update.rv$a <- TRUE
  })
  
  observeEvent(update.rv$a,{
    MIB.score.observer <- MIB.score()
    ind.order <- order(MIB.score.observer, decreasing = TRUE)
    MIB.score.observer <- MIB.score.observer[ind.order]
    Metrics.Modules.shiny <- Metrics.Modules.shiny[ind.order,]
    Modules.composition.shiny <- Modules.composition.shiny[ind.order,]
    Ranks.shiny <- Ranks.shiny[ind.order,]
    Ranks.Used.Metrics.shiny <- Ranks.Used.Metrics.shiny[ind.order,]
    Used.Metrics.shiny <- Used.Metrics.shiny[ind.order,]
    
    
    ind.kept <- which(Metrics.Modules.shiny[, "N clusters MiBiG in"] >= input$MIBIG)
    
    isolate({
      Metrics.Modules.shiny[,1] <- MIB.score.observer
      output$mytable1 <- renderDataTable(datatable(Metrics.Modules.shiny[ind.kept,input$show_vars],
                                                   rownames=TRUE, options = list(
                                                     pageLength=20,
                                                     lengthMenu=c(20,100,200,500)
                                                   ), selection ="single") %>%
                                           formatRound(c("MIB score" , "Shannon's Entropy", "max.pval" ),2),
                                         server = TRUE, selection ="single")
    })
    
    
    #### selecting the top 20 according what we decided
    ordered.modules <-rownames(Metrics.Modules.shiny)[ind.kept]
    ordered.modules <- ordered.modules[order(MIB.score.observer[ind.kept], decreasing = T)]
    
    i <- 1
    k <- 1
    
    Modules.temp <- Modules.composition.shiny[ind.kept,]
    Selected <- NULL
    Used <- Selected
    while(length(Selected)<20 & i<=length(ordered.modules)){
      tmp.name <- ordered.modules[i]
      if(!tmp.name%in%Used & !tmp.name%in%Selected){
        Selected <- c(Selected, tmp.name)
        ind <- which(rownames(Modules.temp)==tmp.name)
        tmp.module <- Modules.temp[ind,]
        ind.NA <-which(!is.na(tmp.module))
        tmp.module <- tmp.module[ind.NA]
        for(x in 1:nrow(Modules.temp)){
          tmp.module2 <- Modules.temp[x,]
          tmp.module2 <- tmp.module2[which(!is.na(tmp.module2))]
          val1 <- length(union(tmp.module,tmp.module2))-length(tmp.module)
          val2 <- length(union(tmp.module,tmp.module2))-length(tmp.module2)
          if((val1==0 & val2==1) | (val1==1 & val2==1) | (val1==1 & val2==0)) {# plus one
            Used <- c(Used,rownames(Modules.temp)[x])
          }

        }
      }
      i <- i+1
    }
    
    ind.top.20 <- which(rownames(Metrics.Modules.shiny)%in%Selected)
    top.20.metrics <- Metrics.Modules.shiny[ind.top.20,]
    top.20.metrics <- top.20.metrics[order(top.20.metrics[,1], decreasing = T),]
    
    
    
    # sorted columns are colored now because CSS are attached to them
    output$mytable2 <-  renderDataTable(datatable(top.20.metrics[,input$show_vars],
                                                  rownames=TRUE, options = list(
                                                    pageLength=20,
                                                    lengthMenu=c(5,10,20)
                                                  ), selection ="single") %>%
                                          formatRound(c("MIB score" , "Shannon's Entropy", "max.pval"),2), server = TRUE)
    

    
    table1.names.rv$a <- rownames(Metrics.Modules.shiny[ind.kept,])
    table2.names.rv$a <- rownames(top.20.metrics)
    
    update.rv$a <- FALSE
    
  }) # creating outputs for the first page... (Summary Tables in MIB score).
                                  #the top 20 thing is not working properly
  

  
  
  
  
  
  observeEvent(input$select,{
    selected.module.rv$a <- c(table1.names.rv$a[input$mytable1_rows_selected],
                              table2.names.rv$a[input$mytable2_rows_selected],
                              table3.names.rv$a[input$mytable3_rows_selected])
    
    Current.Module.rv$a <- selected.module.rv$a[1]
  }) # if you press select Current.Module.rv$a is the module selected in the first page. In case of multiple selecions
                                   #
  
  
  
  
  
  observe({
    Current.Module <- table1.names.rv$a[input$mytable1_rows_selected]
    ind.mod.com <- which(rownames(Modules.composition.shiny)==Current.Module)
    min.MIBIG <- input$MIBIG
    
    Current.mod.comp <- Modules.composition.shiny[ind.mod.com, which(!is.na(Modules.composition.shiny[ind.mod.com,]))]
    ind.hit <- NULL
    if(length(Current.mod.comp)>1){
        ind.hit <- unique(which(Clusters.complete==Current.mod.comp[1], arr.ind = TRUE)[,2])
        for(k in 2:length(Current.mod.comp)){
          ind.hit2 <- unique(which(Clusters.complete==Current.mod.comp[k], arr.ind = TRUE)[,2])  
          ind.hit <- intersect(ind.hit, ind.hit2)
        }  
      }
    Clusters.complete <- Clusters.complete[c(1:2,4:nrow(Clusters.complete)),] ## comment this if you want to show the organism
    clusters.hitted <-NULL
      if(length(ind.hit)>0){
         clusters.hitted <- Clusters.complete[,ind.hit]
         clusters.hitted <- clusters.hitted[,order(clusters.hitted[3,], na.last = TRUE)]
       }
       levels.1 <-unique(as.vector(clusters.hitted))
       values.1 <- rep("rgb(255,255,255)", length(levels.1))
       values.1[which(levels.1%in%Current.mod.comp)] <- "rgb(173,255,47)"
       
       clusters.hitted <- as.data.frame(clusters.hitted)
       
       
       output$clust.hitted <- renderDataTable(datatable(clusters.hitted, rownames =FALSE,
                                                  options=list(paging=FALSE,
                                                                 searching=FALSE,
                                                                 bSort=FALSE)) %>%
                                                formatStyle(names(clusters.hitted),
                                                            backgroundColor=styleEqual(levels.1, values.1)))
       
  })## creating outputs in third page (CLUSTERS)
  
  
  
  
  
  
  
  # 
  
  
  
  
  
  
}

