# **ASGBD - Práctica Grupal 3: Usuarios**

## **Parte Grupal**

**Tabla de contenidos:**

- [**ASGBD - Práctica Grupal 3: Usuarios**](#asgbd---práctica-grupal-3-usuarios)
  - [**Parte Grupal**](#parte-grupal)
    - [**Caso Práctico 2**](#caso-práctico-2)
      - [**Ejercicio 1**](#ejercicio-1)
      - [**Ejercicio 2**](#ejercicio-2)
      - [**Ejercicio 3**](#ejercicio-3)
      - [**Ejercicio 4**](#ejercicio-4)

---

### **Caso Práctico 2**

#### **Ejercicio 1**

> **1. (Oracle) La vida de un DBA es dura. Tras pedirlo insistentemente, en tu empresa han contratado una persona para ayudarte. Decides que se encargará de las siguientes tareas:**
> **- Resetear los archivos de log en caso de necesidad.**
>
> **- Crear funciones de complejidad de contraseña y asignárselas a usuarios.**
>
> **- Eliminar la información de rollback. (este privilegio podrá pasarlo a quien quiera).**
>
> **- Modificar información existente en la tabla dept del usuario scott. (este privilegio podrá pasarlo a quien quiera).**
>
> **- Realizar pruebas de todos los procedimientos existentes en la base de datos.**
>
> **- Poner un tablespace fuera de línea.**

Creación del usuario AYUDANTE:

```sql
CREATE USER AYUDANTE IDENTIFIED BY AYUDANTE;
```

Resetear los archivos de log en caso de necesidad:

```sql
GRANT ALTER DATABASE TO AYUDANTE;
```

Crear funciones de complejidad de contraseña y asignárselas a usuarios:

```sql
GRANT CREATE ANY PROCEDURE,ALTER PROFILE TO AYUDANTE;
```

Eliminar la información de rollback. (este privilegio podrá pasarlo a quien quiera):

```sql
GRANT DROP ROLLBACK SEGMENT TO AYUDANTE WITH GRANT OPTION;
```

Modificar información existente en la tabla dept del usuario scott (este privilegio podrá pasarlo a quien quiera):

```sql
GRANT UPDATE,SELECT ON SCOTT.DEPT TO AYUDANTE WITH GRANT OPTION;
```

Realizar pruebas de todos los procedimientos existentes en la base de datos:

```sql
GRANT EXECUTE ANY PROCEDURE TO AYUDANTE;
```

Poner un tablespace fuera de línea:

```sql
GRANT ALTER TABLESPACE TO AYUDANTE;
```

#### **Ejercicio 2**

> **2. (Oracle) Muestra el texto de la última sentencia SQL que se ejecutó en el servidor, junto con el número de veces que se ha ejecutado desde que se cargó en el Shared Pool y el tiempo de CPU empleado en su ejecución.**

```sql
SELECT DISTINCT SQL_TEXT, EXECUTIONS, CPU_TIME
FROM V$SQLAREA
ORDER BY FIRST_LOAD_TIME DESC
FETCH FIRST 1 ROWS ONLY;
```

![Ej2](img/Caso%20Pr%C3%A1ctico%202/Ej2.png)

#### **Ejercicio 3**

> **3. (Oracle, PostgreSQL) Realiza un procedimiento que reciba dos nombres de usuario y genere un script que asigne al primero los privilegios de inserción y modificación sobre todas las tablas del segundo, así como el de ejecución de cualquier procedimiento que tenga el segundo usuario.**

- **Oracle:**

    ```sql
    CREATE OR REPLACE PROCEDURE P_PRIVILEGIOS_PROCEDIMIENTOS (P_USUARIO1 IN VARCHAR2, P_USUARIO2 IN VARCHAR2) IS
        CURSOR C_PROCEDIMIENTOS IS
            SELECT OBJECT_NAME
            FROM DBA_OBJECTS
            WHERE OBJECT_TYPE = 'PROCEDURE'
                AND OWNER = P_USUARIO2;
        V_CURSOR C_PROCEDIMIENTOS%ROWTYPE;
    BEGIN
        FOR V_CURSOR IN C_PROCEDIMIENTOS LOOP
            DBMS_OUTPUT.PUT_LINE('GRANT EXECUTE ON ' || P_USUARIO2 || '.' || V_CURSOR.OBJECT_NAME || ' TO ' || P_USUARIO1 || ';');
        END LOOP;
    END P_PRIVILEGIOS_PROCEDIMIENTOS;
    /

    -- Comprobación:
    EXEC P_PRIVILEGIOS_PROCEDIMIENTOS('SYS', 'XDB');
    ```

    ![Ej3 - 1](img/Caso%20Pr%C3%A1ctico%202/Ej3%20-%201.png)

    ```sql
    CREATE OR REPLACE PROCEDURE P_PRIVILEGIOS_TABLAS (P_USUARIO1 IN VARCHAR2, P_USUARIO2 IN VARCHAR2) IS
        CURSOR C_TABLAS IS
            SELECT TABLE_NAME
            FROM ALL_TABLES
            WHERE OWNER = P_USUARIO2;
        V_CURSOR C_TABLAS%ROWTYPE;
    BEGIN
        FOR V_CURSOR IN C_TABLAS LOOP
            DBMS_OUTPUT.PUT_LINE('GRANT INSERT, UPDATE ON ' || P_USUARIO2 || '.' || V_CURSOR.TABLE_NAME || ' TO ' || P_USUARIO1 || ';');
            DBMS_OUTPUT.PUT_LINE('GRANT ALTER ON ' || P_USUARIO2 || '.' || V_CURSOR.TABLE_NAME || ' TO ' || P_USUARIO1 || ';');
        END LOOP;
    END P_PRIVILEGIOS_TABLAS;
    /

    -- Comprobación:
    EXEC P_PRIVILEGIOS_TABLAS('SYS', 'XDB');
    ```

    ![Ej3 - 2](img/Caso%20Pr%C3%A1ctico%202/Ej3%20-%202.png)

    ```sql
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
    -- Este procedimiento no cuenta con comprobación ya que es el usado en la parte de Oracle del alumno 4. Se comprobó su funcionamiento en su documentación correspondiente.

    CREATE OR REPLACE PROCEDURE P_OTORGAR_PRIVILEGIOS(P_USUARIO1 IN VARCHAR2,     P_USUARIO2 IN VARCHAR2) IS
        VN_RESULTADO1 NUMBER(1) := '0';
        VN_RESULTADO2 NUMBER(1) := '0';
        E_USUARIO_NO_EXISTE EXCEPTION;
    BEGIN
        P_USUARIO_EXISTE(P_USUARIO1, VN_RESULTADO1);
        P_USUARIO_EXISTE(P_USUARIO2, VN_RESULTADO2);
        IF VN_RESULTADO1 = '0' OR VN_RESULTADO2 = '0' THEN
            RAISE E_USUARIO_NO_EXISTE;
        END IF;
        P_PRIVILEGIOS_TABLAS(P_USUARIO1, P_USUARIO2);
        P_PRIVILEGIOS_PROCEDIMIENTOS(P_USUARIO1, P_USUARIO2);
    EXCEPTION
        WHEN E_USUARIO_NO_EXISTE THEN
            DBMS_OUTPUT.PUT_LINE('Alguno de los usuarios especificados no existe.');
    END P_OTORGAR_PRIVILEGIOS;
    /

    -- Comprobación:
    EXEC P_OTORGAR_PRIVILEGIOS('SYS', 'XDB');
    ```

    ![Ej3 - 3](img/Caso%20Pr%C3%A1ctico%202/Ej3%20-%203.png)

    ![Ej3 - 4](img/Caso%20Pr%C3%A1ctico%202/Ej3%20-%204.png)

    Si ejecutamos el procedimiento indicando algún usuario que no existe, nos mostrará la excepción indicada:

    ```sql
    EXEC P_OTORGAR_PRIVILEGIOS('SYS', 'FSDFAS');
    EXEC P_OTORGAR_PRIVILEGIOS('DSIFBDNF', 'FSDFAS');
    EXEC P_OTORGAR_PRIVILEGIOS('DSIFBDNF', 'XDB');
    ```

    ![Ej3 - 5](img/Caso%20Pr%C3%A1ctico%202/Ej3%20-%205.png)

- **PostgreSQL:**

#### **Ejercicio 4**

> **4. (Oracle) Realiza un procedimiento que genere un script que cree un rol conteniendo todos los permisos que tenga el usuario cuyo nombre reciba como parámetro, le hayan sido asignados a aquél directamente o a través de roles. El nuevo rol deberá llamarse *BackupPrivsNombreUsuario*.**

1. Creamos los procedimientos y funciones necesarios:

    ```sql
    CREATE OR REPLACE PROCEDURE P_CREAROL (P_USUARIO VARCHAR2) IS
        V_VALIDAR NUMBER := 0;
        V_ROLNEW VARCHAR(50) := 'BACKUPPRIVS' || P_USUARIO;
    BEGIN
        V_VALIDAR := P_COMPRUEBAUSUARIO(P_USUARIO);
        IF V_VALIDAR = 0 THEN
            DBMS_OUTPUT.PUT_LINE('CREATE ROLE BACKUPPRIVS' || P_USUARIO);
            P_PRIVILEGIOSSISTEMA(P_USUARIO, V_ROLNEW);
            P_PRIVILEGIOSOBJETOS(P_USUARIO, V_ROLNEW);
        END IF;
    END;
    /

    CREATE OR REPLACE PROCEDURE P_PRIVILEGIOSOBJETOS(P_USUARIO VARCHAR2,    P_NEWROL VARCHAR2) IS
        CURSOR C_PRIVTAB IS
            SELECT DISTINCT PRIVILEGE, OWNER, TABLE_NAME
            FROM DBA_TAB_PRIVS
            WHERE GRANTEE = P_USUARIO OR GRANTEE IN (SELECT DISTINCT GRANTED_ROLE
                                                     FROM DBA_ROLE_PRIVS
                                                     START WITH GRANTEE = P_USUARIO
                                                     CONNECT BY GRANTEE = PRIOR GRANTED_ROLE);
        V_CURSOR C_PRIVTAB%ROWTYPE;
    BEGIN
        FOR V_CURSOR IN C_PRIVTAB LOOP
            P_ADDPRIVOBJECT(V_CURSOR.PRIVILEGE, V_CURSOR.OWNER, V_CURSOR.TABLE_NAME, P_NEWROL);
        END LOOP;
    END;
    /

    CREATE OR REPLACE PROCEDURE P_ADDPRIVOBJECT(P_PRIVILEGIO DBA_TAB_PRIVS. PRIVILEGE%TYPE, P_OWNER DBA_TAB_PRIVS.OWNER%TYPE, P_NOMBRETABLA  DBA_TAB_PRIVS.TABLE_NAME%TYPE, P_NEWROL VARCHAR2)
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('GRANT ' || P_PRIVILEGIO || ' ON ' || P_OWNER || '.' || P_NOMBRETABLA || ' TO ' || P_NEWROL || ';');
    END;
    /

    CREATE OR REPLACE PROCEDURE P_PRIVILEGIOSSISTEMA(P_USUARIO VARCHAR2,    P_NEWROL VARCHAR2) IS
        CURSOR C_PRIVSIS IS
        SELECT DISTINCT PRIVILEGE, ADMIN_OPTION
        FROM DBA_SYS_PRIVS
        WHERE GRANTEE = P_USUARIO OR GRANTEE IN (SELECT DISTINCT GRANTED_ROLE
                                                 FROM DBA_ROLE_PRIVS
                                                 START WITH GRANTEE = P_USUARIO
                                                 CONNECT BY GRANTEE = PRIOR  GRANTED_ROLE);
        V_CURSOR C_PRIVSIS%ROWTYPE;
    BEGIN
        FOR V_CURSOR IN C_PRIVSIS LOOP
            P_ADDPRIVSYS(V_CURSOR.PRIVILEGE, V_CURSOR.ADMIN_OPTION, P_NEWROL);
        END LOOP;
    END;
    /

    CREATE OR REPLACE PROCEDURE P_ADDPRIVSYS(P_PRIVILEGIO USER_SYS_PRIVS.   PRIVILEGE%TYPE, P_OPCADMIN USER_SYS_PRIVS.ADMIN_OPTION%TYPE, P_NEWROL  VARCHAR2) IS
    BEGIN
        IF P_OPCADMIN = 'YES' THEN
            DBMS_OUTPUT.PUT_LINE('GRANT ' || P_PRIVILEGIO || ' TO ' || P_NEWROL || ' WITH ADMIN OPTION;');
        ELSE
            DBMS_OUTPUT.PUT_LINE('GRANT ' || P_PRIVILEGIO || ' TO ' || P_NEWROL || ';   ');
        END IF;
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

2. Ejecutamos el procedimiento:

    Primero voy a forzar que el procedimiento lance la excepción:

    ![Ej4 - 1](img/Caso%20Pr%C3%A1ctico%202/Ej4%20-%201.png)

    Ejecución exitosa:

    ![Ej4 - 2](img/Caso%20Pr%C3%A1ctico%202/Ej4%20-%202.png)

---

✒️ **Documentación realizada por Paco Diz Ureña.**

✒️ **Documentación realizada por Alejandro Montes Delgado.**

✒️ **Documentación realizada por Carlos Manuel Gámez Pérez de Guzmán.**

✒️ **Documentación realizada por Juan Jesús Alejo Sillero.**
