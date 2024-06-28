/*
	TP Base de Datos 1
	Grupo 24
*/
-- 2)Creacion de la Base de Datos
CREATE SCHEMA IF NOT EXISTS automotriz;

-- Usar Base de Datos
USE automotriz;

-- -- Creacion de Tablas -- --

-- Modelo
CREATE TABLE modelo(
	id_modelo int primary key,
    nombre varchar(45) not null
);

-- Concensionario
CREATE TABLE concensionario(
	id_concensionario int primary key,
    nombre varchar(45) not null,
    direccion varchar(45) not null,
    telefono varchar(45)
);

-- Pedido
CREATE TABLE pedido(
	numero int primary key,
    fecha_hora datetime not null,
    concensionario_id_concensionario int not null,
    foreign key (concensionario_id_concensionario) references concensionario(id_concensionario)
);

-- Tabla intermedia Modelo - Pedido
CREATE TABLE detalle_del_pedido(
	cantidad int not null,
    modelo_id_modelo int not null,
    pedido_numero int not null,
    foreign key (modelo_id_modelo) references modelo(id_modelo),
    foreign key (pedido_numero) references pedido(numero)
);

-- Automovil
CREATE TABLE automovil(
	numero_de_chasis varchar(45) primary key,
    patente varchar(45) not null,
    fecha_finalizacion datetime,
    modelo_id_modelo int not null,
    pedido_numero int not null,
    foreign key (modelo_id_modelo) references modelo(id_modelo),
    foreign key (pedido_numero) references pedido(numero)
);

-- Linea de Montaje
CREATE TABLE linea_de_montaje(
	idlinea_de_montaje int primary key,
    modelo_id_modelo int not null,
    foreign key (modelo_id_modelo) references modelo(id_modelo)
);

-- Tarea
CREATE TABLE tarea(
	id_tarea int primary key,
    nombre varchar(45) not null
);

-- Estacion
CREATE TABLE estacion(
	id_estacion int primary key,
    orden int not null,
    tarea_id_tarea int not null,
    linea_de_montaje_idlinea_de_montaje int not null,
    foreign key (tarea_id_tarea) references tarea(id_tarea),
    foreign key (linea_de_montaje_idlinea_de_montaje) references linea_de_montaje(idlinea_de_montaje)
);

-- Tabla Intermedia Estacion - Automovil
CREATE TABLE estacion_CON_automovil(
	fecha_hora_ingreso datetime not null,
    fecha_hora_egreso datetime not null,
    estacion_id_estacion int not null,
    automovil_numero_de_chasis varchar(45) not null,
    foreign key (estacion_id_estacion) references estacion(id_estacion),
    foreign key (automovil_numero_de_chasis) references automovil(numero_de_chasis)
);

-- Insumo
CREATE TABLE insumo(
	codigo_insumo int primary key,
    descripcion_insumo varchar(45) not null,
    precio_insumo float not null
);

-- Tabla Intermedia Tarea - Insumo
CREATE TABLE tarea_CON_insumo(
	cantidad float not null,
    insumo_codigo_insumo int not null,
    tarea_id_tarea int not null,
    foreign key (insumo_codigo_insumo) references insumo(codigo_insumo),
    foreign key (tarea_id_tarea) references tarea(id_tarea)
);

-- Proveedor
CREATE TABLE proveedor(
	id_proveedor int primary key,
    nombre_proveedor varchar(45) not null,
    direccion_proveedor varchar(45) not null,
    telefono_proveedor varchar(45)
);

-- Compra
CREATE TABLE compra(
	numero_compra int primary key,
    fecha_hora datetime not null,
    proveedor_id_proveedor int not null,
    foreign key (proveedor_id_proveedor) references proveedor(id_proveedor)
);

-- Tabla Intermedia Compra- Insumo
CREATE TABLE detalle_compra_insumo(
	precio float not null,
    cantidad int not null,
    compra_numero_compra int not null,
    insumo_codigo_insumo int not null,
    foreign key (compra_numero_compra) references compra(numero_compra),
	foreign key (insumo_codigo_insumo) references insumo(codigo_insumo)
);

-- Ver tablas de la Base de Datos
SHOW TABLES;

