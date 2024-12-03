WITH tb_rfv AS (
    SELECT 
        idCustomer,
        
        CAST(min(julianday('2024-06-04') - julianday(dtTransaction))
                AS INTEGER) + 1 AS recenciaDias,
        
        COUNT(DISTINCT DATE(dtTransaction)) as Frequencia,

        SUM(CASE
                WHEN pointsTransaction > 0 THEN pointsTransaction 
            END) as pointsTotal

    FROM transactions

    WHERE dtTransaction < '2024-06-04'
    AND dtTransaction >= DATE('2024-06-04', '-21 day')

    GROUP BY idCustomer

),

tb_idade as 
(
SELECT 
    t1.idCustomer, 
    CAST(MAX(julianday('2024-06-04') - julianday(t2.dtTransaction))
                AS INTEGER) + 1 AS idadeBaseDias

FROM tb_rfv as t1

LEFT JOIN transactions as t2 
ON t1.idCustomer = t2.idCustomer

GROUP BY t2.idCustomer

)

SELECT 
    t1.*,
    t2.idadeBaseDias,
    t3.flEmail

FROM tb_rfv as t1 

LEFT JOIN tb_idade as t2
ON t1.idCustomer = t2.idCustomer

LEFT JOIN customers as t3
on t2.idCustomer = t3.idCustomer
