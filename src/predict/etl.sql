
SELECT  
        t1.dtRef,
        t1.idCustomer,
        t1.recenciaDias,
        t1.Frequencia,
        t1.valorPoints,
        t1.idadeBaseDias,
        t1.flEmail,
        t3.qtdePointsManha,
        t3.qtdePointsTarde,
        t3.qtdePointsNoite,
        t3.pctPointsManha,
        t3.pctPointsTarde,
        t3.pctPointsNoite,
        t3.qtdePointsTransacoesManha,
        t3.qtdeTransacoesTarde,
        t3.qtdeTransacoesNoite,
        t3.pctTransacoesManha,
        t3.pctTransacoesTarde,
        t3.pctTransacoesNoite,
        t4.saldoPointsD21,
        t4.saldoPointsD14,
        t4.saldoPointsD7,
        t4.pointsAcumuladosD21,
        t4.pointsAcumuladosD14,
        t4.pointsAcumuladosD7,
        t4.pointsResgatadosD21,
        t4.pointsResgatadosD14,
        t4.pointsResgatadosD7,
        t4.saldoPoints,
        t4.pointsAcumuladosVida,
        t4.pointsResgatadosVida,
        t4.pointsPorDia,
        t5.QtdeChatMessage,
        t5.QtdeListaDePresenca,
        t5.QtdeResgatarPonei,
        t5.QtdeTrocaDePontosStreamElements,
        t5.QtdePresencaStreak,
        t5.QtdeAirflowLover,
        t5.QtdeRLover,
        t5.pointsChatMessage,
        t5.pointsListaDePresenca,
        t5.pointsResgatarPonei,
        t5.pointsTrocaDePontosStreamElements,
        t5.pointsPresencaStreak,
        t5.pointsAirflowLover,
        t5.pointsRLover,
        t5.pctChatMessage,
        t5.pctListaDePresenca,
        t5.pctResgatarPonei,
        t5.pctTrocaDePontosStreamElements,
        t5.pctPresencaStreak,
        t5.pctAirflowLover,
        t5.pctRLover,
        t5.avgChatLive,
        t5.productMaxQtde,
        t6.qtdeDiasD21,
        t6.qtdeDiasD14,
        t6.qtdeDiasD7,
        t6.avgLiveMinutes,
        t6.sumLiveMinutes,
        t6.minLiveMinutes,
        t6.maxLiveMinutes,
        t6.qtdeTransacaoVida,
        t6.avgTransacaoDia

FROM fs_general AS t1

LEFT JOIN fs_horario AS t3
ON t1.idCustomer = t3.idCustomer
AND t1.dtRef = t3.dtRef

LEFT JOIN fs_points AS t4
ON t1.idCustomer = t4.idCustomer
AND t1.dtRef = t4.dtRef

LEFT JOIN fs_produto AS t5
ON t1.idCustomer = t5.idCustomer
AND t1.dtRef = t5.dtRef

LEFT JOIN fs_transacoes AS t6
ON t1.idCustomer = t6.idCustomer
AND t1.dtRef = t6.dtRef

WHERE t1.dtRef = date('2024-06-07')