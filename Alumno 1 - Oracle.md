# **ASGBD - Práctica Grupal 3: Usuarios**

## **Alumno 1 - Oracle**

**Tabla de contenidos:**

- [**ASGBD - Práctica Grupal 3: Usuarios**](#asgbd---práctica-grupal-3-usuarios)
  - [**Alumno 1 - Oracle**](#alumno-1---oracle)
  - [**Oracle**](#oracle)
    - [**Ejercicio 1**](#ejercicio-1)
    - [**Ejercicio 2**](#ejercicio-2)
    - [**Ejercicio 3**](#ejercicio-3)
    - [**Ejercicio 4**](#ejercicio-4)
    - [**Ejercicio 5**](#ejercicio-5)
    - [**Ejercicio 6**](#ejercicio-6)
    - [**Ejercicio 7**](#ejercicio-7)
    - [**Ejercicio 8**](#ejercicio-8)
    - [**Ejercicio 9**](#ejercicio-9)
    - [**Ejercicio 10**](#ejercicio-10)
    - [**Ejercicio 11**](#ejercicio-11)
    - [**Ejercicio 12**](#ejercicio-12)
    - [**Ejercicio 13**](#ejercicio-13)
    - [**Ejercicio 14**](#ejercicio-14)
    - [**Ejercicio 15**](#ejercicio-15)
    - [**Ejercicio 16**](#ejercicio-16)
    - [**Ejercicio 17**](#ejercicio-17)
    - [**Ejercicio 18**](#ejercicio-18)
    - [**Ejercicio 19**](#ejercicio-19)
    - [**Ejercicio 20**](#ejercicio-20)
    - [**Ejercicio 21**](#ejercicio-21)
    - [**Ejercicio 22**](#ejercicio-22)
    - [**Ejercicio 23**](#ejercicio-23)
    - [**Ejercicio 24**](#ejercicio-24)
    - [**Ejercicio 25**](#ejercicio-25)

---

## **Oracle**

### **Ejercicio 1**

> **1. Crea un rol ROLPRACTICA1 con los privilegios necesarios para conectarse a la base de datos, crear tablas y vistas e insertar datos en la tabla EMP de SCOTT.**

```sql
alter session set "_ORACLE_SCRIPT"=true;
CREATE ROLE ROLPRACTICA1;
GRANT CONNECT,CREATE TABLE,CREATE VIEW TO ROLPRACTICA1;
GRANT INSERT ON SCOTT.EMP TO ROLPRACTICA1;
```

### **Ejercicio 2**

> **2. Crea un usuario USRPRACTICA1 con el tablespace USERS por defecto y averigua que cuota se le ha asignado por defecto en el mismo. Sustitúyela por una cuota de 1M.**

```sql
CREATE USER USRPRACTICA1 IDENTIFIED BY USRPRACTICA1 DEFAULT TABLESPACE USERS;
```

Por defecto viene en 0M por lo que al hacer la siguiente consulta el usuario no aparece en la tabla *dba_ts_quotas*. Pruebas:

```sql
SELECT username, tablespace_name, bytes
FROM dba_ts_quotas
WHERE username = 'USRPRACTICA1';
```

Para sustituirla:

```sql
ALTER USER USRPRACTICA1 QUOTA 1M ON USERS;
```

Y comprobarlo:

```sql
SELECT USERNAME, TABLESPACE_NAME, MAX_BYTES, BYTES
FROM DBA_TS_QUOTAS
WHERE USERNAME = 'USRPRACTICA1';
```

![2](img/Alumno%201/Oracle/2.png)

### **Ejercicio 3**

> **3. Modifica el usuario USRPRACTICA1 para que tenga cuota 0 en el tablespace SYSTEM.**

```sql
ALTER USER USRPRACTICA1 QUOTA 0M ON SYSTEM;
```

Para comprobarlo:

```sql
SELECT USERNAME, TABLESPACE_NAME, MAX_BYTES, BYTES
FROM DBA_TS_QUOTAS
WHERE USERNAME = 'USRPRACTICA1' AND TABLESPACE_NAME='SYSTEM';
```

![3](img/Alumno%201/Oracle/3.png)

### **Ejercicio 4**

> **4. Concede a USRPRACTICA1 el ROLPRACTICA1.**

```sql
GRANT ROLPRACTICA1 TO USRPRACTICA1;
```

### **Ejercicio 5**

> **5. Concede a USRPRACTICA1 el privilegio de crear tablas e insertar datos en el esquema de cualquier usuario. Prueba el privilegio. Comprueba si puede modificar la estructura o eliminar las tablas creadas.**

```sql
GRANT CREATE ANY TABLE,INSERT ANY TABLE TO USRPRACTICA1;
```

Para comprobarlo:

Crear tablas e insertar datos:

```sql
CREATE TABLE SCOTT.NUEVA_TAB(campo1 VARCHAR2(15));

INSERT INTO SCOTT.NUEVA_TAB (campo1) VALUES ('prueba1');
```

Comprueba si se puede modificar estructura o eliminar tablas:

```sql
ALTER TABLE SCOTT.DEPT ADD prueba VARCHAR2(10); 

ALTER TABLE SCOTT.DEPT DROP COLUMN LOC;
```

![5](img/Alumno%201/Oracle/5.png)

### **Ejercicio 6**

> **6. Concede a USRPRACTICA1 el privilegio de leer la tabla DEPT de SCOTT con la posibilidad de que lo pase a su vez a terceros usuarios.**

```sql
GRANT SELECT ON SCOTT.DEPT TO USRPRACTICA1 WITH GRANT OPTION;
```

Para comprobar:

```sql
SELECT * FROM SCOTT.DEPT;
```

![6](img/Alumno%201/Oracle/6.png)

### **Ejercicio 7**

> **7. Comprueba que USRPRACTICA1 puede realizar todas las operaciones previstas en el rol.**

```sql
CONNECT USRPRACTICA1/USRPRACTICA1;

CREATE TABLE TABLA_NUEVA(campo1 VARCHAR2(15));
INSERT INTO TABLA_NUEVA(campo1) VALUES ('Paco');


CREATE VIEW tnueva_view AS
SELECT campo1
FROM tabla_nueva;

SELECT * FROM tnueva_view;


INSERT INTO SCOTT.EMP (empno, ename, job, sal, deptno)
VALUES (9000, 'Paco', 'MANAGER', 3000, 20);
```

![7](img/Alumno%201/Oracle/7.png)

### **Ejercicio 8**

> **8. Quita a USRPRACTICA1 el privilegio de crear vistas. Comprueba que ya no puede hacerlo.**

```sql
REVOKE CREATE VIEW FROM ROLPRACTICA1;
```

Comprobación:

```sql
CONNECT USRPRACTICA1/USRPRACTICA1;

CREATE OR REPLACE VIEW tnueva_view2 AS
SELECT campo1
FROM tabla_nueva;
```

### **Ejercicio 9**

> **9. Crea un perfil NOPARESDECURRAR que limita a dos el número de minutos de inactividad permitidos en una sesión.**

```sql
CREATE PROFILE NOPARESDECURRAR LIMIT IDLE_TIME 2;
```

### **Ejercicio 10**

> **10. Activa el uso de perfiles en ORACLE.**

En la versión que usamos viene ya por defecto activado. De hecho vienen activados por defecto desde la versión de Oracle 9i (2001). Se activaban de la siguiente forma:

```bash
netadm enable
```

### **Ejercicio 11**

> **11. Asigna el perfil creado a USRPRACTICA1 y comprueba su correcto funcionamiento.**

```sql
ALTER USER USRPRACTICA1 PROFILE NOPARESDECURRAR;
```

### **Ejercicio 12**

> **12. Crea un perfil CONTRASEÑASEGURA especificando que la contraseña caduca mensualmente y sólo se permiten tres intentos fallidos para acceder a la cuenta. En caso de superarse, la cuenta debe quedar bloqueada indefinidamente.**

```sql
CREATE PROFILE CONTRASENASEGURA LIMIT 
PASSWORD_LIFE_TIME 30 
PASSWORD_REUSE_TIME UNLIMITED 
PASSWORD_REUSE_MAX 3 
PASSWORD_LOCK_TIME 1;
```

### **Ejercicio 13**

> **13. Asigna el perfil creado a USRPRACTICA1 y comprueba su funcionamiento. Desbloquea posteriormente al usuario.**

```sql
ALTER USER USRPRACTICA1 PROFILE CONTRASENASEGURA;

CONNECT USRPRACTICA1/USRPRACTICA1
```

![13](img/Alumno%201/Oracle/13.png)

### **Ejercicio 14**

> **14. Consulta qué usuarios existen en tu base de datos.**

```sql
SELECT USERNAME FROM DBA_USERS;
```

![14](img/Alumno%201/Oracle/14.png)

### **Ejercicio 15**

> **15. Elige un usuario concreto y consulta qué cuota tiene sobre cada uno de los tablespaces.**

```sql
SELECT USERNAME, TABLESPACE_NAME, MAX_BYTES, BYTES
FROM DBA_TS_QUOTAS
WHERE USERNAME = 'MDSYS';
```

![15](img/Alumno%201/Oracle/15.png)

### **Ejercicio 16**

> **16. Elige un usuario concreto y muestra qué privilegios de sistema tiene asignados.**

```sql
SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE GRANTEE = 'AUDSYS';
```

![16](img/Alumno%201/Oracle/16.png)

### **Ejercicio 17**

> **17. Elige un usuario concreto y muestra qué privilegios sobre objetos tiene asignados.**

```sql
SELECT GRANTEE, TABLE_NAME, PRIVILEGE, GRANTOR
FROM DBA_TAB_PRIVS
WHERE GRANTEE = 'SYS';
```

![17](img/Alumno%201/Oracle/17.png)

### **Ejercicio 18**

> **18. Consulta qué roles existen en tu base de datos.**

```sql
SELECT ROLE FROM DBA_ROLES;
```

![18](img/Alumno%201/Oracle/18.png)

### **Ejercicio 19**

> **19. Elige un rol concreto y consulta qué usuarios lo tienen asignado.**

```sql
SELECT GRANTEE
FROM DBA_ROLE_PRIVS
WHERE GRANTED_ROLE = 'DBA';
```

![19](img/Alumno%201/Oracle/19.png)

### **Ejercicio 20**

> **20. Elige un rol concreto y averigua si está compuesto por otros roles o no.**

```sql
SELECT ROLE, GRANTED_ROLE
FROM ROLE_ROLE_PRIVS
WHERE ROLE='DBA';
```

![20](img/Alumno%201/Oracle/20.png)

### **Ejercicio 21**

> **21. Consulta qué perfiles existen en tu base de datos.**

```sql
SELECT PROFILE FROM DBA_PROFILES;
```

![21](img/Alumno%201/Oracle/21.png)

### **Ejercicio 22**

> **22. Elige un perfil y consulta qué límites se establecen en el mismo.**

```sql
SELECT PROFILE, LIMIT
FROM DBA_PROFILES
WHERE PROFILE='DEFAULT';
```

![22](img/Alumno%201/Oracle/22.png)

### **Ejercicio 23**

> **23. Muestra los nombres de los usuarios que tienen limitado el número de sesiones concurrentes.**

No existe ningún perfil con límite en mi sistema Oracle por lo cual voy a cambiar el perfil creado *NOPARESDECURRAR* a 3 sesiones concurrentes:

```sql
ALTER PROFILE NOPARESDECURRAR LIMIT SESSIONS_PER_USER 3;

SELECT PROFILE, RESOURCE_NAME, LIMIT
FROM DBA_PROFILES
WHERE RESOURCE_NAME='SESSIONS_PER_USER' AND PROFILE='NOPARESDECURRAR';
```

![23](img/Alumno%201/Oracle/23.png)

### **Ejercicio 24**

> **24. Realiza un procedimiento que reciba un nombre de usuario y un privilegio de sistema y nos muestre el mensaje 'SI, DIRECTO' si el usuario tiene ese privilegio concedido directamente, 'SI, POR ROL' si el usuario tiene ese privilegio en alguno de los roles que tiene concedidos y un 'NO' si el usuario no tiene dicho privilegio.**

```sql
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE mostrar_priv(p_user IN VARCHAR2, p_priv IN VARCHAR2)
IS
   direct_priv NUMBER;
   role_priv NUMBER;
BEGIN
   SELECT COUNT(*) INTO direct_priv
   FROM DBA_SYS_PRIVS
   WHERE GRANTEE = p_user
   AND PRIVILEGE = p_priv;

   SELECT COUNT(*) INTO role_priv
   FROM DBA_ROLE_PRIVS
   JOIN ROLE_SYS_PRIVS
   ON DBA_ROLE_PRIVS.GRANTED_ROLE = ROLE_SYS_PRIVS.ROLE
   WHERE DBA_ROLE_PRIVS.GRANTEE = p_user             
   AND ROLE_SYS_PRIVS.PRIVILEGE = p_priv;

   IF direct_priv > 0 THEN
      DBMS_OUTPUT.PUT_LINE('SI, DIRECTO');
   ELSIF role_priv > 0 THEN
      DBMS_OUTPUT.PUT_LINE('SI, POR ROL');
   ELSE
      DBMS_OUTPUT.PUT_LINE('NO');
   END IF;
END;
/
```

![24-1](img/Alumno%201/Oracle/24-1.png)

Creación de usuario de prueba y asignación de permisos:

```sql
alter session set "_ORACLE_SCRIPT"=true;
CREATE USER PACO IDENTIFIED BY PACO;
GRANT CREATE ANY TABLE,INSERT ANY TABLE,CREATE SESSION TO PACO;
```

![24-2](img/Alumno%201/Oracle/24-2.png)

Prueba con la opción: SI, DIRECTO

```sql
SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE='PACO';
exec mostrar_priv('PACO','CREATE ANY TABLE');
```

![24-3](img/Alumno%201/Oracle/24-3.png)

Creación del rol de prueba y asignación de permisos:

```sql
alter session set "_ORACLE_SCRIPT"=true;
CREATE ROLE eliminar_tablas;
GRANT DROP ANY TABLE TO eliminar_tablas;
GRANT eliminar_tablas TO PACO;
```

![24-4](img/Alumno%201/Oracle/24-4.png)

Prueba con la opción: SI, POR ROL

```sql
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE='PACO';
exec mostrar_priv('PACO','DROP ANY TABLE');
```

![24-5](img/Alumno%201/Oracle/24-5.png)

Prueba con la opción: NO

```sql
SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE='PACO';
exec mostrar_priv('PACO','DELETE ANY USER');
```

![24-6](img/Alumno%201/Oracle/24-6.png)

### **Ejercicio 25**

> **25. Realiza un procedimiento llamado MostrarNumSesiones que reciba un nombre de usuario y muestre el número de sesiones concurrentes que puede tener abiertas como máximo y las que tiene abiertas realmente.**

```sql
CREATE OR REPLACE FUNCTION f_devolver_perfil(p_user DBA_USERS.USERNAME%TYPE)
RETURN VARCHAR2
IS
   v_perfil DBA_USERS.PROFILE%TYPE;
BEGIN
   SELECT PROFILE INTO v_perfil
   FROM DBA_USERS
   WHERE USERNAME = p_user;
   RETURN v_perfil;
END;
/

CREATE OR REPLACE PROCEDURE sesiones_concurrentes (p_profile DBA_USERS.PROFILE%TYPE)
IS
   v_numero_sesiones VARCHAR2(100);
BEGIN
   SELECT LIMIT INTO v_numero_sesiones
   FROM DBA_PROFILES
   WHERE RESOURCE_NAME='SESSIONS_PER_USER' AND PROFILE=p_profile;
   DBMS_OUTPUT.PUT_LINE('Numero de sesiones concurrentes permitidas: '||v_numero_sesiones);
END;
/


CREATE OR REPLACE PROCEDURE MostrarNumSesiones (p_user V$SESSION.USERNAME%TYPE)
IS
   v_sessiones_abiertas NUMBER;
BEGIN
   SELECT count(*) INTO v_sessiones_abiertas
   FROM V$SESSION
   WHERE USERNAME = p_user;
   DBMS_OUTPUT.PUT_LINE('Numero de sesiones abiertas: '||v_sessiones_abiertas);
   sesiones_concurrentes(f_devolver_perfil(p_user));
END;
/
```

![25-1](img/Alumno%201/Oracle/25-1.png)

```sql
exec MostrarNumSesiones('PACO');
ALTER PROFILE DEFAULT LIMIT SESSIONS_PER_USER 3;
```

Y abrimos una sesión con este usuario en una ventana. Con esto realizado al ejecutarlo de nuevo veremos como funciona correctamente el procedimiento.

```sql
exec MostrarNumSesiones('PACO');
```

![25-2](img/Alumno%201/Oracle/25-2.png)

Para volver a definir el límite del perfil, en este caso DEFAULT, como ILIMITADO ejecutamos:

```sql
ALTER PROFILE DEFAULT LIMIT SESSIONS_PER_USER UNLIMITED;
```

---

✒️ **Documentación realizada por Paco Diz Ureña.**
