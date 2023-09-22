/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                 Views                                  ***/
/******************************************************************************/


/* View: VIEW_NOTASAIDA_C176 */
CREATE OR ALTER VIEW VIEW_NOTASAIDA_C176(
    DT_EMISSAO,
    CLIENTE,
    ESTADO_DEST,
    QUANTIDADE,
    DS_ITEM,
    VL_UNITARIO,
    VL_TOTAL,
    BASE_ICMS_NORMAL,
    BASE_ICMS_ST,
    VL_ICMS_ST,
    CD_EMPRESA,
    EMPRESA_ORIG,
    LANCA_ORIG,
    SERIE_ORIG,
    NOTA_ORIG,
    ITEM_ORIG)
AS
WITH EMPRESAS
   AS (
      SELECT E.CD_EMPRESA, ME.SG_ESTADO
      FROM EMPRESA E
      INNER JOIN PESSOA PP ON (PP.CD_PESSOA = E.CD_PESSOA)
      INNER JOIN ENDERECOPESSOA EPP ON (EPP.CD_PESSOA = PP.CD_PESSOA
                                    AND EPP.CD_ENDERECO = 1)
      INNER JOIN MUNICIPIO ME ON (ME.CD_MUNICIPIO = EPP.CD_MUNICIPIO)
   )
SELECT
   N.DT_EMISSAO, P.NM_PESSOA CLIENTE, MU.SG_ESTADO ESTADO_DEST, COALESCE(IT.PS_ITEMNOTA, IT.QT_ITEMNOTA) QUANTIDADE,
   I.CD_ITEM||' - '||I.DS_ITEM DS_ITEM, IT.VL_UNITARIO, IT.VL_TOTAL, IPN.VL_BASE BASE_ICMS_NORMAL,
   IPN.VL_BASESUBST BASE_ICMS_ST, IPN.VL_SUBSTRIB VL_ICMS_ST, E.CD_EMPRESA,
   ------------------ EXTERNO -----------------------
   ITO.CD_EMPRESAORIGEM EMPRESA_ORIG, ITO.NR_LANCAMENTOORIGEM LANCA_ORIG, ITO.CD_SERIEORIGEM SERIE_ORIG,
   ITO.TP_NOTAORIGEM NOTA_ORIG, ITO.CD_ITEMORIGEM ITEM_ORIG

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
INNER JOIN IMPOSTONOTACTB IPN ON (IPN.CD_EMPRESA = IT.CD_EMPRESA
                           AND IPN.NR_LANCAMENTO = IT.NR_LANCAMENTO
                           AND IPN.TP_NOTA = IT.TP_NOTA
                           AND IPN.CD_SERIE = IT.CD_SERIE
                           AND IPN.SQ_ITEM = IT.SQ_ITEM)
INNER JOIN IMPOSTO IMP ON (IMP.CD_IMPOSTO = IPN.CD_IMPOSTO)
INNER JOIN EMPRESAS E ON (E.CD_EMPRESA = N.CD_EMPRESA
                      AND E.SG_ESTADO <> MU.SG_ESTADO)
INNER JOIN MODELONF MNF ON (MNF.CD_SERIE = N.CD_SERIE
                        AND MNF.CD_ESPECIE = N.CD_ESPECIE)
LEFT JOIN ITEMNOTAORIGEM ITO ON (ITO.CD_EMPRESADESTINO = IT.CD_EMPRESA
                              AND ITO.NR_LANCAMENTODESTINO = IT.NR_LANCAMENTO
                              AND ITO.TP_NOTADESTINO = IT.TP_NOTA
                              AND ITO.CD_SERIEDESTINO = IT.CD_SERIE
                              AND ITO.CD_ITEMDESTINO = IT.CD_ITEM)
WHERE IMP.TP_IMPOSTO = 'I'
   AND IMP.ST_SUBSTITUICAO = 'S'
   AND N.TP_NOTA = 'S'
   AND N.ST_NOTA = 'V'
   AND MNF.CD_MODELO IN (1, 55)
   AND M.TP_MOTIVOC176 NOT IN (0)
GROUP BY
   N.DT_EMISSAO, CLIENTE, ESTADO_DEST,
   DS_ITEM, IT.VL_UNITARIO, IT.VL_TOTAL, N.NR_LANCAMENTO, QUANTIDADE,
   BASE_ICMS_NORMAL , BASE_ICMS_ST, VL_ICMS_ST, E.CD_EMPRESA, E.SG_ESTADO,
   EMPRESA_ORIG, LANCA_ORIG, SERIE_ORIG, NOTA_ORIG, ITEM_ORIG, E.CD_EMPRESA
;




/******************************************************************************/
/***                               Privileges                               ***/
/******************************************************************************/