-- 3)Construcción Stored Procedures para el Alta, la Baja y la Modificación de las entidades principales

-- Alta consecionario
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_concesionario_alta`(
	-- Parametros a recibir
	in pId int,
	in pNombre varchar(45), 
    in pDireccion varchar(45), 
    in pActivo boolean,
    in pTelefono varchar(45))
BEGIN -- Inicio de procedimiento
	-- Se crean dos variables a devolver
	DECLARE cMensaje varchar(45) DEFAULT "";
    DECLARE nResultado int DEFAULT 0;
    -- Si el ID ya existe, se cargan variables con mensajes de Error
	IF EXISTS(select id_concesionario from concesionario where id_concesionario=pId) THEN
		set cMensaje = "El concesionario ya existe en BD!";
        set nResultado = -1;
	-- Sino, se ingresan datos y cargan mensajes de Exito
	ELSE
		insert into concesionario(id_concesionario, nombre, direccion, activo, telefono) values (pId, pNombre, pDireccion, pActivo, pTelefono);
        set cMensaje = "Ingreso exitoso!";
        set nResultado = 0;
	END IF;
    -- Retorna los mensajes
    SELECT nResultado, cMensaje;
END

-- baja concecionario
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_concesionario_baja`(
	-- Parametros a recibir
	in pId int,
    in pActivo boolean)
BEGIN -- Inicio de procedimiento
	-- Se crean dos variables a devolver
	DECLARE cMensaje varchar(45) DEFAULT "";
    DECLARE nResultado int DEFAULT 0;
    -- Si el ID existe, se modifican el valor
	IF EXISTS(select id_concesionario from concesionario where id_concesionario=pId) THEN
		update concesionario set activo = pActivo where id_concesionario=pId;
		set cMensaje = "Operacion exitosa!";
        set nResultado = 0;
	-- Sino, se cargan mensajes de error
	ELSE
        set cMensaje = "Error, ID no existe en BD!";
        set nResultado = -1;
	END IF;
    -- Retorna los mensajes
    SELECT nResultado, cMensaje;
END 

