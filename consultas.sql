-- Proyecto: Análisis de embudo y retención para MercadoLibre
-- Periodo analizado: 2025-01-01 a 2025-08-31


-- ============================================================
-- CONSULTA 1: Embudo de conversión por país
-- Porcentaje de usuarios que llega a cada etapa, sobre los usuarios de first_visit
-- ============================================================

WITH first_visits AS (
  -- Usuarios únicos por país que entraron por primera vez
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'first_visit'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
select_item AS (
  -- Usuarios que seleccionaron un producto o una promoción
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name IN ('select_item', 'select_promotion')
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_to_cart AS (
  -- Usuarios que agregaron al carrito
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'add_to_cart'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
begin_checkout AS (
  -- Usuarios que iniciaron el checkout
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'begin_checkout'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_shipping_info AS (
  -- Usuarios que ingresaron la información de envío
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'add_shipping_info'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_payment_info AS (
  -- Usuarios que ingresaron la información de pago
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'add_payment_info'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
purchase AS (
  -- Usuarios que completaron la compra
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'purchase'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
funnel_counts AS (
  -- Conteo de usuarios por etapa y país, partiendo de first_visits
  SELECT
    fv.country,
    COUNT(fv.user_id)  AS usuarios_first_visit,
    COUNT(si.user_id)  AS usuarios_select_item,
    COUNT(a.user_id)   AS usuarios_add_to_cart,
    COUNT(bc.user_id)  AS usuarios_begin_checkout,
    COUNT(asi.user_id) AS usuarios_add_shipping_info,
    COUNT(api.user_id) AS usuarios_add_payment_info,
    COUNT(p.user_id)   AS usuarios_purchase
  FROM first_visits AS fv
    LEFT JOIN select_item si        ON fv.user_id = si.user_id  AND fv.country = si.country
    LEFT JOIN add_to_cart a         ON fv.user_id = a.user_id   AND fv.country = a.country
    LEFT JOIN begin_checkout bc     ON fv.user_id = bc.user_id  AND fv.country = bc.country
    LEFT JOIN add_shipping_info asi ON fv.user_id = asi.user_id AND fv.country = asi.country
    LEFT JOIN add_payment_info api  ON fv.user_id = api.user_id AND fv.country = api.country
    LEFT JOIN purchase p            ON fv.user_id = p.user_id   AND fv.country = p.country
  GROUP BY fv.country
)
-- Conversión de cada etapa como porcentaje de los usuarios de first_visit
SELECT
  country,
  usuarios_select_item       * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_select_item,
  usuarios_add_to_cart       * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_add_to_cart,
  usuarios_begin_checkout    * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_begin_checkout,
  usuarios_add_shipping_info * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_add_shipping_info,
  usuarios_add_payment_info  * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_add_payment_info,
  usuarios_purchase          * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_purchase
FROM funnel_counts;


-- ============================================================
-- CONSULTA 2: Retención por cohorte mensual de registro
-- Porcentaje de usuarios con actividad al día 7, 14, 21 y 28 o después del registro
-- ============================================================

WITH cohort AS (
  -- Cohorte de cada usuario (YYYY-MM) según su primera fecha de registro
  SELECT
    user_id,
    TO_CHAR(DATE_TRUNC('month', MIN(signup_date)), 'YYYY-MM') AS cohort
  FROM mercadolibre_retention
  GROUP BY user_id
),
activity AS (
  -- Actividad de cada usuario con su cohorte, dentro del periodo analizado
  SELECT
    r.user_id,
    c.cohort,
    r.day_after_signup,
    r.active
  FROM mercadolibre_retention AS r
  LEFT JOIN cohort AS c
    ON r.user_id = c.user_id
  WHERE r.activity_date BETWEEN '2025-01-01' AND '2025-08-31'
)
-- Usuarios activos acumulados por hito, divididos entre el tamaño de la cohorte
SELECT
  cohort,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup >= 7  AND active = 1 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d7_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup >= 14 AND active = 1 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d14_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup >= 21 AND active = 1 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d21_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup >= 28 AND active = 1 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d28_pct
FROM activity
GROUP BY cohort
ORDER BY cohort;


-- ============================================================
-- CONSULTA 3: Tamaño de la muestra por país
-- Usuarios únicos con first_visit por país, para saber qué porcentajes se apoyan en pocos usuarios
-- ============================================================

SELECT
  country,
  COUNT(*) AS usuarios_first_visit
FROM (
  SELECT DISTINCT user_id, country
  FROM mercadolibre_funnel
  WHERE event_name = 'first_visit'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
) AS fv
GROUP BY country
ORDER BY usuarios_first_visit;
