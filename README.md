# Análisis de sentimientos en Twitter sobre la película "Ligthyear" en R

Para obtener el dataset de tweets que aparece incorporado en el repositorio se ha utilizado la herramienta: [`Twint`](https://github.com/twintproject/twint)

Twint es una herramienta que nos permite descargar tweets sin tener que autenticarnos, por lo que podemos obtener más tweets que los 100 que permite como máximo la API de Twitter. 

El entorno de instalación y los requisitos necesarios vienen en su propio repositorio especificados. La sentencia de extracción de la que se ha hecho uso para extraer el dataset es la siguiente: 

```sh
  twint -s Ligthyear -o tweetsLY.json --json
```

Con dicha extracción se obtiene un objeto JSON que se convertirá en data.frame y será sobre éste último donde se harán las transformaciones y los procesados necesarios. 

### Requisitos

R en versión 2022.02.3

Es necesario tener instalados los siguientes paquetes de R: 

* [reshape2]
* [wordcloud]
* [quanteda]
* [readtext]
* [tidytext]
* [rjson]
* [dplyr]
* [textdata]
* [ggplot2]

