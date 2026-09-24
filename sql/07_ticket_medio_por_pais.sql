-- Responde: quais paises geram maior receita e ticket medio?

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
