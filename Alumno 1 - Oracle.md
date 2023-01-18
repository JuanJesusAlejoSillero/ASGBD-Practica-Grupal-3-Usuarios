# **ASGBD - Práctica Grupal 3: Usuarios**

## **Alumno 1 - Oracle**

**Tabla de contenidos:**

- [**ASGBD - Práctica Grupal 3: Usuarios**](#asgbd---práctica-grupal-3-usuarios)
  - [**Alumno 1 - PostgreSQL y Oracle**](#alumno-1---oracle)
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

alter session set "_ORACLE_SCRIPT"=true;

> **1. Crea un rol ROLPRACTICA1 con los privilegios necesarios para conectarse a la base de datos, crear tablas y vistas e insertar datos en la tabla EMP de SCOTT.**

   ```sql
   CREATE ROLE ROLPRACTICA1;
   GRANT CONNECT,CREATE TABLE,CREATE VIEW,INSERT ON SCOTT.EMP TO ROLPRACTICA1;
   ```

### **Ejercicio 2**

> **2. Crea un usuario USRPRACTICA1 con el tablespace USERS por defecto y averigua que cuota se le ha asignado por defecto en el mismo. Sustitúyela por una cuota de 1M.**

```sql
CREATE USER USRPRACTICA1 IDENTIFIED BY USRPRACTICA1 DEFAULT TABLESPACE USERS;
```

Por defecto viene en 0M por lo que al hacer la siguiente consulta el usuario no aparece en la tabla dba_ts_quotas. Pruebas:

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

### **Ejercicio 3**

> **3. Modifica el usuario USRPRACTICA1 para que tenga cuota 0 en el tablespace SYSTEM.**

```sql
ALTER USER USRPRACTICA1 QUOTA 0M ON SYSTEM;
```

### **Ejercicio 4**

> **4. Concede a USRPRACTICA1 el ROLPRACTICA1.**

```sql
GRANT ROLPRACTICA1 TO USRPRACTICA1;
```

### **Ejercicio 5**

> **5. Concede a USRPRACTICA1 el privilegio de crear tablas e insertar datos en el esquema de cualquier usuario. Prueba el privilegio. Comprueba si puede modificar la estructura o eliminar las tablas creadas.**

```sql
GRANT CREATE ANY TABLE,INSERT ANY TABLE TO USRPRACTICA1;

CREATE TABLE SCOTT.NUEVA_TAB(campo1 VARCHAR2(15));

INSERT INTO SCOTT.NUEVA_TAB (campo1) VALUES ('prueba1');

ALTER TABLE SCOTT.DEPT ADD prueba VARCHAR2(10); 

ALTER TABLE SCOTT.DEPT DROP COLUMN LOC;
```

### **Ejercicio 6**

> **6. Concede a USRPRACTICA1 el privilegio de leer la tabla DEPT de SCOTT con la posibilidad de que lo pase a su vez a terceros usuarios.**

```sql
GRANT SELECT ON SCOTT.DEPT TO USRPRACTICA1 WITH GRANT OPTION;
```

### **Ejercicio 7**

> **7. Comprueba que USRPRACTICA1 puede realizar todas las operaciones previstas en el rol.**

```sql
CONNECT USRPRACTICA1/USRPRACTICA1;

CREATE TABLE TABLA_NUEVA(campo1 VARCHAR2(15));


CREATE VIEW emp_view AS
SELECT ename, job
FROM emp;

DESCRIBE emp_view;
SELECT * FROM emp_view;


INSERT INTO SCOTT.EMP (empno, ename, job, sal, deptno)
VALUES (9000, 'Paco', 'MANAGER', 3000, 20);
```


### **Ejercicio 8**

> **8. Quita a USRPRACTICA1 el privilegio de crear vistas. Comprueba que ya no puede hacerlo.**

```sql
REVOKE CREATE VIEW FROM USRPRACTICA1;

CREATE VIEW emp2_view AS
SELECT ename, job
FROM emp;
```

### **Ejercicio 9**

> **9. Crea un perfil NOPARESDECURRAR que limita a dos el número de minutos de inactividad permitidos en una sesión.**

```sql
CREATE PROFILE NOPARESDECURRAR LIMIT IDLE_TIME 2;
```

### **Ejercicio 10**

> **10. Activa el uso de perfiles en ORACLE.**

En la versión que usamos viene ya por defecto activado. De hecho vienen activados por defecto desde la versión de oracle 9i(2001). Se activaban de la siguiente forma:

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
ALTER USER USRPRACTICA1 PROFILE CONTRASEÑASEGURA;

CONNECT USRPRACTICA1/USRPRACTICA1 -- 3 veces hasta fallar
```

### **Ejercicio 14**

> **14. Consulta qué usuarios existen en tu base de datos.**

```sql
SELECT USERNAME FROM DBA_USERS;
```

### **Ejercicio 15**

> **15. Elige un usuario concreto y consulta qué cuota tiene sobre cada uno de los tablespaces.**

```sql
SELECT USERNAME, TABLESPACE_NAME, MAX_BYTES, BYTES
FROM DBA_TS_QUOTAS
WHERE USERNAME = 'MDSYS';
```

### **Ejercicio 16**

> **16. Elige un usuario concreto y muestra qué privilegios de sistema tiene asignados.**

```sql
SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE GRANTEE = 'AUDSYS';
```

### **Ejercicio 17**

> **17. Elige un usuario concreto y muestra qué privilegios sobre objetos tiene asignados.**

```sql
SELECT GRANTEE, TABLE_NAME, PRIVILEGE, GRANTOR
FROM DBA_TAB_PRIVS
WHERE GRANTEE = 'SYS';
```

### **Ejercicio 18**

> **18. Consulta qué roles existen en tu base de datos.**

```sql
SELECT ROLE FROM DBA_ROLES;
```

### **Ejercicio 19**

> **19. Elige un rol concreto y consulta qué usuarios lo tienen asignado.**

```sql
SELECT GRANTEE
FROM DBA_ROLE_PRIVS
WHERE GRANTED_ROLE = 'DBA';
```

### **Ejercicio 20**

> **20. Elige un rol concreto y averigua si está compuesto por otros roles o no.**

```sql
SELECT ROLE, GRANTED_ROLE
FROM ROLE_ROLE_PRIVS
WHERE ROLE='DBA';
```

### **Ejercicio 21**

> **21. Consulta qué perfiles existen en tu base de datos.**

```sql
SELECT PROFILE FROM DBA_PROFILES;
```

### **Ejercicio 22**

> **22. Elige un perfil y consulta qué límites se establecen en el mismo.**

```sql
SELECT PROFILE, LIMIT
FROM DBA_PROFILES
WHERE PROFILE='DEFAULT';
```

### **Ejercicio 23**

> **23. Muestra los nombres de los usuarios que tienen limitado el número de sesiones concurrentes.**

No existe ningún perful con límite en mi sistema oracle por lo cual voy a cambiar el perfil creado "NOPARESDECURRAR" a 3 sesiones concurrentes, con:

```sql
ALTER PROFILE NOPARESDECURRAR LIMIT SESSIONS_PER_USER 3;

SELECT PROFILE, RESOURCE_NAME, LIMIT
FROM DBA_PROFILES
WHERE RESOURCE_NAME='SESSIONS_PER_USER' AND PROFILE='NOPARESDECURRAR';
```