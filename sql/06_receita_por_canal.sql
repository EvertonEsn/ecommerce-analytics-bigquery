-- Responde: quais canais de aquisicao trazem mais sessoes, pedidos e receita?

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