-- modificar concecionario

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_concesionario_modificar`(
	-- Parametros a recibir
	in pId int,
	in pNombre varchar(45), 
    in pDireccion varchar(45),
    in pTelefono varchar(45))
BEGIN -- Inicio de procedimiento
	-- Se crean dos variables a devolver
	DECLARE cMensaje varchar(45) DEFAULT "";
    DECLARE nResultado int DEFAULT 0;
    -- Si el ID existe, se modifican los valores
	IF EXISTS(select id_concesionario from concesionario where id_concesionario=pId) THEN
		update concesionario set nombre = pNombre, direccion=pDireccion, telefono=pTelefono where id_concesionario=pId;
		set cMensaje = "Modificacion exitosa!";
        set nResultado = 0;
	-- Sino, se cargan mensajes de error
	ELSE

        set cMensaje = "Error, ID no existe en BD!";
        set nResultado = -1;
	END IF;
    -- Retorna los mensajes
    SELECT nResultado, cMensaje;
END


-- alta pedido
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_pedido_alta`(
	-- Parametros a recibir
	in pIdPedido int,
	in pNumero int,
   
BEGIN -- Inicio de procedimiento
	-- Se crean dos variables a devolver
	DECLARE cMensaje varchar(45) DEFAULT "";
    DECLARE nResultado int DEFAULT 0;
    -- Si el ID ya existe, se cargan variables con mensajes de Error
	IF EXISTS(select id_pedido from pedido where id_pedido=pIdPedido) THEN
		set cMensaje = "El pedido ya existe en BD!";
        set nResultado = -1;
	-- Sino, se ingresan datos y cargan mensajes de Exito
	ELSE
		insert into pedido(id_pedido,numero ) values (pIdPedido,numero );
        set cMensaje = "Ingreso exitoso!";
        set nResultado = 0;
	END IF;
    -- Retorna los mensajes
    SELECT nResultado, cMensaje;
END

-- baja pedido
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_pedido_baja`(
	-- Parametros a recibir
	in pIdPedido int,
	 in pActivo boolean)
BEGIN -- Inicio de procedimiento
	-- Se crean dos variables a devolver
	DECLARE cMensaje varchar(45) DEFAULT "";
    DECLARE nResultado int DEFAULT 0;
    -- Si el ID existe, se modifican el valor
	IF EXISTS(select id_pedido from pedido where id_pedido=pIdPedido) THEN
		update pedido set activo = pActivo where id_pedido=pIdPedido;
		set cMensaje = "Operacion exitosa!";
        set nResultado = 0;
	-- Sino, se cargan mensajes de error
	ELSE
        set cMensaje = "Error, ID no existe en BD!";
        set nResultado = -1;
	END IF;
    -- Retorna los mensajes
    SELECT nResultado, cMensaje;
END 

-- modificar pedido
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_pedido_modificar`(
	-- Parametros a recibir
	in pIdPedido int,
	in pNumero int,
BEGIN -- Inicio de procedimiento
	-- Se crean dos variables a devolver
	DECLARE cMensaje varchar(45) DEFAULT "";
    DECLARE nResultado int DEFAULT 0;
    -- Si el ID existe, se modifican los valores
	IF EXISTS(select id_pedido from pedido where id_pedido=pIdPedido) THEN
		update pedido set id_pedido = pIdPedido, numero=pNumero where id_pedido=pIdPedido;
		set cMensaje = "Modificacion exitosa!";
        set nResultado = 0;
	-- Sino, se cargan mensajes de error
	ELSE

        set cMensaje = "Error, ID no existe en BD!";
        set nResultado = -1;
	END IF;
    -- Retorna los mensajes
    SELECT nResultado, cMensaje;
END

-- alta proveedor
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_proveedor_alta`(
	in 	pRazonSocial varchar(45),
    out pID int,
    out pMensaje varchar(255),
    out nResultado INT
)
BEGIN
	if exists(select nombre, id from terminal_proveedores where nombre = pRazonSocial) then
		set pMensaje= 'La Razon Social ya Existe en la Base de Datos';
		set pID = (select id from terminal_proveedores where nombre = pRazonSocial);
        set nResultado = -1;
    else
		insert into terminal_proveedores(nombre) values(pRazonSocial);
		set pMensaje= 'Ingreso Exitoso';
        set pID = (select id from terminal_proveedores where nombre = pRazonSocial);
        set nResultado = 0;
    end if;
END

-- baja proveedor
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_proveedor_baja`(
	in pID int,
    out pMensaje varchar(255),
    out nResultado INT
)
BEGIN
	update terminal_proveedores set eliminado = 1, eliminadoFecha = now() where id = pID;
    IF (SELECT row_count() > 0) THEN
		set pMensaje = "Proveedor dada de Baja Correctamente";
        set nResultado = 0;
	ELSE 
		set pMensaje = "ID de Proveedor no Encontrado";
        set nResultado = -1;
    END IF;
END

-- modificar proveedor
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_proveedor_modificar`(
	in pID int,
	in pNuevoNombre varchar(45),
    out pMensaje VARCHAR(255),
    out nResultado INT
)
BEGIN
	update terminal_proveedores set nombre = pNuevoNombre where id = pID;
    IF( row_count() > 0 ) THEN
		set pMensaje = "Proveedor Modificado Correctamente";
        set nResultado = 0;
    ELSE
		set pMensaje = "No se Encontro el Proveedor";
        set nResultado = -1;
    END IF;
END

-- insumo alta
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insumo_alta`(
	in CodigoInsumo INT,
	in NombreInsumo VARCHAR(45),
    in DescInsumo VARCHAR(45),
    in StockInicial INT,
    out nResultado INT,
    out cMensaje VARCHAR(45)
)
BEGIN
	IF(EXISTS(SELECT * FROM insumos WHERE id = CodigoInsumo)) THEN
		set cMensaje = "Ya esta cargado el Insumo";
        set nResultado = -1;
    ELSE
		INSERT INTO insumos (id, nombre, descripcion, stock) VALUES (CodigoInsumo, NombreInsumo, DescInsumo, StockInicial);
		set cMensaje = "Insumo Cargado Exitosamente";
        set nResultado = 0;
    END IF;
END

