# 05 Exploring Data Frames
csiu  



```
OBJECTIVES
- Be able to add and remove rows and columns.
- Be able to remove rows with NA values.
- Be able to append two data frames
- Be able to articulate what a factor is and how to convert between factor and character.
- Be able to find basic properties of a data frames including size, class or type of the columns, names, and first few rows.
```



## Editing a data frame

- `cbind()` to add a new column to a data frame.
- `rbind()` to add a new row to a data frame.
-  key to remember when adding data to a data frame is that columns are vectors or factors, and rows are lists
- `na.omit()` to remove rows from a data frame with NA values.
- remove rows by minusing offending row


```r
cats[-4,]  # format is dataframe[row,column]
           # "-" to remove
```

## Converting between a factor & character

- when R creates a factor (as column in data frame), it only allows whatever is originally there when our data was first loaded else becomes NA
- `levels()` to explore that categories in a factor
- `as.character()` to convert column "coat" from factor to character:


```r
cats$coat <- as.character(cats$coat)
```


## Inspecting data frames


```r
gapminder <-
  read.csv("https://raw.githubusercontent.com/swcarpentry/r-novice-gapminder/gh-pages/_episodes_rmd/data/gapminder-FiveYearData.csv")


str(gapminder)
str(gapminder$country)

typeof(gapminder)
typeof(gapminder$year)
typeof(gapminder$country)

length(gapminder)

nrow(gapminder)
ncol(gapminder)
dim(gapminder)

head(gapminder)

colnames(gapminder)
rownames(gapminder)
```
