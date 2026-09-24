-- Indicadores principais: sessoes, visitantes, pedidos, itens, receita e ticket medio.
-- As dimensoes de data, dispositivo e canal permitem o uso de filtros no dashboard.

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
