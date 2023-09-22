SET TERM ^ ;

CREATE OR ALTER PROCEDURE CUSTOVENDARNF006_FOLLOWUP (
    I_FILTRO VARCHAR(3000),
    I_TIPO VARCHAR(2),
    I_ORDER VARCHAR(3000),
    I_FILTRO2 VARCHAR(3000) = NULL)
RETURNS (
    NM_EMPRESA VARCHAR(75),
    CD_EMPRESA DOM_INTEGER,
    DT_EMISSAO DOM_DATE,
    NR_NOTAFISCAL DOM_INTEGER,
    NM_PESSOA VARCHAR(75),
    DS_ITEM VARCHAR(75),
    VL_TOTAL NUMERIC(18,6),
    VL_CUSTO NUMERIC(18,6),
    VL_TABCOMPRA NUMERIC(18,6),
    VL_COMISSAO DOM_NUMERIC15_2,
    VL_IMPOSTO DOM_NUMERIC15_2,
    VL_LUCRO NUMERIC(18,6),
    VL_LUCROTABCOMPRA NUMERIC(18,6),
    VL_LUCROLIQUIDO NUMERIC(18,6),
    VL_PERCENTLUCRO NUMERIC(18,6),
    VL_PERCENTLUCROTABCOMPRA NUMERIC(18,6),
    PC_LUCRO NUMERIC(18,2),
    NR_PEDIDOS DOM_VARCHAR5000,
    CD_PESSOA DOM_INTEGER,
    CD_ITEM DOM_INTEGER,
    CD_VENDEDOR DOM_INTEGER,
    NM_VENDEDOR DOM_VARCHAR240,
    QT_ITEMNOTA DOM_NUMERIC15_4,
    SG_UNIDMED DOM_VARCHAR3,
    PS_ITEMNOTA DOM_NUMERIC15_4,
    SG_UNIDALT DOM_VARCHAR3,
    VL_UNITARIO DOM_NUMERIC15_4,
    DS_CONDPAGTO DOM_VARCHAR60,
    DS_OBSERVACAO DOM_VARCHAR240,
    VL_IMPSEMICMS DOM_NUMERIC15_2,
    VL_ULTCUSTO DOM_NUMERIC15_4,
    VL_FRETE DOM_NUMERIC15_2,
    QUEBRAPESSOA DOM_VARCHAR100,
    PC_DESCONTO DOM_NUMERIC15_2)
