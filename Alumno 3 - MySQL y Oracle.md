# **ASGBD - Práctica Grupal 3: Usuarios**

## **Alumno 3 - MySQL y Oracle**

**Tabla de contenidos:**

- [**ASGBD - Práctica Grupal 3: Usuarios**](#asgbd---práctica-grupal-3-usuarios)
	- [**Alumno 3 - MySQL y Oracle**](#alumno-3---mysql-y-oracle)
	- [**MySQL**](#mysql)
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

## **MySQL**

### **Ejercicio 1**

> **1. Averigua que privilegios de sistema hay en MySQL y como se asignan a un usuario.**

- Privilegios globales: Es el nivel más alto de privilegios.

- Bases de datos: Incluye privilegios para administrar las bases de datos, cuentas de, usuarios, etc.

- Privilegios de base de datos: Como tenemos mas de una base de datos este se refiere a una única Base de Datos.

- Privilegios de tablas: Crear o modificar las filas o registros, sobre una tabla.

- Privilegios sobre columnas:  Privilegios que afectan a una columna en
concreto de una tabla.

- Privilegios sobre funciones: Privilegios que se usan sobre la creación y modificación de procedimientos.

- Privilegios sobre procedimientos: Privilegios que usan sobre la creación y modificación de procedimientos.

![1](img/Alumno%203/MySQL/1.png)

Para asignar los privilegios a un usuario utilizaremos la siguiente sintaxis.

```sql
GRANT "PRIVILEGIO" ON "TABLA-OBJECT" TO "USER"@"HOST" [IDENTIFIED BY "PASSWORD"] [WITH GRANT OPTION];
```

Para otorgar a un usuario la capacidad de eliminar tablas en la base de datos específica, usaremos DROP:

```sql
GRANT DROP ON basededatos.* TO 'usuario'@'localhost';
```

### **Ejercicio 2**

> **2. Averigua cual es la forma de asignar y revocar privilegios sobre una tabla concreta en MySQL.**

Permite hacer selects en la tabla emp de la base de datos scott al usuario usuario.

```sql
grant select on scott.emp to usuario@localhost
```

Revoca el privilegio de hacer selects en la tabla emp de la base de datos scott al usuario usuario.

```sql
revoke select on scott.emp to usuario@localhost
```

### **Ejercicio 3**

> **3. Averigua si existe el concepto de rol en MySQL y señala las diferencias con los roles de ORACLE.**

Los roles se introdujeron en MariaDB 10.0.5 .

**¿Para que sirven un ROL?**

En resumen es mas mas fácil cambiar el rol que tienen asignado muchos usuarios a cambiar cada permiso usuario por usuario.

Para crear un rol ejecutamos el siguiente comando;

```sql
CREATE ROLE GESTION;
```

![2](img/Alumno%203/MySQL/2.png)

Ahora hay que asignar derechos al rol que acabamos de crear de la misma manera que para un usuario.

```sql
GRANT CREATE USER ON *.* TO GESTION;
```

![3](img/Alumno%203/MySQL/3.png)

Ahora le damos el rol de gestión al usuario ‘carlos’.

```sql
GRANT GESTION TO 'carlos'@'%';
```

![4](img/Alumno%203/MySQL/4.png)

Ahora entraremos como el usuario domin y intentaremos crear un usuario. No nos va a dejar porque primero tendremos que activar el ROL.

![5](img/Alumno%203/MySQL/5.png)

Las diferencias entre MariaDB y Oracle son muy pocas ya que MariaDB pertenece a Oracle, y tiene mínimas diferencias en la gestión de roles. Algunas diferencias son que se pueden poner contraseñas a los roles.

### **Ejercicio 4**

> **4. Averigua si existe el concepto de perfil como conjunto de límites sobre el uso de recursos o sobre la contraseña en MySQL y señala las diferencias con los perfiles de ORACLE.**

Desde mariadb podemos aplicar restricciones a los usuarios de manera independiente estas son las siguientes.

- Número de consultas que un usuario pueda hacer cada hora.

- Número de updates que un usuario puede hacer cada hora.

- Número de veces que un usuario puede acceder al servidor a la hora.

- Número de conexiones simultaneas permitidas para cada usuario (como max_user_connections pero a nivel individual en lugar de global).

La sintaxis del comando seria la siguiente:

```sql
GRANT ALL ON prueba.* TO 'usuario'@'localhost'
->     WITH MAX_QUERIES_PER_HOUR 100
->          MAX_UPDATES_PER_HOUR 30
->          MAX_CONNECTIONS_PER_HOUR 200
->          MAX_USER_CONNECTIONS 10;
```

También si queremos modificar las contraseña utilizaremos los siguientes parámetros:

- default_password_lifetime: La duración que tendrá la contraseña antes de que expire por defecto es 0.

- disconnect_on_expired_password: Cuando se caduque la contraseña permiso al usuario entrar con privilegios restringidos.

La diferencia que tenemos con Oracle es que tenemos mayor personalización en el tema de los perfiles, en cuanto a limitar el sistema y las contraseñas. También en Oracle podemos asignar un perfil a un ROL y aquí tenemos que ir usuario por usuario que es mucho mas tedioso si tenemos muchos usuarios.

### **Ejercicio 5**

> **5. Realiza consultas al diccionario de datos de MySQL para averiguar todos los privilegios que tiene un usuario concreto.**

Para consultar los privilegios de un usuario en concreto ejecutaremos el siguiente comando:

```sql
show grants for 'carlos';
```

Como vemos de la práctica anterior tenemos un privilegio llamado ‘Gestión’ que es el establecido anteriormente.

![6](img/Alumno%203/MySQL/6.png)

### **Ejercicio 6**

> **6. Realiza consultas al diccionario de datos en MySQL para averiguar qué usuarios pueden consultar una tabla concreta.**

Para poder mirar quien puede consultar que tabla tenemos mysql.tables_priv en la cual aparecen los privilegios que tienen los usuarios sobre las tablas de la base de datos.
En mi caso como no tengo ningún usuario que pueda mirar una tabla en concreto solo aparece el usuario system.

![7](img/Alumno%203/MySQL/7.png)

---

## **Oracle**

### **Ejercicio 1**

> **1. Realiza un procedimiento llamado PermisosdeAsobreB que reciba dos nombres de usuario y muestre los permisos que tiene el primero de ellos sobre objetos del segundo.**

```sql
CREATE OR REPLACE PROCEDURE PermisosdeAsobreB (p_user1 IN VARCHAR2, p_user2 IN VARCHAR2) 
AS
BEGIN
  FOR obj IN (SELECT object_name, privilege FROM user_tab_privs WHERE grantee = p_user1 AND owner = p_user2) LOOP
    DBMS_OUTPUT.PUT_LINE(p_user1 || ' tiene el permiso ' || obj.privilege || ' sobre el objeto ' || obj.object_name || ' de ' || p_user2);
  END LOOP;
END;
/
```

### **Ejercicio 2**

> **2. Realiza un procedimiento llamado MostrarInfoPerfil que reciba el nombre de un perfil y muestre su composición y los usuarios que lo tienen asignado.**

```sql
create procedure Infoperfil (p_perfil dba_profiles.profile%type)
is
	cursor c_informacion
	is
	select resource_name, limit
	from dba_profiles
	where profile = p_perfil;
begin
	dbms_output.put_line('Composición de: '|| p_perfil);	
	for i in c_informacion loop
		dbms_output.put_line('Recurso: '|| i.resource_name || ' Límites: '|| i.limit);
	end loop;
end Infoperfil;
/


create procedure MostrarInfoPerfil (p_perfil dba_profiles.profile%type)
is
	cursor c_perfiles
	is
	select username
	from dba_users
	where profile = p_perfil;
begin 
	Infoperfil(p_perfil);
	for i in c_perfiles loop
		dbms_output.put_line('Usuarios con ese perfil: '|| i.username);
	end loop;
end MostrarInfoPerfil;
/
```

---

✒️ **Documentación realizada por Carlos Manuel Gámez Pérez de Guzmán.**
