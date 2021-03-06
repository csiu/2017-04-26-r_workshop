# 01 Introduction to R and RStudio
csiu  



```
OBJECTIVES
- To gain familiarity with the various panes in the RStudio IDE
- To gain familiarity with the buttons, short cuts and options in the RStudio IDE
- To understand variables and how to assign to them
- To be able to manage your workspace in an interactive R session
- To be able to use mathematical and comparison operations
- To be able to call functions
- Introduction to package management
```

## Rstudio IDE

- layout, panes, buttons, running commands
- Running from scripts vs directly on console
- `>` for new command; `+` for continuation of command on previous line; `Esc` to exit

## Variables

- Use `<-` to assign values to variables (`=` works too, but this is less common in R users)
- Variable names
    - can contain letters, numbers, underscores and periods
    - **cannot** (1) start with a number nor (2) contain spaces at all.
    - conventions for long variable names:
        - periods.between.words
        - underscores_between_words
        - camelCaseToSeparateWords
    - be consistent

## Managing your workspace in an interactive R session

- look at Environment pane in RStudio
- `ls()` to list variables in a program
- `rm()` to delete objects in a program

## Math & Comparison operations

- BEDMAS
- scientific notation representation of very large/small numbers


```r
2/10000 # represented by 2e-04
```

- comparison operations:


```r
1 == 1  # equality (note two equals signs, read as "is equal to")
1 != 2  # inequality (read as "is not equal to")
1 <  2  # less than
1 <= 1  # less than or equal to
1 > 0   # greater than
1 >= -9 # greater than or equal to
```

## Package management

- there are a lot of packages (and you can write them too)
    - \>10,000 on CRAN
    - packages on github
- R and RStudio have functionality for managing packages:
    - You can see what packages are installed by typing `installed.packages()`


```r
# Let 'packagename' stand for a package

install.packages("packagename") # install package
update.packages("packagename")  # update installed package
remove.packages("packagename")  # remove package

library(packagename) # load package to make package available
```
