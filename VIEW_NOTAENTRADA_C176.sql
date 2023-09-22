/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                 Views                                  ***/
/******************************************************************************/


/* View: VIEW_NOTAENTRADA_C176 */
CREATE OR ALTER VIEW VIEW_NOTAENTRADA_C176(
    E_DT_EMISSAO,
    FORNECEDOR,
    E_DS_ITEM,
    E_VL_UNITARIO,
    E_VL_TOTAL,
    E_BASE_ICMS_NORMAL,
    E_BASE_ICMS_ST,
    E_VL_ICMS_NORMAL,
    E_VL_ICMS_ST,
    CD_EMPRESAORIG,
    NR_LANCAORIG,
    CD_SERIEORIG,
    TP_NOTAORIG,
    CD_ITEMORIG)
AS
SELECT
   N.DT_EMISSAO E_DT_EMISSAO, P.NM_PESSOA FORNECEDOR,
   I.CD_ITEM||' - '||I.DS_ITEM E_DS_ITEM, IT.VL_UNITARIO E_VL_UNITARIO, IT.VL_TOTAL E_VL_TOTAL, IPN.VL_BASE E_BASE_ICMS_NORMAL,
   IPN.VL_BASESUBST E_BASE_ICMS_ST, IPN.VL_IMPOSTO E_VL_ICMS_NORMAL ,IPN.VL_SUBSTRIB E_VL_ICMS_ST,

   N.CD_EMPRESA CD_EMPRESAORIG, N.NR_LANCAMENTO NR_LANCAORIG, N.CD_SERIE CD_SERIEORIG,
   N.TP_NOTA TP_NOTAORIG, IT.CD_ITEM CD_ITEMORIG

FROM NOTACTB N
INNER JOIN ITEMNOTACTB IT ON (IT.CD_EMPRESA = N.CD_EMPRESA
                       AND IT.NR_LANCAMENTO = N.NR_LANCAMENTO
                       AND IT.TP_NOTA = N.TP_NOTA
                       AND IT.CD_SERIE = N.CD_SERIE)
INNER JOIN MOVIMENTACAO M ON (M.CD_MOVIMENTACAO = IT.CD_MOVIMENTACAO)
INNER JOIN ITEM I ON (I.CD_ITEM = IT.CD_ITEM)
INNER JOIN PESSOA P ON (P.CD_PESSOA = N.CD_PESSOA)
INNER JOIN ENDERECOPESSOA EP ON (EP.CD_PESSOA = P.CD_PESSOA)
INNER JOIN MUNICIPIO MU ON (MU.CD_MUNICIPIO = EP.CD_MUNICIPIO)
LEFT JOIN IMPOSTONOTACTB IPN ON (IPN.CD_EMPRESA = IT.CD_EMPRESA
                           AND IPN.NR_LANCAMENTO = IT.NR_LANCAMENTO
                           AND IPN.TP_NOTA = IT.TP_NOTA
                           AND IPN.CD_SERIE = IT.CD_SERIE
                           AND IPN.SQ_ITEM = IT.SQ_ITEM)
LEFT JOIN IMPOSTO IMP ON (IMP.CD_IMPOSTO = IPN.CD_IMPOSTO)
INNER JOIN MODELONF MNF ON (MNF.CD_SERIE = N.CD_SERIE
                        AND MNF.CD_ESPECIE = N.CD_ESPECIE)

WHERE --IMP.TP_IMPOSTO = 'I'
--   AND IMP.ST_SUBSTITUICAO = 'S'
    N.TP_NOTA = 'E'
   AND N.ST_NOTA = 'V'
--   AND MNF.CD_MODELO IN (1, 55)
--   AND M.TP_MOTIVOC176 NOT IN (0)
GROUP BY
   E_DT_EMISSAO, FORNECEDOR,
   E_DS_ITEM, E_VL_UNITARIO, E_VL_TOTAL, N.NR_LANCAMENTO,
   E_BASE_ICMS_NORMAL , E_BASE_ICMS_ST, E_VL_ICMS_NORMAL, E_VL_ICMS_ST,
   CD_EMPRESAORIG, NR_LANCAORIG, CD_SERIEORIG, TP_NOTAORIG, CD_ITEMORIG
;




/******************************************************************************/
/***                               Privileges                               ***/
/******************************************************************************/
