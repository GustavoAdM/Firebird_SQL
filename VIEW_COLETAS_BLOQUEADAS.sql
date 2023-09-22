/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                 Views                                  ***/
/******************************************************************************/


/* View: VIEW_COLETAS_BLOQUEADAS */
CREATE OR ALTER VIEW VIEW_COLETAS_BLOQUEADAS(
    CD_EMPRESA,
    NR_PEDIDO,
    NM_CLIENTE,
    DTEMISSAO,
    NM_VENDEDOR,
    QNTD,
    VL_COLETA,
    DT_BLOQUEIO,
    IDPESSOA,
    IDVENDEDOR,
    MT_BLOQUEIO)
AS
SELECT
     PP.IDEMPRESA CD_EMPRESA,PP.ID NR_PEDIDO, P.NM_PESSOA NM_CLIENTE, PP.DTEMISSAO DTEMISSAO,
     PV.NM_PESSOA NM_VENDEDOR, COUNT(IPP.ID) QNTD, SUM(IPP.VLUNITARIO) - COALESCE(SUM(IPP.VLDESCONTO), 0) VL_COLETA,
     PP.DTBLOQUEIO DT_BLOQUEIO, PP.IDPESSOA IDPESSOA, PP.IDVENDEDOR IDVENDEDOR,
     SUBSTRING(PP.DSBLOQUEIO FROM POSITION(']', PP.DSBLOQUEIO)+1) MT_BLOQUEIO
FROM PEDIDOPNEU PP
INNER JOIN ITEMPEDIDOPNEU IPP ON (IPP.IDPEDIDOPNEU = PP.ID)
INNER JOIN PESSOA P ON (P.CD_PESSOA = PP.IDPESSOA)
INNER JOIN PESSOA PV ON (PV.CD_PESSOA = PP.IDVENDEDOR)
WHERE PP.STPEDIDO = 'B'
     AND PP.IDEMPRESA = 1
GROUP BY CD_EMPRESA,NR_PEDIDO, NM_CLIENTE, DTEMISSAO, NM_VENDEDOR, DT_BLOQUEIO,
         IDPESSOA, IDVENDEDOR , MT_BLOQUEIO
ORDER BY DTEMISSAO
;




/******************************************************************************/
/***                               Privileges                               ***/
/******************************************************************************/


/* Privileges of views */
GRANT SELECT ON ITEMPEDIDOPNEU TO VIEW VIEW_COLETAS_BLOQUEADAS;
GRANT SELECT ON PEDIDOPNEU TO VIEW VIEW_COLETAS_BLOQUEADAS;
GRANT SELECT ON PESSOA TO VIEW VIEW_COLETAS_BLOQUEADAS;