# **ASGBD - Práctica Grupal 3: Usuarios**

## **Alumno 2 - PostgreSQL y Oracle**

**Tabla de contenidos:**

- [**ASGBD - Práctica Grupal 3: Usuarios**](#asgbd---práctica-grupal-3-usuarios)
  - [**Alumno 2 - PostgreSQL y Oracle**](#alumno-2---postgresql-y-oracle)
  - [**PostgreSQL**](#postgresql)
    - [**Ejercicio 1**](#ejercicio-1)
    - [**Ejercicio 2**](#ejercicio-2)
    - [**Ejercicio 3**](#ejercicio-3)
    - [**Ejercicio 4**](#ejercicio-4)
    - [**Ejercicio 5**](#ejercicio-5)
    - [**Ejercicio 6**](#ejercicio-6)
  - [**Oracle**](#oracle)
    - [**Ejercicio 1**](#ejercicio-1-1)
    - [**Ejercicio 2**](#ejercicio-2-1)

---

## **PostgreSQL**

### **Ejercicio 1**

> **1. Averigua que privilegios de sistema hay en Postgres y como se asignan a un usuario.**

Los privilegios, son permisos especiales otorgados a usuarios o roles para llevar a vabo ciertas acciones en el sistema.

Algunos de los privilegios de sistema más usados son:

- Create: Permite al usuario crear objetos en el esquema, como tablas, vistas y índices.
- Usage: Permite al usuario utilizar un esquema o una secuencia.
- Select: Permite al usuario leer datos de las tablas para poder realizar una consulta.
- Insert: Permite al usuario insertar nuevas filas en las tablas.
- Update: Permite al usuario modificar filas existentes en las tablas.
- Delete: Permite al usuario eliminar filas de las tablas.
- Truncate: Permite al usuario vaciar las tablas (eliminar todas las filas).
- References: Permite al usuario crear y eliminar claves foráneas.
- Trigger: Permite al usuario crear y eliminar triggers.
- Create procedure: Permite al usuario crear y eliminar procedimientos almacenados.

En este ejemplo, asigno priviliegios a un usuario sobre un esquema:

```txt
postgres=# GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA PUBLIC TO alemd;
GRANT
```

Para otorgar un conjunto de privilegios a un usuario individual o a un grupo de usuarios, se usan roles. Los privilegios del sistema se determinan a través de los roles, que a su vez son los usuarios y pueden tener asignados otros roles. Podemos ver los permisos que contiene un rol con el siguiente comando:

```txt
postgres=# \du
                                     Lista de roles
 Nombre de rol|                        Atributos                         | Miembro de 
--------------+----------------------------------------------------------+------------
 alejandro1   |                                                          | {}
 alemd        |                                                          | {}
 postgres     |Superusuario, Crear rol, Crear BD, Replicación, Ignora RLS| {}
```

Para administrar los privilegios del sistema de forma correcta, se aconseja agrupar los usuarios en diferentes roles. La diferencia principal entre un usuario y los roles de grupo es que los usuarios tendrían privilegios de login.

Estas opciones se pueden asignar a los roles al crearlo o después de crearlo:

```txt
CREATE ROLE <<NOMBRE-ROL>> 
  WITH <<OPCION>>;
ALTER ROLE <<NOMBRE-ROL>> 
  WITH <<OPCION>>;
```

Algunas de las opciones que se le pueden asignar a un rol son:

- ADMIN: opción para indicar el rol o los roles de los formará parte con derecho a agregar a otros roles en este.
- BYPASSRL o NOBYPASSRLS: opción para omitir los sistemas de seguridad de fila de las tablas.
- CREATEDB o NOCREATEDB: opción para crear bases de datos.
- CREATEROLE o NOCREATEROLE: opción para crear nuevos roles.
- CONNECTION LIMIT: limita el número de sesiones concurrentes.
- INHERIT o NOINHERIT: opción para determinar si hereda los privilegios de los roles de los que es miembro.
- IN ROLE: opción para indicar los roles de los que formará parte.
- LOGIN o NOLOGIN: opción para crear sesiones. Para que el usuario pueda o no iniciar sesion.
- REPLICATION o NOREPLICATION: opción para controlar la transmisión.
- SUPERUSER o NOSUPERUSER: se agregan los privilegios de superusuario.
- [ENCRYPTED] PASSWORD: asigna una contraseña al rol/usuario.
- VALID UNTIL: indica la expiración del rol/usuario.

### **Ejercicio 2**

> **2. Averigua cual es la forma de asignar y revocar privilegios sobre una tabla concreta en Postgres.**

Me conecto a la base de datos aeropuerto y le doy permisos sobre la tabla viajes. La instrucción que he usado, es la siguiente:

```txt
aeropuerto=# GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE viajes TO alemd;
GRANT
```

Para revocar los permisos usamos la siguiente instrucción:

```txt
aeropuerto=# REVOKE INSERT ON viajes FROM ALEMD;
REVOKE

```

### **Ejercicio 3**

> **3. Averigua si existe el concepto de rol en Postgres y señala las diferencias con los roles de ORACLE.**

Como ya hemos mencionado anteriormente, sí existe el concepto de rol en Postgres, y lo usamos para agrupar permisos para asignarselos a los usuarios de una forma correcta. Las diferencias son las siguientes:

- La primera diferencia, es que en Postgres se utiliza el término usuario pero solo se trabaja con roles.

- mientras que en Oracle los roles son grupos de usuarios y/o de otros roloes, en Postgres los roles son los propietarios de las bases de datos y pueden estar compuesto por otros roles.

- No hay diferencias en la sintaxis a la hora de crear roles y asignarle privilegios a estos en ambos SGBD.

- En oracle puedes asignar un rol a un usuario mientras que en Postgres no puedes asignar un rol a un usuario ya que no existen como tal.

- Para ver los roles asignados a un usuario en oracle se usa la siguiente consulta:

```sql
select grantee, granted_role from dba_role_privs
where grantee = upper ('&grantee')
order by grantee;
```

En Postgres basta con ejecutar `\du`.

### **Ejercicio 4**

> **4. Averigua si existe el concepto de perfil como conjunto de límites sobre el uso de recursos o sobre la contraseña en Postgres y señala las diferencias con los perfiles de ORACLE.**

En PostgreSQL no existen los perfiles ya que todas las delimitaciones se realizan mediante objetos, sin embargo, buscando información, en la versión profesional de postgres(Postgres Pro) sí existen los perfiles.

### **Ejercicio 5**

> **5. Realiza consultas al diccionario de datos de Postgres para averiguar todos los privilegios que tiene un usuario concreto.**

Dejo un ejemplo consultando el diccionario de datos con los permisos que le he dado al rol o usuario alemd en el primer ejercicio:

```txt
aeropuerto=# SELECT PRIVILEGE_TYPE, TABLE_NAME, TABLE_SCHEMA, TABLE_CATALOG FROM INFORMATION_SCHEMA.TABLE_PRIVILEGES WHERE GRANTEE='alemd';
 privilege_type | table_name | table_schema | table_catalog 
----------------+------------+--------------+---------------
 SELECT         | viajes     | public       | aeropuerto
 UPDATE         | viajes     | public       | aeropuerto
 DELETE         | viajes     | public       | aeropuerto
(3 filas)
```

### **Ejercicio 6**

> **6. Realiza consultas al diccionario de datos en Postgres para averiguar qué usuarios pueden consultar una tabla concreta.**

Muestro un ejemplo mostrando los usuarios que tienen privilegios de consulta sobre la tabla viajes.

```txt
aeropuerto=# SELECT GRANTEE FROM INFORMATION_SCHEMA.TABLE_PRIVILEGES WHERE TABLE_NAME = 'viajes' AND PRIVILEGE_TYPE = 'SELECT';
 grantee  
----------
 postgres
 alemd
(2 filas)
```

---

## **Oracle**

### **Ejercicio 1**

> **1. Realiza una función de verificación de contraseñas que compruebe que la contraseña difiere en más de tres caracteres de la anterior y que la longitud de la misma es diferente de la anterior. Asígnala al perfil CONTRASEÑASEGURA. Comprueba que funciona correctamente.**

1. Lo primero que debemos de hacer es entrar como administrador en SQLplus.

    ```sql
    sqlplus / as sysdba
    ```

2. Habilitaremos el modo script y la salida por pantalla:

    ```sql
    ALTER SESSION SET "_ORACLE_SCRIPT"=true;
    SET SERVEROUTPUT ON;
    ```

3. Crearemos la función y los módulos de programación pertinentes para la resolución del ejercicio:

    ```sql
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
    ```

4. Creamos el perfil CONTRASEÑASEGURA.

    ```txt
    SQL> CREATE PROFILE CONTRASENASEGURA LIMIT PASSWORD_VERIFY_FUNCTION F_VERIFYPASSWORD;

    Perfil creado.
    ```

5. Creamos un usuario al que asignaremos el perfil y le asignamos algunos permisos sobre la tabla SCOTT.

    ```txt
    SQL> CREATE USER EJ7PASSWD IDENTIFIED BY "123456789";
    
    Usuario creado.
    
    SQL> GRANT CONNECT, RESOURCE TO EJ7PASSWD;
    
    Concesion terminada correctamente.
    ```

6. Asignamos el perfil CONTRASEÑASEGURA al usuario creado anteriormente.

    ```txt
    SQL> ALTER USER EJ7PASSWD PROFILE CONTRASENASEGURA;
    
    Usuario modificado.
    ```

7. Nos logueamos con el usuario al que le hemos asignado el perfil.

    ```txt
    SQL> connect EJ7PASSWD/123456789;
    Conectado.
    SQL> 
    ```

8. Cambiamos la contraseña por una no válida para comprobar que funciona correctamente:

    Hemos provocado que salte el error de que la contraseña tiene la misma longitud.

    ```txt
    SQL> ALTER USER EJ7PASSWD IDENTIFIED BY "qwertyuio" REPLACE "123456789";
    ALTER USER EJ7PASSWD IDENTIFIED BY "qwertyuio" REPLACE "123456789"
    *
    ERROR en linea 1:
    ORA-28003: fallo en la verificacion de la contrase?a especificada
    ORA-20100: La nueva contrase??a no puede tener la misma longitud que la
    anterior.
    ```

    Ahora provocamos que salte el error de que la contraseña debe de tener al menos 5 caracteres distintos:

    ```txt
    SQL> ALTER USER EJ7PASSWD IDENTIFIED BY "123qwe" REPLACE "123456789";
    ALTER USER EJ7PASSWD IDENTIFIED BY "123qwe" REPLACE "123456789"
    *
    ERROR en linea 1:
    ORA-28003: fallo en la verificacion de la contrase?a especificada
    ORA-20101: La nueva contrase??a debe de tener al menos 5 car??cteres distintos
    ```

    Ahora haremos que el usuario cambie la contraseña correctamente:

    ```txt
    SQL> ALTER USER EJ7PASSWD IDENTIFIED BY "usuario" REPLACE "123456789";

    Usuario modificado.
    ```

### **Ejercicio 2**

> **2. Realiza un procedimiento llamado MostrarPrivilegiosdelRol que reciba el nombre de un rol y muestre los privilegios de sistema y los privilegios sobre objetos que lo componen.**

1. Lo primero que debemos de hacer es entrar como administrador en SQLplus.

    ```sql
    sqlplus / as sysdba
    ```

2. Habilitaremos el modo script y la salida por pantalla:

    ```sql
    ALTER SESSION SET "_ORACLE_SCRIPT"=true;
    SET SERVEROUTPUT ON;
    ```

3. Crearemos los módulos de programación pertinentes para la resolución del ejercicio:

    ```sql
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
    ```

4. Crearemos un rol y le añadiremos privilegios sobre objetos y privilegios del sistema para mostrar el correcto funcionamiento.

    Primero creamos el rol y le doy privilegios del sistema y ejecuto el procedimiento:

    ```txt
    SQL> CREATE ROLE pruebarol;

    Rol creado.

    SQL> GRANT CREATE SESSION, CREATE DATABASE LINK TO pruebarol;

    Concesion terminada correctamente.

    SQL> exec P_MUESTRAPRIVROL('PRUEBAROL');
    PRIVILEGIOS DEL SISTEMA
    ___________________________________________________
    CREATE DATABASE LINK
    CREATE SESSION
    ___________________________________________________
    PRIVILEGIOS SOBRE OBJETOS
    ___________________________________________________

    Procedimiento PL/SQL terminado correctamente.
    ```

    Ahora le añado privilegios sobre objetos y vuelvo a ejecutar el procedimiento:

    ```txt
    SQL> GRANT SELECT, INSERT, UPDATE ON ALUMNOS TO PRUEBAROL;

    Concesion terminada correctamente.

    SQL> exec P_MUESTRAPRIVROL('PRUEBAROL');
    PRIVILEGIOS DEL SISTEMA
    ___________________________________________________
    CREATE DATABASE LINK
    CREATE SESSION
    ___________________________________________________
    PRIVILEGIOS SOBRE OBJETOS
    ___________________________________________________
    EL USUARIO ALEMD TIENE PRIVILEGIOS UPDATE SOBRE LA TABLA ALUMNOS
    EL USUARIO ALEMD TIENE PRIVILEGIOS INSERT SOBRE LA TABLA ALUMNOS
    EL USUARIO ALEMD TIENE PRIVILEGIOS SELECT SOBRE LA TABLA ALUMNOS

    Procedimiento PL/SQL terminado correctamente.
    ```

    Si ponemos un rol que no existe ocurre lo siguiente:

    ```txt
    SQL> exec P_MUESTRAPRIVROL('fsdfsfsdf');
    EL ROL fsdfsfsdf NO EXISTE.
    
    Procedimiento PL/SQL terminado correctamente.
    ```

---

✒️ **Documentación realizada por Alejandro Montes Delgado.**
