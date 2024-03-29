Sys.setlocale("LC_CTYPE", ".1251")
Sys.getlocale()

# finding the latest Sunday

# install.packages("lubridate")
library(lubridate)

findSunday <- function() {
  mday<-today()
  
  while (TRUE) {
    if(wday(mday)==1){
      return(mday)
    }else {mday<-mday-1}
  }
}


# get weekly meals table
# install.packages("stringr")
# install.packages("httr")

library(stringr)
library(httr)
library(rvest)

getMeals <- function() {
  
  lunch<-NULL
  dinner<-NULL
  mday <- findSunday()
  
  for (i in 1:7) {

    url<-str_c("https://www.kaist.ac.kr/kr/html/campus/053001.html?dvs_cd=seoul&stt_dt=", mday, sep="")
    
    html<- GET(url)
    html
    my_html<-read_html(html)
    meals<-html_nodes(my_html,"td" )
    meals<-html_text(meals)
    meals<-meals[-1] # no breakfast; aka bullshit

    # escape sequence termination
    meals<-gsub("[\t\n]", "", meals)
    meals<-str_replace_all(meals, "\r\r", replacement="")
    meals<-str_replace_all(meals, "\r", replacement="\n")
    
    meals[1] <-str_replace_all(meals[1], "- 4층 교직원식당 -(\n.*)*", "")
    meals[1] <-str_replace_all(meals[1], "- 2층 학생식당 -(\n)?", "")
    meals[1] <-str_replace_all(meals[1], "2코너", "\n2코너")
       
    meals[2] <-str_replace_all(meals[2], "- 2층 학생식당 -(\n)?", "")
    
    lunch[i] <-meals[1]
    dinner[i]<-meals[2]
    mday<-mday+1
  }
  mealTable<-t(data.frame(lunch, dinner))
  colnames(mealTable) <- c("SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT")
  
  return(data.frame(mealTable))
}

library(gridExtra)
library(ggplot2)
mealTable<-getMeals()

filename<-paste0(getwd(), "/table.png")
png(filename=filename, width=1000)
grid.table(mealTable, row=NULL, height= unit(c(100, 60), "mm"))
dev.off()