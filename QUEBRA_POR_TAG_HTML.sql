SELECT
    N.CD_PESSOA CD_PES, P.NM_PESSOA,
    LIST('S�rie do Documento Fiscal: Nota Fiscal de Servi�os Eletr�nica - NFSe'||'</br>'||
         'Nota Eletr�nica de Servi�os: '||N.NR_NOTAFISCAL||'</br>'||
         'Chave de Identifica��o: '||NF.CD_AUTENTICACAO||'</br>'||
         'Recibo Provis�rio de Servi�os: '||NF.NR_RPS||'</br>'||
         'Data e Hora de Emiss�o: '||DATETOSTR( NF.DT_REGISTRO, '%d/%m/%Y %H:%M')||'</br>'||
         'Valor da NFSe/RPS: '||REPLACE(N.VL_CONTABIL,'.',',')||'</br>'||
         '</br>'||NF.DS_ENDERECOIMP||'</br>'||
         '--------------x--------------'||'</br>',
         ASCII_CHAR(10)) DS_NOTA

FROM NOTA N
INNER JOIN NFSE NF ON (NF.NR_LANCAMENTO = N.NR_LANCAMENTO
                   AND NF.CD_EMPRESA = N.CD_EMPRESA)
INNER JOIN PESSOA P ON (P.CD_PESSOA = N.CD_PESSOA)
WHERE N.CD_EMPRESA = 1
    AND N.CD_SERIE = '8'
    AND N.TP_NOTA = 'S'
    AND N.ST_NOTA = 'V'
    AND N.DT_EMISSAO >= CURRENT_DATE - 80
    AND P.DS_EMAIL IS NOT NULL
GROUP BY 1, 2