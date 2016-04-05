
#################################
## PLOT HISTOGRAM/DENSITY PAGE ##  ------------------------------------------------------------------------------------
#################################


## generate reactiveValues lists for all initial values
rv_hist_1D_button <- reactiveValues()
rv_hist_1D_button <- 1 # 0
rv_hist_1D_var <- reactiveValues()

## aesthetics
rv_hist_1D_col <- reactiveValues()
rv_hist_1D_transp <- reactiveValues()
rv_hist_1D_n.bins <- reactiveValues()
rv_hist_1D_grid <- reactiveValues()



#########################
## .set.reactiveValues.hist_1D ##
#########################
## fn to set reactiveValues initially for each k:
.set.reactiveValues.hist_1D <- function(dat, k){

  k <- as.character(k)

  x.var.choices <- x.var.sel <- NULL

  ## get variables
  if(!is.null(dat)){

    ## get numeric variables
    numCols <- which(sapply(c(1:ncol(dat$y)),
                            function(e) is.numeric(dat$y[,e])))

    var.choices <- c("Position", "Chromosome", names(dat$y)[numCols])

    x.var.choices <- var.choices

    x.var.sel <- x.var.choices[3]
    ## set intial values
    rv_hist_1D_var[[k]] <- x.var.sel

    rv_hist_1D_n.bins[[k]] <- 100
    rv_hist_1D_grid[[k]] <- FALSE

    rv_hist_1D_col[[k]] <- "blue"
    rv_hist_1D_transp[[k]] <- 0.25

  }
} # end .set.reactiveValues.hist_1D



####################################
## .update.reactiveValues.hist_1D ##
####################################
## fn to set reactiveValues initially for each k:
.update.reactiveValues.hist_1D <- function(dat, k){

  k <- as.character(k)

  x.var.choices <- x.var.sel <- NULL

  ## get variables
  if(!is.null(dat)){

    ## Get currently-selected values:

    ## Get x-axis & y-axis
    xSelection <- eval(parse(text=paste("input$hist_1D_var", k, sep="_")))

    ## Get plot aesthetics
    n.bins <- eval(parse(text=paste("input$hist_1D_n.bins", k, sep="_")))
    grid <- eval(parse(text=paste("input$hist_1D_grid", k, sep="_")))

    col <- eval(parse(text=paste("input$hist_1D_col", k, sep="_")))
    transp <- eval(parse(text=paste("input$hist_1D_transp", k, sep="_")))


    ## update "intial" values to current values
    rv_hist_1D_var[[k]] <- xSelection

    rv_hist_1D_n.bins[[k]] <- n.bins
    rv_hist_1D_grid[[k]] <- grid

    rv_hist_1D_col[[k]] <- col
    rv_hist_1D_transp[[k]] <- transp

  }
} # end .update.reactiveValues.hist_1D



## update K & set reactiveValues[[k]] if button pressed
observe({

  k <- input$new_hist_1D_button

  if(length(k) == 1){
    k <- k[1]+1
    ## if input button updates, set new panel of initial input values

    dat <- cleanData()

    ## if K updates:
    if(!is.null(dat)){

      if(k == 1){
        .set.reactiveValues.hist_1D(dat, k)
      }else{
        if(k > rv_hist_1D_button){
          ## update rv_hist_1D_button
          rv_hist_1D_button <- k

          # set reactive values for Kth element of rv lists
          .set.reactiveValues.hist_1D(dat, k)
          # .update.reactiveValues.hist_1D(dat, k)

          ## if more than one panel requested, update "initial" values for plots 1:k-1
          if(k > 1){
            for(i in 1:(k-1)){
              .update.reactiveValues.hist_1D(dat, i)
            }
          }
        }
      }
    }
  }
})


##################
## BOX OF BOXES ##
##################
## (to keep each set of plots+controls in line with each other... )

## Generate K individual BOXES for each univariate plot,
## produced using lapply method, K taken from actionButton:
output$box_hist_1D <- renderUI({

  k <- 1
  k <- input$new_hist_1D_button[1] + 1

  if(length(k) > 0){
    if(k > 0){
      lapply(1:k,function(i){

        dat <- title.k <- NULL

        ## get title
        title.k <- paste("Histogram #", i, sep = " ")

        ## get data
        dat <- cleanData()

        ## get box of boxes
        if(!is.null(dat)){
          box(title=title.k,
              status="warning",
              solidHeader=TRUE,
              collapsible=TRUE,
              width=12,

              fluidRow(
                column(4,
                       .get.hist_1D.controls(dat, i)
                ),

                column(8,
                       .get.hist_1D.plot(dat, i),
                       .get.hist_1D.controls.aes(dat, i)
                )
              )
          )
        }
      })
    }
  }
})



#######################################################
## Box: Global Controls for Univariate Distributions ##
#######################################################

## Fn to generate boxes containing controls for univariate distribution plots

.get.hist_1D.controls <- function(dat, k=1){

  k <- as.character(k)

  id_hist_1D_var <- paste("hist_1D_var", k, sep="_")

  out <- NULL
  var.choices <- var.sel <- NULL

  if(!is.null(dat)){

    ## get numeric variables
    numCols <- which(sapply(c(1:ncol(dat$y)),
                            function(e) is.numeric(dat$y[,e])))

    var.choices <- c("Position", "Chromosome", names(dat$y)[numCols])


  out <-
    box(title="Select Variables:", # "Univariate Distributions"
        status="primary",
        solidHeader=TRUE,
        collapsible=TRUE,
        width=12,

        ###################
        ## Choose x-axis ##
        ###################

        box(title="Select a variable to plot:", # "Univariate Distributions"
            status="info",
            #status = "primary",
            solidHeader=TRUE,
            collapsible=TRUE,
            width=12,

            ## NOTE: Would like to be able to pull the Chromosome and Position variables
            ## selected/generated in the Format Data tab to be available as options
            ## and autoatically selected below...

            ## Variable to plot
            selectizeInput(id_hist_1D_var,
                           label="Variable:",
                           choices= var.choices,
                           selected = rv_hist_1D_var[[k]],
                           multiple=FALSE)
        )

        )
  }

  return(out)
} # end .get.hist_1D.controls



