# Análisis de embudo y retención para MercadoLibre: dónde se pierden los usuarios y cuándo dejan de volver

En resumen, este proyecto busca descubrir en qué etapa de la compra MercadoLibre pierde más usuarios y qué tan bien los retiene durante el primer mes después de registrarse, para decidir dónde conviene intervenir primero.

## Visuales

Solo el 1.25% de los usuarios que entran por primera vez termina comprando, y la mayor fuga está entre seleccionar un producto y agregarlo al carrito

La pérdida entre seleccionar y agregar al carrito va del 72% al 88% según el país

La retención cae de 86.6% en D7 a 2.6% en D28 de forma muy parecida en todas las cohortes

## Desafío

El director de producto del equipo de Crecimiento y Retención de MercadoLibre necesitaba entender en qué etapa se pierden más usuarios y cómo mejorar su retención en el tiempo. Había que responder tres cosas: la tasa de conversión entre cada etapa del embudo entre enero y agosto de 2025, cómo varía la pérdida por país, y qué porcentaje de los usuarios registrados entre el 1 de enero y el 1 de junio de 2025 sigue activo en D7, D14, D21 y D28.

## Datos

Dos tablas: mercadolibre_funnel (eventos de compra por usuario y sesión, con país, dispositivo y fuente de tráfico; 1,199 usuarios con primera visita entre enero y agosto de 2025) y mercadolibre_retention (actividad por usuario y día desde el registro). Análisis hecho en SQL y resumen ejecutivo en Google Sheets.

## Proceso

* Construcción del embudo de siete etapas (de first_visit a purchase) con CTEs, contando usuarios únicos por etapa
* Cálculo de la tasa de conversión entre etapas y de la caída porcentual en cada paso
* Desglose de la pérdida por país, verificando cuántos usuarios hay en cada uno para saber qué resultados se apoyan en una muestra pequeña
* Definición de la cohorte mensual de registro de cada usuario y cálculo de la retención acumulada en D7, D14, D21 y D28, también por país
* Resumen ejecutivo con el método Contexto → Hallazgo → Implicación

Nunca había trabajado con cohortes en SQL, así que ese fue el reto principal del proyecto. Aprender a agrupar a los usuarios por mes de registro y medir cuántos seguían activos días después fue lo que más me llevé.

## Resultado

* De cada 100 usuarios que entran por primera vez, solo 1.25 termina comprando
* La mayor caída del embudo está entre seleccionar un producto y agregarlo al carrito: se pierde el 85.68% de los usuarios (solo el 14.32% avanza)
* Las siguientes caídas más grandes son de carrito a checkout (63.64%), de pago a compra (40.0%) y de checkout a información de envío (39.58%)
* La pérdida entre seleccionar y agregar al carrito varía por país: Argentina (88.33%), Perú (88.17%) y Bolivia (88.00%) pierden más; Chile (77.63%) y Uruguay (72.22%) pierden menos. Paraguay (21 usuarios), Uruguay (22) y Bolivia (31) tienen muy pocos usuarios, por lo que sus resultados deben leerse con cautela
* Retención (usuarios con actividad al día indicado o después del registro), promedio simple de las cohortes de enero a junio: 86.63% en D7, 55.42% en D14, 24.95% en D21 y 2.63% en D28
* Los usuarios regresan en la primera semana, pero no consolidan el hábito: la caída fuerte ocurre entre D7 y D28
* Ecuador tiene la menor caída entre D7 y D28 (76.6 puntos) y Brasil la mayor (84.7 puntos), aunque en parte porque Ecuador parte de un D7 más bajo (79.1% frente a 87.2%)
* En D28 todos los países quedan entre 1.6% (Colombia) y 3.2% (Perú), por lo que la pérdida de usuarios después de la primera semana es un problema general y no de un mercado puntual
* La cohorte de agosto se ve mucho más baja porque sus usuarios no alcanzan a cumplir 28 días antes del corte del 31 de agosto, por lo que no se compara con las demás

## Recomendaciones / Siguientes pasos

1. Optimizar la página de producto, que es donde está la mayor fuga: aclarar precios y costos de envío, reforzar señales de confianza y simplificar el botón de agregar al carrito
2. Hacer pruebas A/B en Argentina y Perú, donde la pérdida es alta y hay usuarios suficientes para medir el efecto, y replicar las buenas prácticas de Chile
3. Reforzar la activación después del registro con recordatorios personalizados entre D14 y D28 e incentivos de recompra entre D14 y D21
4. Comparar Ecuador y Brasil para identificar qué prácticas se pueden replicar

## Entregable

Las imágenes de arriba muestran los resultados principales. El código SQL completo está en el archivo [consultas.sql](consultas.sql) de este repositorio, y el resumen ejecutivo con las tablas de cada pestaña está en Google Sheets: https://docs.google.com/spreadsheets/d/1vkOSEgHOT2cX2NfkAMLw4MwSo7G1T1gsfEYcVOHHXz0/edit?usp=drive_link
