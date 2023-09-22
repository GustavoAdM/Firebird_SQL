SET TERM ^ ;

CREATE OR ALTER FUNCTION TIRA_ACENTOS (
    PARAM_1 DOM_VARCHAR5000 COLLATE ISO8859_1 = '')
RETURNS TYPE OF DOM_VARCHAR5000
AS
DECLARE VARIABLE RETORNO TYPE OF DOM_VARCHAR5000 COLLATE ISO8859_1;
DECLARE VARIABLE V_COM_ACENTO TYPE OF DOM_VARCHAR60 COLLATE ISO8859_1 = '·„‡‚¡√¿¬ÚÛÙı“”‘’ÈËÍ»… ÌÏÕÃ˙˘˚⁄Ÿ€';
DECLARE VARIABLE V_SEM_ACENTO TYPE OF DOM_VARCHAR60 COLLATE ISO8859_1 = 'aaaaAAAAooooOOOOeeeEEEiiIIuuuUUU';
DECLARE VARIABLE V_LOOP_1 INTEGER;
DECLARE VARIABLE V_LOOP_2 INTEGER;
DECLARE VARIABLE V_TEM_ACENTO CHAR(1);
BEGIN
   RETORNO = '';
   V_LOOP_1 = 1;

   --[iniciando LOOP_1 do texto principal] --
   WHILE (V_LOOP_1 <= CHAR_LENGTH(:PARAM_1)) DO
   BEGIN

      V_LOOP_2 = 1;
      V_TEM_ACENTO = 'N';

      -- [iniciando LOOP_2 para verificar os acentos no texto] --
      WHILE (V_LOOP_2 <= CHAR_LENGTH(:V_COM_ACENTO)) DO
      BEGIN
         IF ((SUBSTRING(:PARAM_1 FROM V_LOOP_1 FOR 1)) = (SUBSTRING(:V_COM_ACENTO FROM V_LOOP_2 FOR 1))) THEN
         BEGIN
            RETORNO = RETORNO || SUBSTRING(:V_SEM_ACENTO FROM V_LOOP_2 FOR 1);
            V_TEM_ACENTO = 'S';
            LEAVE;
         END
         ELSE
         BEGIN
            V_LOOP_2 = V_LOOP_2 + 1;
         END
      END

      -- [Apos o fim do LOOP_2 n„o tiver acento, adicionar a letra]
      IF (V_TEM_ACENTO = 'N' ) THEN
      BEGIN
         RETORNO = RETORNO || SUBSTRING(:PARAM_1 FROM V_LOOP_1 FOR 1);
      END

      -- [incrementar valor ao LOOP_1] --
      V_LOOP_1 = V_LOOP_1 + 1;

   END
   RETURN RETORNO;
END^

SET TERM ; ^

/* Existing privileges on this procedure */

GRANT EXECUTE ON FUNCTION TIRA_ACENTOS TO SYSDBA;