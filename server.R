"linMap" <- function(x, from, to){
  (x - min(x)) / max(x - min(x)) * (to - from) + from
}


library(shiny)
library(DT)
load("data/modules_explorer_data.Rdata")


function(input, output, session) {
  getPage<-function(x) {
    HTML(x)
  }
  
  #### reactive varia
  update.rv <- reactiveValues(a=TRUE)
  Current.Module.rv <- reactiveValues(a=NULL)
  table1.names.rv <- reactiveValues(a=NULL)
  
  # loading data I need
  ## creating the weights vector from the inputs
  weights<-reactive({c(input$W1, input$W2, input$W3, input$W4, input$W5, input$W6, input$W7, input$W8, input$W9,
                       input$W10, input$W11, input$W12, input$W13, input$W14, input$W15, input$W16)})
  
  
  #### everything inside here gets updated when I press the button compute
  observeEvent(input$do,{
    update.rv$a <- TRUE
  })
  
  observeEvent(update.rv$a,{
    ### computing the MIB score and scaling it in order to be from 0 to 100
    MIB.score <- linMap(apply(Ranks.Used.Metrics.shiny,1,weighted.mean, w=weights()),0,100)
    ind.order <- order(MIB.score, decreasing = TRUE)
    MIB.score <- MIB.score[ind.order]
    Metrics.Modules.shiny <- Metrics.Modules.shiny[ind.order,]
    Ranks.Used.Metrics.shiny <- Ranks.Used.Metrics.shiny[ind.order,]
    ind.kept <- which(Metrics.Modules.shiny[, "N clusters MiBiG in"] >= input$MIBIG)
    Metrics.Modules.shiny[,1] <- MIB.score
    Metrics.Modules.shiny <- as.data.frame(Metrics.Modules.shiny)
    Metrics.Modules.shiny[,"MIB score"] <- MIB.score 
    
    
    ### I have to change this to stop seeing the warning.
    output$mytable1 <- renderDT(datatable(Metrics.Modules.shiny[ind.kept,input$show_vars],
                                            rownames=TRUE, options = list(
                                              pageLength=20,
                                              lengthMenu=c(20,100,200,500)
                                            ), selection ="single") %>%
                                    formatRound(c("MIB score" , "Shannon's Entropy", "max.pval" ),2),
                                  server = TRUE, selection ="single")
  
      
    table1.names.rv$a <- rownames(Metrics.Modules.shiny[ind.kept,])
    update.rv$a <- FALSE
  }) 
  
  
  observeEvent(input$mytable1_rows_selected,{
    selected_module <- table1.names.rv$a[input$mytable1_rows_selected[1]]
    url.tmp <- unlist(strsplit(selected_module, split="_"))[2]
    url.tmp <- paste("module", url.tmp,".xhtml", sep="")
    url <- a("Explore selected module", href=url.tmp, target="_blank")
    output$tab <- renderUI({tagList(selected_module, url)})
    
    ind <- which(rownames(Modules.composition.shiny)==selected_module)
    mod.comp <- Modules.composition.shiny[ind,]
    mod.comp <- mod.comp[!is.na(mod.comp)]
    ind <- which(rownames(smCOGs.description)%in%mod.comp)
    tmp <- t(smCOGs.description[ind,])
    tmp2 <- apply(tmp,1,function(x){all(is.na(x))})
    tmp <- tmp[which(!tmp2),]
    output$mytable2 <- renderDT(datatable(tmp, rownames = FALSE))
    
  })
  

  
}

