-- View base utilizada por todas as analises do projeto.
-- Padroniza nomes, datas e valores monetarios para facilitar o uso no Looker Studio.

CREATE OR REPLACE VIEW
  `gen-lang-client-0299298088.ecommerce_portfolio.vw_base_dashboard` AS
SELECT
  PARSE_DATE('%Y%m%d', a.date) AS data,
  COALESCE(w.device.deviceCategory, 'Nao informado') AS dispositivo,
  COALESCE(a.channelGrouping, 'Nao informado') AS canal_aquisicao,
  COALESCE(a.country, 'Nao informado') AS pais,
  COALESCE(a.city, 'Nao informado') AS cidade,
  CONCAT(a.fullVisitorId, '-', CAST(a.visitId AS STRING)) AS id_sessao,
  a.fullVisitorId AS id_visitante,
  a.transactionId AS id_pedido,
  a.productSKU AS sku,
  a.v2ProductName AS produto,
  COALESCE(NULLIF(a.v2ProductCategory, ''), 'Sem categoria') AS categoria_produto,
  COALESCE(a.productQuantity, a.itemQuantity, 0) AS unidades,
  COALESCE(a.productRevenue, a.itemRevenue, 0) / 1000000 AS receita_produto,
  COALESCE(a.productPrice, 0) / 1000000 AS preco_produto,
  COALESCE(a.totalTransactionRevenue, a.transactionRevenue, 0) / 1000000 AS receita_transacao,
  a.eCommerceAction_type AS acao_ecommerce,
  a.eCommerceAction_step AS etapa_ecommerce,
  a.pageviews AS pageviews_sessao,
  a.timeOnSite AS tempo_no_site_segundos,
  a.sessionQualityDim AS qualidade_sessao,
  a.transactions AS transacoes_sessao
FROM `data-to-insights.ecommerce.all_sessions` AS a
LEFT JOIN `data-to-insights.ecommerce.web_analytics` AS w
  ON a.fullVisitorId = w.fullVisitorId
  AND a.visitId = w.visitId
  AND a.date = w.date;
