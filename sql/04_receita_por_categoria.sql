-- Responde: quais categorias de produto concentram vendas e receita?

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
