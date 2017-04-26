# 08 Creating Publication-Quality Graphics
csiu  



```
OBJECTIVES
- To be able to use ggplot2 to generate publication quality graphics.
- To understand the basic grammar of graphics, including the aesthetics and geometry layers, adding statistics, transforming scales, and coloring or panelling by groups.
```

## ggplot2

- built on the grammar of graphics, the idea that any plot can be expressed from the same set of components:
    - a data set
    - a coordinate system, and 
    - a set of geoms–the visual representation of data points
- think layers


```r
# Load package
library("ggplot2")

ggplot(data = gapminder,                   # data set
       aes(x = gdpPercap, y = lifeExp)) +  # coordinate system
  geom_point()                             # layer
```

- `aes` tell ggplot how variables are map to *aesthetic* properties of the figure

## customization

- Customizing aesthetics
    - setting *alpha* to change transparency
    - setting *size* to e.g. make lines thicker
- Customizing geometry
    - `geom_point()` to make scatter plot
    - `geom_line()` to make line plot
    - ...
- Customizing statistics
    - `geom_smooth(method="lm")` to fit simple relationship ie. linear model
- Customizing scale transformation
    - can change the *scale* of units e.g. `scale_x_log10()`
- Customizing grouping
    - `aes(group = ...)`

- `facet_wrap` to plot multi-panel figures
- Customize text
    - `xlab()` to change x label
    - `ylab()` to change y label
- `theme(...)` to change more stuff
