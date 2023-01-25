# **ASGBD - Práctica Grupal 3: Usuarios**

## **Parte Grupal**

**Tabla de contenidos:**

- [**ASGBD - Práctica Grupal 3: Usuarios**](#asgbd---práctica-grupal-3-usuarios)
  - [**Parte Grupal**](#parte-grupal)
    - [**Caso Práctico 1**](#caso-práctico-1)
      - [**Ejercicio 1**](#ejercicio-1)
      - [**Ejercicio 2**](#ejercicio-2)
      - [**Ejercicio 3**](#ejercicio-3)
      - [**Ejercicio 4**](#ejercicio-4)
      - [**Ejercicio 5**](#ejercicio-5)

---

### **Caso Práctico 1**

#### **Ejercicio 1**

> **1. (Oracle, PostgreSQL, MySQL) Crea un usuario llamado Becario y, sin usar los roles de Oracle, dale los siguientes privilegios: (1,5 puntos)**
> 
> **- Conectarse a la base de datos.**
>
> **- Modificar el número de errores en la introducción de la contraseña de cualquier usuario.**
>
> **- Modificar índices en cualquier esquema (este privilegio podrá pasarlo a quien quiera)**
>
> **- Insertar filas en scott.emp (este privilegio podrá pasarlo a quien quiera)**
>
> **- Crear objetos en cualquier tablespace.**
>
> **- Gestión completa de usuarios, privilegios y roles.**

- **Oracle:**

    Creación del usuario:

    ```sql
    alter session set "_ORACLE_SCRIPT"=true;
    CREATE USER becario IDENTIFIED BY becario;
    ```

    Conectarse a la base de datos:

    ```sql
    GRANT CONNECT, CREATE SESSION TO becario;
    ```

    Modificar el número de errores en la introducción de la contraseña de cualquier usuario.

    Le asignamos permiso para que pueda crear roles:

    ```sql
    GRANT CREATE PROFILE TO becario;
    ```

    Creamos el perfil que nos permite asignarle el número del límite a 3:

    ```sql
    CREATE PROFILE limitepass LIMIT FAILED_LOGIN_ATTEMPTS 3;
    ```

    Le asignamos el perfil al usuario:

    ```sql
    ALTER USER becario PROFILE limitepass;
    ```

    Modificar índices en cualquier esquema (este privilegio podrá pasarlo a quien quiera).

    ```sql
    GRANT ALTER ANY INDEX TO becario WITH ADMIN OPTION;
    ```

    Insertar filas en scott.emp (este privilegio podrá pasarlo a quien quiera).

    ```sql
    GRANT INSERT ON SCOTT.EMP TO becario with GRANT OPTION;
    ```

    Crear objetos en cualquier tablespace.

    ```sql
    GRANT UNLIMITED TABLESPACE TO becario;
    ```

    Gestión completa de usuarios, privilegios y roles.

    Usuarios:

    ```sql
    GRANT CREATE USER,ALTER USER,DROP USER TO becario;
    ```

    Privilegios:

    ```sql
    GRANT ALL PRIVILEGES TO becario;
    ```

    Roles:

    ```sql
    GRANT CREATE ROLE TO becario;
    GRANT ALTER ANY ROLE TO becario;
    GRANT DROP ANY ROLE TO becario;
    GRANT GRANT ANY ROLE TO becario;
    ```

- **MySQL:**

    Creación del usuario:

    ```sql
    CREATE USER 'becario';
    ```

    Conectarse a la base de datos.

    ```sql
    GRANT USAGE ON *.* TO 'becario'@localhost IDENTIFIED BY 'becario';
    ```

    Modificar el número de errores en la introducción de la contraseña de cualquier usuario.

    ```sql
    ALTER USER 'becario'@'localhost' FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME UNBOUNDED;
    ```

    Modificar índices en cualquier esquema (este privilegio podrá pasarlo a quien quiera)

    ```sql
    GRANT ALTER,CREATE,DROP ON *.* TO 'becario'@'localhost' WITH GRANT OPTION;
    ```

    Insertar filas en scott.emp (este privilegio podrá pasarlo a quien quiera)

    ```sql
    GRANT INSERT ON depart TO 'becario'@'localhost' IDENTIFIED BY "becario" WITH GRANT OPTION;
    ```

    Crear objetos en cualquier tablespace.

    ```sql
    GRANT CREATE ON *.* TO 'becario'@'localhost';
    ```

    Gestión completa de usuarios, privilegios y roles.

    ```sql
    GRANT ALL PRIVILEGES ON *.* TO 'becario'@'localhost';
    ```

- **PostgreSQL:**

    Creación del usuario:

    ```sql
    CREATE USER becario WITH PASSWORD 'becario';
    ```

    Creación de la base de datos de prueba:

    ```sql
    CREATE DATABASE db1;
    ```

    Conectarse a la base de datos.

    ```sql
    GRANT CONNECT ON database db1 TO becario;
    ALTER ROLE becario WITH LOGIN;
    ```

    Modificar el número de errores en la introducción de la contraseña de cualquier usuario.

    Esta opción en PostgreSQL no existe como tal.

    Modificar índices en cualquier esquema (este privilegio podrá pasarlo a quien quiera)

    ```sql
    ALTER ROLE becario WITH SUPERUSER;
    ```

    Insertar filas en scott.emp (este privilegio podrá pasarlo a quien quiera)

    ```sql
    GRANT INSERT ON EMP TO 'becario'@'localhost' WITH GRANT OPTION;
    ```

    Crear objetos en cualquier tablespace.

    ```sql
    GRANT ALL PRIVILEGES ON *.* TO 'becario'@'localhost';
    ```

    Gestión completa de usuarios, privilegios y roles.

    Usuarios y privilegios:

    ```sql
    ALTER ROLE BECARIO WITH SUPERUSER;
    ```

    Roles:

    ```sql
    ALTER ROLE becario WITH CREATEROLE;
    ```

#### **Ejercicio 2**

> **2. (Oracle, PostgreSQL, MySQL) Escribe una consulta que obtenga un script para quitar el privilegio de borrar registros en alguna tabla de SCOTT a los usuarios que lo tengan.**

- **Oracle:**

    1. Comienzo creando el esquema SCOTT si no lo tuviera ya.

    2. Le doy a otro usuario el privilegio de borrar registros en la tabla EMP de SCOTT:

        ```sql
        GRANT DELETE ON SCOTT.EMP TO ALEMD;
        ```

    3. Ejecuto la consulta:

        ```sql
        SELECT 'REVOKE DELETE ON SCOTT.' || TABLE_NAME || ' FROM ' || GRANTEE || ';' FROM DBA_TAB_PRIVS WHERE OWNER = 'SCOTT' AND PRIVILEGE = 'DELETE';
        ```

        ![Ej2 - 1](img/Caso%20Pr%C3%A1ctico%201/Ej2%20-%201.png)

- **PostgreSQL:**

    1. Creo si es necesario las tablas del esquema SCOTT.

    2. Le asigno a varios usuarios el privilegio de borrar registros en la tabla EMP y DEPT:

        ```sql
        GRANT DELETE ON DEPT TO prueba;

        GRANT DELETE ON EMP TO postgres;

        GRANT DELETE ON DEPT TO postgres;
        ```

    3. Ejecutamos la siguiente consulta:

        ```sql
        SELECT 'REVOKE DELETE ON ' || TABLE_CATALOG || '.' || TABLE_NAME || ' FROM ' || GRANTEE || ';' FROM INFORMATION_SCHEMA.ROLE_TABLE_GRANTS WHERE TABLE_CATALOG = 'SCOTT' AND PRIVILEGE_TYPE = 'DELETE' AND TABLE_SCHEMA = 'PUBLIC';
        ```

        ![Ej2 - 3](img/Caso%20Pr%C3%A1ctico%201/Ej2%20-%203.png)

- **MySQL:**

    1. Creo si es necesario las tablas del esquema SCOTT.

    2. Creamos un usuario y le asignamos permisos delete:

        ```sql
        CREATE USER PRUEBA IDENTIFIED BY 'usuario';
        
        GRANT DELETE ON SCOTT.DEPT TO PRUEBA;
        ```

    3. Ejecutamos la siguiente consulta:

        ```sql
        SELECT CONCAT('REVOKE DELETE ON ', TABLE_SCHEMA, '.', TABLE_NAME, ' FROM ', GRANTEE, ';') AS SCRIPT FROM INFORMATION_SCHEMA.TABLE_PRIVILEGES WHERE TABLE_SCHEMA = 'SCOTT' AND PRIVILEGE_TYPE = 'DELETE';
        ```

        ![Ej2 - 2](img/Caso%20Pr%C3%A1ctico%201/Ej2%20-%202.png)

#### **Ejercicio 3**

> **3. (Oracle) Crea un tablespace TS2 con tamaño de extensión de 256K. Realiza una consulta que genere un script que asigne ese tablespace como tablespace por defecto a los usuarios que no tienen privilegios para consultar ninguna tabla de SCOTT, excepto a SYSTEM.**

Crear el tablespace TS2:

```sql
CREATE TABLESPACE TS2 DATAFILE 'ts2.dbf' SIZE 256k;
```

![Ej3 - 1](img/Caso%20Pr%C3%A1ctico%201/Ej3%20-%201.png)

Consulta que genera el script:

```sql
SELECT 'ALTER USER "'||USERNAME||'" DEFAULT TABLESPACE TS2;'
FROM DBA_USERS
WHERE USERNAME!='SYSTEM'
AND USERNAME NOT IN (SELECT GRANTEE 
                     FROM DBA_TAB_PRIVS 
                     WHERE PRIVILEGE='SELECT' 
                     AND OWNER='SCOTT');
```

![Ej3 - 2](img/Caso%20Pr%C3%A1ctico%201/Ej3%20-%202.png)

#### **Ejercicio 4**

> **4. (Oracle, PostgreSQL) Realiza un procedimiento que reciba un nombre de usuario y nos muestre cuántas sesiones tiene abiertas en este momento. Además, para cada una de dichas sesiones nos mostrará la hora de comienzo y el nombre de la máquina, sistema operativo y programa desde el que fue abierta.**

- **Oracle:**

    ```sql
    CREATE OR REPLACE PROCEDURE P_VERSESIONES(P_USER VARCHAR2) IS
        CURSOR C_SESIONES IS
            SELECT MACHINE AS MAQUINA, TO_CHAR(LOGON_TIME, 'YYYY/MM/DD HH24:MI') AS COMIENZO, PROGRAM AS PROGRAMA
            FROM V$SESSION
            WHERE USERNAME = P_USER;
        V_CONT NUMBER(2) := 1;
        V_RESULT NUMBER(2) := 0;
    BEGIN
        FOR V_SESION IN C_SESIONES LOOP
            DBMS_OUTPUT.PUT_LINE('SESION ' || V_CONT || '->');
            DBMS_OUTPUT.PUT_LINE('HORA DE COMIENZO: ' || V_SESION.COMIENZO);
            DBMS_OUTPUT.PUT_LINE('NOMBRE MÁQUINA: ' || V_SESION.MAQUINA);
            DBMS_OUTPUT.PUT_LINE('NOMBRE PROGRAMA: ' || V_SESION.PROGRAMA);
            V_CONT := V_CONT+1;
        END LOOP;
        V_RESULT := V_CONT - 1;
        DBMS_OUTPUT.PUT_LINE('TOTAL DE SESIONES ABIERTAS: ' || V_RESULT);
    END;
    /

    CREATE OR REPLACE PROCEDURE P_MUESTRACONEXIONES(P_USER VARCHAR2) IS
        V_VALIDAR NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('USUARIO: ' || P_USER);
        V_VALIDAR := F_COMPRUEBAUSUARIO(P_USER);
        P_VERSESIONES(P_USER);
    END;
    /

    CREATE OR REPLACE FUNCTION F_COMPRUEBAUSUARIO(P_USER VARCHAR2) RETURN NUMBER IS
        V_RESULTADO VARCHAR2(30);
    BEGIN
        SELECT USERNAME INTO V_RESULTADO
        FROM DBA_USERS
        WHERE USERNAME = P_USER;
        RETURN 0;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NO EXISTE EL USUARIO ' || P_USER);
            RETURN 1;
    END;
    /
    ```

    Para comprobarlo, abro varias sesiones con el mismo usuario y lo ejecuto:

    ![Ej4 - 3](img/Caso%20Pr%C3%A1ctico%201/Ej4%20-%203.png)

- **PostgreSQL:**

    ```sql
    CREATE OR REPLACE FUNCTION F_COMPRUEBAUSUARIO(P_USER VARCHAR)
    RETURNS INTEGER AS $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = P_USER) THEN
            RAISE EXCEPTION 'El usuario % no existe', P_USER;
        ELSE
            RETURN 1;
        END IF;
    END;
    $$ LANGUAGE plpgsql;

    CREATE OR REPLACE PROCEDURE P_VERSESIONES(P_USER VARCHAR) AS $$
    DECLARE
        V_REG record;
        V_SESIONINFO CURSOR FOR SELECT * FROM pg_stat_activity WHERE usename=P_USER and state is not null;
        V_COUNT INTEGER;
        V_VALIDAR INTEGER;
    BEGIN
        V_VALIDAR := F_COMPRUEBAUSUARIO(P_USER);
        V_COUNT := 0;
        RAISE NOTICE 'Información Sobre las sesiones del usuario %',P_USER;
        OPEN V_SESIONINFO;
        LOOP
            FETCH V_SESIONINFO INTO V_REG;
            EXIT WHEN NOT FOUND;
            V_COUNT := V_COUNT + 1;
            RAISE NOTICE 'El PID de la sesion es %, la aplicación que usa es %,la fecha y hora de inicio de sesion es %  y el tipo de cliente es: %', V_REG.pid, V_REG.application_name, V_REG. backend_start, V_REG.backend_type;
        END LOOP;
        CLOSE V_SESIONINFO;
        RAISE NOTICE 'Total de sesiones abiertas: %', V_COUNT;
    END;
    $$ LANGUAGE plpgsql;
    ```

    Para comprobarlo, primero voy a hacer que salte la excepción:

    ![Ej4 - 1](img/Caso%20Pr%C3%A1ctico%201/Ej4%20-%201.png)

    Ahora lo ejecuto con varias sesiones abiertas:

    ![Ej4 - 2](img/Caso%20Pr%C3%A1ctico%201/Ej4%20-%202.png)

#### **Ejercicio 5**

> **5. (Oracle) Realiza un procedimiento que muestre los usuarios que pueden conceder privilegios de sistema a otros usuarios y cuales son dichos privilegios.**

```sql
CREATE OR REPLACE PROCEDURE P_VER_USUARIO_DIRECTO (P_ROL IN VARCHAR2, P_PRIVILEGIO IN VARCHAR2) IS
    CURSOR C_USUARIOS IS
        SELECT GRANTEE
        FROM DBA_ROLE_PRIVS
        WHERE GRANTED_ROLE = P_ROL;
BEGIN
    FOR V_USUARIOS IN C_USUARIOS LOOP
        DBMS_OUTPUT.PUT_LINE('Usuario: ' || V_USUARIOS.GRANTEE || CHR(10) || 'Privilegio: ' || P_PRIVILEGIO || CHR(10) || '================================');
    END LOOP;
END P_VER_USUARIO_DIRECTO;
/

CREATE OR REPLACE PROCEDURE P_VER_USUARIO_INDIRECTO (P_ROL IN VARCHAR2, P_PRIVILEGIO IN VARCHAR2) IS
    CURSOR C_INDIRECTO IS
        SELECT GRANTEE
        FROM DBA_ROLE_PRIVS
        START WITH GRANTED_ROLE = P_ROL
        CONNECT BY GRANTED_ROLE = PRIOR GRANTEE;
    VN_TIPO_PRIVILEGIO NUMBER(1) := 0;
BEGIN
    SELECT COUNT(*) INTO VN_TIPO_PRIVILEGIO
    FROM ROLE_SYS_PRIVS
    WHERE ROLE = P_ROL
        AND PRIVILEGE = P_PRIVILEGIO;
    IF VN_TIPO_PRIVILEGIO != 0 THEN
        FOR V_INDIRECTO IN C_INDIRECTO LOOP
            P_VER_USUARIO_DIRECTO(V_INDIRECTO.GRANTEE, P_PRIVILEGIO);
        END LOOP;
    ELSE
        P_VER_USUARIO_DIRECTO(P_ROL, P_PRIVILEGIO);
    END IF;
END P_VER_USUARIO_INDIRECTO;
/

CREATE OR REPLACE PROCEDURE P_PRIVILEGIOS_SISTEMA_ROL IS
    CURSOR C_PRIVS IS
        SELECT GRANTEE, PRIVILEGE
        FROM DBA_SYS_PRIVS
        WHERE ADMIN_OPTION='YES'
            AND GRANTEE IN (SELECT ROLE
                            FROM DBA_ROLES);
    VN_INDIRECTO NUMBER(1) := 0;
BEGIN
    FOR V_PRIVS IN C_PRIVS LOOP
        SELECT COUNT(*) INTO VN_INDIRECTO
        FROM DBA_ROLE_PRIVS
        WHERE GRANTED_ROLE = V_PRIVS.GRANTEE;
        IF VN_INDIRECTO = 0 THEN
            P_VER_USUARIO_DIRECTO(V_PRIVS.GRANTEE, V_PRIVS.PRIVILEGE);
        ELSE
            P_VER_USUARIO_INDIRECTO(V_PRIVS.GRANTEE, V_PRIVS.PRIVILEGE);
        END IF;
    END LOOP;
END P_PRIVILEGIOS_SISTEMA_ROL;
/

CREATE OR REPLACE PROCEDURE P_PRIVILEGIOS_SISTEMA_DIRECTO IS
    CURSOR C_PRIV_SIST_DIRECTO IS
        SELECT GRANTEE, PRIVILEGE
        FROM DBA_SYS_PRIVS
        WHERE ADMIN_OPTION='YES'
            AND GRANTEE IN (SELECT USERNAME
                            FROM DBA_USERS);
BEGIN
    FOR V_PRIV_SIST_DIRECTO IN C_PRIV_SIST_DIRECTO LOOP
        DBMS_OUTPUT.PUT_LINE('Usuario: ' || V_PRIV_SIST_DIRECTO.GRANTEE || CHR(10) || 'Privilegio: ' || V_PRIV_SIST_DIRECTO.PRIVILEGE || CHR(10) || '================================');
    END LOOP;
END P_PRIVILEGIOS_SISTEMA_DIRECTO;
/

CREATE OR REPLACE PROCEDURE P_PRINCIPAL_PRIVILEGIOS_SISTEMA IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('==== USUARIOS QUE PUEDEN CONCEDER PRIVILEGIOS DE SISTEMA DE FORMA DIRECTA ====' || CHR(10) || '=================================================');
    P_PRIVILEGIOS_SISTEMA_DIRECTO;
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '==== USUARIOS QUE PUEDEN CONCEDER PRIVILEGIOS DE SISTEMA POR SUS ROLES ====' || CHR(10) || '=================================================');
    P_PRIVILEGIOS_SISTEMA_ROL;
END P_PRINCIPAL_PRIVILEGIOS_SISTEMA;
/

EXEC P_PRINCIPAL_PRIVILEGIOS_SISTEMA;
```

![Ej5 - 1](img/Caso%20Pr%C3%A1ctico%201/Ej5%20-%201.png)

![Ej5 - 2](img/Caso%20Pr%C3%A1ctico%201/Ej5%20-%202.png)

---

✒️ **Documentación realizada por Paco Diz Ureña.**

✒️ **Documentación realizada por Alejandro Montes Delgado.**

✒️ **Documentación realizada por Juan Jesús Alejo Sillero.**
