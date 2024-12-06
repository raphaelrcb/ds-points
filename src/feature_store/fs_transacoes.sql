WITH tb_transactions AS (
       
    SELECT *
    FROM transactions
    WHERE dtTransaction < '{date}'
    AND dtTransaction >= DATE('{date}', '-21 day')

),

tb_freq AS (

    SELECT
    idCustomer,
    COUNT(DISTINCT DATE(dtTransaction)) AS qtdeDiasD21,
    COUNT(DISTINCT CASE WHEN dtTransaction > DATE('{date}', '-14 day') THEN DATE(dtTransaction) END) AS qtdeDiasD14,
    COUNT(DISTINCT CASE WHEN dtTransaction > DATE('{date}', '-7 day') THEN DATE(dtTransaction) END) AS qtdeDiasD7

    FROM tb_transactions
    
    GROUP BY idCustomer
),

tb_live_minutes AS (SELECT  idCustomer,
        DATE(DATETIME(dtTransaction, '-3 hour')) as dtTransactionDate,
        MAX(DATETIME(dtTransaction, '-3 hour')) as dtFim,
        MIN(DATETIME(dtTransaction, '-3 hour')) as dtInit,

        (julianday(MAX(DATETIME(dtTransaction, '-3 hour'))) -
        julianday(MIN(DATETIME(dtTransaction, '-3 hour')))) * 24 * 60 AS liveMinutes
        
FROM tb_transactions

GROUP BY 1,2),

tb_hours AS (
    SELECT  idCustomer,
            AVG(liveMinutes) as avgLiveMinutes,
            SUM(liveMinutes) as sumLiveMinutes,
            MIN(liveMinutes) as minLiveMinutes,
            MAX(liveMinutes) as maxLiveMinutes

    FROM tb_live_minutes

    GROUP BY idCustomer
),

tb_vida AS (

    SELECT  
        idCustomer,
        COUNT(DISTINCT idTransaction) AS qtdeTransacaoVida,
        COUNT(DISTINCT idTransaction) / (MAX(julianday('{date}') - julianday(dtTransaction))) AS avgTransacaoDia

    FROM transactions
    WHERE dtTransaction < '{date}'
    GROUP BY idCustomer

),

tb_join as (
    SELECT t1.*,
        t2.avgLiveMinutes,
        t2.sumLiveMinutes,
        t2.minLiveMinutes,
        t2.maxLiveMinutes,
        t3.qtdeTransacaoVida,
        t3.avgTransacaoDia

    FROM tb_freq as t1

    LEFT JOIN tb_hours as t2
    ON t1.idCustomer = t2.idCustomer

    LEFT JOIN tb_vida as t3
    ON t1.idCustomer = t3.idCustomer
)

SELECT 
        '{date}' as dtRef, 
        * 
FROM tb_join 