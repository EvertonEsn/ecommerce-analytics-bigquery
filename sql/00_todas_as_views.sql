-- ============================================================
-- PROJETO: Google Merchandise Store - Analytics
-- Execute este arquivo completo no BigQuery usando GoogleSQL.
-- ============================================================

-- 1. Base padronizada para todas as analises
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

-- 2. Indicadores principais
CREATE OR REPLACE VIEW
  `gen-lang-client-0299298088.ecommerce_portfolio.vw_resumo_kpis` AS
SELECT
  data,
  dispositivo,
  canal_aquisicao,
  COUNT(DISTINCT id_sessao) AS sessoes,
  COUNT(DISTINCT id_visitante) AS visitantes,
  COUNT(DISTINCT id_pedido) AS pedidos,
  SUM(unidades) AS itens_vendidos,
  SUM(receita_produto) AS receita,
  SAFE_DIVIDE(SUM(receita_produto), COUNT(DISTINCT id_pedido)) AS ticket_medio
FROM `gen-lang-client-0299298088.ecommerce_portfolio.vw_base_dashboard`
GROUP BY data, dispositivo, canal_aquisicao;

-- 3. Receita por dispositivo
CREATE OR REPLACE VIEW
  `gen-lang-client-0299298088.ecommerce_portfolio.vw_receita_por_dispositivo` AS
SELECT
  data,
  dispositivo,
  canal_aquisicao,
  COUNT(DISTINCT id_pedido) AS pedidos,
  SUM(receita_produto) AS receita
FROM `gen-lang-client-0299298088.ecommerce_portfolio.vw_base_dashboard`
WHERE receita_produto > 0
GROUP BY data, dispositivo, canal_aquisicao;

-- 4. Receita por categoria de produto
CREATE OR REPLACE VIEW
  `gen-lang-client-0299298088.ecommerce_portfolio.vw_receita_por_categoria` AS
SELECT
  data,
  dispositivo,
  canal_aquisicao,
  categoria_produto,
  COUNT(DISTINCT id_pedido) AS pedidos,
  SUM(unidades) AS itens_vendidos,
  SUM(receita_produto) AS receita
FROM `gen-lang-client-0299298088.ecommerce_portfolio.vw_base_dashboard`
WHERE receita_produto > 0
GROUP BY data, dispositivo, canal_aquisicao, categoria_produto;

-- 5. Visualizacoes versus vendas por produto
CREATE OR REPLACE VIEW
  `gen-lang-client-0299298088.ecommerce_portfolio.vw_visualizacoes_vs_vendas` AS
SELECT
  data,
  dispositivo,
  canal_aquisicao,
  produto,
  COUNT(DISTINCT IF(acao_ecommerce = '2', id_sessao, NULL)) AS sessoes_com_visualizacao,
  COUNT(DISTINCT id_pedido) AS pedidos,
  SUM(unidades) AS unidades_vendidas,
  SUM(receita_produto) AS receita
FROM `gen-lang-client-0299298088.ecommerce_portfolio.vw_base_dashboard`
WHERE produto IS NOT NULL
  AND produto != ''
GROUP BY data, dispositivo, canal_aquisicao, produto
HAVING sessoes_com_visualizacao > 0
  OR unidades_vendidas > 0;

-- 6. Receita por canal de aquisicao
CREATE OR REPLACE VIEW
  `gen-lang-client-0299298088.ecommerce_portfolio.vw_receita_por_canal` AS
SELECT
  data,
  dispositivo,
  canal_aquisicao,
  COUNT(DISTINCT id_sessao) AS sessoes,
  COUNT(DISTINCT id_pedido) AS pedidos,
  SUM(receita_produto) AS receita,
  SAFE_DIVIDE(SUM(receita_produto), COUNT(DISTINCT id_pedido)) AS ticket_medio
FROM `gen-lang-client-0299298088.ecommerce_portfolio.vw_base_dashboard`
GROUP BY data, dispositivo, canal_aquisicao;

-- 7. Ticket medio por pais
CREATE OR REPLACE VIEW
  `gen-lang-client-0299298088.ecommerce_portfolio.vw_ticket_medio_por_pais` AS
SELECT
  data,
  dispositivo,
  canal_aquisicao,
  pais,
  COUNT(DISTINCT id_pedido) AS pedidos,
  SUM(receita_produto) AS receita,
  SAFE_DIVIDE(SUM(receita_produto), COUNT(DISTINCT id_pedido)) AS ticket_medio
FROM `gen-lang-client-0299298088.ecommerce_portfolio.vw_base_dashboard`
WHERE id_pedido IS NOT NULL
GROUP BY data, dispositivo, canal_aquisicao, pais;

-- 8. Carrinhos abandonados de alta intencao
CREATE OR REPLACE VIEW
  `gen-lang-client-0299298088.ecommerce_portfolio.vw_carrinhos_abandonados_alta_intencao` AS
WITH sessoes AS (
  SELECT
    data,
    dispositivo,
    canal_aquisicao,
    pais,
    id_sessao,
    MAX(qualidade_sessao) AS qualidade_sessao,
    COUNTIF(acao_ecommerce = '3') AS itens_adicionados,
    COUNT(DISTINCT id_pedido) AS pedidos,
    SUM(IF(acao_ecommerce = '3', preco_produto, 0)) AS valor_potencial_carrinho
  FROM `gen-lang-client-0299298088.ecommerce_portfolio.vw_base_dashboard`
  GROUP BY data, dispositivo, canal_aquisicao, pais, id_sessao
)
SELECT * EXCEPT(pedidos)
FROM sessoes
WHERE itens_adicionados > 0
  AND pedidos = 0
  AND qualidade_sessao >= 60;
