# Parsing for R commands
csiu  
April 24, 2017  



----

I’ll be teaching an R workshop in a couple days based on the [R for Reproducible Scientific Analysis](http://swcarpentry.github.io/r-novice-gapminder/) Software Carpentry lesson plan (lessons 1-10). To get a copy of the R commands (so that I can try them out), I could either (A) copy everything by hand or (B) automatically scrape the commands.

*If you know me, then the choice is pretty obvious...*

In this post, I scrape the R commands using R and [`rvest`](https://github.com/hadley/rvest).

## Getting the syllabus

`read_html` reads the html from a given url and `html_nodes` selects the particular nodes of an HTML document.


```r
# Packages I use
library(rvest)
library(dplyr)
library(purrr)
```


```r
main_url <- "http://swcarpentry.github.io/r-novice-gapminder/"
```


```r
# Get HTML
syllabus <-
  read_html(main_url) %>%
  html_nodes("body div.syllabus table td.col-md-3 a")

# Extract relevant fields & make data frame
(syllabus <-
  data.frame(
    label = html_text(syllabus),
    href = html_attr(syllabus, "href"),
    stringsAsFactors = FALSE
  ) %>%
  mutate(
    lesson_plan = ifelse(grepl("\\d{2}", href),
                         sub(".*(\\d{2}).*", "\\1",  href),
                         "00") %>% as.integer()
  )
) %>%
  mutate(
    href = sprintf("[%s](%s)", href, paste0(main_url, href))
  ) %>%
  knitr::kable(format="markdown")
```



|label                                 |href                                                                                                       | lesson_plan|
|:-------------------------------------|:----------------------------------------------------------------------------------------------------------|-----------:|
|Setup                                 |[./setup](http://swcarpentry.github.io/r-novice-gapminder/./setup)                                         |           0|
|Introduction to R and RStudio         |[./01-rstudio-intro/](http://swcarpentry.github.io/r-novice-gapminder/./01-rstudio-intro/)                 |           1|
|Project Management With RStudio       |[./02-project-intro/](http://swcarpentry.github.io/r-novice-gapminder/./02-project-intro/)                 |           2|
|Seeking Help                          |[./03-seeking-help/](http://swcarpentry.github.io/r-novice-gapminder/./03-seeking-help/)                   |           3|
|Data Structures                       |[./04-data-structures-part1/](http://swcarpentry.github.io/r-novice-gapminder/./04-data-structures-part1/) |           4|
|Exploring Data Frames                 |[./05-data-structures-part2/](http://swcarpentry.github.io/r-novice-gapminder/./05-data-structures-part2/) |           5|
|Subsetting Data                       |[./06-data-subsetting/](http://swcarpentry.github.io/r-novice-gapminder/./06-data-subsetting/)             |           6|
|Control Flow                          |[./07-control-flow/](http://swcarpentry.github.io/r-novice-gapminder/./07-control-flow/)                   |           7|
|Creating Publication-Quality Graphics |[./08-plot-ggplot2/](http://swcarpentry.github.io/r-novice-gapminder/./08-plot-ggplot2/)                   |           8|
|Vectorization                         |[./09-vectorization/](http://swcarpentry.github.io/r-novice-gapminder/./09-vectorization/)                 |           9|
|Functions Explained                   |[./10-functions/](http://swcarpentry.github.io/r-novice-gapminder/./10-functions/)                         |          10|
|Writing Data                          |[./11-writing-data/](http://swcarpentry.github.io/r-novice-gapminder/./11-writing-data/)                   |          11|
|Split-Apply-Combine                   |[./12-plyr/](http://swcarpentry.github.io/r-novice-gapminder/./12-plyr/)                                   |          12|
|Dataframe Manipulation with dplyr     |[./13-dplyr/](http://swcarpentry.github.io/r-novice-gapminder/./13-dplyr/)                                 |          13|
|Dataframe Manipulation with tidyr     |[./14-tidyr/](http://swcarpentry.github.io/r-novice-gapminder/./14-tidyr/)                                 |          14|
|Producing Reports With knitr          |[./15-knitr-markdown/](http://swcarpentry.github.io/r-novice-gapminder/./15-knitr-markdown/)               |          15|
|Writing Good Software                 |[./16-wrap-up/](http://swcarpentry.github.io/r-novice-gapminder/./16-wrap-up/)                             |          16|

## Getting the commands from one page

I first extract the R commands from 1 page, and then I can generalize to the other pages. Fortunately, the parsing is easy as all the R commands are tagged by `<div style="r highlighter-rouge">` elements.


```r
child_url <- paste0(main_url, syllabus[2,"href"])
```


```r
# Extract the commands
cmds <-
  read_html(child_url) %>%
  html_nodes("div.r,highlighter-rouge") %>%
  html_nodes("code") %>%
  html_text()
```


```r
# Display the commands by Markdown fashion
counter = 1
for (cmd in cmds) {
  cmd <-
    paste0("    ", cmd) %>%
    {gsub("\n", "\n    ", .)} %>%
    {gsub("\n    $", "\n", .)}
  cat(cmd)

  ## As this is a test, print only 5 commands
  if (counter < 5){
    counter <- counter + 1
  } else {
    break
  }
}
```

    1 + 100
    > 1 +
    3 + 5 * 2
    (3 + 5) * 2
    (3 + (5 * (2 ^ 2))) # hard to read
    3 + 5 * 2 ^ 2       # clear, if you remember the rules
    3 + 5 * (2 ^ 2)     # if you forget some rules, this might help

### Modularized functionality

Next I generalize the parsing of R commands from one page to allow parsing of other pages. The commands are also encapsulated by a function for modularity.


```r
get_cmds <- function(href, is_tidy=TRUE) {
  child_url <- paste0(main_url, href)

  cmds <-
    read_html(child_url) %>%
    html_nodes("div.r,highlighter-rouge") %>%
    html_nodes("code") %>%
    html_text()

  if (is_tidy) {
    lapply(cmds, function(cmd){
      paste0("    ", cmd) %>%
      {gsub("\n", "\n    ", .)} %>%
      {gsub("\n    $", "\n", .)}
    }) %>%
      unlist()
  } else {
    cmds
  }
}
```

## Getting the commands from many pages


```r
# Get/parse R commands from each link of each lesson
syllabus <-
  syllabus %>%
  mutate(
    cmds = map(href, get_cmds)
  )
```


```r
# Display results (with proper heading)
# The remaining content (following this code block) is generated by R.
for (i in 1:max(syllabus$lesson_plan)) {
  cat(
    sprintf("### %s: %s\n",
            syllabus[i,]["lesson_plan"],
            syllabus[i,]["label"])
  )
  cat(
    syllabus[i,]$cmds %>%
      unlist() %>%
      paste(collapse = "")
    )
}
```

### 0: Setup
### 1: Introduction to R and RStudio
    1 + 100
    > 1 +
    3 + 5 * 2
    (3 + 5) * 2
    (3 + (5 * (2 ^ 2))) # hard to read
    3 + 5 * 2 ^ 2       # clear, if you remember the rules
    3 + 5 * (2 ^ 2)     # if you forget some rules, this might help
    2/10000
    5e3  # Note the lack of minus here
    sin(1)  # trigonometry functions
    log(1)  # natural logarithm
    log10(10) # base-10 logarithm
    exp(0.5) # e^(1/2)
    1 == 1  # equality (note two equals signs, read as "is equal to")
    1 != 2  # inequality (read as "is not equal to")
    1 <  2  # less than
    1 <= 1  # less than or equal to
    1 > 0  # greater than
    1 >= -9 # greater than or equal to
    x <- 1/40
    x
    log(x)
    x <- 100
    x <- x + 1 #notice how RStudio updates its description of x on the top right tab
    x = 1/40
    1:5
    2^(1:5)
    x <- 1:5
    2^x
    ls()
    ls
    rm(x)
    rm(list = ls())
    rm(list <- ls())
    min_height
    max.height
    _age
    .mass
    MaxLength
    min-length
    2widths
    celsius2kelvin
    min_height
    max.height
    MaxLength
    celsius2kelvin
    .mass
    _age
    min-length
    2widths
    mass <- 47.5
    age <- 122
    mass <- mass * 2.3
    age <- age - 20
    mass <- 47.5
    age <- 122
    mass <- mass * 2.3
    age <- age - 20
    mass > age
    rm(age, mass)
    install.packages("ggplot2")
    install.packages("plyr")
    install.packages("gapminder")
### 2: Project Management With RStudio
    install.packages("ProjectTemplate")
    library("ProjectTemplate")
    create.project("../my_project", merge.strategy = "allow.non.conflict")
    ls -lh data/gapminder-FiveYearData.csv
    wc -l data/gapminder-FiveYearData.csv
    head data/gapminder-FiveYearData.csv
### 3: Seeking Help
    ?function_name
    help(function_name)
    ?"+"
    ??function_name
    ?dput
    sessionInfo()
    c(1, 2, 3)
    c('d', 'e', 'f')
    c(1, 2, 'f')
    help("paste")
    ?paste
### 4: Data Structures
    coat,weight,likes_string
    calico,2.1,1
    black,5.0,0
    tabby,3.2,1
    cats <- read.csv(file = "data/feline-data.csv")
    cats
    cats$weight
    cats$coat
    ## Say we discovered that the scale weighs two Kg light:
    cats$weight + 2
    paste("My cat is", cats$coat)
    cats$weight + cats$coat
    typeof(cats$weight)
    typeof(3.14)
    typeof(1L) # The L suffix forces the number to be an integer, since by default R uses float numbers
    typeof(1+1i)
    typeof(TRUE)
    typeof('banana')
    file.show("data/feline-data_v2.csv")
    coat,weight,likes_string
    calico,2.1,1
    black,5.0,0
    tabby,3.2,1
    tabby,2.3 or 2.4,1
    cats <- read.csv(file="data/feline-data_v2.csv")
    typeof(cats$weight)
    cats$weight + 2
    class(cats)
    cats <- read.csv(file="data/feline-data.csv")
    my_vector <- vector(length = 3)
    my_vector
    another_vector <- vector(mode='character', length=3)
    another_vector
    str(another_vector)
    str(cats$weight)
    combine_vector <- c(2,6,3)
    combine_vector
    quiz_vector <- c(2,6,'3')
    coercion_vector <- c('a', TRUE)
    coercion_vector
    another_coercion_vector <- c(0, TRUE)
    another_coercion_vector
    character_vector_example <- c('0','2','4')
    character_vector_example
    character_coerced_to_numeric <- as.numeric(character_vector_example)
    character_coerced_to_numeric
    numeric_coerced_to_logical <- as.logical(character_coerced_to_numeric)
    numeric_coerced_to_logical
    cats$likes_string
    cats$likes_string <- as.logical(cats$likes_string)
    cats$likes_string
    ab_vector <- c('a', 'b')
    ab_vector
    combine_example <- c(ab_vector, 'SWC')
    combine_example
    mySeries <- 1:10
    mySeries
    seq(10)
    seq(1,10, by=0.1)
    sequence_example <- seq(10)
    head(sequence_example, n=2)
    tail(sequence_example, n=4)
    length(sequence_example)
    class(sequence_example)
    typeof(sequence_example)
    my_example <- 5:8
    names(my_example) <- c("a", "b", "c", "d")
    my_example
    names(my_example)
    x <- 1:26
    x <- x * 2
    names(x) <- LETTERS
    str(cats$weight)
    str(cats$likes_string)
    str(cats$coat)
    coats <- c('tabby', 'tortoiseshell', 'tortoiseshell', 'black', 'tabby')
    coats
    str(coats)
    CATegories <- factor(coats)
    class(CATegories)
    str(CATegories)
    typeof(coats)
    typeof(CATegories)
    cats <- read.csv(file="data/feline-data.csv", stringsAsFactors=FALSE)
    str(cats$coat)
    cats <- read.csv(file="data/feline-data.csv", colClasses=c(NA, NA, "character"))
    str(cats$coat)
    mydata <- c("case", "control", "control", "case")
    factor_ordering_example <- factor(mydata, levels = c("control", "case"))
    str(factor_ordering_example)
    list_example <- list(1, "a", TRUE, 1+4i)
    list_example
    another_list <- list(title = "Research Bazaar", numbers = 1:10, data = TRUE )
    another_list
    typeof(cats)
    cats$coat
    cats[,1]
    typeof(cats[,1])
    str(cats[,1])
    cats[1,]
    typeof(cats[1,])
    str(cats[1,])
    cats[1]
    cats[[1]]
    cats$coat
    cats["coat"]
    cats[1, 1]
    cats[, 1]
    cats[1, ]
    matrix_example <- matrix(0, ncol=6, nrow=3)
    matrix_example
    class(matrix_example)
    typeof(matrix_example)
    str(matrix_example)
    dim(matrix_example)
    nrow(matrix_example)
    ncol(matrix_example)
    matrix_example <- matrix(0, ncol=6, nrow=3)
    length(matrix_example)
    x <- matrix(1:50, ncol=5, nrow=10)
    x <- matrix(1:50, ncol=5, nrow=10, byrow = TRUE) # to fill by row
    dataTypes <- c('double', 'complex', 'integer', 'character', 'logical')
    dataStructures <- c('data.frame', 'vector', 'factor', 'list', 'matrix')
    answer <- list(dataTypes, dataStructures)
    matrix(c(4, 1, 9, 5, 10, 7), ncol = 2, byrow = TRUE)
### 5: Exploring Data Frames
    age <- c(2,3,5,12)
    cats
    cats <- cbind(cats, age)
    cats
    age <- c(4,5,8)
    cats <- cbind(cats, age)
    cats
    newRow <- list("tortoiseshell", 3.3, TRUE, 9)
    cats <- rbind(cats, newRow)
    levels(cats$coat)
    levels(cats$coat) <- c(levels(cats$coat), 'tortoiseshell')
    cats <- rbind(cats, list("tortoiseshell", 3.3, TRUE, 9))
    str(cats)
    cats$coat <- as.character(cats$coat)
    str(cats)
    cats
    cats[-4,]
    na.omit(cats)
    cats <- na.omit(cats)
    cats <- rbind(cats, cats)
    cats
    rownames(cats) <- NULL
    cats
    df <- data.frame(id = c('a', 'b', 'c'),
                     x = 1:3,
                     y = c(TRUE, TRUE, FALSE),
                     stringsAsFactors = FALSE)
    df <- data.frame(first = c('Grace'),
                     last = c('Hopper'),
                     lucky_number = c(0),
                     stringsAsFactors = FALSE)
    df <- rbind(df, list('Marie', 'Curie', 238) )
    df <- cbind(df, coffeetime = c(TRUE,TRUE))
    gapminder <- read.csv("data/gapminder-FiveYearData.csv")
    download.file("https://raw.githubusercontent.com/swcarpentry/r-novice-gapminder/gh-pages/_episodes_rmd/data/gapminder-FiveYearData.csv", destfile = "data/gapminder-FiveYearData.csv")
    gapminder <- read.csv("data/gapminder-FiveYearData.csv")
    gapminder <- read.csv("https://raw.githubusercontent.com/swcarpentry/r-novice-gapminder/gh-pages/_episodes_rmd/data/gapminder-FiveYearData.csv")
    str(gapminder)
    typeof(gapminder$year)
    typeof(gapminder$country)
    str(gapminder$country)
    length(gapminder)
    typeof(gapminder)
    nrow(gapminder)
    ncol(gapminder)
    dim(gapminder)
    colnames(gapminder)
    head(gapminder)
    download.file("https://raw.githubusercontent.com/swcarpentry/r-novice-gapminder/gh-pages/_episodes_rmd/data/gapminder-FiveYearData.csv", destfile = "data/gapminder-FiveYearData.csv")
    gapminder <- read.csv(file = "data/gapminder-FiveYearData.csv")
    source(file = "scripts/load-gapminder.R")
### 6: Subsetting Data
    x <- c(5.4, 6.2, 7.1, 4.8, 7.5)
    names(x) <- c('a', 'b', 'c', 'd', 'e')
    x
    x[1]
    x[4]
    x[c(1, 3)]
    x[1:4]
    1:4
    c(1, 2, 3, 4)
    x[c(1,1,3)]
    x[6]
    x[0]
    x[-2]
    x[c(-1, -5)]  # or x[-c(1,5)]
    x[-1:3]
    x[-(1:3)]
    x <- x[-4]
    x
    x <- c(5.4, 6.2, 7.1, 4.8, 7.5)
    names(x) <- c('a', 'b', 'c', 'd', 'e')
    print(x)
    x[2:4]
    x[-c(1,5)]
    x[c("b", "c", "d")]
    x[c(2,3,4)]
    x[c("a", "c")]
    x[-which(names(x) == "a")]
    names(x) == "a"
    which(names(x) == "a")
    x[-which(names(x) %in% c("a", "c"))]
    x <- c(5.4, 6.2, 7.1, 4.8, 7.5)
    names(x) <- c('a', 'b', 'c', 'd', 'e')
    print(x)
    x[-which(names(x) == "g")]
    x <- 1:3
    x
    names(x) <- c('a', 'a', 'a')
    x
    x['a']  # only returns first value
    x[which(names(x) == 'a')]  # returns all three values
    names(x) == c('a', 'c')
    c("a", "b", "c", "e")  # names of x
       |    |    |    |    # The elements == is comparing
    c("a", "c")
    c("a", "b", "c", "e")  # names of x
       |    |    |    |    # The elements == is comparing
    c("a", "c", "a", "c")
    names(x) == c('a', 'c', 'e')
    x[c(TRUE, TRUE, FALSE, FALSE)]
    x[c(TRUE, FALSE)]
    x[x > 7]
    x <- c(5.4, 6.2, 7.1, 4.8, 7.5)
    names(x) <- c('a', 'b', 'c', 'd', 'e')
    print(x)
    x_subset <- x[x<7 & x>4]
    print(x_subset)
    f <- factor(c("a", "a", "b", "c", "c", "d"))
    f[f == "a"]
    f[f %in% c("b", "c")]
    f[1:3]
    f[-3]
    set.seed(1)
    m <- matrix(rnorm(6*4), ncol=4, nrow=6)
    m[3:4, c(3,1)]
    m[, c(3,4)]
    m[3,]
    m[3, , drop=FALSE]
    m[, c(3,6)]
    m[5]
    matrix(1:6, nrow=2, ncol=3)
    matrix(1:6, nrow=2, ncol=3, byrow=TRUE)
    m <- matrix(1:18, nrow=3, ncol=6)
    print(m)
    xlist <- list(a = "Software Carpentry", b = 1:10, data = head(iris))
    xlist[1]
    xlist[1:2]
    xlist[[1]]
    xlist[[1:2]]
    xlist[[-1]]
    xlist[["a"]]
    xlist$data
    xlist <- list(a = "Software Carpentry", b = 1:10, data = head(iris))
    xlist$b[2]
    xlist[[2]][2]
    xlist[["b"]][2]
    mod <- aov(pop ~ lifeExp, data=gapminder)
    attributes(mod) ## `df.residual` is one of the names of `mod`
    mod$df.residual
    head(gapminder[3])
    head(gapminder[["lifeExp"]])
    head(gapminder$year)
    gapminder[1:3,]
    gapminder[3,]
    gapminder[gapminder$year = 1957,]
    gapminder[,-1:4]
    gapminder[gapminder$lifeExp > 80]
    gapminder[1, 4, 5]
    gapminder[gapminder$year == 2002 | 2007,]
    # gapminder[gapminder$year = 1957,]
    gapminder[gapminder$year == 1957,]
    # gapminder[,-1:4]
    gapminder[,-c(1:4)]
    # gapminder[gapminder$lifeExp > 80]
    gapminder[gapminder$lifeExp > 80,]
    # gapminder[1, 4, 5]
    gapminder[1, c(4, 5)]
     # gapminder[gapminder$year == 2002 | 2007,]
     gapminder[gapminder$year == 2002 | gapminder$year == 2007,]
     gapminder[gapminder$year %in% c(2002, 2007),]
    gapminder_small <- gapminder[c(1:9, 19:23),]
### 7: Control Flow
    # if
    if (condition is true) {
      perform action
    }
    
    # if ... else
    if (condition is true) {
      perform action
    } else {  # that is, if the condition is false,
      perform alternative action
    }
    # sample a random number from a Poisson distribution
    # with a mean (lambda) of 8
    
    x <- rpois(1, lambda=8)
    
    if (x >= 10) {
      print("x is greater than or equal to 10")
    }
    
    x
    set.seed(10)
    x <- rpois(1, lambda=8)
    
    if (x >= 10) {
      print("x is greater than or equal to 10")
    } else if (x > 5) {
      print("x is greater than 5")
    } else {
      print("x is less than 5")
    }
    x  <-  4 == 3
    if (x) {
      "4 equals 3"
    }
    x <- 4 == 3
    x
    gapminder[(gapminder$year == 2002),]
    rows2002_number <- nrow(gapminder[(gapminder$year == 2002),])
    rows2002_number >= 1
    if(nrow(gapminder[(gapminder$year == 2002),]) >= 1){
       print("Record(s) for the year 2002 found.")
    }
    if(any(gapminder$year == 2002)){
       print("Record(s) for the year 2002 found.")
    }
    for(iterator in set of values){
      do a thing
    }
    for(i in 1:10){
      print(i)
    }
    for(i in 1:5){
      for(j in c('a', 'b', 'c', 'd', 'e')){
        print(paste(i,j))
      }
    }
    output_vector <- c()
    for(i in 1:5){
      for(j in c('a', 'b', 'c', 'd', 'e')){
        temp_output <- paste(i, j)
        output_vector <- c(output_vector, temp_output)
      }
    }
    output_vector
    output_matrix <- matrix(nrow=5, ncol=5)
    j_vector <- c('a', 'b', 'c', 'd', 'e')
    for(i in 1:5){
      for(j in 1:5){
        temp_j_value <- j_vector[j]
        temp_output <- paste(i, temp_j_value)
        output_matrix[i, j] <- temp_output
      }
    }
    output_vector2 <- as.vector(output_matrix)
    output_vector2
    while(this condition is true){
      do a thing
    }
    z <- 1
    while(z > 0.1){
      z <- runif(1)
      print(z)
    }
    all(output_vector == output_vector2)
    all(output_vector %in% output_vector2)
    all(output_vector2 %in% output_vector)
    output_vector2 <- as.vector(output_matrix)
    output_vector2 <- as.vector(t(output_matrix))
    output_matrix[i, j] <- temp_output
    output_matrix[j, i] <- temp_output
    gapminder <- read.csv("data/gapminder-FiveYearData.csv")
    unique(gapminder$continent)
    for( iContinent in unique(gapminder$continent) ){
       tmp <- mean(subset(gapminder, continent==iContinent)$lifeExp)
       cat("Average Life Expectancy in", iContinent, "is", tmp, "\n")
       rm(tmp)
    }
    thresholdValue <- 50
    > >
    for( iContinent in unique(gapminder$continent) ){
       tmp <- mean(subset(gapminder, continent==iContinent)$lifeExp)
       
       if(tmp < thresholdValue){
           cat("Average Life Expectancy in", iContinent, "is less than", thresholdValue, "\n")
       }
       else{
           cat("Average Life Expectancy in", iContinent, "is greater than", thresholdValue, "\n")
            } # end if else condition
       rm(tmp)
       } # end for loop
    > >
     lowerThreshold <- 50
     upperThreshold <- 70
     
    for( iCountry in unique(gapminder$country) ){
        tmp <- mean(subset(gapminder, country==iCountry)$lifeExp)
        
        if(tmp < lowerThreshold){
            cat("Average Life Expectancy in", iCountry, "is less than", lowerThreshold, "\n")
        }
        else if(tmp > lowerThreshold && tmp < upperThreshold){
            cat("Average Life Expectancy in", iCountry, "is between", lowerThreshold, "and", upperThreshold, "\n")
        }
        else{
            cat("Average Life Expectancy in", iCountry, "is greater than", upperThreshold, "\n")
        }
        rm(tmp)
    }
    grep("^B", unique(gapminder$country))
    grep("^B", unique(gapminder$country), value=TRUE)
    candidateCountries <- grep("^B", unique(gapminder$country), value=TRUE)
    > >
    for( iCountry in candidateCountries){
        tmp <- mean(subset(gapminder, country==iCountry)$lifeExp)
        
        if(tmp < thresholdValue){
            cat("Average Life Expectancy in", iCountry, "is less than", thresholdValue, "plotting life expectancy graph... \n")
            
            with(subset(gapminder, country==iCountry),
                    plot(year,lifeExp,
                         type="o",
                         main = paste("Life Expectancy in", iCountry, "over time"),
                         ylab = "Life Expectancy",
                         xlab = "Year"
                       ) # end plot
                  ) # end with
        } # end for loop
        rm(tmp)
     }```
    > {: .solution}
    {: .challenge}
### 8: Creating Publication-Quality Graphics
    library("ggplot2")
    ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp)) +
      geom_point()
    ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp))
    ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp)) +
      geom_point()
    ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp)) + geom_point()
    ggplot(data = gapminder, aes(x = year, y = lifeExp)) + geom_point()
    ggplot(data = gapminder, aes(x = year, y = lifeExp, color=continent)) +
      geom_point()
    ggplot(data = gapminder, aes(x=year, y=lifeExp, by=country, color=continent)) +
      geom_line()
    ggplot(data = gapminder, aes(x=year, y=lifeExp, by=country, color=continent)) +
      geom_line() + geom_point()
    ggplot(data = gapminder, aes(x=year, y=lifeExp, by=country)) +
      geom_line(aes(color=continent)) + geom_point()
    ggplot(data = gapminder, aes(x=year, y=lifeExp, by=country)) +
     geom_point() + geom_line(aes(color=continent))
    ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp, color=continent)) +
      geom_point()
    ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp)) +
      geom_point(alpha = 0.5) + scale_x_log10()
    ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp)) +
      geom_point() + scale_x_log10() + geom_smooth(method="lm")
    ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp)) +
      geom_point() + scale_x_log10() + geom_smooth(method="lm", size=1.5)
    ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp)) +
     geom_point(size=3, color="orange") + scale_x_log10() +
     geom_smooth(method="lm", size=1.5)
    ggplot(data = gapminder, aes(x = gdpPercap, y = lifeExp, color = continent)) +
    geom_point(size=3, shape=17) + scale_x_log10() +
    geom_smooth(method="lm", size=1.5)
    starts.with <- substr(gapminder$country, start = 1, stop = 1)
    az.countries <- gapminder[starts.with %in% c("A", "Z"), ]
    ggplot(data = az.countries, aes(x = year, y = lifeExp, color=continent)) +
      geom_line() + facet_wrap( ~ country)
    ggplot(data = az.countries, aes(x = year, y = lifeExp, color=continent)) +
      geom_line() + facet_wrap( ~ country) +
      xlab("Year") + ylab("Life expectancy") + ggtitle("Figure 1") +
      scale_colour_discrete(name="Continent") +
      theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
    ggplot(data = gapminder, aes(x = gdpPercap, fill=continent)) +
     geom_density(alpha=0.6) + facet_wrap( ~ year) + scale_x_log10()
### 9: Vectorization
    x <- 1:4
    x * 2
    y <- 6:9
    x + y
    x:  1  2  3  4
        +  +  +  +
    y:  6  7  8  9
    ---------------
        7  9 11 13
    gapminder$pop_millions <- gapminder$pop / 1e6
    head(gapminder)
    ggplot(gapminder, aes(x = year, y = pop_millions)) +
     geom_point()
    countryset <- c("China","India","Indonesia")
    ggplot(gapminder[gapminder$country %in% countryset,],
           aes(x = year, y = pop_millions)) +
      geom_point()
    x > 2
    a <- x > 3  # or, for clarity, a <- (x > 3)
    a
    x <- 1:4
    log(x)
    m <- matrix(1:12, nrow=3, ncol=4)
    m * -1
    m %*% matrix(1, nrow=4, ncol=1)
    matrix(1:4, nrow=1) %*% matrix(1:4, ncol=1)
    m <- matrix(1:12, nrow=3, ncol=4)
    m
    m <- matrix(1:12, nrow=3, ncol=4)
    m
     x = 1/(1^2) + 1/(2^2) + 1/(3^2) + ... + 1/(n^2)
     x = 1/(1^2) + 1/(2^2) + 1/(3^2) + ... + 1/(n^2)
    sum(1/(1:100)^2)
    sum(1/(1:1e04)^2)
    n <- 10000
    sum(1/(1:n)^2)
    inverse_sum_of_squares <- function(n) {
      sum(1/(1:n)^2)
    }
    inverse_sum_of_squares(100)
    inverse_sum_of_squares(10000)
    n <- 10000
    inverse_sum_of_squares(n)
### 10: Functions Explained
    my_sum <- function(a, b) {
      the_sum <- a + b
      return(the_sum)
    }
    fahr_to_kelvin <- function(temp) {
      kelvin <- ((temp - 32) * (5 / 9)) + 273.15
      return(kelvin)
    }
    # freezing point of water
    fahr_to_kelvin(32)
    # boiling point of water
    fahr_to_kelvin(212)
    kelvin_to_celsius <- function(temp) {
     celsius <- temp - 273.15
     return(celsius)
    }
    fahr_to_kelvin <- function(temp) {
      kelvin <- ((temp - 32) * (5 / 9)) + 273.15
      return(kelvin)
    }
    
    kelvin_to_celsius <- function(temp) {
      celsius <- temp - 273.15
      return(celsius)
    }
    fahr_to_celsius <- function(temp) {
      temp_k <- fahr_to_kelvin(temp)
      result <- kelvin_to_celsius(temp_k)
      return(result)
    }
    # Takes a dataset and multiplies the population column
    # with the GDP per capita column.
    calcGDP <- function(dat) {
      gdp <- dat$pop * dat$gdpPercap
      return(gdp)
    }
    calcGDP(head(gapminder))
    # Takes a dataset and multiplies the population column
    # with the GDP per capita column.
    calcGDP <- function(dat, year=NULL, country=NULL) {
      if(!is.null(year)) {
        dat <- dat[dat$year %in% year, ]
      }
      if (!is.null(country)) {
        dat <- dat[dat$country %in% country,]
      }
      gdp <- dat$pop * dat$gdpPercap
    
      new <- cbind(dat, gdp=gdp)
      return(new)
    }
    source("functions/functions-lesson.R")
    head(calcGDP(gapminder, year=2007))
    calcGDP(gapminder, country="Australia")
    calcGDP(gapminder, year=2007, country="Australia")
    calcGDP <- function(dat, year=NULL, country=NULL) {
      if(!is.null(year)) {
        dat <- dat[dat$year %in% year, ]
      }
      if (!is.null(country)) {
        dat <- dat[dat$country %in% country,]
      }
      gdp <- dat$pop * dat$gdpPercap
      new <- cbind(dat, gdp=gdp)
      return(new)
    }
    best_practice <- c("Write", "programs", "for", "people", "not", "computers")
    paste(best_practice, collapse=" ")
    fence(text=best_practice, wrapper="***")
    fence <- function(text, wrapper){
      text <- c(wrapper, text, wrapper)
      result <- paste(text, collapse = " ")
      return(result)
    }
    best_practice <- c("Write", "programs", "for", "people", "not", "computers")
    fence(text=best_practice, wrapper="***")
### 11: Writing Data
    ggsave("My_most_recent_plot.pdf")
    pdf("Life_Exp_vs_time.pdf", width=12, height=4)
    ggplot(data=gapminder, aes(x=year, y=lifeExp, colour=country)) +
      geom_line()
    
    # You then have to make sure to turn off the pdf device!
    
    dev.off()
    aust_subset <- gapminder[gapminder$country == "Australia",]
    
    write.table(aust_subset,
      file="cleaned-data/gapminder-aus.csv",
      sep=","
    )
    head cleaned-data/gapminder-aus.csv
    ?write.table
    write.table(
      gapminder[gapminder$country == "Australia",],
      file="cleaned-data/gapminder-aus.csv",
      sep=",", quote=FALSE, row.names=FALSE
    )
    head cleaned-data/gapminder-aus.csv
### 12: Split-Apply-Combine
    # Takes a dataset and multiplies the population column
    # with the GDP per capita column.
    calcGDP <- function(dat, year=NULL, country=NULL) {
      if(!is.null(year)) {
        dat <- dat[dat$year %in% year, ]
      }
      if (!is.null(country)) {
        dat <- dat[dat$country %in% country,]
      }
      gdp <- dat$pop * dat$gdpPercap
    
      new <- cbind(dat, gdp=gdp)
      return(new)
    }
    withGDP <- calcGDP(gapminder)
    mean(withGDP[withGDP$continent == "Africa", "gdp"])
    mean(withGDP[withGDP$continent == "Americas", "gdp"])
    mean(withGDP[withGDP$continent == "Asia", "gdp"])
    library("plyr")
    xxply(.data, .variables, .fun)
    ddply(
     .data = calcGDP(gapminder),
     .variables = "continent",
     .fun = function(x) mean(x$gdp)
    )
    dlply(
     .data = calcGDP(gapminder),
     .variables = "continent",
     .fun = function(x) mean(x$gdp)
    )
    ddply(
     .data = calcGDP(gapminder),
     .variables = c("continent", "year"),
     .fun = function(x) mean(x$gdp)
    )
    daply(
     .data = calcGDP(gapminder),
     .variables = c("continent", "year"),
     .fun = function(x) mean(x$gdp)
    )
    d_ply(
      .data=gapminder,
      .variables = "continent",
      .fun = function(x) {
        meanGDPperCap <- mean(x$gdpPercap)
        print(paste(
          "The mean GDP per capita for", unique(x$continent),
          "is", format(meanGDPperCap, big.mark=",")
       ))
      }
    )
    ddply(
      .data = gapminder,
      .variables = gapminder$continent,
      .fun = function(dataGroup) {
         mean(dataGroup$lifeExp)
      }
    )
    ddply(
      .data = gapminder,
      .variables = "continent",
      .fun = mean(dataGroup$lifeExp)
    )
    ddply(
      .data = gapminder,
      .variables = "continent",
      .fun = function(dataGroup) {
         mean(dataGroup$lifeExp)
      }
    )
    adply(
      .data = gapminder,
      .variables = "continent",
      .fun = function(dataGroup) {
         mean(dataGroup$lifeExp)
      }
    )
### 13: Dataframe Manipulation with dplyr
    mean(gapminder[gapminder$continent == "Africa", "gdpPercap"])
    mean(gapminder[gapminder$continent == "Americas", "gdpPercap"])
    mean(gapminder[gapminder$continent == "Asia", "gdpPercap"])
    install.packages('dplyr')
    library("dplyr")
    year_country_gdp <- select(gapminder,year,country,gdpPercap)
    year_country_gdp <- gapminder %>% select(year,country,gdpPercap)
    year_country_gdp_euro <- gapminder %>%
        filter(continent=="Europe") %>%
        select(year,country,gdpPercap)
    year_country_lifeExp_Africa <- gapminder %>%
                               filter(continent=="Africa") %>%
                               select(year,country,lifeExp)
    str(gapminder)
    str(gapminder %>% group_by(continent))
    gdp_bycontinents <- gapminder %>%
        group_by(continent) %>%
        summarize(mean_gdpPercap=mean(gdpPercap))
    lifeExp_bycountry <- gapminder %>%
       group_by(country) %>%
       summarize(mean_lifeExp=mean(lifeExp))
    lifeExp_bycountry %>% 
       filter(mean_lifeExp == min(mean_lifeExp) | mean_lifeExp == max(mean_lifeExp))
    lifeExp_bycountry %>%
       arrange(mean_lifeExp) %>%
       head(1)
    lifeExp_bycountry %>%
       arrange(desc(mean_lifeExp)) %>%
       head(1)
    gdp_bycontinents_byyear <- gapminder %>%
        group_by(continent,year) %>%
        summarize(mean_gdpPercap=mean(gdpPercap))
    gdp_pop_bycontinents_byyear <- gapminder %>%
        group_by(continent,year) %>%
        summarize(mean_gdpPercap=mean(gdpPercap),
                  sd_gdpPercap=sd(gdpPercap),
                  mean_pop=mean(pop),
                  sd_pop=sd(pop))
    gdp_pop_bycontinents_byyear <- gapminder %>%
        mutate(gdp_billion=gdpPercap*pop/10^9) %>%
        group_by(continent,year) %>%
        summarize(mean_gdpPercap=mean(gdpPercap),
                  sd_gdpPercap=sd(gdpPercap),
                  mean_pop=mean(pop),
                  sd_pop=sd(pop),
                  mean_gdp_billion=mean(gdp_billion),
                  sd_gdp_billion=sd(gdp_billion))
    # Get the start letter of each country
    starts.with <- substr(gapminder$country, start = 1, stop = 1)
    # Filter countries that start with "A" or "Z"
    az.countries <- gapminder[starts.with %in% c("A", "Z"), ]
    # Make the plot
    ggplot(data = az.countries, aes(x = year, y = lifeExp, color = continent)) +
      geom_line() + facet_wrap( ~ country)
    gapminder %>% 
       # Get the start letter of each country 
       mutate(startsWith = substr(country, start = 1, stop = 1)) %>% 
       # Filter countries that start with "A" or "Z"
       filter(startsWith %in% c("A", "Z")) %>%
       # Make the plot
       ggplot(aes(x = year, y = lifeExp, color = continent)) + 
       geom_line() + 
       facet_wrap( ~ country)
    gapminder %>%
        # Filter countries that start with "A" or "Z"
    	filter(substr(country, start = 1, stop = 1) %in% c("A", "Z")) %>%
    	# Make the plot
    	ggplot(aes(x = year, y = lifeExp, color = continent)) + 
    	geom_line() + 
    	facet_wrap( ~ country)
    lifeExp_2countries_bycontinents <- gapminder %>%
       filter(year==2002) %>%
       group_by(continent) %>%
       sample_n(2) %>%
       summarize(mean_lifeExp=mean(lifeExp)) %>%
       arrange(desc(mean_lifeExp))
### 14: Dataframe Manipulation with tidyr
    #install.packages("tidyr")
    #install.packages("dplyr")
    library("tidyr")
    library("dplyr")
    str(gapminder)
    gap_wide <- read.csv("data/gapminder_wide.csv", stringsAsFactors = FALSE)
    str(gap_wide)
    gap_long <- gap_wide %>%
        gather(obstype_year, obs_values, starts_with('pop'),
               starts_with('lifeExp'), starts_with('gdpPercap'))
    str(gap_long)
    gap_long <- gap_wide %>% gather(obstype_year,obs_values,-continent,-country)
    str(gap_long)
    gap_long <- gap_long %>% separate(obstype_year,into=c('obs_type','year'),sep="_")
    gap_long$year <- as.integer(gap_long$year)
    gap_long %>% group_by(continent,obs_type) %>%
       summarize(means=mean(obs_values))
    gap_normal <- gap_long %>% spread(obs_type,obs_values)
    dim(gap_normal)
    dim(gapminder)
    names(gap_normal)
    names(gapminder)
    gap_normal <- gap_normal[,names(gapminder)]
    all.equal(gap_normal,gapminder)
    head(gap_normal)
    head(gapminder)
    gap_normal <- gap_normal %>% arrange(country,continent,year)
    all.equal(gap_normal,gapminder)
    gap_temp <- gap_long %>% unite(var_ID,continent,country,sep="_")
    str(gap_temp)
    gap_temp <- gap_long %>%
        unite(ID_var,continent,country,sep="_") %>%
        unite(var_names,obs_type,year,sep="_")
    str(gap_temp)
    gap_wide_new <- gap_long %>%
        unite(ID_var,continent,country,sep="_") %>%
        unite(var_names,obs_type,year,sep="_") %>%
        spread(var_names,obs_values)
    str(gap_wide_new)
    gap_ludicrously_wide <- gap_long %>%
       unite(var_names,obs_type,year,country,sep="_") %>%
       spread(var_names,obs_values)
    gap_wide_betterID <- separate(gap_wide_new,ID_var,c("continent","country"),sep="_")
    gap_wide_betterID <- gap_long %>%
        unite(ID_var, continent,country,sep="_") %>%
        unite(var_names, obs_type,year,sep="_") %>%
        spread(var_names, obs_values) %>%
        separate(ID_var, c("continent","country"),sep="_")
    str(gap_wide_betterID)
    all.equal(gap_wide, gap_wide_betterID)
### 15: Producing Reports With knitr
