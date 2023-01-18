# **ASGBD - Práctica Grupal 3: Usuarios**

## **Alumno 4 - MongoDB y Oracle**

**Tabla de contenidos:**

- [**ASGBD - Práctica Grupal 3: Usuarios**](#asgbd---práctica-grupal-3-usuarios)
  - [**Alumno 4 - MongoDB y Oracle**](#alumno-4---mongodb-y-oracle)
  - [**MongoDB**](#mongodb)
    - [**Preparación del escenario**](#preparación-del-escenario)
    - [**Ejercicio 1**](#ejercicio-1)
    - [**Ejercicio 2**](#ejercicio-2)
    - [**Ejercicio 3**](#ejercicio-3)
    - [**Ejercicio 4**](#ejercicio-4)
  - [**Oracle**](#oracle)
    - [**Preparación del escenario**](#preparación-del-escenario-1)
    - [**Ejercicio 1**](#ejercicio-1-1)
    - [**Ejercicio 2**](#ejercicio-2-1)

---

## **MongoDB**

### **Preparación del escenario**

Pasos a seguir para dejar todo listo para hacer las comprobaciones de los siguientes ejercicios empezando desde una instalación limpia de MongoDB 6:

1. Entrar en la consola de MongoDB y crear el usuario administrador:

    ```bash
    mongosh
    ```

    ```js
    use admin

    db.createUser({user: 'admin', pwd: 'admin', roles: [{role: 'userAdminAnyDatabase', db: 'admin'}, {role: 'readWriteAnyDatabase', db: 'admin'}]})

    exit
    ```

2. Iniciar *mongosh* como administrador:

    ```bash
    mongosh -u admin -p admin --authenticationDatabase admin
    ```

### **Ejercicio 1**

> **1. Averigua si existe la posibilidad en MongoDB de limitar el acceso de un usuario a los datos de una colección determinada.**

Sí, se puede, usando roles.

Procedimiento para comprobarlo:

1. Creo una base de datos y una colección:

    ```js
    use PRAC5

    db.createCollection("COLPRAC5")
    ```

    ![1](img/Alumno%204/MongoDB/1.png)

2. Inserto algunos datos en la colección

    ```js
    db.COLPRAC5.insertMany([
        {ID: 1, NOMBRE: "Juan"},
        {ID: 2, NOMBRE: "Pedro"},
        {ID: 3, NOMBRE: "Luis"},
        {ID: 4, NOMBRE: "Ana"},
        {ID: 5, NOMBRE: "María"},
        {ID: 6, NOMBRE: "Laura"},
        {ID: 7, NOMBRE: "Antonio"},
        {ID: 8, NOMBRE: "Javier"},
        {ID: 9, NOMBRE: "Sara"},
        {ID: 10, NOMBRE: "Marta"}
    ])
    ```

    ![2](img/Alumno%204/MongoDB/2.png)

3. Creo un usuario con permisos de lectura y escritura en la base de datos *PRAC5*:

    ```js
    db.createUser({user: 'USERPRAC5', pwd: 'USERPRAC5', roles: ["readWrite"]})

    db.getUser("USERPRAC5")
    ```

    ![3](img/Alumno%204/MongoDB/3.png)

4. Salgo de la consola de administrador, entro con el nuevo usuario y compruebo que puedo acceder a la base de datos y a la colección:

    ```js
    exit
    ```

    ```bash
    mongosh -u USERPRAC5 -p USERPRAC5 --authenticationDatabase PRAC5

    use PRAC5

    db.COLPRAC5.find()
    ```

    ![4](img/Alumno%204/MongoDB/4.png)

5. Salgo de la consola de usuario y entro de nuevo como administrador. Le quito los permisos de lectura y escritura sobre la base de datos *PRAC5* al usuario *USERPRAC5*, le asigno un nuevo rol que únicamente le permita leer la colección *COLPRAC5*. Finalmente creo una colección llamada *COLSECRETAPRAC5* e inserto documentos en ella para más tarde comprobar que el usuario no puede acceder a tales documentos:

    ```js
    exit
    ```

    ```bash
    mongosh -u admin -p admin --authenticationDatabase admin
    ```

    ```js
    use PRAC5

    db.revokeRolesFromUser("USERPRAC5", [{role: "readWrite", db: "PRAC5"}])

    db.createRole({role: "readCOLPRAC5", privileges: [{resource: {db: "PRAC5", collection: "COLPRAC5"}, actions: ["find"]}], roles: []})

    db.grantRolesToUser("USERPRAC5", [{role: "readCOLPRAC5", db: "PRAC5"}])

    db.createCollection("COLSECRETAPRAC5")

    db.COLSECRETAPRAC5.insertMany([
        {ID: 1, NOMBRE: "Bulbasaur", TIPO: "Planta"},
        {ID: 2, NOMBRE: "Charmander", TIPO: "Fuego"},
        {ID: 3, NOMBRE: "Squirtle", TIPO: "Agua"},
        {ID: 4, NOMBRE: "Pikachu", TIPO: "Eléctrico"},
        {ID: 5, NOMBRE: "Eevee", TIPO: "Normal"}
    ])

    show collections

    db.COLSECRETAPRAC5.find()
    ```

    ![5](img/Alumno%204/MongoDB/5.png)

6. Salgo de la consola de administrador y entro con el usuario *USERPRAC5* para comprobar que no puede leer la colección *COLSECRETAPRAC5* pero sí la colección *COLPRAC5*:

    ```js
    exit
    ```

    ```bash
    mongosh -u USERPRAC5 -p USERPRAC5 --authenticationDatabase PRAC5
    ```

    ```js
    use PRAC5

    db.COLSECRETAPRAC5.find()

    db.COLPRAC5.find()
    ```

    ![6](img/Alumno%204/MongoDB/6.png)

Vemos que efectivamente, podemos limitar el acceso de un usuario a una colección determinada mediante el uso de roles.

### **Ejercicio 2**

> **2. Averigua si en MongoDB existe el concepto de privilegio del sistema y muestra las diferencias más importantes con Oracle.**

No, no existe un equivalente directo al concepto de privilegios de sistema.

En Oracle los [privilegios del sistema](https://docs.oracle.com/database/121/TTSQL/privileges.htm#TTSQL339) permiten realizar una acción particular sobre cualquier objeto o sobre cualquier objeto de un tipo concreto. Esto incluye tablas, vistas, índices, funciones, procedimientos, paquetes... Solo el administrador o un usuario con el privilegio *ADMIN* puede otorgar o revocar este tipo de privilegios.

En cambio, en MongoDB para cubrir este tipo de necesidades se utilizan los [roles predefinidos](https://www.mongodb.com/docs/manual/reference/built-in-roles/). Estos roles son conjuntos de privilegios que se pueden asignar a un usuario.

Los privilegios de un rol especifican qué acciones se pueden realizar sobre qué recursos. Por ejemplo, en el [ejercicio anterior](#ejercicio-1) se le revocó el rol *readWrite* al usuario *USERPRAC5* sobre la base de datos *PRAC5*. Esto significa que el usuario ya no puede realizar ninguna acción de lectura o escritura sobre la base de datos *PRAC5*.

Más información respecto a los roles predefinidos de MongoDB y como asignadorlos en el [siguiente ejercicio](#ejercicio-3).

### **Ejercicio 3**

> **3. Explica los roles por defecto que incorpora MongoDB y como se asignan a los usuarios.**

Según [la documentación oficial de MongoDB](https://www.mongodb.com/docs/manual/reference/built-in-roles/), los roles predefinidos (o por defecto) que incorpora son los siguientes:

- **Roles de usuario**:
  - **read**: Permite leer datos de una base de datos o colección.
  - **readWrite**: Proporciona todos los privilegios del rol *read*, más la capacidad de modificar datos en todas las colecciones que no son del sistema y la colección *system.js*.

- **Roles de administración de base de datos**:
  - **dbAdmin**: Brinda la capacidad de realizar tareas administrativas, como tareas relacionadas con esquemas, indexación y recopilación de estadísticas. Aunque pudiera parecerlo por su nombre, este rol no otorga privilegios para la gestión de usuarios y roles.
  - **dbOwner**: El propietario de la base de datos puede realizar cualquier acción administrativa en la base de datos. Este rol combina los privilegios otorgados por los roles *readWrite*, *dbAdmin* y *userAdmin*.
  - **userAdmin**: Permite crear y modificar roles y usuarios en la base de datos actual. Dado que la función *userAdmin* permite a los usuarios otorgar privilegios a cualquier usuario, incluidos ellos mismos, la función también **proporciona indirectamente acceso de superusuario** a la base de datos o, si se limita a la base de datos de administración, al clúster.

- **Roles de administración de clúster**:
  - **clusterAdmin**: Proporciona el mayor acceso posible a la administración de clústeres. Este rol combina los privilegios otorgados por los roles *clusterManager*, *clusterMonitor* y *hostManager*. Además, el rol proporciona la acción *dropDatabase*.
  - **clusterManager**: Proporciona acciones de gestión y seguimiento sobre el clúster. Un usuario con este rol puede acceder a las bases de datos locales y de configuración, que se utilizan en la fragmentación (*sharding*) y la replicación, respectivamente.
  - **clusterMonitor**: Proporciona acceso de solo lectura a las herramientas de monitoreo, como [*MongoDB Cloud Manager*](https://cloud.mongodb.com/?tck=docs_server) y el agente de supervisión de [*Ops Manager*](https://www.mongodb.com/docs/ops-manager/current/).
  - **hostManager**: Brinda la capacidad de monitorear y administrar servidores.

- **Roles de backup y restauración**:
  - **backup**: Proporciona los privilegios mínimos necesarios para realizar copias de seguridad de los datos. Este rol proporciona suficientes privilegios para usar *mongodump* para hacer una copia de seguridad de una instancia *mongod* completa.
  - **restore**: Proporciona los privilegios necesarios para restaurar copias de seguridad mientras que dichas copias no incluyan, datos de la colección *system.profile* y se ejecute *mongorestore* sin la opción *--oplogReplay*.

- **Roles de todas las bases de datos**:
  - **readAnyDatabase**: Proporciona los mismos privilegios de solo lectura que *read* en todas las bases de datos excepto *local* y *config*. El rol también proporciona la acción *listDatabases* en el clúster como un todo.
  - **readWriteAnyDatabase**: Proporciona los mismos privilegios que *readWrite* en todas las bases de datos excepto *local* y *config*. El rol también proporciona la acción *listDatabases* en el clúster como un todo y la acción *compactStructuredEncryptionData*.
  - **userAdminAnyDatabase**: Proporciona el mismo acceso a las operaciones de administración de usuarios que *userAdmin* en todas las bases de datos excepto *local* y *config*.
  - **dbAdminAnyDatabase**: Proporciona los mismos privilegios que *dbAdmin* en todas las bases de datos excepto *local* y *config*. El rol también proporciona la acción *listDatabases* en el clúster como un todo.

- **Roles de superusuario**:
  - **root**: Proporciona privilegios completos en todos los recursos. En concreto combinan los privilegios otorgados por los roles *readWriteAnyDatabase*, *dbAdminAnyDatabase*, *userAdminAnyDatabase*, *clusterAdmin*, *restore*, *backup* y además, otorga el privilegio *validate* en las colecciones *system.*.

- **Rol interno**:
  - **__system**: MongoDB asigna esta función a los objetos de usuario que representan a los miembros del clúster: miembros del conjunto de réplicas e instancias de *mongos*. El rol da derecho a su titular a tomar cualquier acción contra cualquier objeto en la base de datos. **Este rol no se debe asignar a ningún usuario**.

Para asignar uno o varios roles a un usuario, se utiliza el comando `grantRolesToUser()`:

```js
db.grantRolesToUser(
   "<usuario>",
   [
      { role: "<rol>", db: "<base de datos>" },
      { role: "<rol>", db: "<base de datos>" },
      ...
   ]
)
```

Si queremos que los roles estén ya asignados al usuario desde el momento de su creación, debemos crearlo con la siguiente sintaxis:

```js
db.createUser(
   {
        user: "<usuario>",
        pwd: "<contraseña>",
        roles: [
            { role: "<rol>", db: "<base de datos>" },
            { role: "<rol>", db: "<base de datos>" },
            ...
        ]
    }
)
```

Por último, si quisiéramos revocar un rol a un usuario, como hicimos antes, sería de la siguiente manera:

```js
db.revokeRolesFromUser(
   "<usuario>",
   [
      { role: "<rol>", db: "<base de datos>" },
      { role: "<rol>", db: "<base de datos>" },
      ...
   ]
)
```

### **Ejercicio 4**

> **4. Explica como puede consultarse el diccionario de datos de MongoDB para saber que roles han sido concedidos a un usuario y qué privilegios incluyen.**

Si queremos consultar los roles de un usuario y los privilegios que estos incluyen, podemos hacerlo elegantemente de la siguiente manera, aunque esto nos dará la información del usuario que estamos usando en ese momento:

```js
db.runCommand(
   {
      connectionStatus: 1,
      showPrivileges: true
   }
)
```

![7](img/Alumno%204/MongoDB/7.png)

O, para obtener la información de un usuario en concreto:

```js
db.runCommand(
   {
      usersInfo: {
         user: "<usuario>",
            db: "<base de datos>"
        },
        showPrivileges: true
    }
)
```

![8](img/Alumno%204/MongoDB/8.png)

No obstante, si únicamente queremos obtener los roles de un usuario:

```js
use <base de datos>

db.getUser("<usuario>")
```

![9](img/Alumno%204/MongoDB/9.png)

Y, si quisiéramos ver los privilegios de un rol:

```js
use <base de datos>

db.getRole("<rol>", { showPrivileges: true })
```

![10](img/Alumno%204/MongoDB/10.png)

---

## **Oracle**

### **Preparación del escenario**

Pasos a seguir para dejar todo listo para hacer las comprobaciones de los siguientes dos ejercicios empezando desde una instalación limpia de Oracle 21c:

1. Entrar en SQLPlus como administrador.

    ```bash
    sqlplus / as sysdba
    ```

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

[Según los apuntes de Raúl sobre gestión de usuarios en Oracle](https://educacionadistancia.juntadeandalucia.es/centros/sevilla/mod/resource/view.php?id=105462), la vista que hay que consultar para obtener los *GRANTS* de un usuario sobre un objeto es *DBA_TAB_PRIVS*. Esto es correcto, sin embargo, esta vista también contiene los *GRANTS* sobre objetos de los roles, por lo que no será necesario consultar la vista *DBA_ROLE_PRIVS* como indican los apuntes. Teniendo esto en cuenta, los pasos a seguir para resolver este ejercicio son los siguientes:

1. Ya que la vista *DBA_TAB_PRIVS* contiene tanto usuarios como roles, tengo que detectar si se ha introducido el nombre de un usuario para evitar errores. Para ello, primero crearé un procedimiento que, en caso de recibir un usuario no existente devolverá un un *0*.

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

3. Ahora, creo un procedimiento que buscará en la vista *DBA_TAB_PRIVS* los objetos a los cuales, el usuario (o rol) que le pasemos tiene acceso de forma directa:

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

2. Una vez que ya tengo la certeza de estar tratando con un usuario, creo un procedimiento que buscará en la vista *DBA_TAB_PRIVS* el nombre del usuario (o rol, esto será útil para más tarde) y, si tiene el privilegio indicado sobre el objeto indicado, devolverá *1*, si no, no devolverá nada.

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
