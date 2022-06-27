library(quanteda)
library(readtext)
library(tidytext)
library(rjson)
library(dplyr)
library(textdata)
library(ggplot2)
library(reshape2)
library(wordcloud)
library(tidyverse)
library(naivebayes)
library(caret)
library("quanteda.sentiment")

#Carga de json
Lines <- readLines("tweetsLY.json") 
lineas <- as.data.frame(t(sapply(Lines, fromJSON)))

#Filtros para elegir los tweets en ingles 
lineas <- filter(lineas, language == "en")
tweets <- lineas["tweet"]
tweets$tweet <- as.character(tweets$tweet)

tweets_token <- unnest_tokens(tbl=tweets,
                              output = "word",
                              input = "tweet",
                              token = "words")

tweets_token <- anti_join(x=tweets_token,
                          y=stop_words,
                          by="word")

tweets_token <- filter(tweets_token, word != "https" &  word != "t.co")

tweet_tokens_senty <- tweets_token %>%
  inner_join(get_sentiments("bing"))

tweet_tokens_senty %>%
  count(word, sentiment, sort = TRUE) %>%
  spread(key = word, value = n)

tweet_tokens_senty %>%
  count(word, sentiment, sort = TRUE) %>%
  #Filtramos como minimo una distribucion de 100 datos
  filter(n > 100) %>%
  #Creamos una columna "n" en la cual clasificamos el sentimiento positivo con un numero positivo
  #y el sentimiento negativo con un numero negativo
  mutate(n = ifelse(sentiment == "positive", n, -n)) %>%
  #Ordenamos de mayor a menor agrupacion de palabras
  mutate(word = reorder(word, n)) %>%
  #Printeamos el grafico con la palabra y el sentimiento con un color
  ggplot(aes(word, n, fill = sentiment)) +
  #Imprimimos en columnas y le damos los atributos al grafico
  geom_col() +
  coord_flip() +
  labs(y = "Distribucion de numeros de palabras por sentimientos")

tweet_tokens_senty %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("orange", "green"),
                  title.size = 2,
                   title.colors = "blue",
                   max.words = 100)

corp <- corpus(tweets, text_field = "tweet")
tokens_t <- tokens(corp, remove_punct = TRUE, remove_symbols = TRUE, remove_numbers = TRUE)
tokens_t <- tokens_tolower(tokens_t)
tokens_t <- tokens_wordstem(tokens_t)
tokens_t <- tokens_select(tokens_t, stopwords("en"), selection = 'remove')
tokens_t <- tokens_lookup(tokens_t,data_dictionary_LSD2015[1:2], exclusive = FALSE, 
                          nested_scope = "dictionary")

tweetsDFM <- dfm(tokens_t)

random <- sample(1:30000, 10000, replace = FALSE)

docvars(tweetsDFM, "Tweet no") <-
  sprintf("%02d", 1:ndoc(tweetsDFM)) 


tweets_tr <- dfm_subset(tweetsDFM, tweetsDFM@docvars$`Tweet no` %in% random)
tweets_pr <- dfm_subset(tweetsDFM, !tweetsDFM@docvars$`Tweet no` %in% random)

#Creacion del modelo 
multi <- textmodel_nb(tweets_tr, docvars(tweets_tr, "Tweet no"), distribution = "multinomial")
summary(multi)
#Usamos el dfm de las predicciones con el modelo
pred <- predict(multi, newdata = tweets_pr)
#Crear la matriz de confusion
confM <- confusionMatrix(table(pred, as.factor(tweets_pr@docvars$`Tweet no`)),mode = "everything")
 

