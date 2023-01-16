--Realiza una función de verificación de contraseñas que compruebe que la contraseña difiere en más
--de tres caracteres de la anterior y que la longitud de la misma es diferente de la anterior. Asígnala al
--perfil CONTRASEÑASEGURA. Comprueba que funciona correctamente.

CREATE OR REPLACE FUNCTION F_VERIFYPASSWORD (P_USER VARCHAR2, P_PASSWDNEW VARCHAR2, P_PASSWDOLD VARCHAR2)
RETURN BOOLEAN
IS
    V_CUENTANUM NUMBER :=0;
    V_LETRAIGUAL NUMBER :=0;
    V_VALIDAR NUMBER :=0;
    V_REPETIDO NUMBER :=0;
    V_CUENTALETRA NUMBER :=0;
BEGIN
    P_MISMALONGITUD(P_PASSWDNEW, P_PASSWDOLD);
    FOR V_CONT IN 1..LENGTH(P_PASSWDNEW) LOOP
        P_CUENTANUMYLETRAS(SUBSTR(P_PASSWDNEW, V_CONT, 1), V_CUENTANUM, V_CUENTALETRA);
        P_COMPARACARACTERES(SUBSTR(P_PASSWDNEW, V_CONT, 1), P_PASSWDOLD, V_LETRAIGUAL);
        IF V_LETRAIGUAL=0 THEN
            V_REPETIDO:=V_REPETIDO + 1;
        END IF;
        V_LETRAIGUAL:=0;
    END LOOP;
    V_VALIDAR:= F_ERRORES(V_REPETIDO, V_CUENTANUM, V_CUENTALETRA);
    RETURN TRUE;
END;
/
CREATE OR REPLACE PROCEDURE P_MISMALONGITUD (P_PASSWDNEW VARCHAR2, P_PASSWDOLD VARCHAR2)
IS
BEGIN
    IF LENGTH(P_PASSWDNEW) = LENGTH(P_PASSWDOLD) THEN
        RAISE_APPLICATION_ERROR(-20100,'La nueva contraseña no puede tener la misma longitud que la anterior.');
    END IF;
END;
/
CREATE OR REPLACE FUNCTION F_ERRORES (P_REPE NUMBER, P_CUENTANUM NUMBER, P_CUENTALETRA NUMBER)
RETURN NUMBER
IS
BEGIN
    CASE
    WHEN P_REPE < 6 THEN
        RAISE_APPLICATION_ERROR(-20101,'La nueva contraseña debe de tener al menos 5 carácteres distintos');
    ELSE
        RETURN 1;
    END CASE;
END;
/
CREATE OR REPLACE PROCEDURE P_COMPARACARACTERES(P_CARACTER VARCHAR2, P_PASSWD VARCHAR2, P_LETRAIGUAL IN OUT VARCHAR2)
IS
BEGIN
    FOR V_CONT IN 1..LENGTH(P_PASSWD) LOOP
        IF SUBSTR(P_PASSWD,V_CONT,1)=P_CARACTER THEN
            P_LETRAIGUAL:=1;
        END IF;        
    END LOOP;
END;
/
CREATE OR REPLACE PROCEDURE P_CUENTANUMYLETRAS (P_CARACTER VARCHAR2, P_NUM IN OUT NUMBER, P_LETRA IN OUT NUMBER)
IS
BEGIN
    IF P_CARACTER=REGEXP_REPLACE(P_CARACTER,'[0-9]') THEN
        P_NUM := P_NUM + 1;
    ELSE 
        P_LETRA := P_LETRA +1;
    END IF;
END;
/

--Realiza un procedimiento llamado MostrarPrivilegiosdelRol que reciba el nombre de un rol y muestre los privilegios de sistema y los privilegios sobre objetos que lo componen.

CREATE OR REPLACE PROCEDURE P_MUESTRAPRIVROL (P_ROL VARCHAR2)
IS
    V_VALIDAR NUMBER:=0;
BEGIN
    V_VALIDAR:=F_EXISTSROL(P_ROL);
    IF V_VALIDAR=0 THEN
        P_BUSCASYSPRIV(P_ROL);
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('___________________________________________________');
        DBMS_OUTPUT.PUT_LINE(' ');
        P_BUSCAOBJECTPRIV(P_ROL);
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE P_BUSCASYSPRIV(P_ROL VARCHAR2)
IS
    CURSOR C_SYSPRIV
    IS
    SELECT DISTINCT PRIVILEGE
    FROM ROLE_SYS_PRIVS
    WHERE ROLE IN (SELECT DISTINCT ROLE 
                   FROM ROLE_ROLE_PRIVS 
                   START WITH ROLE=P_ROL
                   CONNECT BY ROLE = PRIOR GRANTED_ROLE)
    OR ROLE = P_ROL;
    V_SYS C_SYSPRIV%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('PRIVILEGIOS DEL SISTEMA');
    DBMS_OUTPUT.PUT_LINE('___________________________________________________');
    FOR V_SYS IN C_SYSPRIV LOOP
        DBMS_OUTPUT.PUT_LINE(V_SYS.PRIVILEGE);
    END LOOP;
END;
/


CREATE OR REPLACE PROCEDURE P_BUSCAOBJECTPRIV(P_ROL VARCHAR2)
IS
    CURSOR C_TABPRIV
    IS
    SELECT DISTINCT PRIVILEGE, TABLE_NAME, OWNER
    FROM ROLE_TAB_PRIVS
    WHERE ROLE IN (SELECT DISTINCT ROLE 
                   FROM ROLE_ROLE_PRIVS 
                   START WITH ROLE=P_ROL
                   CONNECT BY ROLE = PRIOR GRANTED_ROLE)
    OR ROLE = P_ROL;
    V_TAB C_TABPRIV%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('PRIVILEGIOS SOBRE OBJETOS');
    DBMS_OUTPUT.PUT_LINE('___________________________________________________');
    FOR V_TAB IN C_TABPRIV LOOP
        DBMS_OUTPUT.PUT_LINE(' EL USUARIO '||V_TAB.OWNER||' TIENE PRIVILEGIOS '||V_TAB.PRIVILEGE||' SOBRE LA TABLA '||V_TAB.TABLE_NAME);
    END LOOP;
END ;
/


CREATE OR REPLACE FUNCTION F_EXISTSROL(P_ROL VARCHAR2)
RETURN NUMBER
IS
    V_RESULTADO VARCHAR2(30);
BEGIN
    SELECT ROLE INTO V_RESULTADO
    FROM DBA_ROLES
    WHERE ROLE=P_ROL;
    RETURN 0;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('EL ROL '||P_ROL||' NO EXISTE.');
        RETURN -1;
END;
/