###############################
## .get.hist_1D.controls.aes ##
###############################
## fn to get widgets to control plot AESTHETICS under plot
.get.hist_1D.controls.aes <- function(dat, k=1){

  k <- as.character(k)

  ## get Id's | k
  id_hist_1D_n.bins <- paste("hist_1D_n.bins", k, sep="_")
  id_hist_1D_grid <- paste("hist_1D_grid", k, sep="_")

  id_hist_1D_col <- paste("hist_1D_col", k, sep="_")
  id_hist_1D_transp <- paste("hist_1D_transp", k, sep="_")

  out <- NULL

  out <-
    box(title="Adjust Plot Aesthetics:",
        status="warning",
        solidHeader=TRUE,
        collapsible=TRUE,
        width=12,

        sliderInput(id_hist_1D_n.bins,
                    label = "Number of bins:",
                    min = 2, max = 1000,
                    value = rv_hist_1D_n.bins[[k]],
                    step = 1),

        radioButtons(id_hist_1D_grid,
                     label="Overlay grid?",
                     choices=list("Yes" = TRUE,
                                  "No" = FALSE),
                     selected = rv_hist_1D_grid[[k]],
                     inline = TRUE),

        selectizeInput(id_hist_1D_col,
                       label = "Colour:", # (fill)
                       choices = list("Red" = "red",
                                      "Orange" = "orange",
                                      "Yellow" = "yellow",
                                      "Green" = "green",
                                      "Blue" = "blue",
                                      "Purple" = "purple"),
                       selected =  rv_hist_1D_col[[k]], # "purple",
                       multiple=FALSE),

        sliderInput(id_hist_1D_transp,
                    label = "Transparency:",
                    min = 0, max = 1,
                    value =  rv_hist_1D_transp[[k]], # 0.25,
                    step = 0.05)
    ) # end box

  return(out)

} # end .get.hist_1D.controls.aes



####################################
## BUTTON: Generate another plot? ##
####################################
output$box_hist_1D_button <- renderUI({
  box(
    title = "Generate another plot?",
    solidHeader = TRUE,
    status = "primary",
    value = NULL,
    width=12,

    ## button
    actionButton(inputId = "new_hist_1D_button",
                 label = "Yes, please!",
                 icon = icon("cog"))
  )
})


########################
## Plot: hist_1D_plot ##
########################

######################
## get.hist_1D.plot ##
######################
.get.hist_1D.plot <- function(dat, k=1){

  out <- NULL

  if(!is.null(k)){

    ## get unique outputId
    id_hist_1D <- paste("id_hist_1D", k, sep="_")

    out <-
      box(title=NULL,
          status="warning",
          solidHeader=FALSE,
          collapsible=TRUE,
          width=12,
          # plotOutput("plot_hist_1D_plot")
          renderPlot(plotOutput(
            outputId = id_hist_1D,
            .get.hist_1D(input, k=k)))
      )
  }
  return(out)
}


##################
## .get.hist_1D ##
##################
.get.hist_1D <- function(input, k=1){

  histplot <- dat <- xData <- xSelection <-
    col <- transp <- n.bins <- NULL

  k <- as.character(k)

  ## Get x-axis & y-axis
  xSelection <- eval(parse(text=paste("input$hist_1D_var", k, sep="_")))

  ## Get data and plot output
  if(!is.null(cleanData())){
    if(!is.null(xSelection)){

      ## Get data
      dat <- cleanData()

      ## Get x-variable data
      if(!is.null(xSelection)){
        ## Get variable to plot
        if(xSelection == "Position"){
          ## could be used to check for missing values...
          xData <- eval(parse(text="dat$pos"))
        }else{
          if(xSelection == "Chromosome"){
            ## could be used to check for representation/length of each chromosome
            xData <- eval(parse(text="dat$chrom"))
          }else{
            xData <- eval(parse(text=paste("dat$y", xSelection, sep="$")))
          }
        }
      }

      #########################
      ## Get plot aesthetics ##
      #########################

      ## Get plot aesthetics
      n.bins <- eval(parse(text=paste("input$hist_1D_n.bins", k, sep="_")))
      grid <- eval(parse(text=paste("input$hist_1D_grid", k, sep="_")))

      col <- eval(parse(text=paste("input$hist_1D_col", k, sep="_")))
      transp <- eval(parse(text=paste("input$hist_1D_transp", k, sep="_")))


      transp <- 1-transp

      if(transp != 1){
        col <- transp(col, alpha=transp)
      }

      # produce plot
      ## PLOT HISTOGRAM
      if(!is.null(xData)){
        if(!is.null(n.bins)){
          hist(xData, breaks=n.bins, col=col, main=NULL)
          if(grid) grid()
        }
      }
      ## SET TITLE TO VALUE BEING HISTOGRAMIFIED
      title(xSelection) # to be changed to textInput( w var selected)

      }
    }
  # return(hist_1D)
} # end .get.hist_1D
