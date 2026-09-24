-- Identifica sessoes de alta intencao que adicionaram produtos ao carrinho,
-- mas nao concluiram nenhum pedido.

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
