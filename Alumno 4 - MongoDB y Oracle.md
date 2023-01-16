# **ASGBD - Práctica Grupal 3: Usuarios**

## **Alumno 4 - MongoDB y Oracle**

**Tabla de contenidos:**

- [**ASGBD - Práctica Grupal 3: Usuarios**](#asgbd---práctica-grupal-3-usuarios)
  - [**Alumno 4 - MongoDB y Oracle**](#alumno-4---mongodb-y-oracle)
  - [**MongoDB**](#mongodb)
    - [**Ejercicio 1**](#ejercicio-1)
    - [**Ejercicio 2**](#ejercicio-2)
    - [**Ejercicio 3**](#ejercicio-3)
    - [**Ejercicio 4**](#ejercicio-4)
  - [**Oracle**](#oracle)
    - [**Preparación del escenario**](#preparación-del-escenario)
    - [**Ejercicio 1**](#ejercicio-1-1)
    - [**Ejercicio 2**](#ejercicio-2-1)

---

## **MongoDB**

### **Ejercicio 1**

> **1. Averigua si existe la posibilidad en MongoDB de limitar el acceso de un usuario a los datos de una colección determinada.**



### **Ejercicio 2**

> **2. Averigua si en MongoDB existe el concepto de privilegio del sistema y muestra las diferencias más importantes con ORACLE.**



### **Ejercicio 3**

> **3. Explica los roles por defecto que incorpora MongoDB y como se asignan a los usuarios.**



### **Ejercicio 4**

> **4. Explica como puede consultarse el diccionario de datos de MongoDB para saber que roles han sido concedidos a un usuario y qué privilegios incluyen.**



---

## **Oracle**

### **Preparación del escenario**

Pasos a seguir para dejar todo listo para hacer las comprobaciones de los siguientes dos ejercicios empezando desde una instalación limpia de Oracle 21c:

1. Entrar en SQLPlus como administrador.

2. Habilitar el modo script y la salida por pantalla, así como aumentar el tamaño de las líneas y páginas:

    ```sql
    ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
    SET LINESIZE 32000;
    SET PAGESIZE 400;
    SET SERVEROUTPUT ON;
    ```

3. Crear un usuario y una tabla. Además le daré algunos privilegios al usuario sobre la tabla:

    ```sql
    CREATE USER PRAC5 IDENTIFIED BY PRAC5;

    CREATE TABLE TABLAPRAC5 (
        ID NUMBER(10) NOT NULL,
        NOMBRE VARCHAR2(100) NOT NULL,
        PRIMARY KEY (ID)
    );

    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLAPRAC5 TO PRAC5;
    ```

    ![1](img/Alumno%204/Oracle/1.png)

4. Creo varios roles con sus privilegios y un procedimiento *tonto* sobre el que dar privilegio de ejecución a uno de estos roles:

    ```sql
    -- Creo el procedimiento:
    CREATE OR REPLACE PROCEDURE P_DUMMY IS
    BEGIN
        NULL;
    END P_DUMMY;
    /

    -- Creo los roles:
    CREATE ROLE R1_PRAC5;
    CREATE ROLE R2_PRAC5;
    CREATE ROLE R3_PRAC5;

    -- Asigno privilegios a los roles:
    GRANT EXECUTE ON P_DUMMY TO R1_PRAC5;
    GRANT ALTER ON TABLAPRAC5 TO R2_PRAC5;
    GRANT READ ON TABLAPRAC5 TO R3_PRAC5;

    -- Asigno los roles R1/R2_PRAC5 al usuario:
    GRANT R1_PRAC5, R2_PRAC5 TO PRAC5;
    
    -- Asigno el rol R3_PRAC5 al rol R2_PRAC5:
    GRANT R3_PRAC5 TO R2_PRAC5;
    ```

    ![2](img/Alumno%204/Oracle/2.png)

Hecho esto ya tendríamos todo listo para empezar con los ejercicios.

### **Ejercicio 1**

> **1. Realiza un procedimiento llamado *MostrarObjetosAccesibles* que reciba un nombre de usuario y muestre todos los objetos a los que tiene acceso.**

[Según los apuntes de Raúl sobre gestión de usuarios en Oracle](https://educacionadistancia.juntadeandalucia.es/centros/sevilla/mod/resource/view.php?id=105462), la tabla que hay que consultar para obtener los *GRANTS* de un usuario sobre un objeto es *DBA_TAB_PRIVS*. Esto es correcto, sin embargo, esta tabla también contiene los *GRANTS* sobre objetos de los roles, por lo que no será necesario consultar la tabla *DBA_ROLE_PRIVS* como indican los apuntes. Teniendo esto en cuenta, los pasos a seguir para resolver este ejercicio son los siguientes:

1. Ya que la tabla *DBA_TAB_PRIVS* contiene tanto usuarios como roles, tengo que detectar si se ha introducido el nombre de un usuario para evitar errores. Para ello, primero crearé un procedimiento que, en caso de recibir un usuario no existente devolverá un un *0*.

    ```sql
    -- Procedimiento P_USUARIO_EXISTE:
    CREATE OR REPLACE PROCEDURE P_USUARIO_EXISTE (P_USUARIO IN VARCHAR2, P_RESULTADO OUT NUMBER) IS
        CURSOR C_USUARIOS IS
            SELECT * FROM DBA_USERS
            WHERE USERNAME = P_USUARIO;
        VC_USUARIOS C_USUARIOS%ROWTYPE;
    BEGIN
        OPEN C_USUARIOS;
        FETCH C_USUARIOS INTO VC_USUARIOS;
        IF C_USUARIOS%NOTFOUND THEN
            P_RESULTADO := '0';
        END IF;
        CLOSE C_USUARIOS;
    END P_USUARIO_EXISTE;
    /

    -- Comprobaciones del procedimiento P_USUARIO_EXISTE:
    DECLARE
        VN_RESULTADO NUMBER;
    BEGIN
        P_USUARIO_EXISTE('PRAC5', VN_RESULTADO);
        DBMS_OUTPUT.PUT_LINE('El usuario PRAC5 existe, por lo que no devuelve nada' || VN_RESULTADO);
    END;
    /

    DECLARE
        VN_RESULTADO NUMBER;
    BEGIN
        P_USUARIO_EXISTE('NOEXISTE', VN_RESULTADO);
        DBMS_OUTPUT.PUT_LINE('- El usuario no existe, valor devuelto: ' || VN_RESULTADO);
    END;
    /

    DECLARE
        VN_RESULTADO NUMBER;
    BEGIN
        P_USUARIO_EXISTE('R1_PRAC5', VN_RESULTADO);
        DBMS_OUTPUT.PUT_LINE('- El usuario no existe, es un rol, valor devuelto: ' || VN_RESULTADO);
    END;
    /
    ```

    Captura de pantalla del procedimiento creado y sus comprobaciones:

    ![3](img/Alumno%204/Oracle/3.png)

2. A continuación, escribo un procedimiento que se encargue de obtener de forma iterativa los distintos roles que tiene un usuario, ya sean directos o indirectos (rol de rol, de nuevo, al contrario de lo que indican los apuntes, ambos tipos de roles se pueden hallar en *DBA_ROLE_PRIVS*, sin consultar *ROLE_ROLE_PRIVS*). El procedimiento abrirá un cursor de tipo [*SYS_REFCURSOR*](https://oracle-base.com/articles/misc/using-ref-cursors-to-return-recordsets#12c-updates) que obtendrá los roles directos e indirectos usando el operador jerárquico [*CONNECT_BY_ROOT*](https://www.youtube.com/watch?v=VSVm2GuY1l0). La raíz de la jerarquía (*START WITH*) será el usuario que se le pasa como parámetro, y los hijos serán los roles que tiene directa e indirectamente:

    ```sql
    -- Procedimiento P_BUSCAR_ROLES:
    CREATE OR REPLACE PROCEDURE P_BUSCAR_ROLES (P_USUARIO IN VARCHAR2, RC_ROLES OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN RC_ROLES FOR
            SELECT DISTINCT CONNECT_BY_ROOT GRANTEE AS GRANTED_USER, GRANTED_ROLE
            FROM DBA_ROLE_PRIVS
            START WITH GRANTEE = P_USUARIO
            CONNECT BY GRANTEE = PRIOR GRANTED_ROLE;
    END P_BUSCAR_ROLES;
    /

    -- Comprobación del procedimiento P_BUSCAR_ROLES:
    DECLARE
        RC_ROLES SYS_REFCURSOR;
        VV_GRANTED_USER DBA_TAB_PRIVS.GRANTEE%TYPE;
        VV_GRANTED_ROLE DBA_TAB_PRIVS.GRANTEE%TYPE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('+ Roles del usuario PRAC5:');
        P_BUSCAR_ROLES('PRAC5', RC_ROLES);
        LOOP
            FETCH RC_ROLES INTO VV_GRANTED_USER, VV_GRANTED_ROLE;
            EXIT WHEN RC_ROLES%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('- ' || VV_GRANTED_ROLE);
        END LOOP;
        CLOSE RC_ROLES;
    END;
    /
    ```

    Captura de pantalla del procedimiento creado y sus comprobaciones:

    ![4](img/Alumno%204/Oracle/4.png)

3. Ahora, creo un procedimiento que buscará en la tabla *DBA_TAB_PRIVS* los objetos a los cuales, el usuario (o rol) que le pasemos tiene acceso de forma directa:

    ```sql
    -- Procedimiento P_BUSCAR_OBJETOS_ACCESIBLES_DIRECTA:
    CREATE OR REPLACE PROCEDURE P_BUSCAR_OBJETOS_ACCESIBLES_DIRECTA (P_USUARIO_ROL IN VARCHAR2) IS
        CURSOR C_OBJETOS_ACCESIBLES IS
            SELECT * FROM DBA_TAB_PRIVS
            WHERE GRANTEE = P_USUARIO_ROL;
        VC_OBJETOS_ACCESIBLES C_OBJETOS_ACCESIBLES%ROWTYPE;
    BEGIN
        OPEN C_OBJETOS_ACCESIBLES;
        LOOP
            FETCH C_OBJETOS_ACCESIBLES INTO VC_OBJETOS_ACCESIBLES;
            EXIT WHEN C_OBJETOS_ACCESIBLES%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('- Nombre del objeto: ' || VC_OBJETOS_ACCESIBLES.TABLE_NAME || CHR(10) || '- Privilegio concedido: ' || VC_OBJETOS_ACCESIBLES.PRIVILEGE || CHR(10) || '- Propietario del objeto: ' || VC_OBJETOS_ACCESIBLES.OWNER || CHR(10) || '- Cedido por: ' || VC_OBJETOS_ACCESIBLES.GRANTOR || CHR(10) || '=================================================');
        END LOOP;
        CLOSE C_OBJETOS_ACCESIBLES;
    END P_BUSCAR_OBJETOS_ACCESIBLES_DIRECTA;
    /

    -- Comprobaciones del procedimiento P_BUSCAR_OBJETOS_ACCESIBLES_DIRECTA:
    BEGIN
        P_BUSCAR_OBJETOS_ACCESIBLES_DIRECTA('PRAC5');
    END;
    /

    BEGIN
        P_BUSCAR_OBJETOS_ACCESIBLES_DIRECTA('R1_PRAC5');
    END;
    /
    -- Aunque este último no es un usuario, debo comprobarlo para saber que el procedimiento podrá buscar los privilegios de un rol correctamente para usarlo más tarde.
    ```

    Capturas de pantalla del procedimiento creado y sus comprobaciones:

    ![5](img/Alumno%204/Oracle/5.png)

    ![6](img/Alumno%204/Oracle/6.png)

4. Por último, creo el procedimiento principal cuyo flujo de ejecución será el siguiente:

    1. Primero invocará al procedimiento *P_USUARIO_EXISTE*, si devuelve *0*, se invocará la excepción *EX_USUARIO_NO_EXISTE* con código de error *-20001*. En caso de no devolver *0*, se continuará la ejecución.

    2. Se invocará al procedimiento *P_BUSCAR_OBJETOS_ACCESIBLES_DIRECTA*, para pasándole el usuario recibido como parámetro, buscará los objetos a los cuales dicho usuario tiene acceso de forma directa.

    3. Se invocará al procedimiento *P_BUSCAR_ROLES*, para abrir el cursor *RC_ROLES*.

    4. Mientras haya datos en el cursor, se ejecutará el procedimiento *P_BUSCAR_OBJETOS_ACCESIBLES_DIRECTA*, pasándole como parámetro los roles que se están recorriendo con el cursor.

    5. Se cerrará el cursor *RC_ROLES*.

    ```sql
    -- Procedimiento P_MOSTRAR_OBJETOS_ACCESIBLES:
    CREATE OR REPLACE PROCEDURE P_MOSTRAR_OBJETOS_ACCESIBLES (P_USUARIO IN VARCHAR2) IS
        VN_RESULTADO NUMBER;
        RC_ROLES SYS_REFCURSOR;
        VV_GRANTED_USER DBA_TAB_PRIVS.GRANTEE%TYPE;
        VV_GRANTED_ROLE DBA_TAB_PRIVS.GRANTEE%TYPE;
        EX_USUARIO_NO_EXISTE EXCEPTION;
    BEGIN
        P_USUARIO_EXISTE(P_USUARIO, VN_RESULTADO);
        IF VN_RESULTADO = 0 THEN
            RAISE EX_USUARIO_NO_EXISTE;
        END IF;
        DBMS_OUTPUT.PUT_LINE('==== OBJETOS ACCESIBLES POR EL USUARIO ' || P_USUARIO || ' ====' || CHR(10) || '=================================================');
        P_BUSCAR_OBJETOS_ACCESIBLES_DIRECTA(P_USUARIO);
        P_BUSCAR_ROLES(P_USUARIO, RC_ROLES);
        LOOP
            FETCH RC_ROLES INTO VV_GRANTED_USER, VV_GRANTED_ROLE;
            EXIT WHEN RC_ROLES%NOTFOUND;
            P_BUSCAR_OBJETOS_ACCESIBLES_DIRECTA(VV_GRANTED_ROLE);
        END LOOP;
        CLOSE RC_ROLES;
    EXCEPTION
        WHEN EX_USUARIO_NO_EXISTE THEN
            RAISE_APPLICATION_ERROR(-20001, 'El usuario ' || P_USUARIO || ' no existe.');
    END P_MOSTRAR_OBJETOS_ACCESIBLES;
    /

    -- Comprobaciones del procedimiento principal P_MOSTRAR_OBJETOS_ACCESIBLES:
    EXEC P_MOSTRAR_OBJETOS_ACCESIBLES('PRAC5');

    EXEC P_MOSTRAR_OBJETOS_ACCESIBLES('JULIÁN');
    ```

    Capturas de pantalla del procedimiento principal y sus comprobaciones:

    ![7](img/Alumno%204/Oracle/7.png)

    ![8](img/Alumno%204/Oracle/8.png)

    Como se puede ver, el procedimiento muestra correctamente tanto los objetos accesibles de forma directa como los objetos accesibles a través de los roles recursivamente. Igualmente detecta cuando lo introducido no es un nombre de usuario existente.

---

### **Ejercicio 2**

> **2. Realiza un procedimiento que reciba un nombre de usuario, un privilegio y un objeto y nos muestre el mensaje 'SÍ, DIRECTO' si el usuario tiene ese privilegio sobre objeto concedido directamente, 'SÍ, POR ROL' si el usuario lo tiene en alguno de los roles que tiene concedidos y un 'NO' si el usuario no tiene dicho privilegio.**

Pasos a seguir teniendo en cuenta que se ha seguido la ejecución del [ejercicio anterior](#ejercicio-1-1):

1. De nuevo y por el mismo motivo que el explicado anteriormente, primero usaré un procedimiento para distinguir si lo pasado por parámetro es un usuario que existe (no devolverá nada) o que no existe (devolverá *0*). Esto ya lo hice en el [ejercicio anterior](#ejercicio-1-1) (procedimiento *P_USUARIO_EXISTE*), por lo que no volveré a redactarlo aquí.

2. Una vez que ya tengo la certeza de estar tratando con un usuario, creo un procedimiento que buscará en la tabla *DBA_TAB_PRIVS* el nombre del usuario (o rol, esto será útil para más tarde) y, si tiene el privilegio indicado sobre el objeto indicado, devolverá *1*, si no, no devolverá nada.

    ```sql
    -- Procedimiento P_BUSCAR_PRIVILEGIO:
    CREATE OR REPLACE PROCEDURE P_BUSCAR_PRIVILEGIO (P_USUARIO_ROL IN VARCHAR2, P_PRIVILEGIO IN VARCHAR2, P_OBJETO IN VARCHAR2, P_RESULTADO OUT NUMBER) IS
        CURSOR C_PRIVILEGIOS IS
            SELECT *
            FROM DBA_TAB_PRIVS
            WHERE GRANTEE = P_USUARIO_ROL
                AND PRIVILEGE = P_PRIVILEGIO
                AND TABLE_NAME = P_OBJETO;
        VC_PRIVILEGIOS C_PRIVILEGIOS%ROWTYPE;
    BEGIN
        OPEN C_PRIVILEGIOS;
        FETCH C_PRIVILEGIOS INTO VC_PRIVILEGIOS;
        IF C_PRIVILEGIOS%FOUND THEN
            P_RESULTADO := '1';
        END IF;
        CLOSE C_PRIVILEGIOS;
    END P_BUSCAR_PRIVILEGIO;
    /

    -- Comprobaciones del procedimiento P_BUSCAR_PRIVILEGIO:
    DECLARE
        VN_RESULTADO NUMBER;
    BEGIN
        P_BUSCAR_PRIVILEGIO('PRAC5', 'INSERT', 'TABLAPRAC5', VN_RESULTADO);
        DBMS_OUTPUT.PUT_LINE('- El usuario PRAC5 tiene el privilegio INSERT sobre la tabla TABLAPRAC5 de forma directa, valor devuelto: ' || VN_RESULTADO);
    END;
    /

    DECLARE
        VN_RESULTADO NUMBER;
    BEGIN
        P_BUSCAR_PRIVILEGIO('PRAC5', 'READ', 'TABLAPRAC5', VN_RESULTADO);
        DBMS_OUTPUT.PUT_LINE('- El usuario PRAC5 no tiene el privilegio READ sobre la tabla TABLAPRAC5, al menos de forma directa, por lo que no devuelve nada' || VN_RESULTADO);
    END;
    /

    DECLARE
        VN_RESULTADO NUMBER;
    BEGIN
        P_BUSCAR_PRIVILEGIO('R3_PRAC5', 'READ', 'TABLAPRAC5', VN_RESULTADO);
        DBMS_OUTPUT.PUT_LINE('- El rol R3_PRAC5 sí tiene el privilegio READ sobre la tabla TABLAPRAC5, valor devuelto: ' || VN_RESULTADO);
    END;
    /
    ```

    Captura de pantalla del procedimiento creado y sus comprobaciones:

    ![9](img/Alumno%204/Oracle/9.png)

3. Ahora, haré un procedimiento que obtendrá de forma iterativa los roles de un usuario, esto ya lo hice en el [ejercicio anterior](#ejercicio-1-1) (procedimiento *P_BUSCAR_ROLES*), por lo que no volveré a redactarlo aquí.

4. Por último, creo el procedimiento principal cuyo flujo de ejecución será el siguiente:

    1. Primero invocará al procedimiento *P_USUARIO_EXISTE*, si devuelve *0*, se invocará la excepción *EX_USUARIO_NO_EXISTE* con código de error *-20001*. En caso de no devolver *0*, se continuará la ejecución.

    2. Se invocará al procedimiento *P_BUSCAR_PRIVILEGIO*, si devuelve *1*, se invocará la excepción *EX_PRIVILEGIO_DIRECTO* que mediante un *DBMS_OUTPUT.PUT_LINE* escribirá 'SÍ, DIRECTO'. En caso de no devolver *1*, se continuará la ejecución.

    3. Se invocará al procedimiento *P_BUSCAR_ROLES*, para abrir el cursor *RC_ROLES*.

    4. Mientras haya datos en el cursor, se ejecutará el procedimiento *P_BUSCAR_PRIVILEGIO* pasándole el valor de la columna *GRANTED_ROLE* devuelta por el cursor, si devuelve *1*, se invocará la excepción *EX_PRIVILEGIO_POR_ROL* que mediante un *DBMS_OUTPUT.PUT_LINE* escribirá 'SÍ, POR ROL'. Si devuelve *0*, continuará la ejecución del procedimiento que al final invocará la excepción *EX_PRIVILEGIO_NO_EXISTE* que mediante *DBMS_OUTPUT.PUT_LINE* escribirá 'NO'.

    ```sql
    -- Procedimiento P_TIPO_PRIVILEGIO:
    CREATE OR REPLACE PROCEDURE P_TIPO_PRIVILEGIO (P_USUARIO IN VARCHAR2, P_PRIVILEGIO IN VARCHAR2, P_OBJETO IN VARCHAR2) IS
        VN_RESULTADO NUMBER;
        RC_ROLES SYS_REFCURSOR;
        VV_GRANTED_USER DBA_TAB_PRIVS.GRANTEE%TYPE;
        VV_GRANTED_ROLE DBA_TAB_PRIVS.GRANTEE%TYPE;
        EX_USUARIO_NO_EXISTE EXCEPTION;
        EX_PRIVILEGIO_DIRECTO EXCEPTION;
        EX_PRIVILEGIO_POR_ROL EXCEPTION;
        EX_PRIVILEGIO_NO_EXISTE EXCEPTION;
    BEGIN
        P_USUARIO_EXISTE(P_USUARIO, VN_RESULTADO);
        IF VN_RESULTADO = 0 THEN
            RAISE EX_USUARIO_NO_EXISTE;
        END IF;
        P_BUSCAR_PRIVILEGIO(P_USUARIO, P_PRIVILEGIO, P_OBJETO, VN_RESULTADO);
        IF VN_RESULTADO = 1 THEN
            RAISE EX_PRIVILEGIO_DIRECTO;
        END IF;
        P_BUSCAR_ROLES(P_USUARIO, RC_ROLES);
        LOOP
            FETCH RC_ROLES INTO VV_GRANTED_USER, VV_GRANTED_ROLE;
            EXIT WHEN RC_ROLES%NOTFOUND;
            P_BUSCAR_PRIVILEGIO(VV_GRANTED_ROLE, P_PRIVILEGIO, P_OBJETO, VN_RESULTADO);
            IF VN_RESULTADO = 1 THEN
                RAISE EX_PRIVILEGIO_POR_ROL;
            END IF;
        END LOOP;
        CLOSE RC_ROLES;
        RAISE EX_PRIVILEGIO_NO_EXISTE;
    EXCEPTION
        WHEN EX_USUARIO_NO_EXISTE THEN
            RAISE_APPLICATION_ERROR(-20001, 'El usuario ' || P_USUARIO || ' no existe.');
        WHEN EX_PRIVILEGIO_DIRECTO THEN
            DBMS_OUTPUT.PUT_LINE('SÍ, DIRECTO');
        WHEN EX_PRIVILEGIO_POR_ROL THEN
            DBMS_OUTPUT.PUT_LINE('SÍ, POR ROL');
        WHEN EX_PRIVILEGIO_NO_EXISTE THEN
            DBMS_OUTPUT.PUT_LINE('NO');
    END;
    /

    -- Comprobaciones del procedimiento P_TIPO_PRIVILEGIO:
    EXEC P_TIPO_PRIVILEGIO('PRAC5', 'SELECT', 'TABLAPRAC5');
    -- Imprimirá por pantalla: SÍ, DIRECTO

    EXEC P_TIPO_PRIVILEGIO('JULIAN', 'SELECT', 'TABLAPRAC5');
    -- Imprimirá por pantalla el error: ORA-20001: El usuario JULIAN no existe.

    EXEC P_TIPO_PRIVILEGIO('PRAC5', 'READ', 'TABLAPRAC5');
    -- Imprimirá por pantalla: SÍ, POR ROL

    EXEC P_TIPO_PRIVILEGIO('PRAC5', 'SELECT', 'TABLAPRAC6');
    -- Imprimirá por pantalla: NO
    ```

    Capturas de pantalla del procedimiento principal creado y de sus comprobaciones:

    ![10](img/Alumno%204/Oracle/10.png)

    ![11](img/Alumno%204/Oracle/11.png)

    El procedimiento indica correctamente si un privilegio sobre un objeto está concedido o no, y si lo está, si es de forma directa o a través de roles. Igualmente detecta cuando lo introducido no es un nombre de usuario existente.

---

✒️ **Documentación realizada por Juan Jesús Alejo Sillero.**
