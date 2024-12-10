WITH tb_transactions_products AS (    
    SELECT  t1.*,
            t2.NameProduct,
            t2.QuantityProduct

    FROM transactions AS t1

    LEFT JOIN transactions_product AS t2
    ON t1.idTransaction = t2.idTransaction 

    WHERE t1.dtTransaction < '{date}'
    AND t1.dtTransaction >= DATE('{date}', '-21 day')
    ),

tb_share as (SELECT 

idCustomer,
SUM( CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) AS QtdeChatMessage,
SUM( CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END) AS QtdeListaDePresenca,
SUM( CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END) AS QtdeResgatarPonei,
SUM( CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END) AS QtdeTrocaDePontosStreamElements,
SUM( CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) AS QtdePresencaStreak,
SUM( CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) AS QtdeAirflowLover,
SUM( CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END) AS QtdeRLover,

SUM( CASE WHEN NameProduct = 'ChatMessage' THEN pointsTransaction ELSE 0 END) AS pointsChatMessage,
SUM( CASE WHEN NameProduct = 'Lista de presença' THEN pointsTransaction ELSE 0 END) AS pointsListaDePresenca,
SUM( CASE WHEN NameProduct = 'Resgatar Ponei' THEN pointsTransaction ELSE 0 END) AS pointsResgatarPonei,
SUM( CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN pointsTransaction ELSE 0 END) AS pointsTrocaDePontosStreamElements,
SUM( CASE WHEN NameProduct = 'Presença Streak' THEN pointsTransaction ELSE 0 END) AS pointsPresencaStreak,
SUM( CASE WHEN NameProduct = 'Airflow Lover' THEN pointsTransaction ELSE 0 END) AS pointsAirflowLover,
SUM( CASE WHEN NameProduct = 'R Lover' THEN pointsTransaction ELSE 0 END) AS pointsRLover,

1.0 * SUM( CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctChatMessage,
1.0 * SUM( CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctListaDePresenca,
1.0 * SUM( CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctResgatarPonei,
1.0 * SUM( CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctTrocaDePontosStreamElements,
1.0 * SUM( CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctPresencaStreak,
1.0 * SUM( CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctAirflowLover,
1.0 * SUM( CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctRLover,

SUM (CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / COUNT(DISTINCT DATE(dtTransaction)) AS avgChatLive

FROM tb_transactions_products

GROUP BY idCustomer),

tb_group AS (SELECT  idCustomer,
        NameProduct,
        SUM(QuantityProduct) as qtde,
        SUM(pointsTransaction) as points
FROM tb_transactions_products
GROUP BY idCustomer, NameProduct), 

tb_rn AS (
    
    SELECT  *,
            ROW_NUMBER() OVER (PARTITION BY idCustomer ORDER BY qtde DESC, points DESC)  as rnQtde
    FROM tb_group
    ORDER BY idCustomer
),

tb_produto_max as (

    SELECT * 
    FROM tb_rn 
    WHERE rnQtde = 1

) 

SELECT  
        '{date}' as dtRef,
        t1.*,
        t2.NameProduct as productMaxQtde

FROM tb_share as t1

LEFT JOIN tb_produto_max as t2
ON t1.idCustomer = t2.idCustomer