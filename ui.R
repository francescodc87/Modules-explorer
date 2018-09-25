library(markdown)
# loading data I need
#load("data/modules_explorer_data.Rdata")
nomi <- c("MIB score","Shannon's Entropy","Module length","N clusters in",
          "N clusters MiBiG in","max.pval","N compound classes","compound classes",
          "CORE","CORE/TAILORING","MIXED","OTHER","REGULATOR","REGULATOR/TAILORING",
          "TAILORING","TAILORING/CORE","TAILORING/REGULATOR","TAILORING/TRANSPORT",
          "TRANSPORT")

navbarPage("Modules Explorer",
           #tabPanel("Summary Tables and MIB score",
                    sidebarLayout(
                      sidebarPanel(
                        actionButton("do", "UPDATE MIB score"),
                        #div(style="display:inline-block; width: 100px",checkboxInput("redundancy", "top20", value = FALSE, width = NULL)),
                        uiOutput("tab"),
                        div(style = "height:10px;", " "),
                        div(style="display:inline-block; width: 100px",numericInput("W1", "# compounds", 0, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W2", "Shannon's Entropy", 15, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W3", "Length", 2, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W4", "N clusters", 10, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W5", "max p-value", 5, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W6", "% CORE", 0, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W7", "% CORE / TAILORING", 0, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W8", "% MIXED", 0, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W9", "% OTHER", 0, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W10", "% REGULATOR", 0, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W11", "% REGULATOR / TAILORING", 0, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W12", "% TAILORING", 10, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W13", "% TAILORING / CORE", 0, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W14", "% TAILORING / REGULATOR", 0, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W15", "% TAILORING / TRANSPORT", 0, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("W16", "% TRANSPORT", 0, min=-15,max=15)),
                        div(style="display:inline-block; width: 100px",numericInput("MIBIG", "min hits in MiBiG", 1, min=0,max=100)),
                        checkboxGroupInput('show_vars',
                                           'Columns in Metrics and Ranks',
                                           nomi,
                                           selected = nomi[1:7], inline = TRUE),
                        div(style = "height:10px;", " "),
                        div(style = "height:10px;", " "),
                        div(style = "height:10px;", " "),
                        tags$img(src="logos.png", height=80)
                      ),
                      mainPanel(
                        tabsetPanel(
                          tabPanel('Modules metrics',
                                   dataTableOutput("mytable1")),
                          tabPanel('Module smCOG composition', dataTableOutput("mytable2"))
                        )
                      )
                  )
              )

