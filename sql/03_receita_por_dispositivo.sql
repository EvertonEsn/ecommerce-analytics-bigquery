-- Responde: quais dispositivos geram mais pedidos e receita?

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
