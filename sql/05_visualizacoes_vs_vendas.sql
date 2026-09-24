-- Compara o interesse nos produtos com a quantidade efetivamente vendida.
-- Utilizada no grafico de dispersao do dashboard.

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