AS
DECLARE VARIABLE V_CONSULTA VARCHAR(20000);
DECLARE VARIABLE V_CD_EMPRESA DOM_INTEGER;
DECLARE VARIABLE V_NR_LANCAMENTO DOM_INTEGER;
DECLARE VARIABLE V_CD_SERIE DOM_VARCHAR4;
DECLARE VARIABLE V_CD_ITEM DOM_INTEGER;
DECLARE VARIABLE V_CD_OPERACAO DOM_INTEGER;
DECLARE VARIABLE V_CD_TIPOLOCAL DOM_INTEGER;
DECLARE VARIABLE V_CD_LOCAL DOM_INTEGER;
DECLARE VARIABLE V_VL_TOTAL DOM_NUMERIC15_4;
DECLARE VARIABLE V_VL_ESTOQUE DOM_NUMERIC15_4;
DECLARE VARIABLE V_VL_IMPOSTO DOM_NUMERIC15_4;
DECLARE VARIABLE V_VL_COMISSAO DOM_NUMERIC15_2;
DECLARE VARIABLE V_VL_TABCOMPRA DOM_NUMERIC18_6;
DECLARE VARIABLE V_NR_PEDIDOS DOM_VARCHAR5000;
DECLARE VARIABLE V_NR_ITENS DOM_INTEGER;
DECLARE VARIABLE V_VL_FRETE DOM_NUMERIC15_2;
DECLARE VARIABLE V_TP_UNIDADE DOM_CHAR1;
DECLARE VARIABLE V_ST_DEVOLUCAO DOM_CHAR1;
DECLARE VARIABLE V_ST_VARIOSVENDEDORES DOM_CHAR1;
DECLARE VARIABLE V_CD_TABCOMPRA DOM_INTEGER;
DECLARE VARIABLE V_VENDEDORES DOM_VARCHAR500;
DECLARE VARIABLE V_SELECTVENDEDORES DOM_VARCHAR500;
begin
   -- Tipo do Relatorio
   -- A - Analítico;  S - Sintetico;  C - Analítico último custo estoque

   SELECT S.CD_EMPRESA
   FROM SESSAO S
   WHERE S.NR_CONEXAO = CURRENT_CONNECTION
   INTO :V_CD_EMPRESA;

   SELECT PF.CD_TABCOMPRA, PF.ST_VARIOSVENDEDORES
   FROM PARMFATUR PF
   WHERE PF.CD_EMPRESA = :V_CD_EMPRESA
   INTO :V_CD_TABCOMPRA, :V_ST_VARIOSVENDEDORES;

   if ( STRPOS('V', I_TIPO) > 0 ) then
   BEGIN
      V_SELECTVENDEDORES =
         '        COALESCE(V.CD_PESSOA, 0), ' ||
         '        COALESCE(COALESCE(V.CD_PESSOA,'''')||'' - ''|| V.NM_PESSOA, ''Sem Vendedor'')';

     I_ORDER = COALESCE(NULLIF(:I_ORDER,''),'ORDER BY 1')||', 14';

      IF(COALESCE(:V_ST_VARIOSVENDEDORES,'S') = 'S') THEN
      BEGIN
         V_VENDEDORES =
            'LEFT JOIN ITEMNOTAVENDEDOR ITV ON (ITV.CD_EMPRESA    = I.CD_EMPRESA '||
            '                               AND ITV.NR_LANCAMENTO = I.NR_LANCAMENTO '||
            '                               AND ITV.TP_NOTA  = I.TP_NOTA '||
            '                               AND ITV.CD_SERIE = I.CD_SERIE '||
            '                               AND ITV.CD_ITEM  = I.CD_ITEM) '||
            'LEFT JOIN TIPOVENDEDOR TP ON (TP.CD_TIPO = ITV.CD_TIPO) '||
            'LEFT JOIN PESSOA V ON (ITV.CD_VENDEDOR = V.CD_PESSOA) ';
      END ELSE
         V_VENDEDORES =
            'LEFT JOIN PESSOA V ON (N.CD_VENDEDOR = V.CD_PESSOA) ';
   END ELSE
      V_SELECTVENDEDORES =
         '       CAST(NULL AS INTEGER), ' ||
         '       CAST(NULL AS VARCHAR(80)) ';


   V_CONSULTA =
      ' SELECT N.CD_EMPRESA, N.NR_LANCAMENTO, N.CD_SERIE, ' ||
      '        N.DT_EMISSAO, N.NR_NOTAFISCAL, ' ||
      '        N.CD_PESSOA||''-''||PESSOA.NM_PESSOA QUEBRAPESSOA,' ||
      '        N.CD_PESSOA||''-''||PESSOA.NM_PESSOA,' ||
      '        N.CD_EMPRESA||''-''||EMPRESA.NM_EMPRESA,' ||
      '        N.CD_PESSOA, CONDPAGTO.DS_CONDPAGTO,' ||
      '        N.DS_OBSERVACAO, COUNT(I.CD_ITEM),M.ST_DEVOLUCAO' ||
      COALESCE(', '||V_SELECTVENDEDORES,'')||
      ' FROM NOTA N' ||
      ' INNER JOIN ITEMNOTA I ON (I.CD_EMPRESA = N.CD_EMPRESA' ||
      '                       AND I.NR_LANCAMENTO = N.NR_LANCAMENTO' ||
      '                       AND I.TP_NOTA = N.TP_NOTA' ||
      '                       AND I.CD_SERIE = N.CD_SERIE)' ||
      ' INNER JOIN MOVIMENTACAO M ON (M.CD_MOVIMENTACAO = I.CD_MOVIMENTACAO' ||
      '                           AND M.ST_DEVOLUCAO = ''N'' AND M.CD_TIPOCONTA IS NOT NULL)' ||
      ' INNER JOIN EMPRESA ON (EMPRESA.CD_EMPRESA = N.CD_EMPRESA)' ||
      COALESCE(V_VENDEDORES,'')||
      ' INNER JOIN PESSOA ON (PESSOA.CD_PESSOA = N.CD_PESSOA)' ||
      ' INNER JOIN CONDPAGTO ON (CONDPAGTO.CD_CONDPAGTO = N.CD_CONDPAGTO)' ||
      ' WHERE N.ST_NOTA = ''V'' '||
      '   AND N.TP_NOTA = ''S'' '||
      '   AND M.ST_DEVOLUCAO = ''N'' ' || coalesce(I_FILTRO,' ') || ' ' ||
      ' GROUP BY N.CD_EMPRESA, N.NR_LANCAMENTO, N.CD_SERIE,' ||
      '          N.DT_EMISSAO, N.NR_NOTAFISCAL,' ||
      '          PESSOA.NM_PESSOA, N.CD_PESSOA,' ||
      '          EMPRESA.NM_EMPRESA, N.CD_EMPRESA,' ||
      '          N.CD_PESSOA, CONDPAGTO.DS_CONDPAGTO,' ||
      '          N.DS_OBSERVACAO, M.ST_DEVOLUCAO' ||
      COALESCE(', '||V_SELECTVENDEDORES,'')||
      '' ||
      '   UNION ALL' ||
      '' ||
      ' SELECT N.CD_EMPRESA, N.NR_LANCAMENTO, N.CD_SERIE,' ||
      '        N.DT_EMISSAO, N.NR_NOTAFISCAL,' ||
      '        N.CD_PESSOA||''-''||PESSOA.NM_PESSOA QUEBRAPESSOA,' ||
      '        N.CD_PESSOA||''-''||PESSOA.NM_PESSOA,' ||
      '        N.CD_EMPRESA||''-''||EMPRESA.NM_EMPRESA,' ||
      '        N.CD_PESSOA, CONDPAGTO.DS_CONDPAGTO,' ||
      '        N.DS_OBSERVACAO, COUNT(I.CD_ITEM),M.ST_DEVOLUCAO' ||
       COALESCE(', '||V_SELECTVENDEDORES,'')||
      ' FROM NOTA N ' ||
      ' INNER JOIN ITEMNOTA I ON (I.CD_EMPRESA = N.CD_EMPRESA ' ||
      '                       AND I.NR_LANCAMENTO = N.NR_LANCAMENTO ' ||
      '                       AND I.TP_NOTA = N.TP_NOTA ' ||
      '                       AND I.CD_SERIE = N.CD_SERIE)' ||
      ' INNER JOIN MOVIMENTACAO M ON (M.CD_MOVIMENTACAO = I.CD_MOVIMENTACAO ' ||
      '                           AND M.CD_TIPOCONTA IS NOT NULL) ' ||
      ' INNER JOIN EMPRESA ON (EMPRESA.CD_EMPRESA = N.CD_EMPRESA) ' ||
      COALESCE(V_VENDEDORES,'')||
      ' INNER JOIN PESSOA ON (PESSOA.CD_PESSOA = N.CD_PESSOA) ' ||
      ' INNER JOIN CONDPAGTO ON (CONDPAGTO.CD_CONDPAGTO = N.CD_CONDPAGTO) ' ||
      ' WHERE N.ST_NOTA = ''V'' ' ||
      '   AND N.TP_NOTA = ''E'' '||
      '   AND M.ST_DEVOLUCAO = ''D'' ' || coalesce(I_FILTRO,' ') || ' '  ||
      ' GROUP BY N.CD_EMPRESA, N.NR_LANCAMENTO, N.CD_SERIE,' ||
      '          N.DT_EMISSAO, N.NR_NOTAFISCAL,' ||
      '          PESSOA.NM_PESSOA, N.CD_PESSOA,' ||
      '          EMPRESA.NM_EMPRESA, N.CD_EMPRESA,' ||
      '          N.CD_PESSOA, CONDPAGTO.DS_CONDPAGTO,' ||
      '          N.DS_OBSERVACAO,M.ST_DEVOLUCAO  ' ||
      COALESCE(', '||V_SELECTVENDEDORES,'')||
      COALESCE(I_ORDER,'');
   -- Cursor das Notas
   for
      EXECUTE STATEMENT :V_CONSULTA
      INTO :V_CD_EMPRESA, :V_NR_LANCAMENTO, :V_CD_SERIE,
           :DT_EMISSAO, :NR_NOTAFISCAL, :QUEBRAPESSOA,:NM_PESSOA, :NM_EMPRESA, :CD_PESSOA,
           :DS_CONDPAGTO, :DS_OBSERVACAO, :V_NR_ITENS, :V_ST_DEVOLUCAO, :CD_VENDEDOR, :NM_VENDEDOR

   do begin
      VL_TOTAL = 0;
      VL_CUSTO = 0;
      VL_IMPOSTO = 0;
      VL_LUCRO = 0;
      VL_TABCOMPRA = 0;
      VL_LUCROTABCOMPRA = 0;
      VL_COMISSAO = 0;
      vl_percentlucro = 0;
      VL_PERCENTLUCROTABCOMPRA = 0;
      NR_PEDIDOS = null;
      VL_FRETE = NULL;
      CD_EMPRESA = V_CD_EMPRESA;
      --- Busca todos os pedidos da nota
      for
         SELECT PN.NR_PEDIDO
         FROM PEDIDONOTA PN
         WHERE PN.NR_LANCAMENTO = :V_NR_LANCAMENTO
           AND PN.CD_EMPRESA = :V_CD_EMPRESA
           AND PN.TP_NOTA =  'S'
           AND PN.CD_SERIE  = :V_CD_SERIE
         GROUP BY PN.NR_PEDIDO
         ORDER BY PN.NR_PEDIDO
         INTO :V_NR_PEDIDOS
      do begin
         if ( Trim(V_NR_PEDIDOS) <> '') then
         begin
            if ( (Trim(NR_PEDIDOS) = '') or (NR_PEDIDOS is null) ) then
            begin
               NR_PEDIDOS = 'Pedidos.: '||Coalesce(V_NR_PEDIDOS,'');
            end
            else
               NR_PEDIDOS = Coalesce(NR_PEDIDOS,'') ||' - '|| Coalesce(V_NR_PEDIDOS,'');
         end
      end
      -----------------------------------------
     -- Verifica se é DEVOLUCAO
      IF( V_ST_DEVOLUCAO = 'N') THEN
      BEGIN
         V_CONSULTA =
            'SELECT N.CD_ITEM, M.CD_OPERACAO, L.CD_TIPOLOCAL, L.CD_LOCAL, N.VL_LIQUIDO, '||
            '       I.DS_ITEM||'' - ''||N.CD_ITEM, N.VL_COMISSAO, N.QT_ITEMNOTA, I.SG_UNIDMED, '||
            '       N.PS_ITEMNOTA, I.SG_UNIDALT, N.VL_UNITARIO, N.VL_FRETE, TC.TP_UNIDADE, '||
            '       ITC.VL_PRECO, '||
            '       CASE '||
            '         WHEN ((N.VL_TOTAL = 0) AND (N.VL_DESCONTO = 100) ) THEN  CAST(100 AS DOM_NUMERIC15_2) '||
            '         WHEN ((N.VL_TOTAL = 0) AND (COALESCE(N.VL_DESCONTO,0) = 0)) THEN CAST(0 AS DOM_NUMERIC15_2) '||
            '         WHEN (N.VL_TOTAL = 0) THEN CAST(0 AS DOM_NUMERIC15_2) '||
            '       ELSE '||
            '         CAST(COALESCE(100 - (((N.VL_TOTAL - N.VL_DESCONTO) * 100) / VL_TOTAL), 0) AS DOM_NUMERIC15_2) END PC_DESC '||
            'FROM ITEMNOTA N '||
            'LEFT JOIN ITEMNOTALOCAL L ON (L.CD_EMPRESA = N.CD_EMPRESA '||
            '                           AND L.NR_LANCAMENTO = N.NR_LANCAMENTO '||
            '                           AND L.TP_NOTA = N.TP_NOTA '||
            '                           AND L.CD_SERIE = N.CD_SERIE '||
            '                           AND L.CD_ITEM = N.CD_ITEM) '||
            'INNER JOIN ITEM I ON (I.CD_ITEM = N.CD_ITEM) '||
            'INNER JOIN TIPOCALCULO TC ON (TC.CD_TIPOCALCULO = I.CD_TIPOCALCULO) '||
            'INNER JOIN MOVIMENTACAO M ON (M.CD_MOVIMENTACAO = N.CD_MOVIMENTACAO '||
            '                          AND M.ST_DEVOLUCAO = ''N'' '||
            '                          AND M.CD_TIPOCONTA IS NOT NULL) '||
            'LEFT JOIN ITEMTABCOMPRA ITC ON (ITC.CD_TABCOMPRA = '|| :V_CD_TABCOMPRA ||
            '                            AND ITC.CD_ITEM = I.CD_ITEM) '||
            'WHERE N.CD_EMPRESA = '|| :V_CD_EMPRESA ||
            '  AND N.NR_LANCAMENTO = '|| :V_NR_LANCAMENTO ||
            '  AND N.TP_NOTA = ''S'' '||
            '  AND N.CD_SERIE = '''||:V_CD_SERIE||''''||
            coalesce(I_FILTRO2,' ')||' '||
            'ORDER BY I.DS_ITEM';

         for
            EXECUTE STATEMENT V_CONSULTA
            INTO :V_CD_ITEM, :V_CD_OPERACAO, :V_CD_TIPOLOCAL,
                 :V_CD_LOCAL, :V_VL_TOTAL, :DS_ITEM, :V_VL_COMISSAO, :QT_ITEMNOTA, :SG_UNIDMED,
                 :PS_ITEMNOTA, :SG_UNIDALT, :VL_UNITARIO, :V_VL_FRETE, :V_TP_UNIDADE, :V_VL_TABCOMPRA, :PC_DESCONTO
         do begin

            CD_ITEM = :V_CD_ITEM;
            V_VL_ESTOQUE = 0;
            V_VL_IMPOSTO = 0;

            if ( V_TP_UNIDADE = 'Q' ) then
               V_VL_ESTOQUE = Coalesce(QT_ITEMNOTA,0) * Coalesce(V_VL_ESTOQUE,0);
            else
               V_VL_ESTOQUE = Coalesce(PS_ITEMNOTA,0) * Coalesce(V_VL_ESTOQUE,0);

            -- Busca o Custo do Produto
            if ( V_CD_OPERACAO is not null ) then
            begin
               SELECT SUM(E.VL_ESTOQUE)
               FROM MOVESTOQUE E
               WHERE E.CD_EMPRORIGEM = :V_CD_EMPRESA
                 AND E.NR_LANCTONOTA = :V_NR_LANCAMENTO
                 AND E.CD_SERIE = :V_CD_SERIE
                 AND E.TP_NOTA = 'S'
                 AND E.CD_ITEM = :V_CD_ITEM
                 AND E.CD_TIPOLOCAL = :V_CD_TIPOLOCAL
                 AND E.CD_LOCAL = :V_CD_LOCAL
                 --AND E.CD_OPERACAO = :V_CD_OPERACAO
                 AND E.TP_DOCUMENTO = 'NF'
               INTO :V_VL_ESTOQUE;
            end
            else begin
               SELECT X.O_VL_CUSTO
               FROM RETORNA_SALDOESTOQUE(:V_CD_EMPRESA, :V_CD_ITEM, :V_CD_TIPOLOCAL, :V_CD_LOCAL, :DT_EMISSAO) X
               INTO :V_VL_ESTOQUE;

            end

            if ( V_TP_UNIDADE = 'Q' ) then
            begin
               V_VL_TABCOMPRA = Coalesce(QT_ITEMNOTA,0) * Coalesce(V_VL_TABCOMPRA,0);
            end else
            begin
               V_VL_TABCOMPRA = Coalesce(PS_ITEMNOTA,0) * Coalesce(V_VL_TABCOMPRA,0);

            end
   
            -- Ultimo custo estoque
            if ( STRPOS('C', I_TIPO) > 0 ) then
          --  if ( I_TIPO = 'C' ) then
            begin
               SELECT COALESCE(X.O_VL_ULTIMOCUSTO,0)
               FROM RETORNA_SALDOESTOQUE(:V_CD_EMPRESA, :V_CD_ITEM, :V_CD_TIPOLOCAL, :V_CD_LOCAL, :DT_EMISSAO) X
               INTO :VL_ULTCUSTO;
               if ( V_TP_UNIDADE = 'Q' ) then
               begin
                  VL_ULTCUSTO = Coalesce(QT_ITEMNOTA,0) * Coalesce(VL_ULTCUSTO,0);

               end else
               begin
                  VL_ULTCUSTO = Coalesce(PS_ITEMNOTA,0) * Coalesce(VL_ULTCUSTO,0);
               end
            end
   
            -- Busca o Valor dos Impostos da Nota
            -- Valor Impostos + Substituição
           SELECT SUM(COALESCE(P.VL_IMPOSTO,0))
            FROM IMPOSTONOTA P
            INNER JOIN IMPOSTO ON (IMPOSTO.CD_IMPOSTO = P.CD_IMPOSTO)
            WHERE P.CD_EMPRESA = :V_CD_EMPRESA
              AND P.NR_LANCAMENTO = :V_NR_LANCAMENTO
              AND P.TP_NOTA = 'S'
              AND P.CD_SERIE = :V_CD_SERIE
              AND P.CD_ITEM = :V_CD_ITEM
              AND IMPOSTO.ST_IMPOSTONANOTA <> 'S'
            INTO :V_VL_IMPOSTO;
   
            -- Busca o Valor dos Impostos da Nota menos ICMS
            SELECT SUM(P.VL_IMPOSTO)
            FROM IMPOSTONOTA P
            INNER JOIN IMPOSTO ON (IMPOSTO.CD_IMPOSTO = P.CD_IMPOSTO)
            WHERE P.CD_EMPRESA = :V_CD_EMPRESA
              AND P.NR_LANCAMENTO = :V_NR_LANCAMENTO
              AND P.TP_NOTA = 'S'
              AND P.CD_SERIE = :V_CD_SERIE
              AND P.CD_ITEM = :V_CD_ITEM
              AND IMPOSTO.TP_IMPOSTO NOT IN ('I')
            INTO :VL_IMPSEMICMS;
   
            -- Se for Analitico mostra os Produtos da Nota
            if ((STRPOS('A', I_TIPO) > 0)
             or (STRPOS('C', I_TIPO) > 0 ))  then
           -- if ( I_TIPO IN ('A','C') ) then
            begin
               VL_TOTAL          = Coalesce(V_VL_TOTAL,0);
               VL_CUSTO          = Coalesce(V_VL_ESTOQUE,0);
               VL_IMPOSTO        = Coalesce(V_VL_IMPOSTO,0);
               VL_FRETE          = Coalesce(V_VL_FRETE,0);
               VL_TABCOMPRA      = Coalesce(V_VL_TABCOMPRA,0);
               VL_LUCRO          = Coalesce(VL_TOTAL,0) - Coalesce(VL_IMPOSTO,0) - Coalesce(VL_CUSTO,0) - Coalesce(VL_FRETE,0);
               VL_LUCROTABCOMPRA = Coalesce(VL_TOTAL,0) - Coalesce(VL_IMPOSTO,0) - Coalesce(VL_TABCOMPRA,0) - Coalesce(VL_FRETE,0);
               VL_LUCROLIQUIDO   = VL_TOTAL - VL_CUSTO;
   
               if ( (Coalesce(VL_CUSTO,0) > 0) or (Coalesce(VL_TOTAL,0) <> Coalesce(VL_LUCRO,0)) ) then
               begin
                  if (VL_LUCRO < 0) then
                  begin                                                
                     VL_PERCENTLUCRO = (Coalesce(VL_LUCRO,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),100);
                     VL_PERCENTLUCROTABCOMPRA = (Coalesce(VL_LUCROTABCOMPRA,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),100);
                     PC_LUCRO = (Coalesce(VL_LUCROLIQUIDO,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),100);
                  end
                  else
                  begin
                     VL_PERCENTLUCRO = (Coalesce(VL_LUCRO,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),1);
                     VL_PERCENTLUCROTABCOMPRA = (Coalesce(VL_LUCROTABCOMPRA,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),1);
                     PC_LUCRO = (Coalesce(VL_LUCROLIQUIDO,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),1);
                  end
               end
               else begin
                  VL_PERCENTLUCROTABCOMPRA = 100;
                  VL_PERCENTLUCRO = 100;
                  PC_LUCRO = 100;
               end
   
               Suspend;
            end
            else begin
               -- Sintético
               DS_ITEM = null;
               VL_TOTAL = Coalesce(VL_TOTAL,0) + Coalesce(V_VL_TOTAL,0);
               VL_CUSTO = Coalesce(VL_CUSTO,0) + Coalesce(V_VL_ESTOQUE,0);
               VL_IMPOSTO = Coalesce(VL_IMPOSTO,0) + Coalesce(V_VL_IMPOSTO,0);
               VL_TABCOMPRA  = Coalesce(V_VL_TABCOMPRA,0) + Coalesce(VL_TABCOMPRA,0);
               VL_LUCRO = Coalesce(VL_TOTAL,0) - Coalesce(VL_IMPOSTO,0) - Coalesce(VL_CUSTO,0) - Coalesce(VL_FRETE,0);
               VL_LUCROTABCOMPRA = Coalesce(VL_TOTAL,0) - Coalesce(VL_IMPOSTO,0) - Coalesce(VL_TABCOMPRA,0) - Coalesce(VL_FRETE,0);
               VL_LUCROLIQUIDO = Coalesce(VL_TOTAL,0) - Coalesce(VL_CUSTO,0);
               VL_COMISSAO = Coalesce(VL_COMISSAO,0) + Coalesce(V_VL_COMISSAO,0);
               VL_FRETE = Coalesce(VL_FRETE,0) + Coalesce(V_VL_FRETE,0);
   
               if ( (Coalesce(VL_CUSTO,0) > 0) or (VL_TOTAL <> VL_LUCRO) ) then
               begin
                  if (VL_LUCRO < 0) then
                  begin
                     VL_PERCENTLUCRO = (Coalesce(VL_LUCRO,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),100);
                     VL_PERCENTLUCROTABCOMPRA = (Coalesce(VL_LUCROTABCOMPRA,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),100);
                     PC_LUCRO = (Coalesce(VL_LUCROLIQUIDO,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),100);
                  end
                  else
                  begin
                     VL_PERCENTLUCRO = (Coalesce(VL_LUCRO,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),1);
                     VL_PERCENTLUCROTABCOMPRA = (Coalesce(VL_LUCROTABCOMPRA,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),1);
                     PC_LUCRO = (Coalesce(VL_LUCROLIQUIDO,0) * 100) / Coalesce(cast(NULLIF(VL_TOTAL,0)as numeric(18,5)),1);
                  end
               end
               else begin
                  VL_PERCENTLUCROTABCOMPRA = 100;
                  VL_PERCENTLUCRO = 100;
                  PC_LUCRO = 100;
               end
            end
         end
         if (STRPOS('S', I_TIPO) > 0 ) then
        -- if ( I_TIPO = 'S' ) then
         begin
            Suspend;
         end

      END
      ELSE
      BEGIN
      -- Devolucoes
         for
            SELECT N.CD_ITEM, M.CD_OPERACAO, L.CD_TIPOLOCAL, L.CD_LOCAL, N.VL_LIQUIDO,
                   I.DS_ITEM||' - '||N.CD_ITEM, N.VL_COMISSAO, N.QT_ITEMNOTA, I.SG_UNIDMED,
                   N.PS_ITEMNOTA, I.SG_UNIDALT, N.VL_UNITARIO, N.VL_FRETE, TC.TP_UNIDADE,
                   ITC.VL_PRECO,
                   CASE
                     WHEN ((N.VL_TOTAL = 0) AND (N.VL_DESCONTO = 100) ) THEN  CAST(100 AS DOM_NUMERIC15_2)
                     WHEN ((N.VL_TOTAL = 0) AND (COALESCE(N.VL_DESCONTO,0) = 0)) THEN CAST(0 AS DOM_NUMERIC15_2)
                     WHEN (N.VL_TOTAL = 0) THEN CAST(0 AS DOM_NUMERIC15_2)
                   ELSE
                     CAST(COALESCE(100 - (((N.VL_TOTAL - N.VL_DESCONTO) * 100) / VL_TOTAL), 0) AS DOM_NUMERIC15_2) END PC_DESC
            FROM ITEMNOTA N
            LEFT JOIN ITEMNOTALOCAL L ON (L.CD_EMPRESA = N.CD_EMPRESA
                                       AND L.NR_LANCAMENTO = N.NR_LANCAMENTO
                                       AND L.TP_NOTA = N.TP_NOTA
                                       AND L.CD_SERIE = N.CD_SERIE
                                       AND L.CD_ITEM = N.CD_ITEM)
            INNER JOIN ITEM I ON (I.CD_ITEM = N.CD_ITEM)
            INNER JOIN TIPOCALCULO TC ON (TC.CD_TIPOCALCULO = I.CD_TIPOCALCULO)
            INNER JOIN MOVIMENTACAO M ON (M.CD_MOVIMENTACAO = N.CD_MOVIMENTACAO
                                      AND M.ST_DEVOLUCAO = 'D'
                                      AND M.CD_TIPOCONTA IS NOT NULL)
            LEFT JOIN ITEMTABCOMPRA ITC ON (ITC.CD_TABCOMPRA = :V_CD_TABCOMPRA
                                        AND ITC.CD_ITEM = I.CD_ITEM)
            WHERE N.CD_EMPRESA = :V_CD_EMPRESA
              AND N.NR_LANCAMENTO = :V_NR_LANCAMENTO
              AND N.TP_NOTA = 'E'
              AND N.CD_SERIE = :V_CD_SERIE
            ORDER BY I.DS_ITEM
            INTO :V_CD_ITEM, :V_CD_OPERACAO, :V_CD_TIPOLOCAL,
                 :V_CD_LOCAL, :V_VL_TOTAL, :DS_ITEM, :V_VL_COMISSAO, :QT_ITEMNOTA, :SG_UNIDMED,
                 :PS_ITEMNOTA, :SG_UNIDALT, :VL_UNITARIO, :V_VL_FRETE, :V_TP_UNIDADE, :V_VL_TABCOMPRA, :PC_DESCONTO
         do begin
            CD_ITEM = :V_CD_ITEM;
            V_VL_ESTOQUE = 0;
            V_VL_IMPOSTO = 0;
   
            -- Busca o Custo do Produto
            if ( V_CD_OPERACAO is not null ) then
            begin
               SELECT SUM(E.VL_ESTOQUE)
               FROM MOVESTOQUE E
               WHERE E.CD_EMPRORIGEM = :V_CD_EMPRESA
                 AND E.NR_LANCTONOTA = :V_NR_LANCAMENTO
                 AND E.CD_SERIE = :V_CD_SERIE
                 AND E.TP_NOTA = 'E'
                 AND E.CD_ITEM = :V_CD_ITEM
                 AND E.CD_TIPOLOCAL = :V_CD_TIPOLOCAL
                 AND E.CD_LOCAL = :V_CD_LOCAL
                 --AND E.CD_OPERACAO = :V_CD_OPERACAO
                 AND E.TP_DOCUMENTO = 'NF'
               INTO :V_VL_ESTOQUE;
            end
            else
            begin
               SELECT X.O_VL_CUSTO
               FROM RETORNA_SALDOESTOQUE(:V_CD_EMPRESA, :V_CD_ITEM, :V_CD_TIPOLOCAL, :V_CD_LOCAL, :DT_EMISSAO) X
               INTO :V_VL_ESTOQUE;
               if ( V_TP_UNIDADE = 'Q' ) then
               begin
                  V_VL_TABCOMPRA = Coalesce(QT_ITEMNOTA,0) * Coalesce(V_VL_TABCOMPRA,0);
                  V_VL_ESTOQUE = Coalesce(QT_ITEMNOTA,0) * Coalesce(V_VL_ESTOQUE,0);
               end else
               begin
                 V_VL_TABCOMPRA = Coalesce(PS_ITEMNOTA,0) * Coalesce(V_VL_TABCOMPRA,0);
                  V_VL_ESTOQUE = Coalesce(PS_ITEMNOTA,0) * Coalesce(V_VL_ESTOQUE,0);
               end
            end
            -- Ultimo custo estoque
            if ( STRPOS('C', I_TIPO) > 0 ) then
            --if ( I_TIPO = 'C' ) then
            begin
               SELECT COALESCE(X.O_VL_ULTIMOCUSTO,0)
               FROM RETORNA_SALDOESTOQUE(:V_CD_EMPRESA, :V_CD_ITEM, :V_CD_TIPOLOCAL, :V_CD_LOCAL, :DT_EMISSAO) X
               INTO :VL_ULTCUSTO;
               if ( V_TP_UNIDADE = 'Q' ) then
                  VL_ULTCUSTO = Coalesce(QT_ITEMNOTA,0) * Coalesce(VL_ULTCUSTO,0);
               else
                  VL_ULTCUSTO = Coalesce(PS_ITEMNOTA,0) * Coalesce(VL_ULTCUSTO,0);
            end
            -- Busca o Valor dos Impostos da Nota
            -- Valor Impostos + Substituição
            SELECT SUM(Coalesce(P.VL_IMPOSTO,0) + Coalesce(P.VL_SUBSTRIB,0))
            FROM IMPOSTONOTA P
            WHERE P.CD_EMPRESA = :V_CD_EMPRESA
              AND P.NR_LANCAMENTO = :V_NR_LANCAMENTO
              AND P.TP_NOTA = 'S'
              AND P.CD_SERIE = :V_CD_SERIE
              AND P.CD_ITEM = :V_CD_ITEM
            INTO :V_VL_IMPOSTO;
            -- Busca o Valor dos Impostos da Nota menos ICMS
            SELECT SUM(P.VL_IMPOSTO)
            FROM IMPOSTONOTA P
            INNER JOIN IMPOSTO ON (IMPOSTO.CD_IMPOSTO = P.CD_IMPOSTO)
            WHERE P.CD_EMPRESA = :V_CD_EMPRESA
              AND P.NR_LANCAMENTO = :V_NR_LANCAMENTO
              AND P.TP_NOTA = 'S'
              AND P.CD_SERIE = :V_CD_SERIE
              AND P.CD_ITEM = :V_CD_ITEM
              AND IMPOSTO.TP_IMPOSTO NOT IN ('I')
            INTO :VL_IMPSEMICMS;
            -- Se for Analitico mostra os Produtos da Nota
            if ((STRPOS('A', I_TIPO) > 0)
             or (STRPOS('C', I_TIPO) > 0)  ) then
           -- if ( I_TIPO IN ('A','C') ) then
            begin
               VL_TOTAL          = Coalesce(V_VL_TOTAL,0);
               VL_CUSTO          = Coalesce(V_VL_ESTOQUE,0);
               VL_IMPOSTO        = Coalesce(V_VL_IMPOSTO,0);
               VL_FRETE          = Coalesce(V_VL_FRETE,0);
               VL_TABCOMPRA      = Coalesce(V_VL_TABCOMPRA,0);
               VL_LUCRO          = Coalesce(VL_TOTAL,0) - Coalesce(VL_IMPOSTO,0) - Coalesce(VL_CUSTO,0) - Coalesce(VL_FRETE,0);
               VL_LUCROTABCOMPRA = Coalesce(VL_TOTAL,0) - Coalesce(VL_IMPOSTO,0) - Coalesce(VL_TABCOMPRA,0) - Coalesce(VL_FRETE,0);
               VL_LUCROLIQUIDO = VL_TOTAL - VL_CUSTO;
   
               if ( (Coalesce(VL_CUSTO,0) > 0) or (Coalesce(VL_TOTAL,0) <> Coalesce(VL_LUCRO,0)) ) then
               begin
                  if (VL_LUCRO < 0) then
                  begin
                     VL_PERCENTLUCRO = (Coalesce(VL_LUCRO,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),100);
                     VL_PERCENTLUCROTABCOMPRA = (Coalesce(VL_LUCROTABCOMPRA,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),100);
                     PC_LUCRO = (Coalesce(VL_LUCROLIQUIDO,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),100);
                  end
                  else
                  begin
                     VL_PERCENTLUCRO = (Coalesce(VL_LUCRO,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),1);
                     VL_PERCENTLUCROTABCOMPRA = (Coalesce(VL_LUCROTABCOMPRA,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),1);
                     PC_LUCRO = (Coalesce(VL_LUCROLIQUIDO,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),1);
                  end
               end
               else begin
                  VL_LUCROTABCOMPRA = 100;
                  VL_PERCENTLUCRO = 100;
                  PC_LUCRO = 100;
               end


               VL_TOTAL          =   VL_TOTAL * (-1);
               VL_CUSTO          =   VL_CUSTO * (-1);
               VL_COMISSAO       =   VL_COMISSAO * (-1);
               VL_IMPOSTO        =   VL_IMPOSTO * (-1);
               VL_LUCRO          =   VL_LUCRO * (-1);
               VL_LUCROTABCOMPRA =   VL_LUCROTABCOMPRA * (-1);
               VL_LUCROLIQUIDO   =  VL_LUCROLIQUIDO * (-1);
               VL_PERCENTLUCRO   =  VL_PERCENTLUCRO * (-1);
               PC_LUCRO          =  PC_LUCRO * (-1);
               QT_ITEMNOTA       =  QT_ITEMNOTA * (-1);
               PS_ITEMNOTA       =  PS_ITEMNOTA * (-1);
               VL_UNITARIO       =  VL_UNITARIO * (-1);
               VL_IMPSEMICMS     =  VL_IMPSEMICMS * (-1);
               VL_ULTCUSTO       =  VL_ULTCUSTO * (-1);
               VL_FRETE          =  VL_FRETE  * (-1);
   
               Suspend;
            end
            else begin
               -- Sintético
               DS_ITEM = null;
               VL_TOTAL = (Coalesce(VL_TOTAL,0) + Coalesce(V_VL_TOTAL,0) );
               VL_CUSTO = Coalesce(VL_CUSTO,0) + Coalesce(V_VL_ESTOQUE,0);
               VL_IMPOSTO = Coalesce(VL_IMPOSTO,0) + Coalesce(V_VL_IMPOSTO,0);
               VL_TABCOMPRA  = Coalesce(V_VL_TABCOMPRA,0) + Coalesce(VL_TABCOMPRA,0);
               VL_LUCRO = Coalesce(VL_TOTAL,0) - Coalesce(VL_IMPOSTO,0) - Coalesce(VL_CUSTO,0) - Coalesce(VL_FRETE,0);
               VL_LUCROTABCOMPRA = Coalesce(VL_TOTAL,0) - Coalesce(VL_IMPOSTO,0) - Coalesce(VL_TABCOMPRA,0) - Coalesce(VL_FRETE,0);
               VL_LUCROLIQUIDO = Coalesce(VL_TOTAL,0) - Coalesce(VL_CUSTO,0);
               VL_COMISSAO = Coalesce(VL_COMISSAO,0) + Coalesce(V_VL_COMISSAO,0);
               VL_FRETE = Coalesce(VL_FRETE,0) + Coalesce(V_VL_FRETE,0);

               if ( (Coalesce(VL_CUSTO,0) > 0) or (VL_TOTAL <> VL_LUCRO) ) then
               begin
                  if (VL_LUCRO < 0) then
                  begin
                     VL_PERCENTLUCRO = (Coalesce(VL_LUCRO,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),100);
                     VL_PERCENTLUCROTABCOMPRA = (Coalesce(VL_LUCROTABCOMPRA,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),100);
                     PC_LUCRO = (Coalesce(VL_LUCROLIQUIDO,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),100);
                  end
                  else
                  begin
                     VL_PERCENTLUCRO = ((Coalesce(VL_LUCRO,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),1) );
                     VL_PERCENTLUCROTABCOMPRA = ((Coalesce(VL_LUCROTABCOMPRA,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),1) );
                     PC_LUCRO = ((Coalesce(VL_LUCROLIQUIDO,0) * 100) / Coalesce(NULLIF(VL_TOTAL,0),1) );
                  end
               end
               else begin
                  VL_LUCROTABCOMPRA = 100;
                  VL_PERCENTLUCRO = (100 ) ;
                  PC_LUCRO = (100 ) ;
               end
            end
         end
         if (STRPOS('S', I_TIPO) > 0) then
       --  IF ( I_TIPO = 'S' ) THEN
         BEGIN
            VL_TOTAL       =   VL_TOTAL * (-1);
            VL_CUSTO       =   VL_CUSTO * (-1);
            VL_COMISSAO    =   VL_COMISSAO * (-1);
            VL_IMPOSTO     =   VL_IMPOSTO * (-1);
            VL_LUCRO       =   VL_LUCRO * (-1);
            VL_LUCROTABCOMPRA =  VL_LUCROTABCOMPRA * (-1);
            VL_LUCROLIQUIDO =  VL_LUCROLIQUIDO * (-1);
            VL_PERCENTLUCRO =  VL_PERCENTLUCRO * (-1);
            PC_LUCRO        =  PC_LUCRO * (-1);
            QT_ITEMNOTA     =  QT_ITEMNOTA * (-1);
            PS_ITEMNOTA     =  PS_ITEMNOTA * (-1);
            VL_UNITARIO     =  VL_UNITARIO * (-1);
            VL_IMPSEMICMS   =  VL_IMPSEMICMS * (-1);
            VL_ULTCUSTO     =  VL_ULTCUSTO * (-1);
            VL_FRETE        =  VL_FRETE  * (-1);
            SUSPEND;
         END
      END


   end
end^

SET TERM ; ^

/* Following GRANT statements are generated automatically */

GRANT EXECUTE ON FUNCTION STRPOS TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON SESSAO TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON PARMFATUR TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON PEDIDONOTA TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON MOVESTOQUE TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT EXECUTE ON PROCEDURE RETORNA_SALDOESTOQUE TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON IMPOSTONOTA TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON IMPOSTO TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON ITEMNOTA TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON ITEMNOTALOCAL TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON ITEM TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON TIPOCALCULO TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON MOVIMENTACAO TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;
GRANT SELECT ON ITEMTABCOMPRA TO PROCEDURE CUSTOVENDARNF006_FOLLOWUP;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE CUSTOVENDARNF006_FOLLOWUP TO JUNSOFT;