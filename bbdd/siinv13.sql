-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 05-11-2026 a las 17:30:51
-- Versión del servidor: 10.11.16-MariaDB
-- Versión de PHP: 8.3.36

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `siinv13`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_bien_ml_Q01` (IN `p_idSala` INT, IN `p_buscar` VARCHAR(60))   BEGIN
    SELECT B.idBien, B.cbi, B.descripcion, T.nombre AS Tipo, M.nombre AS Marca, MO.nombre AS Modelo, E.nombre AS Estado, G.nombre AS Grupo, B.serieMedida, B.otrasEspecificaciones, B.fechaCreacion, B.fechaModificacion, B.idUsuarioCrea, B.idUsuarioModifica
    FROM BIEN B
    LEFT JOIN TIPO T ON B.idTipo = T.idTipo
    LEFT JOIN MARCA M ON B.idMarca = M.idMarca
    LEFT JOIN MODELO MO ON B.idModelo = MO.idModelo
    LEFT JOIN ESTADO E ON B.idEstado = E.idEstado
    LEFT JOIN GRUPO G ON B.idGrupo = G.idGrupo
    WHERE B.idSala = p_idSala
      AND B.st_registro = 1
      AND B.descripcion LIKE CONCAT('%', p_buscar, '%')
    ORDER BY B.descripcion;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_bien_mt_D01` (IN `p_idBien` INT, IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_bien_mt_validarEliminar_Q01(p_idBien, p_valid);

    IF p_valid = '1' THEN
        UPDATE BIEN
        SET st_registro          = 0,
            idUsuarioModifica    = p_idUsuario,
            fechaModificacion    = NOW(),
            pcTerminalModifica   = p_pcTerminal
        WHERE idBien = p_idBien;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_bien_mt_I01` (INOUT `p_idBien` INT, IN `p_idSala` INT, IN `p_idGrupo` INT, IN `p_cbi` VARCHAR(10), IN `p_idTipo` INT, IN `p_descripcion` VARCHAR(100), IN `p_idMarca` INT, IN `p_idModelo` INT, IN `p_serieMedida` VARCHAR(100), IN `p_idEstado` INT, IN `p_otrasEspecificaciones` VARCHAR(100), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_bien_mt_validar_Q01(p_idBien, p_idSala, p_cbi, p_valid);

    IF p_valid = '1' THEN
        INSERT INTO BIEN (idSala, idGrupo, cbi, idTipo, descripcion, idMarca, idModelo, serieMedida, idEstado, otrasEspecificaciones, st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea)
        VALUES (p_idSala, p_idGrupo, p_cbi, p_idTipo, p_descripcion, p_idMarca, p_idModelo, p_serieMedida, p_idEstado, p_otrasEspecificaciones, 1, p_idUsuario, NOW(), p_pcTerminal);

        SET p_idBien = LAST_INSERT_ID();
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_bien_mt_Q01` (IN `p_idBien` INT, OUT `p_idSala` INT, OUT `p_idGrupo` INT, OUT `p_cbi` VARCHAR(10), OUT `p_idTipo` INT, OUT `p_descripcion` VARCHAR(100), OUT `p_idMarca` INT, OUT `p_idModelo` INT, OUT `p_serieMedida` VARCHAR(100), OUT `p_idEstado` INT, OUT `p_otrasEspecificaciones` VARCHAR(100))   BEGIN
    SELECT idSala, idGrupo, cbi, idTipo, descripcion, idMarca, idModelo, serieMedida, idEstado, otrasEspecificaciones
    INTO p_idSala, p_idGrupo, p_cbi, p_idTipo, p_descripcion, p_idMarca, p_idModelo, p_serieMedida, p_idEstado, p_otrasEspecificaciones
    FROM BIEN
    WHERE idBien = p_idBien;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_bien_mt_U01` (IN `p_idBien` INT, IN `p_idSala` INT, IN `p_idGrupo` INT, IN `p_cbi` VARCHAR(10), IN `p_idTipo` INT, IN `p_descripcion` VARCHAR(100), IN `p_idMarca` INT, IN `p_idModelo` INT, IN `p_serieMedida` VARCHAR(100), IN `p_idEstado` INT, IN `p_otrasEspecificaciones` VARCHAR(100), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_bien_mt_validar_Q01(p_idBien, p_idSala, p_cbi, p_valid);

    IF p_valid = '1' THEN
        UPDATE BIEN
        SET idSala                = p_idSala,
            idGrupo               = p_idGrupo,
            cbi                   = p_cbi,
            idTipo                = p_idTipo,
            descripcion           = p_descripcion,
            idMarca               = p_idMarca,
            idModelo              = p_idModelo,
            serieMedida           = p_serieMedida,
            idEstado              = p_idEstado,
            otrasEspecificaciones = p_otrasEspecificaciones,
            idUsuarioModifica     = p_idUsuario,
            fechaModificacion     = NOW(),
            pcTerminalModifica    = p_pcTerminal
        WHERE idBien = p_idBien;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_bien_mt_validarEliminar_Q01` (IN `p_idBien` INT, OUT `p_valid` VARCHAR(500))   BEGIN
    SET p_valid = '1';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_bien_mt_validar_Q01` (IN `p_idBien` INT, IN `p_idSala` INT, IN `p_cbi` VARCHAR(10), OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idBien) INTO v_count
    FROM BIEN
    WHERE idSala = p_idSala
      AND st_registro = 1
      AND cbi = p_cbi
      AND idBien != IFNULL(p_idBien, 0);

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El CBI "', p_cbi, '" ya existe en esta sala.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_bien_rp_por_estado` (IN `p_idEstado` INT, IN `p_idSala` INT, IN `p_idProgramaEstudio` INT)   BEGIN
    SELECT  
        PE.nombre AS ProgramaEstudio,
        S.nombre AS NombreSala,
        IFNULL(I.nombreCoordinadorArea, 'POR ASIGNAR') AS Coordinador,
        IFNULL(I.nombreAsistenteAreaT1, 'POR ASIGNAR') AS AsistenteT1,
        IFNULL(I.nombreAsistenteAreaT2, 'POR ASIGNAR') AS AsistenteT2,
        CONCAT('Coordinador del Area Académica ', IFNULL(PE.abreviatura, '')) AS CargoCoordinador,
        B.idBien,
        G.nombre AS Grupo,
        B.cbi AS CBI,
        B.descripcion AS DescripcionBien,
        IFNULL(M.nombre, 'S/M') AS Marca,
        IFNULL(MODL.nombre, 'S/M') AS Modelo,
        B.serieMedida AS Serie,
        EST.nombre AS Estado,
        B.otrasEspecificaciones AS Observaciones
    FROM BIEN B
    INNER JOIN SALA S ON B.idSala = S.idSala
    INNER JOIN PROGRAMAESTUDIO PE ON S.idProgramaEstudio = PE.idProgramaEstudio
    INNER JOIN ESTADO EST ON B.idEstado = EST.idEstado
    INNER JOIN GRUPO G ON B.idGrupo = G.idGrupo
    LEFT JOIN INVENTARIO I ON I.idProgramaEstudio = PE.idProgramaEstudio
    LEFT JOIN MARCA M ON B.idMarca = M.idMarca
    LEFT JOIN MODELO MODL ON B.idModelo = MODL.idModelo
    WHERE PE.idProgramaEstudio = p_idProgramaEstudio
      AND (IFNULL(p_idEstado, 0) = 0 OR B.idEstado = p_idEstado)
      AND (IFNULL(p_idSala, 0) = 0 OR B.idSala = p_idSala)
      AND B.st_registro = 1
    ORDER BY S.nombre, B.descripcion;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estado_ml_Q01` (IN `p_buscar` VARCHAR(60))   BEGIN
    SELECT idEstado, nombre
    FROM ESTADO
    WHERE st_registro = 1
      AND nombre LIKE CONCAT('%', p_buscar, '%')
    ORDER BY nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estado_mt_D01` (IN `p_idEstado` INT, IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_estado_mt_validarEliminar_Q01(p_idEstado, p_valid);

    IF p_valid = '1' THEN
        UPDATE ESTADO
        SET st_registro         = 0,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idEstado = p_idEstado;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estado_mt_I01` (IN `p_idEstado` INT, IN `p_nombre` VARCHAR(60), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_estado_mt_validar_Q01(p_idEstado, p_nombre, p_valid);

    IF p_valid = '1' THEN
        INSERT INTO ESTADO (idEstado, nombre, st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea)
        VALUES (p_idEstado, p_nombre, 1, p_idUsuario, NOW(), p_pcTerminal);
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estado_mt_Q01` (IN `p_idEstado` INT, OUT `p_nombre` VARCHAR(60))   BEGIN
    SELECT nombre INTO p_nombre
    FROM ESTADO
    WHERE idEstado = p_idEstado;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estado_mt_U01` (IN `p_idEstado` INT, IN `p_nombre` VARCHAR(60), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_estado_mt_validar_Q01(p_idEstado, p_nombre, p_valid);

    IF p_valid = '1' THEN
        UPDATE ESTADO
        SET nombre              = p_nombre,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idEstado = p_idEstado;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estado_mt_validarEliminar_Q01` (IN `p_idEstado` INT, OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idBien) INTO v_count
    FROM BIEN
    WHERE idEstado = p_idEstado
      AND st_registro = 1;

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El estado tiene bienes asociados.', CHAR(13), 'No puede ser ELIMINADO.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estado_mt_validar_Q01` (IN `p_idEstado` INT, IN `p_nombre` VARCHAR(60), OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idEstado) INTO v_count
    FROM ESTADO
    WHERE st_registro = 1
      AND nombre = p_nombre
      AND idEstado != IFNULL(p_idEstado, 0);

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El estado "', p_nombre, '" ya existe.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_grupo_ml_Q01` (IN `p_idProgramaEstudio` INT, IN `p_buscar` VARCHAR(60))   BEGIN
    SELECT idGrupo, nombre, idUsuarioCrea, fechaCreacion, idUsuarioModifica, fechaModificacion
    FROM GRUPO
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND nombre LIKE CONCAT('%', p_buscar, '%')
      AND st_registro = 1
    ORDER BY nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_grupo_mt_D01` (IN `p_idGrupo` INT, IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_grupo_mt_validarEliminar_Q01(p_idGrupo, p_valid);

    IF p_valid = '1' THEN
        UPDATE GRUPO
        SET st_registro         = 0,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idGrupo = p_idGrupo;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_grupo_mt_I01` (INOUT `p_idGrupo` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_grupo_mt_validar_Q01(p_idGrupo, p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        INSERT INTO GRUPO (idProgramaEstudio, nombre, st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea)
        VALUES (p_idProgramaEstudio, p_nombre, 1, p_idUsuario, NOW(), p_pcTerminal);

        SET p_idGrupo = LAST_INSERT_ID();
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_grupo_mt_Q01` (IN `p_idGrupo` INT, OUT `p_idProgramaEstudio` INT, OUT `p_nombre` VARCHAR(60))   BEGIN
    SELECT idProgramaEstudio, nombre
    INTO p_idProgramaEstudio, p_nombre
    FROM GRUPO
    WHERE idGrupo = p_idGrupo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_grupo_mt_U01` (IN `p_idGrupo` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_grupo_mt_validar_Q01(p_idGrupo, p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        UPDATE GRUPO
        SET idProgramaEstudio   = p_idProgramaEstudio,
            nombre              = p_nombre,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idGrupo = p_idGrupo;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_grupo_mt_validarEliminar_Q01` (IN `p_idGrupo` INT, OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idBien) INTO v_count
    FROM BIEN
    WHERE idGrupo = p_idGrupo
      AND st_registro = 1;

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El grupo tiene bienes asociados.', CHAR(13), 'No puede ser ELIMINADO.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_grupo_mt_validar_Q01` (IN `p_idGrupo` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idGrupo) INTO v_count
    FROM GRUPO
    WHERE st_registro = 1
      AND idProgramaEstudio = p_idProgramaEstudio
      AND nombre = p_nombre
      AND idGrupo != IFNULL(p_idGrupo, 0);

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El grupo "', p_nombre, '" ya existe en este programa.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_inventarioDetalle_ml_Q01` (IN `p_idInventario` INT, IN `p_idSala` INT, IN `p_operacion` VARCHAR(20))   BEGIN
    IF p_operacion = 'NUEVO' THEN
        SELECT  0 AS idInventarioDetalle,
                B.idBien, 
                G.nombre AS GRUPO, 
                B.cbi AS CBI, 
                B.descripcion AS DESCRIPCION, 
                M.nombre AS MARCA,
                MO.nombre AS MODELO,
                B.serieMedida AS SERIE_MEDIDA, 
                B.otrasEspecificaciones AS OTRAS_ESPECIFICACIONES,
                E.nombre AS ESTADO,
                '' AS NRO_DRELM
        FROM BIEN B 
        INNER JOIN SALA S ON S.idSala = B.idSala 
        INNER JOIN GRUPO G ON G.idGrupo = B.idGrupo 
        INNER JOIN TIPO T ON T.idTipo = B.idTipo 
        INNER JOIN MARCA M ON M.idMarca = B.idMarca 
        INNER JOIN MODELO MO ON MO.idModelo = B.idModelo 
        INNER JOIN ESTADO E ON E.idEstado = B.idEstado
        WHERE B.idSala = p_idSala
          AND B.st_registro = 1
        ORDER BY G.nombre, B.descripcion;
    ELSE
        SELECT  idInventarioDetalle,
                idBien,
                nombreGrupo AS GRUPO,
                cbi AS CBI,
                descripcion AS DESCRIPCION,
                nombreMarca AS MARCA,
                nombreModelo AS MODELO,
                serieMedida AS SERIE_MEDIDA,
                otrasEspecificaciones AS OTRAS_ESPECIFICACIONES,
                nombreEstado AS ESTADO,
                nroDRELM AS NRO_DRELM
        FROM INVENTARIO_DETALLE
        WHERE idInventario = p_idInventario
          AND st_registro = 1
        ORDER BY nombreGrupo, descripcion;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_inventarioDetalle_mt_I01` (INOUT `p_idInventarioDetalle` INT, IN `p_idInventario` INT, IN `p_idBien` INT, IN `p_nroDRELM` VARCHAR(10), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100))   BEGIN
    INSERT INTO INVENTARIO_DETALLE (
        idInventario, idBien, idGrupo, nombreGrupo, nroDRELM, cbi, idTipo, nombreTipo, descripcion, idMarca, nombreMarca,
        idModelo, nombreModelo, serieMedida, idEstado, nombreEstado, otrasEspecificaciones, st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea
    )
    SELECT  p_idInventario, B.idBien, B.idGrupo, G.nombre, p_nroDRELM, B.cbi, B.idTipo, T.nombre, B.descripcion, B.idMarca, M.nombre,
            B.idModelo, MO.nombre, B.serieMedida, B.idEstado, E.nombre, B.otrasEspecificaciones, 1, p_idUsuario, NOW(), p_pcTerminal
    FROM BIEN B 
    INNER JOIN GRUPO G ON G.idGrupo = B.idGrupo 
    INNER JOIN TIPO T ON T.idTipo = B.idTipo 
    INNER JOIN MARCA M ON M.idMarca = B.idMarca 
    INNER JOIN MODELO MO ON MO.idModelo = B.idModelo 
    INNER JOIN ESTADO E ON E.idEstado = B.idEstado
    WHERE B.idBien = p_idBien;

    SET p_idInventarioDetalle = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_inventarioDetalle_mt_U01` (IN `p_idInventarioDetalle` INT, IN `p_idInventario` INT, IN `p_idBien` INT, IN `p_nroDRELM` VARCHAR(10), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100))   BEGIN
    UPDATE INVENTARIO_DETALLE
    SET nroDRELM            = p_nroDRELM,
        idUsuarioModifica   = p_idUsuario,
        fechaModificacion   = NOW(),
        pcTerminalModifica  = p_pcTerminal
    WHERE idInventarioDetalle = p_idInventarioDetalle;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_inventario_ml_Q01` (IN `p_idProgramaEstudio` INT, IN `p_buscar` VARCHAR(100))   BEGIN
    IF p_idProgramaEstudio IS NULL THEN SET p_idProgramaEstudio = 2; END IF;
    IF p_buscar IS NULL THEN SET p_buscar = ''; END IF;

    SELECT  I.idInventario AS `idInventario`,
            CONCAT(I.serie, '-', I.numero) AS `INVENTARIO`,
            I.nombreSala AS `SALA`,
            I.nombreCoordinadorArea AS `COORDINADOR`,
            I.nombreAsistenteAreaT1 AS `ASISTENTE T1`,
            I.nombreAsistenteAreaT2 AS `ASISTENTE T2`,
            I.fechaEntrega AS `FECHA ENTREGA`,
            I.observacion AS `OBSERVACION`,
            IFNULL(D.cantidadBienes,0) AS `CANTIDAD DE BIENES`,
            I.st_inventario AS `ESTADO`
    FROM INVENTARIO I 
    LEFT JOIN (
        SELECT idInventario, COUNT(idInventarioDetalle) AS cantidadBienes
        FROM INVENTARIO_DETALLE
        WHERE st_registro = 1
        GROUP BY idInventario
    ) D ON D.idInventario = I.idInventario
    WHERE I.st_registro = 1
      AND I.idProgramaEstudio = p_idProgramaEstudio
      AND CONCAT(I.serie, '-', I.numero, '|', I.nombreSala) LIKE CONCAT('%', p_buscar, '%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_inventario_mt_i01` (INOUT `p_idInventario` INT, IN `p_idProgramaEstudio` INT, IN `p_serie` CHAR(4), OUT `p_numero` VARCHAR(8), IN `p_idSala` INT, IN `p_fechaEntrega` DATE, IN `p_observacion` VARCHAR(500), IN `p_st_inventario` VARCHAR(10), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100))   BEGIN
    DECLARE v_max INT;

    SELECT IFNULL(MAX(CAST(numero AS UNSIGNED)), 0) + 1 INTO v_max
    FROM INVENTARIO
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND serie = p_serie;

    SET p_numero = CAST(v_max AS CHAR);

    INSERT INTO INVENTARIO (
        idProgramaEstudio, serie, numero, idSala, nombreSala, idCoordinadorArea, nombreCoordinadorArea,
        idAsistenteAreaT1, nombreAsistenteAreaT1, idAsistenteAreaT2, nombreAsistenteAreaT2,
        fechaEntrega, observacion, st_inventario, st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea
    )
    SELECT  P.idProgramaEstudio, p_serie, p_numero, S.idSala, S.nombre, C.idPersonal, CONCAT(C.apellidos, ' ', C.nombres),
            A1.idPersonal, CONCAT(A1.apellidos, ' ', A1.nombres), A2.idPersonal, CONCAT(A2.apellidos, ' ', A2.nombres),
            p_fechaEntrega, p_observacion, p_st_inventario, 1, p_idUsuario, NOW(), p_pcTerminal
    FROM PROGRAMAESTUDIO P 
    INNER JOIN SALA S ON S.idProgramaEstudio = P.idProgramaEstudio 
    INNER JOIN PERSONAL C ON C.idPersonal = P.idCoordinadorArea 
    INNER JOIN PERSONAL A1 ON A1.idPersonal = P.idAsistenteAreaT1 
    INNER JOIN PERSONAL A2 ON A2.idPersonal = P.idAsistenteAreaT2
    WHERE P.idProgramaEstudio = p_idProgramaEstudio
      AND S.idSala = p_idSala;

    SET p_idInventario = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_inventario_mt_Q01` (IN `p_idProgramaEstudio` INT, IN `p_operacion` VARCHAR(20), IN `p_idInventario` INT, OUT `p_idSala` INT, OUT `p_serie` CHAR(4), OUT `p_numero` VARCHAR(8), OUT `p_coordinadorArea` VARCHAR(100), OUT `p_asistenteAreaT1` VARCHAR(100), OUT `p_asistenteAreaT2` VARCHAR(100), OUT `p_fechaEntrega` DATE, OUT `p_st_inventario` VARCHAR(10), OUT `p_observacion` VARCHAR(500))   BEGIN
    IF p_operacion = 'NUEVO' THEN
        SELECT  0,
                CAST(YEAR(NOW()) AS CHAR(4)),
                '',
                IFNULL(CONCAT(CO.apellidos, ' ', CO.nombres), ''),
                IFNULL(CONCAT(A1.apellidos, ' ', A1.nombres), ''),
                IFNULL(CONCAT(A2.apellidos, ' ', A2.nombres), ''),
                CURDATE(),
                'ABIERTO',
                ''
        INTO p_idSala, p_serie, p_numero, p_coordinadorArea, p_asistenteAreaT1, p_asistenteAreaT2, p_fechaEntrega, p_st_inventario, p_observacion
        FROM PROGRAMAESTUDIO P 
        LEFT JOIN PERSONAL CO ON CO.idPersonal = P.idCoordinadorArea 
        LEFT JOIN PERSONAL A1 ON A1.idPersonal = P.idAsistenteAreaT1 
        LEFT JOIN PERSONAL A2 ON A2.idPersonal = P.idAsistenteAreaT2
        WHERE P.idProgramaEstudio = p_idProgramaEstudio;
    ELSE
        SELECT  idSala, serie, numero, nombreCoordinadorArea, nombreAsistenteAreaT1, nombreAsistenteAreaT2, fechaEntrega, st_inventario, observacion
        INTO p_idSala, p_serie, p_numero, p_coordinadorArea, p_asistenteAreaT1, p_asistenteAreaT2, p_fechaEntrega, p_st_inventario, p_observacion
        FROM INVENTARIO
        WHERE idInventario = p_idInventario;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_inventario_mt_U01` (IN `p_idInventario` INT, IN `p_fechaEntrega` DATE, IN `p_observacion` VARCHAR(500), IN `p_st_inventario` VARCHAR(10), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100))   BEGIN
    UPDATE INVENTARIO
    SET fechaEntrega        = p_fechaEntrega,
        observacion         = p_observacion,
        st_inventario       = p_st_inventario,
        idUsuarioModifica   = p_idUsuario,
        fechaModificacion   = NOW(),
        pcTerminalModifica  = p_pcTerminal
    WHERE idInventario = p_idInventario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_inventario_obtenerSalas_ml_Q01` (IN `p_idProgramaEstudio` INT)   BEGIN
    SELECT idSala, nombre
    FROM SALA
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND st_registro = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_inventario_rp_listarInventarios_Q01` (IN `p_idProgramaEstudio` INT)   BEGIN
    SELECT idInventario, CONCAT(DATE_FORMAT(fechaEntrega, '%d/%m/%Y'), ' - ', nombreSala) AS inventario
    FROM INVENTARIO
    WHERE idProgramaEstudio = p_idProgramaEstudio
    ORDER BY fechaEntrega DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_inventario_rp_Q01` (IN `p_idInventario` INT)   BEGIN
    SELECT  I.idInventario AS `idInventario`,
            INS.nombre AS `INSTITUCION`,
            I.nombreCoordinadorArea AS `COODINADOR`,
            I.nombreAsistenteAreaT1 AS `ASISTENTE T1`,
            I.nombreAsistenteAreaT2 AS `ASISTENTE T2`,
            I.nombreSala AS `SALA`,
            I.fechaEntrega AS `FECHA DE ENTREGA`,
            D.nombreGrupo AS `GRUPO`,
            D.nroDRELM AS `INV DRELM`,
            D.cbi AS `CBI`,
            D.descripcion AS `DESCRIPCION`,
            D.nombreMarca AS `MARCA`,
            D.nombreModelo AS `MODELO`,
            D.serieMedida AS `SERIE/MEDIDA`,
            D.nombreEstado AS `ESTADO`,
            D.otrasEspecificaciones AS `OTRAS ESPECIFICACIONES`,
            CONCAT('INVENTARIO DE ', I.nombreSala) AS titulo,
            CONCAT('Coordinador del Area Académica ', PE.abreviatura) AS cargoCoodinador,
            CONCAT('Asistente del area de ', PE.abreviatura, ' T1') AS cargoAsistenteT1,
            CONCAT('Asistente del area de ', PE.abreviatura, ' T1') AS cargoAsistenteT2
    FROM INVENTARIO I 
    INNER JOIN INVENTARIO_DETALLE D ON D.idInventario = I.idInventario 
    INNER JOIN PROGRAMAESTUDIO PE ON PE.idProgramaEstudio = I.idProgramaEstudio 
    INNER JOIN INSTITUCION INS ON INS.idInstitucion = PE.idInstitucion
    WHERE I.idInventario = p_idInventario
    ORDER BY D.nombreGrupo, D.descripcion, D.cbi;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_acceso_Q01` (IN `p_idUsuario` VARCHAR(15), IN `p_contraseña` VARCHAR(60), OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;

    SELECT COUNT(idUsuario) INTO v_count
    FROM USUARIO 
    WHERE idUsuario = p_idUsuario 
      AND contraseña = p_contraseña
      AND activo = 1
      AND st_registro = 1;

    IF v_count > 0 THEN
        SET p_valid = '1';
    ELSE
        SET p_valid = CONCAT('Datos Invalidos', CHAR(13), '---------------------------------------------', CHAR(13), 'Usuario y/o contraseña incorrecta(s).');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_sesion_Q01` (IN `p_idUsuario` VARCHAR(15), IN `p_idProgramaEstudio` INT, OUT `p_tipoUsuario` VARCHAR(20), OUT `p_tituloSesion` VARCHAR(250))   BEGIN
    DECLARE v_personal VARCHAR(60);
    DECLARE v_programaEstudio VARCHAR(60);
    DECLARE v_institucion VARCHAR(100);

    SELECT CONCAT(P.apellidos, ' ', P.nombres), U.tipoUsuario 
    INTO v_personal, p_tipoUsuario
    FROM USUARIO U 
    INNER JOIN PERSONAL P ON U.idPersonal = P.idPersonal
    WHERE U.idUsuario = p_idUsuario;
    
    SELECT P.nombre, I.nombre 
    INTO v_programaEstudio, v_institucion
    FROM PROGRAMAESTUDIO P 
    INNER JOIN INSTITUCION I ON I.idInstitucion = P.idInstitucion
    WHERE P.idProgramaEstudio = p_idProgramaEstudio;

    SET p_tituloSesion = CONCAT('[ SIIN-2025-1 ] - [ ', v_programaEstudio, ' ] - [ ', p_idUsuario, ' ] - [ ', v_personal, ' ]');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_usuarioProgramaEstudio_Q01` (IN `p_idUsuario` VARCHAR(15))   BEGIN
    DECLARE v_idPersonal INT;
    DECLARE v_tipoUsuario VARCHAR(20);

    SELECT idPersonal, tipoUsuario INTO v_idPersonal, v_tipoUsuario
    FROM USUARIO
    WHERE idUsuario = p_idUsuario;

    IF (v_tipoUsuario = 'COORDINADOR') THEN
        SELECT PE.idProgramaEstudio, PE.nombre AS programaEstudio
        FROM PROGRAMAESTUDIO PE
        WHERE PE.idCoordinadorArea = v_idPersonal;

    ELSEIF (v_tipoUsuario = 'ASISTENTE') THEN
        SELECT PE.idProgramaEstudio, PE.nombre AS programaEstudio
        FROM PROGRAMAESTUDIO PE
        WHERE PE.idAsistenteAreaT1 = v_idPersonal
           OR PE.idAsistenteAreaT2 = v_idPersonal;

    ELSE
        SELECT UPE.idProgramaEstudio, PE.nombre AS programaEstudio
        FROM USUARIO_PROGRAMAESTUDIO UPE
        INNER JOIN PROGRAMAESTUDIO PE ON PE.idProgramaEstudio = UPE.idProgramaEstudio
        WHERE UPE.idUsuario = p_idUsuario
          AND UPE.acceso = 1;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_marca_ml_Q01` (IN `p_idProgramaEstudio` INT, IN `p_buscar` VARCHAR(60))   BEGIN
    SELECT idMarca, nombre, fechaCreacion, fechaModificacion, idUsuarioCrea, idUsuarioModifica
    FROM MARCA
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND st_registro = 1
      AND nombre LIKE CONCAT('%', p_buscar, '%')
    ORDER BY nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_marca_mt_D01` (IN `p_idMarca` INT, IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_marca_mt_validarEliminar_Q01(p_idMarca, p_valid);

    IF p_valid = '1' THEN
        UPDATE MARCA
        SET st_registro         = 0,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idMarca = p_idMarca;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_marca_mt_I01` (INOUT `p_idMarca` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_marca_mt_validar_Q01(p_idMarca, p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        INSERT INTO MARCA (idProgramaEstudio, nombre, st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea)
        VALUES (p_idProgramaEstudio, p_nombre, 1, p_idUsuario, NOW(), p_pcTerminal);

        SET p_idMarca = LAST_INSERT_ID();
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_marca_mt_Q01` (IN `p_idMarca` INT, OUT `p_nombre` VARCHAR(60), OUT `p_idProgramaEstudio` INT)   BEGIN
    SELECT nombre, idProgramaEstudio
    INTO p_nombre, p_idProgramaEstudio
    FROM MARCA
    WHERE idMarca = p_idMarca;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_marca_mt_U01` (INOUT `p_idMarca` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_marca_mt_validar_Q01(p_idMarca, p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        UPDATE MARCA
        SET idProgramaEstudio   = p_idProgramaEstudio,
            nombre              = p_nombre,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idMarca = p_idMarca;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_marca_mt_validarEliminar_Q01` (IN `p_idMarca` INT, OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idBien) INTO v_count
    FROM BIEN
    WHERE idMarca = p_idMarca;

    IF v_count > 0 THEN
        SET p_valid = CONCAT('La marca tiene bienes asociados.', CHAR(13), 'No puede ser ELIMINADA.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_marca_mt_validar_Q01` (IN `p_idMarca` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idMarca) INTO v_count
    FROM MARCA
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND st_registro = 1
      AND nombre = p_nombre
      AND idMarca != IFNULL(p_idMarca, 0);

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El nombre de marca "', p_nombre, '" ya existe.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_modelo_ml_Q01` (IN `p_idProgramaEstudio` INT, IN `p_buscar` VARCHAR(60))   BEGIN
    SELECT idModelo, idProgramaEstudio, nombre, fechaCreacion, fechaModificacion, idUsuarioCrea, idUsuarioModifica
    FROM MODELO
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND st_registro = 1
      AND nombre LIKE CONCAT('%', p_buscar, '%')
    ORDER BY nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_modelo_mt_D01` (IN `p_idModelo` INT, IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_modelo_mt_validarEliminar_Q01(p_idModelo, p_valid);

    IF p_valid = '1' THEN
        UPDATE MODELO
        SET st_registro         = 0,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idModelo = p_idModelo;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_modelo_mt_I01` (INOUT `p_idModelo` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_modelo_mt_validar_Q01(p_idModelo, p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        INSERT INTO MODELO (idProgramaEstudio, nombre, st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea)
        VALUES (p_idProgramaEstudio, p_nombre, 1, p_idUsuario, NOW(), p_pcTerminal);

        SET p_idModelo = LAST_INSERT_ID();
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_modelo_mt_Q01` (IN `p_idModelo` INT, OUT `p_idProgramaEstudio` INT, OUT `p_nombre` VARCHAR(60))   BEGIN
    SELECT idProgramaEstudio, nombre
    INTO p_idProgramaEstudio, p_nombre
    FROM MODELO
    WHERE idModelo = p_idModelo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_modelo_mt_U01` (IN `p_idModelo` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_modelo_mt_validar_Q01(p_idModelo, p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        UPDATE MODELO
        SET idProgramaEstudio  = p_idProgramaEstudio,
            nombre             = p_nombre,
            idUsuarioModifica  = p_idUsuario,
            fechaModificacion  = NOW(),
            pcTerminalModifica = p_pcTerminal
        WHERE idModelo = p_idModelo;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_modelo_mt_validarEliminar_Q01` (IN `p_idModelo` INT, OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idBien) INTO v_count
    FROM BIEN
    WHERE idModelo = p_idModelo
      AND st_registro = 1;

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El modelo tiene bienes asociados.', CHAR(13), 'No puede ser eliminado.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_modelo_mt_validar_Q01` (IN `p_idModelo` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idModelo) INTO v_count
    FROM MODELO
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND st_registro = 1
      AND nombre = p_nombre
      AND idModelo != IFNULL(p_idModelo, 0);

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El modelo "', p_nombre, '" ya existe.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_ml_Q01` (IN `p_buscar` VARCHAR(100))   BEGIN
    SELECT  
        idPersonal,
        CONCAT(apellidos, ', ', nombres) AS nombreCompleto,
        dni,
        celular,
        email,
        st_registro
    FROM PERSONAL
    WHERE st_registro = 1
      AND (
            apellidos LIKE CONCAT('%', p_buscar, '%')
         OR nombres   LIKE CONCAT('%', p_buscar, '%')
         OR dni       LIKE CONCAT('%', p_buscar, '%')
      )
    ORDER BY apellidos, nombres;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_mt_D01` (IN `p_idPersonal` INT, IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    SET p_valid = '1';

    IF p_valid = '1' THEN
        UPDATE PERSONAL
        SET st_registro        = 0,
            idUsuarioModifica  = p_idUsuario,
            fechaModificacion  = NOW(),
            pcTerminalModifica = p_pcTerminal
        WHERE idPersonal = p_idPersonal;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_mt_I01` (INOUT `p_idPersonal` INT, IN `p_apellidos` VARCHAR(30), IN `p_nombres` VARCHAR(30), IN `p_dni` CHAR(8), IN `p_celular` VARCHAR(30), IN `p_email` VARCHAR(60), IN `p_direccion` VARCHAR(100), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_personal_mt_validar_Q01(p_idPersonal, p_dni, p_valid);

    IF p_valid = '1' THEN
        INSERT INTO PERSONAL (
            apellidos, nombres, dni, celular, email, direccion,
            st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea
        )
        VALUES (
            p_apellidos, p_nombres, p_dni, p_celular, p_email, p_direccion,
            1, p_idUsuario, NOW(), p_pcTerminal
        );

        SET p_idPersonal = LAST_INSERT_ID();
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_mt_Q01` (IN `p_idPersonal` INT, OUT `p_apellidos` VARCHAR(30), OUT `p_nombres` VARCHAR(30), OUT `p_dni` CHAR(8), OUT `p_celular` VARCHAR(30), OUT `p_email` VARCHAR(60), OUT `p_direccion` VARCHAR(100))   BEGIN
    SELECT apellidos, nombres, dni, celular, email, direccion
    INTO p_apellidos, p_nombres, p_dni, p_celular, p_email, p_direccion
    FROM PERSONAL
    WHERE idPersonal = p_idPersonal;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_mt_U01` (IN `p_idPersonal` INT, IN `p_apellidos` VARCHAR(30), IN `p_nombres` VARCHAR(30), IN `p_dni` CHAR(8), IN `p_celular` VARCHAR(30), IN `p_email` VARCHAR(60), IN `p_direccion` VARCHAR(100), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_personal_mt_validar_Q01(p_idPersonal, p_dni, p_valid);

    IF p_valid = '1' THEN
        UPDATE PERSONAL
        SET apellidos          = p_apellidos,
            nombres            = p_nombres,
            dni                = p_dni,
            celular            = p_celular,
            email              = p_email,
            direccion          = p_direccion,
            idUsuarioModifica  = p_idUsuario,
            fechaModificacion  = NOW(),
            pcTerminalModifica = p_pcTerminal
        WHERE idPersonal = p_idPersonal;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_mt_validar_Q01` (IN `p_idPersonal` INT, IN `p_dni` CHAR(8), OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idPersonal) INTO v_count
    FROM PERSONAL
    WHERE dni = p_dni
      AND st_registro = 1
      AND idPersonal != IFNULL(p_idPersonal, 0);

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El DNI "', p_dni, '" ya se encuentra registrado a otro personal.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_programaestudio_ml_Q01` (IN `p_buscar` VARCHAR(60))   BEGIN
    SELECT idProgramaEstudio, nombre, st_programaEstudio
    FROM PROGRAMAESTUDIO
    WHERE st_registro = 1
      AND nombre LIKE CONCAT('%', p_buscar, '%')
    ORDER BY nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_programaestudio_mt_D01` (IN `p_idProgramaEstudio` INT, IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_programaestudio_mt_validarEliminar_Q01(p_idProgramaEstudio, p_valid);

    IF p_valid = '1' THEN
        UPDATE PROGRAMAESTUDIO
        SET st_registro         = 0,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idProgramaEstudio = p_idProgramaEstudio;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_programaestudio_mt_I01` (INOUT `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_idCoordinadorArea` INT, IN `p_idAsistenteAreaT1` INT, IN `p_idAsistenteAreaT2` INT, IN `p_observacion` VARCHAR(100), IN `p_st_programaEstudio` CHAR(10), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_programaestudio_mt_validar_Q01(p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        INSERT INTO PROGRAMAESTUDIO (
            idInstitucion, nombre, idCoordinadorArea, idAsistenteAreaT1, idAsistenteAreaT2,
            observacion, st_programaEstudio, st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea
        )
        VALUES (
            1, p_nombre, p_idCoordinadorArea, p_idAsistenteAreaT1, p_idAsistenteAreaT2,
            p_observacion, p_st_programaEstudio, 1, p_idUsuario, NOW(), p_pcTerminal
        );

        SET p_idProgramaEstudio = LAST_INSERT_ID();
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_programaestudio_mt_Q01` (IN `p_idProgramaEstudio` INT, OUT `p_idInstitucion` INT, OUT `p_nombre` VARCHAR(60), OUT `p_idCoordinadorArea` INT, OUT `p_idAsistenteAreaT1` INT, OUT `p_idAsistenteAreaT2` INT, OUT `p_observacion` VARCHAR(100), OUT `p_st_programaEstudio` CHAR(10))   BEGIN
    SELECT idInstitucion, nombre, idCoordinadorArea, idAsistenteAreaT1, idAsistenteAreaT2, observacion, st_programaEstudio
    INTO p_idInstitucion, p_nombre, p_idCoordinadorArea, p_idAsistenteAreaT1, p_idAsistenteAreaT2, p_observacion, p_st_programaEstudio
    FROM PROGRAMAESTUDIO
    WHERE idProgramaEstudio = p_idProgramaEstudio;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_programaestudio_mt_U01` (IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_idCoordinadorArea` INT, IN `p_idAsistenteAreaT1` INT, IN `p_idAsistenteAreaT2` INT, IN `p_observacion` VARCHAR(100), IN `p_st_programaEstudio` CHAR(10), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_programaestudio_mt_validar_Q01(p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        UPDATE PROGRAMAESTUDIO
        SET nombre              = p_nombre,
            idCoordinadorArea   = p_idCoordinadorArea,
            idAsistenteAreaT1   = p_idAsistenteAreaT1,
            idAsistenteAreaT2   = p_idAsistenteAreaT2,
            observacion         = p_observacion,
            st_programaEstudio  = p_st_programaEstudio,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idProgramaEstudio = p_idProgramaEstudio;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_programaestudio_mt_validarEliminar_Q01` (IN `p_idProgramaEstudio` INT, OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idSala) INTO v_count
    FROM SALA
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND st_registro = 1;

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El programa tiene salas asociadas.', CHAR(13), 'No puede ser ELIMINADO.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_programaestudio_mt_validar_Q01` (IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idProgramaEstudio) INTO v_count
    FROM PROGRAMAESTUDIO
    WHERE st_registro = 1
      AND nombre = p_nombre
      AND idProgramaEstudio != IFNULL(p_idProgramaEstudio, 0);

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El programa de estudio "', p_nombre, '" ya existe.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_sala_ml_Q01` (IN `p_idProgramaEstudio` INT, IN `p_buscar` VARCHAR(60))   BEGIN
    SELECT idSala, nombre, observacion, fechaCreacion, fechaModificacion, idUsuarioCrea, idUsuarioModifica
    FROM SALA
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND st_registro = 1
      AND nombre LIKE CONCAT('%', p_buscar, '%')
    ORDER BY nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_sala_mt_D01` (IN `p_idSala` INT, IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_sala_mt_validarEliminar_Q01(p_idSala, p_valid);

    IF p_valid = '1' THEN
        UPDATE SALA
        SET st_registro         = 0,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idSala = p_idSala;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_sala_mt_I01` (INOUT `p_idSala` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_observacion` VARCHAR(200), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_sala_mt_validar_Q01(p_idSala, p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        INSERT INTO SALA (idProgramaEstudio, nombre, observacion, st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea)
        VALUES (p_idProgramaEstudio, p_nombre, p_observacion, 1, p_idUsuario, NOW(), p_pcTerminal);

        SET p_idSala = LAST_INSERT_ID();
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_sala_mt_Q01` (IN `p_idSala` INT, OUT `p_nombre` VARCHAR(60), OUT `p_observacion` VARCHAR(200), OUT `p_idProgramaEstudio` INT)   BEGIN
    SELECT nombre, observacion, idProgramaEstudio
    INTO p_nombre, p_observacion, p_idProgramaEstudio
    FROM SALA
    WHERE idSala = p_idSala;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_sala_mt_U01` (INOUT `p_idSala` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_observacion` VARCHAR(200), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_sala_mt_validar_Q01(p_idSala, p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        UPDATE SALA
        SET idProgramaEstudio   = p_idProgramaEstudio,
            nombre              = p_nombre,
            observacion         = p_observacion,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idSala = p_idSala;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_sala_mt_validarEliminar_Q01` (IN `p_idSala` INT, OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idBien) INTO v_count
    FROM BIEN
    WHERE idSala = p_idSala;

    IF v_count > 0 THEN
        SET p_valid = CONCAT('La sala tiene bienes asociados.', CHAR(13), 'No puede ser ELIMINADA.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_sala_mt_validar_Q01` (IN `p_idSala` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idSala) INTO v_count
    FROM SALA
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND st_registro = 1
      AND nombre = p_nombre
      AND idSala != IFNULL(p_idSala, 0);

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El nombre "', p_nombre, '" ya existe.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tipo_ml_Q01` (IN `p_idProgramaEstudio` INT, IN `p_buscar` VARCHAR(60))   BEGIN
    SELECT idTipo, NOMBRE
    FROM TIPO
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND st_registro = 1
      AND nombre LIKE CONCAT('%', p_buscar, '%')
    ORDER BY nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tipo_mt_D01` (IN `p_idTipo` INT, IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_tipo_mt_validarEliminar_Q01(p_idTipo, p_valid);

    IF p_valid = '1' THEN
        UPDATE TIPO
        SET st_registro         = 0,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idTipo = p_idTipo;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tipo_mt_I01` (INOUT `p_idTipo` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_tipo_mt_validar_Q01(p_idTipo, p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        INSERT INTO TIPO (idProgramaEstudio, nombre, st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea)
        VALUES (p_idProgramaEstudio, p_nombre, 1, p_idUsuario, NOW(), p_pcTerminal);
        SET p_idTipo = LAST_INSERT_ID();
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tipo_mt_Q01` (IN `p_idTipo` INT, OUT `p_nombre` VARCHAR(60))   BEGIN
    SELECT nombre INTO p_nombre
    FROM TIPO
    WHERE idTipo = p_idTipo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tipo_mt_U01` (INOUT `p_idTipo` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), IN `p_idUsuario` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_tipo_mt_validar_Q01(p_idTipo, p_idProgramaEstudio, p_nombre, p_valid);

    IF p_valid = '1' THEN
        UPDATE TIPO
        SET idProgramaEstudio   = p_idProgramaEstudio,
            nombre              = p_nombre,
            idUsuarioModifica   = p_idUsuario,
            fechaModificacion   = NOW(),
            pcTerminalModifica  = p_pcTerminal
        WHERE idTipo = p_idTipo;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tipo_mt_validarEliminar_Q01` (IN `p_idTipo` INT, OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';
    
    SELECT COUNT(idBien) INTO v_count
    FROM BIEN
    WHERE idTipo = p_idTipo;

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El registro esta en uso, por ', CHAR(13), 'lo tanto, no puede ser ELIMINADO.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tipo_mt_validar_Q01` (IN `p_idTipo` INT, IN `p_idProgramaEstudio` INT, IN `p_nombre` VARCHAR(60), OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idTipo) INTO v_count
    FROM TIPO
    WHERE idProgramaEstudio = p_idProgramaEstudio
      AND st_registro = 1
      AND nombre = p_nombre
      AND idTipo != IFNULL(p_idTipo, 0);

    IF v_count > 0 THEN
        SET p_valid = CONCAT('El nombre "', p_nombre, '" ya existe.');
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_ml_Q01` (IN `p_buscar` VARCHAR(60))   BEGIN
    SELECT idUsuario, tipoUsuario, activo
    FROM USUARIO
    WHERE CONCAT(idUsuario, '|', tipoUsuario) LIKE CONCAT('%', p_buscar, '%')
    ORDER BY idUsuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_mt_D01` (IN `p_idUsuario` VARCHAR(15), OUT `p_valid` VARCHAR(500))   proc_main: BEGIN
    SET p_valid = '1';

    IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE idUsuario = p_idUsuario) THEN
        SET p_valid = 'El usuario no existe.';
        LEAVE proc_main;
    END IF;

    DELETE FROM USUARIO_PROGRAMAESTUDIO WHERE idUsuario = p_idUsuario;
    DELETE FROM USUARIO WHERE idUsuario = p_idUsuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_mt_I01` (IN `p_idUsuario` VARCHAR(15), IN `p_contraseña` VARCHAR(15), IN `p_idPersonal` INT, IN `p_tipoUsuario` VARCHAR(20), IN `p_activo` TINYINT(1), IN `p_idUsuarioSesion` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   proc_main: BEGIN
    SET p_valid = '1';

    IF EXISTS (SELECT 1 FROM USUARIO WHERE idUsuario = p_idUsuario) THEN
        SET p_valid = CONCAT('El usuario "', p_idUsuario, '" ya existe.');
        LEAVE proc_main;
    END IF;

    IF EXISTS (SELECT 1 FROM USUARIO WHERE idPersonal = p_idPersonal AND st_registro = 1) THEN
        SET p_valid = 'El personal ya tiene un usuario registrado.';
        LEAVE proc_main;
    END IF;

    INSERT INTO USUARIO (
        idUsuario, contraseña, idPersonal, tipoUsuario, activo,
        st_registro, idUsuarioCrea, fechaCreacion, pcTerminalCrea
    )
    VALUES (
        p_idUsuario, p_contraseña, p_idPersonal, p_tipoUsuario, p_activo,
        1, p_idUsuarioSesion, NOW(), p_pcTerminal
    );

    IF p_tipoUsuario = 'ADMINISTRADOR' THEN
        INSERT INTO USUARIO_PROGRAMAESTUDIO (idProgramaEstudio, idUsuario, acceso)
        SELECT idProgramaEstudio, p_idUsuario, 1
        FROM PROGRAMAESTUDIO
        WHERE st_registro = 1;

    ELSEIF p_tipoUsuario = 'COORDINADOR' THEN
        INSERT INTO USUARIO_PROGRAMAESTUDIO (idProgramaEstudio, idUsuario, acceso)
        SELECT idProgramaEstudio, p_idUsuario, 1
        FROM PROGRAMAESTUDIO
        WHERE idCoordinadorArea = p_idPersonal
          AND st_registro = 1;

    ELSEIF p_tipoUsuario = 'ASISTENTE' THEN
        INSERT INTO USUARIO_PROGRAMAESTUDIO (idProgramaEstudio, idUsuario, acceso)
        SELECT idProgramaEstudio, p_idUsuario, 1
        FROM PROGRAMAESTUDIO
        WHERE (idAsistenteAreaT1 = p_idPersonal OR idAsistenteAreaT2 = p_idPersonal)
          AND st_registro = 1;

    ELSEIF p_tipoUsuario = 'CONSULTA' THEN
        LEAVE proc_main;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_mt_Q01` (IN `p_idUsuario` VARCHAR(15), OUT `p_contraseña` VARCHAR(15), OUT `p_idPersonal` INT, OUT `p_tipoUsuario` VARCHAR(20), OUT `p_activo` TINYINT(1))   BEGIN
    SELECT contraseña, idPersonal, tipoUsuario, activo
    INTO p_contraseña, p_idPersonal, p_tipoUsuario, p_activo
    FROM USUARIO
    WHERE idUsuario = p_idUsuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_mt_U01` (IN `p_idUsuario` VARCHAR(15), IN `p_contraseña` VARCHAR(15), IN `p_idPersonal` INT, IN `p_tipoUsuario` VARCHAR(20), IN `p_activo` TINYINT(1), IN `p_idUsuarioSesion` VARCHAR(15), IN `p_pcTerminal` VARCHAR(100), OUT `p_valid` VARCHAR(500))   BEGIN
    CALL sp_usuario_mt_validar_Q01(p_idUsuario, p_idPersonal, p_valid);

    IF p_valid = '1' THEN
        UPDATE USUARIO
        SET contraseña         = p_contraseña,
            idPersonal         = p_idPersonal,
            tipoUsuario        = p_tipoUsuario,
            activo             = p_activo,
            idUsuarioModifica  = p_idUsuarioSesion,
            fechaModificacion  = NOW(),
            pcTerminalModifica = p_pcTerminal
        WHERE idUsuario = p_idUsuario;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_mt_validarEliminar_Q01` (IN `p_idUsuario` VARCHAR(15), OUT `p_valid` VARCHAR(500))   BEGIN
    SET p_valid = '1';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_mt_validar_Q01` (IN `p_idUsuario` VARCHAR(15), IN `p_idPersonal` INT, OUT `p_valid` VARCHAR(500))   BEGIN
    DECLARE v_count INT;
    SET p_valid = '1';

    SELECT COUNT(idUsuario) INTO v_count
    FROM USUARIO
    WHERE idPersonal = p_idPersonal
      AND st_registro = 1
      AND idUsuario != IFNULL(p_idUsuario, '');

    IF v_count > 0 THEN
        SET p_valid = 'El personal seleccionado ya tiene un usuario registrado.';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bien`
--

CREATE TABLE `bien` (
  `idBien` int(11) NOT NULL,
  `idSala` int(11) DEFAULT NULL,
  `idGrupo` int(11) DEFAULT NULL,
  `cbi` varchar(10) DEFAULT NULL,
  `idTipo` int(11) DEFAULT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `idMarca` int(11) DEFAULT NULL,
  `idModelo` int(11) DEFAULT NULL,
  `serieMedida` varchar(100) DEFAULT NULL,
  `idEstado` int(11) DEFAULT NULL,
  `otrasEspecificaciones` varchar(100) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `bien`
--

INSERT INTO `bien` (`idBien`, `idSala`, `idGrupo`, `cbi`, `idTipo`, `descripcion`, `idMarca`, `idModelo`, `serieMedida`, `idEstado`, `otrasEspecificaciones`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(1, 1, 1, '266474', 1, 'CASE', 1, 1, 'MXL80215S2', 2, 'Intel Core i7-7700 @ 3.60GHz | 16 GB RAM (2x8GB DDR4 @ 2400MHz) | HDD 1 TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(2, 1, 1, '266428', 2, 'MONITOR', 1, 2, 'CNK75019PK/23.8\"', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(3, 1, 1, '266471', 3, 'TECLADO', 1, 3, 'BEXLOALA971UY', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(4, 1, 1, 'S/N', 4, 'MOUSE', 1, 4, 'FCMHHOAKZA1ITF', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(5, 1, 1, '266519', 5, 'MODULO COMP.', 2, 5, '1.20x0.71x0.71 alto(para 2 pc)', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(6, 1, 2, '266475', 1, 'CASE', 1, 1, 'MXL8021076', 2, 'Core i7-7700 / 24GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(7, 1, 2, '709890', 2, 'MONITOR', 1, 6, 'CNC8170RTY', 2, 'Pantalla LED 20.7\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(8, 1, 2, '705708', 3, 'TECLADO', 1, 7, 'S/S', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(9, 1, 2, 'S/N', 4, 'MOUSE', 1, 8, 'S/S', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(10, 1, 2, '266519', 5, 'MODULO COMP.', 2, 5, '1.20x0.71x0.71 alto(para 2 pc)', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(11, 1, 3, '266476', 1, 'CASE', 1, 1, 'MXL8020YK8', 2, 'Core i7-7700 / 24GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(12, 1, 3, '266434', 2, 'MONITOR', 1, 2, 'CNK75019PD', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(13, 1, 3, '266462', 3, 'TECLADO', 1, 9, 'BEXJL0BV8993XR', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(14, 1, 3, 'S/N', 4, 'MOUSE', 1, 8, 'FCMHHA0A67991G9', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(15, 1, 3, '266520', 5, 'MODULO COMP.', 2, 5, '1.23x0.60 x0.75alto(para 2 pc)', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(16, 1, 4, '266477', 1, 'CASE', 1, 1, 'MXL802161H', 2, 'Core i7-7700 / 24GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(17, 1, 4, '266315', 2, 'MONITOR', 1, 10, '3CQ5353CJZ', 2, 'Pantalla LED 23.6\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(18, 1, 4, '266459', 3, 'TECLADO', 1, 9, 'BEXJL0BV8993TA', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(19, 1, 4, 'S/N', 4, 'MOUSE', 1, 8, 'FCMHH0AKZA1J69', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(20, 1, 4, '266520', 5, 'MODULO COMP.', 2, 5, '1.23x0.60 x0.75alto(para 2 pc)', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(21, 1, 5, '266478', 1, 'CASE', 1, 1, 'MXL802164C', 2, 'Core i7-7700 / 24GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(22, 1, 5, '266432', 2, 'MONITOR', 1, 2, 'CNK7241VVX', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(23, 1, 5, '265862', 3, 'TECLADO', 1, 9, 'BEXJL0B5Y861IJ', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(24, 1, 5, 'S/N', 4, 'MOUSE', 1, 8, 'FCMHHOA199CMR8', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(25, 1, 5, '266521', 5, 'MODULO COMP.', 2, 5, '1.23x0.60 x0.75alto(para 2 pc)', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(26, 1, 6, '266479', 1, 'CASE', 1, 1, 'MXL8020YK3', 2, 'Core i7-7700 / 24GB RAM / HDD 1TB Seagate', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(27, 1, 6, '266443', 2, 'MONITOR', 1, 2, 'CNK75019P5', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(28, 1, 6, '705722', 3, 'TECLADO', 1, 9, 'S/N', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(29, 1, 6, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-LO300-97P-00X1', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(30, 1, 6, '266521', 5, 'MODULO COMP.', 2, 5, '1.23x0.60 x0.75alto(para 2 pc)', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(31, 1, 7, '266486', 1, 'CASE', 1, 1, 'MXL80215KW', 2, 'Core i7-7700 / 8GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(32, 1, 7, '266438', 2, 'MONITOR', 1, 2, 'CNK7241V1Z', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(33, 1, 7, '266455', 3, 'TECLADO', 1, 9, 'S/N', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(34, 1, 7, 'S/N', 4, 'MOUSE', 1, 8, 'S/N', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(35, 1, 7, '266526', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(36, 1, 8, '266487', 1, 'CASE', 1, 1, 'MXL8021614', 2, 'Core i7-7700 / 24GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(37, 1, 8, '266440', 2, 'MONITOR', 1, 2, 'CNK7241VTN', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(38, 1, 8, '266454', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BVB993VU', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(39, 1, 8, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHH0AKZA01SA', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(40, 1, 8, '265839', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(41, 1, 9, '266484', 1, 'CASE', 1, 1, 'MXL8021613', 2, 'Core i7-7700 / 24GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(42, 1, 9, 'S/N', 2, 'MONITOR', 4, 12, 'VK277829', 2, 'Pantalla LED 19.5\" / VGA / MTM 60DF-AAR1-WW', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(43, 1, 9, '266466', 3, 'TECLADO', 1, 7, 'CT: BEXJL0ALA9722H', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(44, 1, 9, 'S/N', 4, 'MOUSE', 1, 8, 'S/N', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(45, 1, 9, '266527', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(46, 1, 10, '266485', 1, 'CASE', 1, 1, 'MXL802105P', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(47, 1, 10, '266419', 2, 'MONITOR', 1, 2, 'CNK7501N2G', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(48, 1, 10, '266458', 3, 'TECLADO', 1, 9, 'BEXJL0BVB993T3', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(49, 1, 10, 'S/N', 4, 'MOUSE', 1, 8, 'FCMHHOAKZA0IK5', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(50, 1, 10, '265835', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(51, 1, 11, '266482', 1, 'CASE', 1, 1, 'MXL80210CH', 2, 'Core i7-7700 / 16GB RAM / HDD 1TB Seagate', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(52, 1, 11, '266441', 2, 'MONITOR', 1, 2, 'CNK7150R2M', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(53, 1, 11, 'S/N', 3, 'TECLADO', 1, 9, 'BEXJLOBSYB44BK', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(54, 1, 11, 'S/N', 4, 'MOUSE', 1, 8, 'FCMHHOA6799I8Z', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(55, 1, 11, '265837', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(56, 1, 12, '266483', 1, 'CASE', 1, 1, 'MXL80215PL', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(57, 1, 12, '266423', 2, 'MONITOR', 1, 2, 'CNK75019PN', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(58, 1, 12, '266468', 3, 'TECLADO', 1, 7, 'BEXJLOALA971T', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(59, 1, 12, 'S/N', 4, 'MOUSE', 1, 8, 'FCMHHOAKZA00N6', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(60, 1, 12, '266534', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(61, 1, 13, '266501', 1, 'CASE', 1, 1, 'MXL802162F', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(62, 1, 13, '266424', 2, 'MONITOR', 1, 2, 'CNK7501N2V', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(63, 1, 13, '266453', 3, 'TECLADO', 1, 9, 'BEXJL0BV8993W6', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(64, 1, 13, 'S/N', 4, 'MOUSE', 1, 8, 'FCMHHOAKZA0375', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(65, 1, 13, '265849', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(66, 1, 14, '266500', 1, 'CASE', 1, 1, 'MXL80210C8', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(67, 1, 14, '266421', 2, 'MONITOR', 1, 2, 'CNK7501N1V', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(68, 1, 14, '266449', 3, 'TECLADO', 1, 9, 'BEXJL0BV8993SZ', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(69, 1, 14, 'S/N', 4, 'MOUSE', 1, 8, 'FCMHHOAKZA032V', 2, 'Optico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(70, 1, 14, '265849', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera/Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(71, 1, 15, '266488', 1, 'CASE', 1, 1, 'MXL802161J', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(72, 1, 15, '266430', 2, 'MONITOR', 1, 2, 'CNK75019PP', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(73, 1, 15, '705674', 3, 'TECLADO', 1, 9, 'CT: BEXJL0B5YB448U', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(74, 1, 15, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOAKZ924Z3', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(75, 1, 15, '266540', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(76, 1, 16, '266481', 1, 'CASE', 1, 1, 'MXL80215LF', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(77, 1, 16, '266425', 2, 'MONITOR', 1, 2, 'CNK7501N2Q', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(78, 1, 16, '266467', 3, 'TECLADO', 1, 7, 'CT: BEXJL0ALA970TU', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(79, 1, 16, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOAKZA00M3', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(80, 1, 16, '266535', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(81, 1, 17, '266490', 1, 'CASE', 1, 1, 'MXL80215QJ', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(82, 1, 17, '266431', 2, 'MONITOR', 1, 2, 'CNK7501N2K', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(83, 1, 17, '266448', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BVB9942N', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(84, 1, 17, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOAKZA1IS5', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(85, 1, 17, '266544', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(86, 1, 18, '266491', 1, 'CASE', 1, 1, 'MXL80215R3', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(87, 1, 18, '266422', 2, 'MONITOR', 1, 2, 'CNK7501N2Z', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(88, 1, 18, '266444', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BV89940R', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(89, 1, 18, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOAKZA0GGD', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(90, 1, 18, '266541', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(91, 1, 19, '266492', 1, 'CASE', 1, 1, 'MXL8020Y5J', 2, 'Core i7-7700 / 16GB RAM / HDD 1TB WD', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(92, 1, 19, '265860', 2, 'MONITOR', 1, 2, 'CNK71405NB', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(93, 1, 19, '266446', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BV899425', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(94, 1, 19, 'S/N', 4, 'MOUSE', 1, 8, 'S/N', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(95, 1, 19, '266531', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(96, 1, 20, '266493', 1, 'CASE', 1, 1, 'MXL8021098', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(97, 1, 20, '266433', 2, 'MONITOR', 1, 2, 'CNK7241VTW', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(98, 1, 20, '266447', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BV89942K', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(99, 1, 20, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOAKZA1J4U', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(100, 1, 20, '266533', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(101, 1, 21, '266480', 1, 'CASE', 1, 1, 'MXL80215NY', 2, 'Core i7-7700 / 8GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(102, 1, 21, '266418', 2, 'MONITOR', 1, 2, 'CNK75019P5', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(103, 1, 21, '266460', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BV8993TE', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(104, 1, 21, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOA679916Z', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(105, 1, 21, '266522', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(106, 1, 22, '266492', 1, 'CASE', 1, 1, 'MXL8020Y5J', 2, 'Core i7-7700 / 16GB RAM / HDD 1TB WD Blue', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(107, 1, 22, '266416', 2, 'MONITOR', 1, 2, 'CNK7501N1F', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(108, 1, 22, '266465', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BCP977YY', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(109, 1, 22, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOAKZA1J41', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(110, 1, 22, '266543', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(111, 1, 23, '266489', 1, 'CASE', 1, 1, 'MXL8021057', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(112, 1, 23, '266420', 2, 'MONITOR', 1, 2, 'CNK7501N11', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(113, 1, 23, '266456', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BV8933SX', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(114, 1, 23, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOA6799182', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(115, 1, 23, '266528', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(116, 1, 24, '266494', 1, 'CASE', 1, 1, 'MXL8021620', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(117, 1, 24, '266435', 2, 'MONITOR', 1, 2, 'CNK7501N18', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(118, 1, 24, '266464', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BV8993LG', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(119, 1, 24, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOAKZA11UR', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(120, 1, 24, '266529', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(121, 1, 25, '266498', 1, 'CASE', 1, 1, 'MXL802163D', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(122, 1, 25, '266439', 2, 'MONITOR', 1, 2, 'CNK7241VVM', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(123, 1, 25, '266461', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BV8993SV', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(124, 1, 25, 'S/N', 4, 'MOUSE', 1, 8, 'S/N', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(125, 1, 25, '266536', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(126, 1, 26, '266499', 1, 'CASE', 1, 1, 'MXL802109L', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(127, 1, 26, '266437', 2, 'MONITOR', 1, 2, 'CNK75019PB', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(128, 1, 26, '266457', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BV8993ZZ', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(129, 1, 26, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOA6799188', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(130, 1, 26, '266538', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(131, 1, 27, '266502', 1, 'CASE', 1, 1, 'MXL8020YLG', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(132, 1, 27, 'S/N', 2, 'MONITOR', 4, 13, 'V124803', 2, 'LCD LED', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(133, 1, 27, '266451', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BV8993ND', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(134, 1, 27, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOAKZA1J6F', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(135, 1, 27, '266539', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(136, 1, 28, '266503', 1, 'CASE', 1, 1, 'MXL802163Y', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(137, 1, 28, '266155', 2, 'MONITOR', 1, 2, 'CNK7190YGK', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(138, 1, 28, '705716', 3, 'TECLADO', 1, 14, 'CN-0C639N-71616-488-082R-A00', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(139, 1, 28, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHH0CQW9LABP', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(140, 1, 28, '266545', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(141, 1, 29, '266497', 1, 'CASE', 1, 1, 'MXL80210BL', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(142, 1, 29, '266417', 2, 'MONITOR', 1, 2, 'CNK75019PW', 2, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(143, 1, 29, '266445', 3, 'TECLADO', 1, 7, 'CT: BEXJL0BV89940B', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(144, 1, 29, 'S/N', 4, 'MOUSE', 1, 8, 'CT: FCMHHOAKZA0OLP', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(145, 1, 29, '266542', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(146, 1, 30, '266496', 1, 'CASE', 1, 1, 'MXL80215LC', 2, 'Core i7-7700 / 16GB RAM / SSD 512GB ADATA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(147, 1, 30, 'S/N', 2, 'MONITOR', 1, 6, 'CNC8222CGV', 2, 'Pantalla LED 20.7\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(148, 1, 30, '266463', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BV8993ZO', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(149, 1, 30, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-LQ300-970-01TP', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(150, 1, 30, '266537', 5, 'MODULO COMP.', 2, 5, '0.78X0.50X0.75, 02 DIV, 01', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(151, 1, NULL, '266590', 6, 'PIZARRA ACRILICA', 2, 5, '2.40mtx1.20mt x 0.3cm alto', 3, 'MARCO DE ALUMINIO BLANCO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(152, 1, NULL, '266584', 7, 'EQUIPO DE SONIDO', 5, 15, 'MHC-GT22', 3, 'NEGRO / CON USB Y CD CON 3 PARLANTES', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(153, 1, NULL, '267782', 8, 'EXTINTOR', 2, 5, 'S/M', 3, '6 KG', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(154, 1, NULL, '266595', 9, 'SWITCH', 6, 16, 'S/N', 2, '24 PUERTOS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(155, 1, NULL, '266596', 9, 'SWITCH', 7, 17, 'F38G386000129', 2, '24 PUERTOS + 2', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(156, 1, NULL, 'S/N', 10, 'PATCH PANEL', 8, 5, 'S/M', 3, 'DE 48 SALIDAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(157, 1, NULL, '266597', 11, 'GABINETE DE METAL', 9, 18, '1.80mt x 1.10mt x 0.45cm fondo', 3, 'BEIGE / GRIS CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(158, 1, NULL, '267826', 12, 'ESCRITORIO DE MADERA', 2, 5, '1mt x 0.50cm x 0.75 alto', 2, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(159, 1, NULL, '265815', 13, 'SILLA METALICA TAPIZADA', 2, 5, 'SILLA DOCENTE', 3, 'NEGRO / TAPIZADO DAÑADO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(160, 1, NULL, '266586', 14, 'LUZ DE EMERGENCIA', 10, 19, 'S/M', 4, 'BEIGE / BLANCO INOPERATIVO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(161, 1, NULL, '266589', 15, 'VENTILADOR ELECTRICO AEREO', 11, 5, 'S/M', 3, 'BLANCO / METALICO. 3 PALETAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(162, 1, NULL, '401603', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220123', 3, 'COLOR GRIS DE 8 TOMAS DE SALIDA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(163, 1, NULL, '401572', 16, 'ESTABILIZADOR', 13, 20, 'ENPCG1200II0606220140', 3, 'COLOR NEGRO DE 8 TOMAS DE SALIDA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(164, 1, NULL, '401474', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220310', 3, 'COLOR GRIS DE 8 TOMAS DE SALIDA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(165, 1, NULL, '401565', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220284', 3, 'COLOR GRIS DE 8 TOMAS DE SALIDA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(166, 1, NULL, '266511', 16, 'ESTABILIZADOR', 14, 5, 'S/N', 3, 'COLOR NEGRO DE 8 TOMAS DE SALIDA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(167, 1, NULL, '266514', 16, 'ESTABILIZADOR', 13, 21, '11312696702', 3, 'COLOR NEGRO DE 8 TOMAS DE SALIDA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(168, 1, NULL, '266381', 16, 'ESTABILIZADOR', 13, 21, '12193750104', 3, 'COLOR NEGRO DE 8 TOMAS DE SALIDA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(169, 1, NULL, '266379', 16, 'ESTABILIZADOR', 14, 5, 'S/N', 3, 'COLOR NEGRO DE 8 TOMAS DE SALIDA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(170, 1, NULL, '266508', 16, 'ESTABILIZADOR', 15, 22, '08423802001623FNR', 3, 'COLOR NEGRO DE 8 TOMAS DE SALIDA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(171, 1, NULL, '401415', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220251', 3, 'COLOR GRIS DE 8 TOMAS DE SALIDA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(172, 1, NULL, '266554', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(173, 1, NULL, '266556', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(174, 1, NULL, '266547', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(175, 1, NULL, '266570', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(176, 1, NULL, '266388', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(177, 1, NULL, '264961', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(178, 1, NULL, '264980', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(179, 1, NULL, '266558', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(180, 1, NULL, '266555', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(181, 1, NULL, '265813', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(182, 1, NULL, '265806', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(183, 1, NULL, '266546', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(184, 1, NULL, '266400', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(185, 1, NULL, '266562', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(186, 1, NULL, '266565', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(187, 1, NULL, '264024', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(188, 1, NULL, '266549', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(189, 1, NULL, '266394', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(190, 1, NULL, '266566', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(191, 1, NULL, '265149', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(192, 1, NULL, '265146', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(193, 1, NULL, '266209', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(194, 1, NULL, '264028', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(195, 1, NULL, 'S/N', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(196, 1, NULL, '266389', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(197, 1, NULL, '266398', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(198, 1, NULL, '261648', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(199, 1, NULL, '266552', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(200, 1, NULL, '265159', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(201, 1, NULL, '266560', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(202, 1, NULL, '266567', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(203, 1, NULL, '264525', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'NEGRO / GRIS OSCURO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(204, 1, NULL, '305958', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(205, 1, NULL, '264878', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(206, 1, NULL, '265803', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(207, 1, NULL, '266572', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(208, 1, NULL, '266384', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(209, 1, NULL, '265809', 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'MARRON CLARO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(210, 1, NULL, '265822', 18, 'MESA PARA PROYECTOR / MESITA DE MADERA', 2, 5, '0.46x0.51x0.76 alto', 3, 'MADERA MARRÓN / CON COMPARTIMIENTOS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(211, 1, NULL, '265836', 18, 'MESA PARA PROYECTOR / MESITA DE MADERA', 2, 5, '0.46x0.51x0.76 alto', 3, 'MADERA MARRÓN / CON COMPARTIMIENTOS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(212, 1, NULL, '265831', 18, 'MESA PARA PROYECTOR / MESITA DE MADERA', 2, 5, '0.46x0.51x0.76 alto', 3, 'MADERA MARRÓN / CON COMPARTIMIENTOS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(213, 1, NULL, '265830', 18, 'MESA PARA PROYECTOR / MESITA DE MADERA', 2, 5, '0.46x0.51x0.76 alto', 3, 'MADERA MARRÓN / CON COMPARTIMIENTOS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(214, 1, NULL, '265823', 18, 'MESA PARA PROYECTOR / MESITA DE MADERA', 2, 5, '0.46x0.51x0.76 alto', 3, 'MADERA MARRÓN / CON COMPARTIMIENTOS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(215, 2, 1, '299584', 19, 'CPU', 3, 23, 'B6CHSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(216, 2, 1, '263072', 2, 'MONITOR', 1, 2, 'CNK75019PW', 1, 'Pantalla LED 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(217, 2, 1, '299585', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-97R-00DK-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(218, 2, 1, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-LO300-970-044G', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(219, 2, 1, '265829', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto para 1 pc', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(220, 2, 2, '299582', 19, 'CPU', 3, 23, 'B5KGSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(221, 2, 2, '299292', 2, 'MONITOR', 1, 25, '1CR9330K01', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(222, 2, 2, '299583', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-97R-00DK-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(223, 2, 2, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-LO300-970-037F', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(224, 2, 2, '265827', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(225, 2, 3, '299580', 19, 'CPU', 3, 23, 'B67LSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(226, 2, 3, '299291', 2, 'MONITOR', 1, 25, '1CR9330JY3', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(227, 2, 3, '299581', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-97R-01MA-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(228, 2, 3, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-970-02SU', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(229, 2, 3, '265825', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(230, 2, 4, '299558', 19, 'CPU', 3, 23, 'B68HSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(231, 2, 4, '299281', 2, 'MONITOR', 1, 25, '1CR9330KD8', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(232, 2, 4, '299561', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-999-14K9-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(233, 2, 4, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-97N-01R5', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(234, 2, 4, '265824', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(235, 2, 5, '299560', 19, 'CPU', 3, 23, 'B58MSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(236, 2, 5, '299299', 2, 'MONITOR', 1, 25, '1CR9330JY3', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(237, 2, 5, '299593', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-999-1512-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(238, 2, 5, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-LO300-98A-0RTJ', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(239, 2, 5, '705703', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(240, 2, 6, '299568', 19, 'CPU', 3, 23, 'B6HLSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(241, 2, 6, '299285', 2, 'MONITOR', 1, 25, '1CR9330KPF', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(242, 2, 6, '299579', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-LO300-94Q-03NF-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(243, 2, 6, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-LO300-97P-0NTO', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(244, 2, 6, '265848', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(245, 2, 7, '299614', 19, 'CPU', 3, 23, 'B5MMSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(246, 2, 7, '299296', 2, 'MONITOR', 1, 25, '1CR9330JZ4', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(247, 2, 7, '299615', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-94Q-00IS-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(248, 2, 7, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-LO300-970-04VL', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(249, 2, 7, '265820', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(250, 2, 8, '299616', 19, 'CPU', 3, 23, 'B6QMSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(251, 2, 8, '299298', 2, 'MONITOR', 1, 25, '1CR9330JYF', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(252, 2, 8, '266452', 3, 'TECLADO', 1, 9, 'CT: BEXJL0BV8993OI', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(253, 2, 8, 'S/N', 4, 'MOUSE', 1, 26, 'CT: FCMHH0C9295DQD', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(254, 2, 8, '265821', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(255, 2, 9, '299574', 19, 'CPU', 3, 23, 'B59KSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(256, 2, 9, '299287', 2, 'MONITOR', 1, 25, '1CR9330JY7', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(257, 2, 9, '299575', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-999-15BJ-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(258, 2, 9, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-98A-0S9N', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(259, 2, 9, '265819', 5, 'MODULO COMP', NULL, NULL, '79 cm x 95 cm x 50 cm alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(260, 2, 10, '299570', 19, 'CPU', 3, 23, 'B68DSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(261, 2, 10, '705668', 2, 'MONITOR', 4, 27, 'SVK276722', 1, 'Pantalla LED', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(262, 2, 10, '299571', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-94Q-004D-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(263, 2, 10, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-97P-0NT8', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(264, 2, 10, '266525', 5, 'MODULO COMP', NULL, NULL, '79 cm x 95 cm x 50 cm alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(265, 2, 11, '299572', 19, 'CPU', 3, 23, 'B5PGSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(266, 2, 11, '299293', 2, 'MONITOR', 1, 25, '1CR9330LBK', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(267, 2, 11, '299573', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-94Q-001P-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(268, 2, 11, 'S/N', 4, 'MOUSE', 1, 26, 'CT: FCMHH0COW9L2YG', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(269, 2, 11, '266530', 5, 'MODULO COMP', NULL, NULL, '79 cm x 95 cm x 50 cm alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(270, 2, 12, '299578', 19, 'CPU', 3, 23, 'B67JSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(271, 2, 12, '299290', 2, 'MONITOR', 1, 25, '1CR9330K6F', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(272, 2, 12, '299559', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-999-15HY-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(273, 2, 12, 'S/N', 4, 'MOUSE', 16, 28, 'X821908-017', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(274, 2, 12, '266532', 5, 'MODULO COMP', NULL, NULL, '79 cm x 95 cm x 50 cm alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(275, 2, 13, '299576', 19, 'CPU', 3, 23, 'B5GPSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(276, 2, 13, '299289', 2, 'MONITOR', 1, 25, '1CR9330KC8', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(277, 2, 13, '299567', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-985-05U7-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(278, 2, 13, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-970-02IX', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(279, 2, 13, '265816', 5, 'MODULO COMP', NULL, NULL, '80 cm x 42 cm x 77 cm alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(280, 2, 14, '299592', 19, 'CPU', 3, 23, 'B6CHSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(281, 2, 14, '299294', 2, 'MONITOR', 1, 25, '1CR9330JYZ', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(282, 2, 14, '299587', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-94Q-00IU-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(283, 2, 14, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-970-0139', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(284, 2, 14, '265817', 5, 'MODULO COMP', NULL, NULL, '80 cm x 42 cm x 77 cm alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(285, 2, 15, '299588', 19, 'CPU', 3, 23, 'B6TJSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(286, 2, 15, '299295', 2, 'MONITOR', 1, 25, '1CR9330K79', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(287, 2, 15, '299589', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-94Q-00HV-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(288, 2, 15, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-970-04VT', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(289, 2, 15, '265826', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(290, 2, 16, '299590', 19, 'CPU', 3, 23, 'B6SHSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(291, 2, 16, '299280', 2, 'MONITOR', 1, 25, '1CR9330KN2', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(292, 2, 16, '299617', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-97R-02UO-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(293, 2, 16, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-98A-0TJ9', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(294, 2, 16, '265828', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(295, 2, 17, '299586', 19, 'CPU', 3, 23, 'B5JPSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(296, 2, 17, '299297', 2, 'MONITOR', 1, 25, '1CR9330KML', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(297, 2, 17, '299563', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-94Q-00JC-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(298, 2, 17, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-97P-0NTT', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(299, 2, 17, '705709', 5, 'MODULO COMP', NULL, NULL, '1.20 m x 0.68 m x 0.76 m alto (Para 2 pcs)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(300, 2, 18, '299564', 19, 'CPU', 3, 23, 'B5BDSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(301, 2, 18, '299283', 2, 'MONITOR', 1, 25, '1CR9330JYV', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(302, 2, 18, '299577', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-97R-01MW-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(303, 2, 18, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-970-02ND', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(304, 2, 18, '705709', 5, 'MODULO COMP', NULL, NULL, '1.20 m x 0.68 m x 0.76 m alto (Para 2 pcs)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(305, 2, 19, '299566', 19, 'CPU', 3, 23, 'B55KSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(306, 2, 19, '299284', 20, 'MONITOR LED', 1, 25, '1CR9330KN5', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(307, 2, 19, '299569', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-999-14K3-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(308, 2, 19, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-98A-0RTS', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(309, 2, 19, '265834', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(310, 2, 20, '299562', 19, 'CPU', 3, 23, 'B5JFSZ2', 1, 'Core i7-8700 3.20GHz, 16GB RAM, SSD 512GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(311, 2, 20, '299282', 2, 'MONITOR', 1, 25, '1CR9330K7W', 1, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(312, 2, 20, '299565', 3, 'TECLADO', 3, 24, 'CN-0F2JV2-L0300-94Q-03NN-A03', 1, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(313, 2, 20, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-97P-0NTG', 1, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL);
INSERT INTO `bien` (`idBien`, `idSala`, `idGrupo`, `cbi`, `idTipo`, `descripcion`, `idMarca`, `idModelo`, `serieMedida`, `idEstado`, `otrasEspecificaciones`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(314, 2, 20, '265838', 5, 'MODULO COMP', NULL, NULL, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'Madera / Melamina', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(315, 2, NULL, NULL, 16, 'ESTABILIZADORES', 14, 29, 'S/SERIE', 3, 'COLOR NEGRO DE 8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(316, 2, NULL, NULL, 16, 'ESTABILIZADORES', 14, 29, 'S/SERIE', 3, 'COLOR NEGRO DE 8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(317, 2, NULL, NULL, 16, 'ESTABILIZADORES', 14, 29, 'S/SERIE', 3, 'COLOR NEGRO DE 8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(318, 2, NULL, NULL, 16, 'ESTABILIZADORES', 12, 20, 'ENPCG1200II0606220224', 3, 'COLOR GRIS DE 8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(319, 2, NULL, NULL, 16, 'ESTABILIZADORES', 12, 20, 'ENPCG1200II0606220298', 3, 'COLOR GRIS DE 8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(320, 2, NULL, NULL, 16, 'ESTABILIZADORES', 12, 20, 'ENPCG1200II0606220190', 3, 'COLOR GRIS DE 8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(321, 2, NULL, NULL, 16, 'ESTABILIZADORES', 12, 20, 'ENPCG1200II0606220239', 3, 'COLOR GRIS DE 8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(322, 2, NULL, NULL, 16, 'ESTABILIZADORES', 13, 30, '11202363327', 3, 'COLOR NEGRO DE 4 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(323, 2, NULL, NULL, 16, 'ESTABILIZADORES', 15, 31, '2KA7471HP4', 3, 'COLOR NEGRO DE 6 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(324, 2, NULL, NULL, 16, 'ESTABILIZADORES', 14, 29, '94103473', 3, 'COLOR NEGRO DE 6 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(325, 2, NULL, NULL, 21, 'CAMARA DE VIDEO', 17, 5, 'S/SERIE', 3, 'CAMARA TIPO DOMO COLOR BLANCO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(326, 2, NULL, NULL, 21, 'CAMARA DE VIDEO', 17, 5, 'S/SERIE', 3, 'CAMARA TIPO DOMO COLOR BLANCO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(327, 2, NULL, NULL, 14, 'LUZ DE EMERGENCIA', 10, 19, 'S/SERIE', 4, 'LUZ DE EMERGENCIA 2 FAROS LED COLOR BEIGE - INOPERATIVO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(328, 2, NULL, NULL, 11, 'GABINETE DE METAL', 18, 32, '0.60 x0.74 x 1.19 ,0.5 DIV,02,1/2', 2, 'GABINETE METALICO RACK COLOR NEGRO CON PUERTAS DE VIDRIO Y RUEDAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(329, 2, NULL, NULL, 22, 'SERVIDOR', 3, 33, 'GT7DB-6DRMD-92M9Q-QXF6T', 4, 'SERVIDOR DE RACK COLOR NEGRO- WINDOWS SERVER 2008 R2 STD', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(330, 2, NULL, NULL, 9, 'SWITCH', 18, 34, '11144900268', 3, 'SWITCH DE RED 24 PUERTOS + 2 PUERTOS GIGABIT ETHERNET COLOR NEGRO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(331, 2, NULL, NULL, 9, 'SWITCH', 7, 35, 'RZG23I3000599', 2, '24 PUERTOS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(332, 2, NULL, NULL, 23, 'RACK PARA PROYECTOR', 2, 5, 'S/SERIE', 2, 'SOPORTE METALICO TELESCOPICO DE TECHO PARA PROYECTOR COLOR NEGRO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(333, 2, NULL, NULL, 8, 'EXTINTOR', 2, 36, 'S/N', 2, 'EXTINTOR POLVO QUIMICO SECO (PQS) CAPACIDAD 06 KG COLOR ROJO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(334, 2, NULL, NULL, 24, 'PIZARRA INTERACTIVA', 19, 37, '1.60cm x 1.20cm', 3, 'PIZARRA INTERACTIVA ACRILICA CON MARCO GRIS Y BANDEJA PORTAMARCADORES', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(335, 2, NULL, NULL, 6, 'PIZARRA ACRILICA', 2, 5, '2.40cm x 1.20cm', 3, 'PIZARRA ACRILICA PARA PLUMON MARCO DE ALUMINIO PARA PARED', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(336, 2, NULL, NULL, 25, 'VENTILADOR DE TECHO', 11, 5, 'S/SERIE', 3, 'VENTILADOR DE TECHO DE 3 PALETAS METALICAS COLOR BLANCO CON SOPORTE Y TAPA DE CANOPY', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(337, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(338, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(339, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(340, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 4, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(341, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(342, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(343, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(344, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(345, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(346, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(347, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(348, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(349, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(350, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(351, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(352, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(353, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(354, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(355, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(356, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(357, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(358, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(359, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(360, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA-', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(361, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(362, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(363, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 4, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(364, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(365, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(366, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(367, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(368, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(369, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(370, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(371, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(372, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(373, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(374, 2, NULL, NULL, 17, 'SILLA FIJA DE MADERA', 2, 5, 'BASE DE MADERA', 3, 'SILLA CON ESTRUCTURA METALICA NEGRA Y ASIENTO/RESPALDO DE MADERA COLOR MARRON/CEREZO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(375, 2, NULL, NULL, 26, 'MESA DE MADERA', 2, 5, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'MESA PARA COMPUTADORA CON PORTATECLADO Y BANDEJA INFERIOR PARA CPU', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(376, 2, NULL, NULL, 26, 'MESA DE MADERA', 2, 5, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'MESA PARA COMPUTADORA CON PORTATECLADO Y BANDEJA INFERIOR PARA CPU', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(377, 2, NULL, NULL, 26, 'MESA DE MADERA', 2, 5, '0.51x0.45 x0.76 alto(para 1 pc)', 3, 'MESA PARA COMPUTADORA CON PORTATECLADO Y BANDEJA INFERIOR PARA CPU', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(378, 2, NULL, NULL, 26, 'MESA DE MADERA', 2, 5, '0.79x0.50 x0.75 alto(para 1 pc)', 3, 'MESA PARA COMPUTADORA CON PORTATECLADO Y COMPARTIMENTOS/REPISAS LATERALES', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(379, 2, NULL, NULL, 26, 'MESA DE MADERA', 2, 5, '0.85x0.45 x0.75 alto(para 1 pc)', 3, 'MESA PARA COMPUTADORA CON PORTATECLADO Y COMPARTIMENTOS/REPISAS LATERALES', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(380, 2, NULL, NULL, 26, 'MESA DE MADERA', 2, 5, '124x0.70 x0.78 alto(para 2 pc)', 3, 'MESA PARA COMPUTADORA CON CAJONERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(381, 2, NULL, NULL, 26, 'MESA DE MADERA', 2, 5, '0.79x0.51 x0.75 alto(para 1 pc)', 3, 'MESA PARA COMPUTADORA CON PORTATECLADO Y COMPARTIMENTOS/REPISAS LATERALES', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(382, 2, NULL, NULL, 26, 'MESA DE MADERA', 2, 5, '0.60x0.50 x0.74 alto', 3, 'MESA DE TRABAJO DE MADERA (USO PARA PROYECTOR)', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(383, 3, 1, '266345', 19, 'CPU', 1, 38, 'MXL5521GTL', 2, 'INTEL CORE I7-4790 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(384, 3, 1, '705804', 2, 'MONITOR', 1, 39, 'CNK7370D90', 2, 'Pantalla LED 24\"\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(385, 3, 1, '266470', 3, 'TECLADO', 1, 5, 'BEXJLOALA97172', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(386, 3, 1, 'S/N', 4, 'MOUSE', 1, 5, 'FCMHHOAKZA0ISG', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(387, 3, 2, '705713', 19, 'CPU', 1, 38, '2UA7481JQX', 2, 'INTEL XEON E3-1270 V6 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(388, 3, 2, '705669', 2, 'MONITOR', 1, 39, 'CNK73317JN', 2, 'Pantalla LED 24\"\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(389, 3, 2, '299591', 3, 'TECLADO', 3, 5, 'CN-0FP2NV-L0300-985-0414-A03', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(390, 3, 2, 'S/N', 4, 'MOUSE', 20, 5, 'S/S', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(391, 3, 3, '299580', 19, 'CPU', 1, 38, '2UA7471Z1J', 2, 'INTEL XEON E3-1270 V6 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(392, 3, 3, '299291', 2, 'MONITOR', 1, 39, 'CNK73317JT', 2, 'Pantalla LCD 24\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(393, 3, 3, '299581', 3, 'TECLADO', 1, 40, 'BEXJLOALA97172', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(394, 3, 3, 'S/N', 4, 'MOUSE', 1, 5, 'FCMHHOAKZA0ISG', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(395, 3, 4, '264681', 19, 'CPU', 1, 38, 'MJ033YP7', 2, 'INTEL CORE I5-4690 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(396, 3, 4, 'S/N', 2, 'MONITOR', 21, 41, 'THU182660914', 2, 'MODELO VS15138', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(397, 3, 4, '705719', 3, 'TECLADO', 1, 5, 'BEXJL0BCP86CKT', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(398, 3, 4, 'S/N', 4, 'MOUSE', 22, 5, 'PID:HS425HB', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(399, 3, 5, '701978', 19, 'CPU', 1, 38, 'S/S', 2, 'INTEL CORE I7-3770 / RAM 16GB / HDD 500GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(400, 3, 5, 'S/N', 2, 'MONITOR', 1, 6, 'CNC8222DFN', 2, 'Pantalla LCD 20.7\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(401, 3, 5, 'S/N', 3, 'TECLADO', 1, 5, 'BEXJL0B5T645C1', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(402, 3, 5, 'S/N', 4, 'MOUSE', 22, 42, '2350AP01RS78', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(403, 3, 6, '705711', 19, 'CPU', 1, 38, '2UA7471HK6', 2, 'INTEL XEON E3-1270 V6 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(404, 3, 6, '705670', 2, 'MONITOR', 1, 39, 'CNK73317MP', 2, 'Pantalla LCD 24\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(405, 3, 6, 'S/N', 3, 'TECLADO', 1, 5, 'BEXJL0BCP86CK9', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(406, 3, 6, 'S/N', 4, 'MOUSE', 1, 5, 'FCMHFOAHD8BHR8', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(407, 3, 7, '705714', 19, 'CPU', 1, 38, '2UA7471Z14', 2, 'INTEL XEON E3-1270 V6 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(408, 3, 7, '709884', 2, 'MONITOR', 21, 41, 'THU182660932', 2, 'MODELO VS15138', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(409, 3, 7, 'S/N', 3, 'TECLADO', 1, 5, 'BEXJLOALA8436L', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(410, 3, 7, 'S/N', 4, 'MOUSE', 1, 5, 'FCMHHOA6792R8V', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(411, 3, 8, '802960', 19, 'CPU', 4, 5, 'MJ04PKYT', 2, 'INTEL CORE I7-6700 / RAM 8GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(412, 3, 8, '705718', 2, 'MONITOR', 1, 39, 'CNK7220V0K', 2, 'Pantalla LCD 24\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(413, 3, 8, '266450', 3, 'TECLADO', 1, 40, 'BEXJL0BV993VV', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(414, 3, 8, 'S/N', 4, 'MOUSE', 1, 5, 'S/S', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(415, 3, 9, '705704', 19, 'CPU', 1, 38, '2UA7471HGN', 2, 'INTEL XEON E3-1270 V6 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(416, 3, 9, '705715', 2, 'MONITOR', 1, 39, 'CNK73317F2', 2, 'Pantalla LCD 24\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(417, 3, 9, '266365', 3, 'TECLADO', 1, 5, 'BDMHE0CPSCL45', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(418, 3, 9, 'S/N', 4, 'MOUSE', 3, 11, 'CN-0PRDV9-L0300-970-014D', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(419, 3, 10, '802959', 19, 'CPU', 4, 5, 'MJ04PL05', 2, 'INTEL CORE I7-6700 / RAM 8GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(420, 3, 10, '261721', 2, 'MONITOR', 1, 43, 'CNC332PFQH', 2, 'Pantalla LED 20\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(421, 3, 10, 'S/N', 3, 'TECLADO', 1, 5, 'BEXJLOALA880KG', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(422, 3, 10, 'S/N', 4, 'MOUSE', 3, 5, 'CN-09RRC7-48721-31G-0047', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(423, 3, 11, '705717', 19, 'CPU', 1, 38, '2UA7471HMX', 2, 'INTEL XEON E3-1270 V6 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(424, 3, 11, '705710', 2, 'MONITOR', 1, 39, 'CNK7320Y1D', 2, 'Pantalla LCD 24\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(425, 3, 11, '266473', 3, 'TECLADO', 1, 5, 'BEXJLOALA970CW', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(426, 3, 11, 'S/N', 4, 'MOUSE', 1, 5, 'FCMHHOAKZA135J', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(427, 3, 12, '266344', 19, 'CPU', 1, 38, 'MXL5521GW5', 2, 'INTEL CORE I7-4790 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(428, 3, 12, '705705', 2, 'MONITOR', 1, 39, 'CNK73317KL', 2, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(429, 3, 12, '705673', 3, 'TECLADO', 3, 14, 'CN-0C839M-71616-48B-0923-A00', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(430, 3, 12, 'S/N', 4, 'MOUSE', 1, 26, 'S/S', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(431, 3, 13, '705672', 19, 'CPU', 1, 38, '2UA7471H6Y', 2, 'INTEL XEON E3-1270 V6 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(432, 3, 13, '705712', 2, 'MONITOR', 1, 39, 'CNK73317RG', 2, 'Pantalla LCD 24\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(433, 3, 13, '266366', 3, 'TECLADO', 1, 5, 'BDMHE0CCP9CL5T', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(434, 3, 13, 'S/N', 4, 'MOUSE', 22, 42, '2025HS04P6R8', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(435, 3, 14, '705671', 19, 'CPU', 1, 38, '2UA7471Z32', 2, 'INTEL XEON E3-1270 V6 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(436, 3, 14, '705781', 2, 'MONITOR', 1, 39, 'CNK73317WS', 2, 'Pantalla LCD 24\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(437, 3, 14, '266472', 3, 'TECLADO', 1, 5, 'BEXJLOALA97227', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(438, 3, 14, 'S/N', 4, 'MOUSE', 1, 8, 'FCMHHOA67990IC', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(439, 3, 15, 'S/N', 19, 'CPU', 1, 38, '2UA7471H7P', 2, 'INTEL XEON E3-1270 V6 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(440, 3, 15, 'S/N', 2, 'MONITOR', 1, 39, 'CNK73317PS', 2, 'Pantalla LCD 23.8\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(441, 3, 15, '705677', 3, 'TECLADO', 1, 5, 'BEXJL0ALA842UI', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(442, 3, 15, 'S/N', 4, 'MOUSE', 2, 5, 'S/S', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(443, 3, 16, 'S/N', 19, 'CPU', 1, 38, 'MXL4361LY7', 2, 'INTEL CORE I5-4590 / RAM 4GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(444, 3, 16, 'S/N', 3, 'TECLADO', 1, 40, 'BEXJL0BV8832OQ', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(445, 3, 16, 'S/N', 4, 'MOUSE', 16, 44, '01706-523-7336745-31535', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(446, 3, 17, 'S/N', 19, 'CPU', 1, 5, '2UA5152FJX', 2, 'INTEL CORE I5-4570 / RAM 8GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(447, 3, 17, 'S/N', 3, 'TECLADO', 1, 5, 'BEXJL0ALA880IQ', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(448, 3, 17, 'S/N', 4, 'MOUSE', 23, 5, '34D97248214014', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(449, 3, 18, 'S/N', 19, 'CPU', 1, 38, '2UA7471Z2X', 2, 'INTEL XEON E3-1270 V6 / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(450, 3, 18, 'S/N', 2, 'MONITOR', 1, 39, 'CNK73317DX', 2, 'Pantalla LCD 24\"', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(451, 3, 18, '705706', 3, 'TECLADO', 1, 5, 'BEXJL0BCP9273X', 2, 'Conexión USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(452, 3, 18, 'S/N', 4, 'MOUSE', 2, 5, 'S/S', 2, 'Óptico USB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(453, 3, 19, '705818', 19, 'CPU', 1, 38, '2UA7481JQD', 2, 'INTEL XEON / RAM 16GB / HDD 1TB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(454, 3, NULL, NULL, 6, 'PIZARRA ACRÍLICA', 2, 5, 'MEDIR', 2, 'BLANCA / MARCO DE ALUMINIO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(455, 3, NULL, NULL, 27, 'SILLA DOCENTE', 2, 5, 'MEDIR', 2, 'TAPIZADO EN CUERINA NEGRA / GIRATORIA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(456, 3, NULL, NULL, 28, 'MESA / ESCRITORIO DOCENTE', 2, 5, 'MEDIR', 2, 'MELAMINA COLOR MADERA Y BASE NEGRA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(457, 4, NULL, '265867', 29, 'CASILLERO METAL', 2, 5, '1.80cm x0.90cm x0.45 fondo', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(458, 4, NULL, '265868', 29, 'CASILLERO METAL', 2, 5, '1.80cm x0.90cm x0.45 fondo', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(459, 4, NULL, '266583', 30, 'GABINETE DE METAL DE 12 LOCKERS', 2, 5, '1.80 mt x 1.10 mt x 0.45cm fondo', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(460, 4, NULL, '265850', 30, 'GABINETE DE METAL DE 12 LOCKERS', 2, 5, '1.80 mt x 1.10 mt x 0.45cm fondo', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(461, 4, NULL, '266035', 8, 'EXTINTOR', 24, 5, 'Color Rojo', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(462, 4, NULL, '265874', 6, 'PIZARRA ACRILICA', 2, 5, '2.42 mt x 1.24 mt', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(463, 4, NULL, '265892', 31, 'MESA PEQUEÑA BASE METÁLICA', 2, 5, '0.60cm x 0.45cm 0.43cm alto', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(464, 4, NULL, '265871', 32, 'PROYECTOR MULTIMEDIA', 25, 45, '536L', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(465, 4, NULL, '601702', 32, 'PROYECTOR MULTIMEDIA', 26, 46, 'BYK45S0523090171', 2, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(466, 4, NULL, '265869', 32, 'PROYECTOR MULTIMEDIA', 25, 47, '297L', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(467, 4, NULL, '306765', 33, 'LAPTOP', 27, 48, 'ZB251380Q', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(468, 4, NULL, '297524', 33, 'LAPTOP', 3, 49, '6JSZQT2', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(469, 4, NULL, '403245', 33, 'LAPTOP', 1, 50, '5CD219FTZ1', 1, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(470, 4, NULL, '263118', 34, 'TELEVISOR MONITOR', 28, 51, 'K9499CA002881', 2, 'inopertivo', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(471, 4, NULL, '266139', 34, 'TELEVISOR MONITOR', 28, 52, 'W669BJA000159', 2, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(472, 4, NULL, '265865', 35, 'MODULO DE MADERA', 2, 5, '0.73cm x0.64cm x0.45 fondo', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(473, 4, NULL, '265863', 36, 'MUEBLE MELAMINA EN L', 2, 5, '1.51mt x 1.51mt x 0.50 x 0.76 alto', 3, 'BLANCO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(474, 4, NULL, '265873', 37, 'MUEBLE LIBRERO NEGRO', 2, 5, '2mt x 0.93cm x 0.35 fondo', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(475, 4, NULL, '265888', 38, 'MUEBLE DE CÓMPUTO', 2, 5, '1.93 alto x 1.20 x 0.60 fondo', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(476, 4, NULL, '265876', 39, 'MUEBLE DE MADERA -LIBRERO', 2, 5, '1.20 alto x 0.89 x 0.49 fondo', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(477, 4, NULL, '265875', 40, 'MUEBLE DE MADERA', 2, 5, '1.14 alto x 0.88 x 0.40 fondo', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(478, 4, NULL, '265901', 41, 'ASPIRADOR -SOPLADOR', 29, 53, 'S/SERIE', 2, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(479, 4, NULL, '265628', 42, 'SOPLADOR DE AIRE', 30, 54, 'S/SERIE', 2, 'OPERATIVO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(480, 4, NULL, '265629', 42, 'SOPLADOR DE AIRE', 30, 55, 'S/SERIE', 2, 'OPERATIVO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(481, 4, NULL, '265627', 42, 'SOPLADOR DE AIRE', 30, 56, 'S/SERIE', 2, 'OPERATIVO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(482, 4, NULL, '265630', 42, 'SOPLADOR DE AIRE', 30, 57, 'S/SERIE', 2, 'OPERATIVO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(483, 4, NULL, '403516', 19, 'CPU', 2, 5, '1CZ230057P', 2, 'INTEL CORE I7-10700 / RAM 8GB + 17GB / HDD 1TB + SSD 256GB', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(484, 4, NULL, '403088', 2, 'MONITOR', 4, 58, 'VNA83DB1', 2, 'NEGRO / 23.8\" / MTM: 62AE-KAR2-WW', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(485, 4, NULL, 'S/E', 3, 'TECLADO', 3, 14, 'CN-0C639M-71616-48B-0639N', 2, 'NEGRO / USB / DP/N 0C639N', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(486, 4, NULL, 'S/E', 4, 'MOUSE', 1, 5, 'TCMHHOCOQW87136', 2, 'NEGRO / USB / P/N: 672662-001', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(487, 4, NULL, '266323', 2, 'MONITOR', 3, 59, '2C32PJU', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(488, 4, NULL, 'S/N', 4, 'MOUSE', 2, 5, 'S/N', 2, 'uso con la laptop', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(489, 4, NULL, '297855', 43, 'IMPRESORA', 25, 60, 'X4DW097316', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(490, 4, NULL, '266381', 16, 'ESTABILIZADOR', 13, 21, 'NO VISIBLE', 4, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(491, 4, NULL, '266511', 16, 'ESTABILIZADOR', 14, 5, 'NO VISIBLE', 3, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(492, 4, NULL, '266378', 16, 'ESTABILIZADOR', 12, 20, '0311', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(493, 4, NULL, '266518', 16, 'ESTABILIZADOR', 2, 5, 'PXA250231', 3, 'NEGRO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(494, 4, NULL, '401560', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220225', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(495, 4, NULL, '401487', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220193', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(496, 4, NULL, '401511', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220293', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(497, 4, NULL, '401541', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220102', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(498, 4, NULL, '266371', 16, 'ESTABILIZADOR', 12, 20, 'S/SERIE', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(499, 4, NULL, '266513', 16, 'ESTABILIZADOR', 31, 5, '94103471', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(500, 4, NULL, '266518', 16, 'ESTABILIZADOR', 2, 5, 'PXA250231', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(501, 4, NULL, '705701', 16, 'ESTABILIZADOR', 12, 20, 'S/SERIE', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(502, 4, NULL, '401414', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220267', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(503, 4, NULL, '401594', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220311', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(504, 4, NULL, '401573', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220163', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(505, 4, NULL, '401567', 16, 'ESTABILIZADOR', 12, 20, 'ENPCG1200II0606220134', 1, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(506, 4, NULL, '265878', 44, 'SILLA DE BASE METALICA BASE', 2, 61, 'Tela', 3, '8 TOMAS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(507, 4, NULL, '267823', 45, 'SILLA TRIPLE BASE METÁLICA', 2, 5, 'Azul', 3, 'CON 3 ASIENTOS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(508, 4, NULL, '265864', 46, 'SILLA GIRATORIA', 2, 5, 'Azul', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(509, 4, NULL, '265881', 46, 'SILLA GIRATORIA', 2, 5, 'Forrada de Tela Azul', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(510, 4, NULL, '265883', 46, 'SILLA GIRATORIA', 2, 5, 'Rojo', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(511, 4, NULL, '265885', 46, 'SILLA GIRATORIA', 2, 5, 'Negra', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(512, 4, NULL, 'S/N', 47, 'GALLARDERTE', 2, 5, '2 mt de alto', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(513, 4, NULL, 'S/N', 48, 'EXTENSIÓN', 32, 5, '2.5 mt', 3, 'Cable Vulcanizado', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(514, 4, NULL, 'S/N', 48, 'EXTENSIÓN', 32, 5, '5 mt', 3, 'Cable Vulcanizado', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(515, 4, NULL, 'S/N', 48, 'EXTENSIÓN', 32, 5, '2.50 mt', 3, 'Cable Vulcanizado', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(516, 4, NULL, 'S/N', 48, 'EXTENSIÓN', 32, 5, '5 mt', 2, 'Cable Vulcanizado', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(517, 4, NULL, 'S/N', 49, 'EXTENSIÓN AMARILLA', 32, 5, '5 mt', 2, 'no funciona', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(518, 4, NULL, '266587', 50, 'PIZARRA ELECTRONICA', 19, 62, '1,60X1,30', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(519, 4, NULL, '705701', 16, 'ESTABILIZADOR', 12, 63, 'S/SERIE', 3, NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(520, 4, NULL, '705702', 51, 'SILLA FIJA DE METAL', 2, 5, 'S/SERIE', 3, 'TAPIZ MARROQUI SIN BRAZOS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(521, 4, NULL, '601796', 52, 'SILLA GIRATORIA DE METAL', 2, 5, 'S/SERIE', 3, 'NEGRO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(522, 4, NULL, '306697', 52, 'SILLA GIRATORIA DE METAL', 2, 5, 'S/SERIE', 3, 'AZUL', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(523, 4, NULL, '705699', 51, 'SILLA FIJA DE METAL', 2, 5, 'S/SERIE', 3, 'TAPIZ MARROQUI SIN BRAZOS (NEGRO)', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(524, 5, NULL, '801310', 53, 'mesa de madera para docente con 3 cajones', 2, 5, 'S/SERIE', 2, 'MARRÓN / NEGRO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(525, 5, NULL, '705702', 54, 'silla tapizada de metal para docente', 2, 5, 'S/SERIE', 3, 'NEGRO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(526, 5, NULL, '262014', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(527, 5, NULL, '258261', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(528, 5, NULL, '258257', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(529, 5, NULL, '258250', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(530, 5, NULL, '258253', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(531, 5, NULL, '261872', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(532, 5, NULL, '262045', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(533, 5, NULL, '258234', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(534, 5, NULL, '305835', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(535, 5, NULL, '260199', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(536, 5, NULL, '305834', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(537, 5, NULL, '264228', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(538, 5, NULL, '258232', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(539, 5, NULL, '264867', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(540, 5, NULL, '261893', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(541, 5, NULL, '261882', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(542, 5, NULL, '258256', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(543, 5, NULL, '260189', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(544, 5, NULL, '261861', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(545, 5, NULL, '262034', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(546, 5, NULL, '264226', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(547, 5, NULL, '261870', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(548, 5, NULL, '258247', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(549, 5, NULL, '261958', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(550, 5, NULL, '258252', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(551, 5, NULL, '261876', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(552, 5, NULL, 'S/C', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(553, 5, NULL, '261889', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(554, 5, NULL, '261628', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(555, 5, NULL, '258264', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(556, 5, NULL, '258262', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(557, 5, NULL, '261887', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(558, 5, NULL, '258266', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(559, 5, NULL, '264405', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(560, 6, NULL, '264411', 56, 'escritorio para docente de melamina', 2, 5, 'S/SERIE', 3, 'NEGRO/MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(561, 6, NULL, '264412', 57, 'silla apilable de metal tapizada', 2, 5, 'S/SERIE', 3, 'NEGRO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(562, 6, NULL, '305888', 58, 'pizarra acrílica para plumón con marco de aluminio', 2, 5, 'S/SERIE', 3, 'BLANCO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(563, 6, NULL, '705723', 58, 'pizarra acrílica para plumón con marco de aluminio', 2, 5, 'S/SERIE', 3, 'BLANCO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(564, 6, NULL, '261622', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(565, 6, NULL, '260187', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(566, 6, NULL, '261625', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(567, 6, NULL, '261635', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(568, 6, NULL, '258245', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(569, 6, NULL, '262041', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(570, 6, NULL, '705920', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(571, 6, NULL, '261886', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(572, 6, NULL, '262081', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(573, 6, NULL, '705724', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(574, 6, NULL, '258240', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(575, 6, NULL, '261005', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(576, 6, NULL, '261878', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(577, 6, NULL, '261674', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(578, 6, NULL, '261869', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(579, 6, NULL, '260183', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(580, 6, NULL, '305911', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(581, 6, NULL, '261007', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(582, 6, NULL, '264230', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(583, 6, NULL, '258246', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(584, 6, NULL, 'S/CBI', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(585, 6, NULL, '264854', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(586, 6, NULL, '261890', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(587, 6, NULL, '258263', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(588, 6, NULL, '261881', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(589, 6, NULL, '261899', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(590, 6, NULL, '261900', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(591, 6, NULL, '258251', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(592, 6, NULL, '261885', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(593, 6, NULL, '265411', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(594, 6, NULL, '264243', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(595, 6, NULL, '261888', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(596, 6, NULL, '218735', 59, 'carpeta de metal unipersonal con brazo de madera', 2, 5, 'S/SERIE', 3, 'CREMA/MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(597, 6, NULL, '223311', 59, 'carpeta de metal unipersonal con brazo de madera', 2, 5, 'S/SERIE', 3, 'CREMA/MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(598, 6, NULL, '219963', 59, 'carpeta de metal unipersonal con brazo de madera', 2, 5, 'S/SERIE', 3, 'CREMA/MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(599, 6, NULL, '219948', 59, 'carpeta de metal unipersonal con brazo de madera', 2, 5, 'S/SERIE', 3, 'CREMA/MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(600, 6, NULL, '219924', 59, 'carpeta de metal unipersonal con brazo de madera', 2, 5, 'S/SERIE', 3, 'CREMA/MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(601, 6, NULL, '223161', 59, 'carpeta de metal unipersonal con brazo de madera', 2, 5, 'S/SERIE', 3, 'CREMA/MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(602, 6, NULL, '219973', 59, 'carpeta de metal unipersonal con brazo de madera', 2, 5, 'S/SERIE', 3, 'CREMA/MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(603, 6, NULL, '222549', 59, 'carpeta de metal unipersonal con brazo de madera', 2, 5, 'S/SERIE', 3, 'CREMA/MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(604, 6, NULL, '305889', 60, 'soporte metálico para proyector multimedia', 2, 5, 'S/SERIE', 3, 'NEGRO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(605, 7, NULL, '262013', 61, 'mesa de madera para docente', 2, 5, 'S/SERIE', 2, 'NEGRO / MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(606, 7, NULL, '261987', 62, 'silla tapizada para docente', 2, 5, 'S/SERIE', 2, 'NEGRO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(607, 7, NULL, '705735', 63, 'pizarra acrílica blanca', 2, 5, 'S/SERIE', 2, 'BLANCO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(608, 7, NULL, '705736', 63, 'pizarra acrílica blanca', 2, 5, 'S/SERIE', 2, 'BLANCO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(609, 7, NULL, '262005', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL);
INSERT INTO `bien` (`idBien`, `idSala`, `idGrupo`, `cbi`, `idTipo`, `descripcion`, `idMarca`, `idModelo`, `serieMedida`, `idEstado`, `otrasEspecificaciones`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(610, 7, NULL, '260837', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(611, 7, NULL, '258244', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(612, 7, NULL, '260833', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(613, 7, NULL, '260848', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(614, 7, NULL, '260843', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(615, 7, NULL, '260827', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(616, 7, NULL, '264248', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(617, 7, NULL, '260826', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(618, 7, NULL, '260840', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(619, 7, NULL, '264809', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(620, 7, NULL, '265022', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(621, 7, NULL, '260829', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(622, 7, NULL, '264213', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(623, 7, NULL, '264841', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(624, 7, NULL, '260828', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(625, 7, NULL, '260838', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(626, 7, NULL, '258271', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(627, 7, NULL, '264247', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(628, 7, NULL, '262004', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(629, 7, NULL, '260841', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(630, 7, NULL, '264814', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(631, 7, NULL, '264224', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(632, 7, NULL, '305926', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(633, 7, NULL, '262002', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(634, 7, NULL, '262007', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(635, 7, NULL, '265009', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(636, 7, NULL, '262009', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(637, 7, NULL, '264820', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(638, 7, NULL, '260192', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(639, 7, NULL, '260839', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(640, 7, NULL, '260920', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(641, 7, NULL, '264830', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(642, 7, NULL, '260842', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(643, 7, NULL, '265034', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(644, 7, NULL, '260835', 55, 'carpeta de metal unipersonal', 2, 5, 'S/SERIE', 3, 'PLOMO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado`
--

CREATE TABLE `estado` (
  `idEstado` int(11) NOT NULL,
  `nombre` varchar(60) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estado`
--

INSERT INTO `estado` (`idEstado`, `nombre`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(1, 'NUEVO', 1, NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'BUENO', 1, NULL, NULL, NULL, NULL, NULL, NULL),
(3, 'REGULAR', 1, NULL, NULL, NULL, NULL, NULL, NULL),
(4, 'MALO', 1, NULL, NULL, NULL, NULL, NULL, NULL),
(5, 'SIN MARCA (S/M)', 1, NULL, NULL, NULL, NULL, NULL, NULL),
(6, 'SIN NUMERO (S/N)', 1, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupo`
--

CREATE TABLE `grupo` (
  `idGrupo` int(11) NOT NULL,
  `idProgramaEstudio` int(11) DEFAULT NULL,
  `nombre` varchar(60) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `grupo`
--

INSERT INTO `grupo` (`idGrupo`, `idProgramaEstudio`, `nombre`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(1, 2, 'MAQUINA 01', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(2, 2, 'MAQUINA 02', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(3, 2, 'MAQUINA 03', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(4, 2, 'MAQUINA 04', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(5, 2, 'MAQUINA 05', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(6, 2, 'MAQUINA 06', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(7, 2, 'MAQUINA 07', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(8, 2, 'MAQUINA 08', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(9, 2, 'MAQUINA 09', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(10, 2, 'MAQUINA 10', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(11, 2, 'MAQUINA 11', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(12, 2, 'MAQUINA 12', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(13, 2, 'MAQUINA 13', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(14, 2, 'MAQUINA 14', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(15, 2, 'MAQUINA 15', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(16, 2, 'MAQUINA 16', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(17, 2, 'MAQUINA 17', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(18, 2, 'MAQUINA 18', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(19, 2, 'MAQUINA 19', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(20, 2, 'MAQUINA 20', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(21, 2, 'MAQUINA 21', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(22, 2, 'MAQUINA 22', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(23, 2, 'MAQUINA 23', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(24, 2, 'MAQUINA 24', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(25, 2, 'MAQUINA 25', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(26, 2, 'MAQUINA 26', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(27, 2, 'MAQUINA 27', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(28, 2, 'MAQUINA 28', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(29, 2, 'MAQUINA 29', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(30, 2, 'MAQUINA 30', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `institucion`
--

CREATE TABLE `institucion` (
  `idInstitucion` int(11) NOT NULL,
  `ruc` char(11) DEFAULT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `direccion` varchar(100) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `institucion`
--

INSERT INTO `institucion` (`idInstitucion`, `ruc`, `nombre`, `direccion`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(1, '11111111111', 'Instituto de Educación Superior Tecnológico Público “Julio César Tello”', 'Villa El Salvador', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario`
--

CREATE TABLE `inventario` (
  `idInventario` int(11) NOT NULL,
  `idProgramaEstudio` int(11) DEFAULT NULL,
  `serie` char(4) DEFAULT NULL,
  `numero` varchar(8) DEFAULT NULL,
  `idSala` int(11) DEFAULT NULL,
  `nombreSala` varchar(60) DEFAULT NULL,
  `idCoordinadorArea` int(11) DEFAULT NULL,
  `nombreCoordinadorArea` varchar(100) DEFAULT NULL,
  `idAsistenteAreaT1` int(11) DEFAULT NULL,
  `nombreAsistenteAreaT1` varchar(100) DEFAULT NULL,
  `idAsistenteAreaT2` int(11) DEFAULT NULL,
  `nombreAsistenteAreaT2` varchar(100) DEFAULT NULL,
  `fechaEntrega` date DEFAULT NULL,
  `observacion` varchar(500) DEFAULT NULL,
  `st_inventario` varchar(10) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario_detalle`
--

CREATE TABLE `inventario_detalle` (
  `idInventarioDetalle` int(11) NOT NULL,
  `idInventario` int(11) DEFAULT NULL,
  `idBien` int(11) DEFAULT NULL,
  `idGrupo` int(11) DEFAULT NULL,
  `nombreGrupo` varchar(60) DEFAULT NULL,
  `nroDRELM` varchar(10) DEFAULT NULL,
  `cbi` varchar(10) DEFAULT NULL,
  `idTipo` int(11) DEFAULT NULL,
  `nombreTipo` varchar(60) DEFAULT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `idMarca` int(11) DEFAULT NULL,
  `nombreMarca` varchar(60) DEFAULT NULL,
  `idModelo` int(11) DEFAULT NULL,
  `nombreModelo` varchar(60) DEFAULT NULL,
  `serieMedida` varchar(100) DEFAULT NULL,
  `idEstado` int(11) DEFAULT NULL,
  `nombreEstado` varchar(60) DEFAULT NULL,
  `otrasEspecificaciones` varchar(100) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marca`
--

CREATE TABLE `marca` (
  `idMarca` int(11) NOT NULL,
  `idProgramaEstudio` int(11) DEFAULT NULL,
  `nombre` varchar(60) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `marca`
--

INSERT INTO `marca` (`idMarca`, `idProgramaEstudio`, `nombre`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(1, 2, 'HP', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(2, 2, 'S/M', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(3, 2, 'DELL', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(4, 2, 'LENOVO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(5, 2, 'SONY', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(6, 2, 'TP-LINK', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(7, 2, 'D-LINK', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(8, 2, 'DIXON', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(9, 2, 'FORTE PE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(10, 2, 'OPALUX', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(11, 2, 'MEDITERRANEO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(12, 2, 'ENERGIT', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(13, 2, 'FORZA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(14, 2, 'STABY LINE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(15, 2, 'OMEGA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(16, 2, 'MICROSOFT', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(17, 2, 'DAHUA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(18, 2, 'SATRA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(19, 2, 'SMART BOARD', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(20, 2, 'HOCHI', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(21, 2, 'VIEWSONIC', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(22, 2, 'LOGITECH', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(23, 2, 'GENIUS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(24, 2, 'VALSPROTEXSG', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(25, 2, 'EPSON', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(26, 2, 'VYINTEK', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(27, 2, 'TOSHIBA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(28, 2, 'AOC', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(29, 2, 'BLOWER', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(30, 2, 'POWERMAR', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(31, 2, 'AVR', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(32, 2, 'BTICINO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_09_10_150844_create_posts_table', 1),
(5, '2026_09_10_151657_create_personals_table', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `modelo`
--

CREATE TABLE `modelo` (
  `idModelo` int(11) NOT NULL,
  `idProgramaEstudio` int(11) DEFAULT NULL,
  `nombre` varchar(60) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `modelo`
--

INSERT INTO `modelo` (`idModelo`, `idProgramaEstudio`, `nombre`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(1, 2, 'HP PRODESK 600 G3 SFF', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(2, 2, 'HP V244H', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(3, 2, 'KU-1156', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(4, 2, 'M-U0010-O', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(5, 2, 'S/M', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(6, 2, 'V214A', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(7, 2, 'KBAR211', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(8, 2, 'MOFYUO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(9, 2, 'KU-1469', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(10, 2, 'HP V241P', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(11, 2, 'MS116T1', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(12, 2, 'E2054A / 60DF-AAR1-WW', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(13, 2, 'LT1953 WIDE / 1453-HB1', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(14, 2, 'KB212-B', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(15, 2, 'GENEZI', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(16, 2, 'TL-SG1024D', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(17, 2, 'DES-1026G', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(18, 2, 'S/N', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(19, 2, '9101.220LED', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(20, 2, 'EN-PCG1200II', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(21, 2, 'FVR-1221B', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(22, 2, '4A50B (PCG 1000)', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(23, 2, 'OPTIPLEX 3070', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(24, 2, 'KB-216T', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(25, 2, 'HP N246V', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(26, 2, 'SM-2022', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(27, 2, 'E2054A', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(28, 2, 'MODEL 1113', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(29, 2, 'SOLIDO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(30, 2, 'FVR-1002', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(31, 2, 'ILEGIBLE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(32, 2, 'DEL SERVIDOR', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(33, 2, 'POWEREDGE R720', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(34, 2, 'SA-F124G2', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(35, 2, 'DGS-1024D', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(36, 2, 'PQS 6KG', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(37, 2, 'SB680-R2', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(38, 2, 'Z240 SFF WORKSTATION', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(39, 2, 'Z24I', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(40, 2, 'KU-1460', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(41, 2, 'VG2039M-LED', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(42, 2, 'M90', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(43, 2, 'LV2011', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(44, 2, 'BASIC OPTICAL MOUSE V2.0', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(45, 2, 'H553A', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(46, 2, 'K45 SMART VERSION', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(47, 2, 'H312A', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(48, 2, 'SATELITE C655-S5547', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(49, 2, 'LATITUDE 3500', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(50, 2, 'PROBOOK 450-G8', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(51, 2, 'L24H828', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(52, 2, 'L42H831', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(53, 2, 'Q1F-3.5', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(54, 2, 'PT2202', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(55, 2, 'PT2203', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(56, 2, 'PT2204', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(57, 2, 'PT2205', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(58, 2, 'THINKVISION S24E-20', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(59, 2, 'E17S13', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(60, 2, 'L4160', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(61, 2, 'NEGRA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(62, 2, 'SB-680', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(63, 2, 'EN-PCG-1200II', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personal`
--

CREATE TABLE `personal` (
  `idPersonal` int(11) NOT NULL,
  `apellidos` varchar(100) DEFAULT NULL,
  `nombres` varchar(100) DEFAULT NULL,
  `dni` char(8) DEFAULT NULL,
  `celular` varchar(30) DEFAULT NULL,
  `email` varchar(60) DEFAULT NULL,
  `direccion` varchar(100) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `personal`
--

INSERT INTO `personal` (`idPersonal`, `apellidos`, `nombres`, `dni`, `celular`, `email`, `direccion`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(1, 'ZUÑIGA ROJAS', 'ANTONIO', '45632178', '987654321', 'antonio@gmail.com', 'AV. SOL 123 VES', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(2, NULL, 'TEO GARCIA TEO', '11111111', '111111111', 'teo@gmail.com', 'AV. SOL 321 VES', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(3, 'LEO', 'MALDONADO', '22222222', '222222222', 'leo@gmail.com', 'AV. SOL 321 VES', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(6, NULL, 'Lucas Mathias Faith Ormeño Herrera', '61270453', '21312321321', 'ormenofaith12@gmail.com', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL),
(7, NULL, 'Alejandro Canales Valles', '71694260', '991402297', 'vallesalejandro123@gmail.com', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personals`
--

CREATE TABLE `personals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `posts`
--

CREATE TABLE `posts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `programaestudio`
--

CREATE TABLE `programaestudio` (
  `idProgramaEstudio` int(11) NOT NULL,
  `idInstitucion` int(11) DEFAULT NULL,
  `nombre` varchar(60) DEFAULT NULL,
  `idCoordinadorArea` int(11) DEFAULT NULL,
  `idAsistenteAreaT1` int(11) DEFAULT NULL,
  `idAsistenteAreaT2` int(11) DEFAULT NULL,
  `abreviatura` varchar(30) DEFAULT NULL,
  `observacion` varchar(100) DEFAULT NULL,
  `st_programaEstudio` char(10) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `programaestudio`
--

INSERT INTO `programaestudio` (`idProgramaEstudio`, `idInstitucion`, `nombre`, `idCoordinadorArea`, `idAsistenteAreaT1`, `idAsistenteAreaT2`, `abreviatura`, `observacion`, `st_programaEstudio`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(1, 1, 'ADMINISTRACIÓN DE EMPRESAS', NULL, NULL, NULL, NULL, '', 'ACTIVO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(2, 1, 'DESARROLLO DE SISTEMAS DE INFORMACIÓN', 1, 2, 6, NULL, NULL, 'ACTIVO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(3, 1, 'CONTABILIDAD', NULL, NULL, NULL, NULL, '', 'ACTIVO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(4, 1, 'ELECTRICIDAD INDUSTRIAL', NULL, NULL, NULL, NULL, '', 'ACTIVO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(5, 1, 'MECANICA AUTOMOTRIZ', NULL, 3, NULL, NULL, '', 'ACTIVO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(6, 1, 'MECANICA DE PRODUCCIÓN', NULL, NULL, NULL, NULL, '', 'ACTIVO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(7, 1, 'SECRETARIADO EJECUTIVO', NULL, NULL, NULL, NULL, '', 'ACTIVO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(8, 1, 'matematica', NULL, NULL, NULL, NULL, NULL, 'ACTIVO', 0, NULL, NULL, NULL, NULL, NULL, NULL),
(9, 1, 'matematica', NULL, NULL, NULL, NULL, 'a', 'ACTIVO', 0, NULL, NULL, NULL, NULL, NULL, NULL),
(10, 1, 'matematica', NULL, NULL, NULL, NULL, 'a', 'ACTIVO', 0, NULL, NULL, NULL, NULL, NULL, NULL),
(11, 1, 'a', 1, 3, 3, NULL, 'a', 'ACTIVO', 0, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sala`
--

CREATE TABLE `sala` (
  `idSala` int(11) NOT NULL,
  `idProgramaEstudio` int(11) DEFAULT NULL,
  `nombre` varchar(60) DEFAULT NULL,
  `observacion` varchar(200) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sala`
--

INSERT INTO `sala` (`idSala`, `idProgramaEstudio`, `nombre`, `observacion`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(1, 2, 'Laboratorio de Cómputo Nro 01', NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(2, 2, 'Laboratorio de Cómputo Nro 02', NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(3, 2, 'Laboratorio de Cómputo Nro 03', NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(4, 2, 'Oficina del Area Académica de Computación e Informática', NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(5, 2, 'Modulo Nro 01', NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(6, 2, 'Modulo Nro 02', NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(7, 2, 'Modulo Nro 03', NULL, 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('jvMiFLdLsBv43JQARJLZgIWRpvhOFqdDlNUfU2sz', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', 'YTo3OntzOjY6Il90b2tlbiI7czo0MDoieEc0cWFlZDZZRWllbHM5TTM5SmdubjdLWHVQUzhmc3dsQndGSHJ0QyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDg6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9pbnZlbnRhcmlvL3BlcnNvbmFsLXNhbGEvMSI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJpZFVzdWFyaW8iO3M6MzoiRkFJIjtzOjE3OiJpZFByb2dyYW1hRXN0dWRpbyI7czoxOiIyIjtzOjExOiJ0aXBvVXN1YXJpbyI7czoxMzoiQURNSU5JU1RSQURPUiI7czoxMjoidGl0dWxvU2VzaW9uIjtzOjExMjoiWyBTSUlOLTIwMjYtMSBdIC0gWyBERVNBUlJPTExPIERFIFNJU1RFTUFTIERFIElORk9STUFDScOTTiBdIC0gWyBGQUkgXSAtIFsgTFVDQVMgTUFUSElBUyBGQUlUSCBPUk1Fw5FPIEhFUlJFUkEgXSI7fQ==', 1793896218);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo`
--

CREATE TABLE `tipo` (
  `idTipo` int(11) NOT NULL,
  `idProgramaEstudio` int(11) DEFAULT NULL,
  `nombre` varchar(60) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo`
--

INSERT INTO `tipo` (`idTipo`, `idProgramaEstudio`, `nombre`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(1, 2, 'CASE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(2, 2, 'MONITOR', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(3, 2, 'TECLADO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(4, 2, 'MOUSE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(5, 2, 'MODULO COMP', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(6, 2, 'PIZARRA ACRILICA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(7, 2, 'EQUIPO DE SONIDO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(8, 2, 'EXTINTOR', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(9, 2, 'SWITCH', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(10, 2, 'PATCH PANEL', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(11, 2, 'GABINETE DE METAL', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(12, 2, 'ESCRITORIO DE MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(13, 2, 'SILLA METALICA TAPIZADA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(14, 2, 'LUZ DE EMERGENCIA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(15, 2, 'VENTILADOR ELECTRICO AEREO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(16, 2, 'ESTABILIZADOR', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(17, 2, 'SILLA FIJA DE MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(18, 2, 'MESA PARA PROYECTOR / MESITA DE MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(19, 2, 'CPU', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(20, 2, 'MONITOR LED', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(21, 2, 'CAMARA DE VIDEO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(22, 2, 'SERVIDOR', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(23, 2, 'RACK PARA PROYECTOR', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(24, 2, 'PIZARRA INTERACTIVA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(25, 2, 'VENTILADOR DE TECHO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(26, 2, 'MESA DE MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(27, 2, 'SILLA DOCENTE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(28, 2, 'MESA / ESCRITORIO DOCENTE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(29, 2, 'CASILLERO METAL', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(30, 2, 'GABINETE DE METAL DE 12 LOCKERS', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(31, 2, 'MESA PEQUEÑA BASE METÁLICA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(32, 2, 'PROYECTOR MULTIMEDIA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(33, 2, 'LAPTOP', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(34, 2, 'TELEVISOR MONITOR', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(35, 2, 'MODULO DE MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(36, 2, 'MUEBLE MELAMINA EN L', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(37, 2, 'MUEBLE LIBRERO NEGRO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(38, 2, 'MUEBLE DE CÓMPUTO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(39, 2, 'MUEBLE DE MADERA -LIBRERO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(40, 2, 'MUEBLE DE MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(41, 2, 'ASPIRADOR -SOPLADOR', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(42, 2, 'SOPLADOR DE AIRE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(43, 2, 'IMPRESORA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(44, 2, 'SILLA DE BASE METALICA BASE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(45, 2, 'SILLA TRIPLE BASE METÁLICA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(46, 2, 'SILLA GIRATORIA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(47, 2, 'GALLARDERTE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(48, 2, 'EXTENSIÓN', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(49, 2, 'EXTENSIÓN AMARILLA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(50, 2, 'PIZARRA ELECTRONICA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(51, 2, 'SILLA FIJA DE METAL', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(52, 2, 'SILLA GIRATORIA DE METAL', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(53, 2, 'MESA DE MADERA PARA DOCENTE CON 3 CAJONES', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(54, 2, 'SILLA TAPIZADA DE METAL PARA DOCENTE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(55, 2, 'CARPETA DE METAL UNIPERSONAL', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(56, 2, 'ESCRITORIO PARA DOCENTE DE MELAMINA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(57, 2, 'SILLA APILABLE DE METAL TAPIZADA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(58, 2, 'PIZARRA ACRÍLICA PARA PLUMÓN CON MARCO DE ALUMINIO', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(59, 2, 'CARPETA DE METAL UNIPERSONAL CON BRAZO DE MADERA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(60, 2, 'SOPORTE METÁLICO PARA PROYECTOR MULTIMEDIA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(61, 2, 'MESA DE MADERA PARA DOCENTE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(62, 2, 'SILLA TAPIZADA PARA DOCENTE', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL),
(63, 2, 'PIZARRA ACRÍLICA BLANCA', 1, 'TEO', '2026-11-05 11:29:31', 'IMPORT_EXCEL', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `toma_inventarios`
--

CREATE TABLE `toma_inventarios` (
  `id` int(11) NOT NULL,
  `anio` varchar(4) NOT NULL,
  `numero` int(11) NOT NULL DEFAULT 1,
  `sala_id` int(11) NOT NULL,
  `coordinador_id` int(11) NOT NULL,
  `asistente1_id` int(11) NOT NULL,
  `asistente2_id` int(11) DEFAULT NULL,
  `fecha_entrega` date DEFAULT NULL,
  `observacion` text DEFAULT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'ABIERTO',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idUsuario` varchar(15) NOT NULL,
  `contraseña` varchar(15) DEFAULT NULL,
  `idPersonal` int(11) DEFAULT NULL,
  `tipoUsuario` varchar(20) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT NULL,
  `st_registro` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idUsuario`, `contraseña`, `idPersonal`, `tipoUsuario`, `activo`, `st_registro`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
('AZUÑIGA', 'AZUÑIGA', 1, 'ADMINISTRADOR', 1, 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
('ELMELIUX', '123', 7, 'ADMINISTRADOR', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL),
('FAI', 'FAI', 6, 'ADMINISTRADOR', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL),
('LEO', 'LEO', 3, 'ASISTENTE', 1, 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
('TEO', 'TEO', 2, 'ASISTENTE', 1, 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL);

--
-- Disparadores `usuario`
--
DELIMITER $$
CREATE TRIGGER `TR_USUARIO_INSERT` AFTER INSERT ON `usuario` FOR EACH ROW BEGIN
    INSERT INTO USUARIO_PROGRAMAESTUDIO (idProgramaEstudio, idUsuario, acceso, idUsuarioCrea, fechaCreacion, pcTerminalCrea)
    SELECT P.idProgramaEstudio, NEW.idUsuario, 0, NEW.idUsuarioCrea, NOW(), NEW.pcTerminalCrea
    FROM PROGRAMAESTUDIO P;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_programaestudio`
--

CREATE TABLE `usuario_programaestudio` (
  `idUsuarioProgramaEstudio` int(11) NOT NULL,
  `idProgramaEstudio` int(11) DEFAULT NULL,
  `idUsuario` varchar(15) DEFAULT NULL,
  `acceso` tinyint(1) DEFAULT NULL,
  `idUsuarioCrea` varchar(15) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `pcTerminalCrea` varchar(100) DEFAULT NULL,
  `idUsuarioModifica` varchar(15) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `pcTerminalModifica` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario_programaestudio`
--

INSERT INTO `usuario_programaestudio` (`idUsuarioProgramaEstudio`, `idProgramaEstudio`, `idUsuario`, `acceso`, `idUsuarioCrea`, `fechaCreacion`, `pcTerminalCrea`, `idUsuarioModifica`, `fechaModificacion`, `pcTerminalModifica`) VALUES
(1, 1, 'AZUÑIGA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(2, 2, 'AZUÑIGA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(3, 3, 'AZUÑIGA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(4, 4, 'AZUÑIGA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(5, 5, 'AZUÑIGA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(6, 6, 'AZUÑIGA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(7, 7, 'AZUÑIGA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(8, 1, 'TEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(9, 2, 'TEO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(10, 3, 'TEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(11, 4, 'TEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(12, 5, 'TEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(13, 6, 'TEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(14, 7, 'TEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(15, 1, 'LEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(16, 2, 'LEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(17, 3, 'LEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(18, 4, 'LEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(19, 5, 'LEO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(20, 6, 'LEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(21, 7, 'LEO', 0, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(36, 1, 'FAI', 0, NULL, '2026-09-15 22:50:11', NULL, NULL, NULL, NULL),
(37, 2, 'FAI', 0, NULL, '2026-09-15 22:50:11', NULL, NULL, NULL, NULL),
(38, 3, 'FAI', 0, NULL, '2026-09-15 22:50:11', NULL, NULL, NULL, NULL),
(39, 4, 'FAI', 0, NULL, '2026-09-15 22:50:11', NULL, NULL, NULL, NULL),
(40, 5, 'FAI', 0, NULL, '2026-09-15 22:50:11', NULL, NULL, NULL, NULL),
(41, 6, 'FAI', 0, NULL, '2026-09-15 22:50:11', NULL, NULL, NULL, NULL),
(42, 7, 'FAI', 0, NULL, '2026-09-15 22:50:11', NULL, NULL, NULL, NULL),
(43, 8, 'FAI', 0, NULL, '2026-09-15 22:50:11', NULL, NULL, NULL, NULL),
(44, 9, 'FAI', 0, NULL, '2026-09-15 22:50:11', NULL, NULL, NULL, NULL),
(45, 10, 'FAI', 0, NULL, '2026-09-15 22:50:11', NULL, NULL, NULL, NULL),
(46, 11, 'FAI', 0, NULL, '2026-09-15 22:50:11', NULL, NULL, NULL, NULL),
(51, 1, 'ELMELIUX', 0, NULL, '2026-09-17 16:09:35', NULL, NULL, NULL, NULL),
(52, 2, 'ELMELIUX', 0, NULL, '2026-09-17 16:09:35', NULL, NULL, NULL, NULL),
(53, 3, 'ELMELIUX', 0, NULL, '2026-09-17 16:09:35', NULL, NULL, NULL, NULL),
(54, 4, 'ELMELIUX', 0, NULL, '2026-09-17 16:09:35', NULL, NULL, NULL, NULL),
(55, 5, 'ELMELIUX', 0, NULL, '2026-09-17 16:09:35', NULL, NULL, NULL, NULL),
(56, 6, 'ELMELIUX', 0, NULL, '2026-09-17 16:09:35', NULL, NULL, NULL, NULL),
(57, 7, 'ELMELIUX', 0, NULL, '2026-09-17 16:09:35', NULL, NULL, NULL, NULL),
(58, 8, 'ELMELIUX', 0, NULL, '2026-09-17 16:09:35', NULL, NULL, NULL, NULL),
(59, 9, 'ELMELIUX', 0, NULL, '2026-09-17 16:09:35', NULL, NULL, NULL, NULL),
(60, 10, 'ELMELIUX', 0, NULL, '2026-09-17 16:09:35', NULL, NULL, NULL, NULL),
(61, 11, 'ELMELIUX', 0, NULL, '2026-09-17 16:09:35', NULL, NULL, NULL, NULL);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `bien`
--
ALTER TABLE `bien`
  ADD PRIMARY KEY (`idBien`),
  ADD KEY `idSala` (`idSala`),
  ADD KEY `idGrupo` (`idGrupo`),
  ADD KEY `idTipo` (`idTipo`),
  ADD KEY `idMarca` (`idMarca`),
  ADD KEY `idModelo` (`idModelo`),
  ADD KEY `idEstado` (`idEstado`);

--
-- Indices de la tabla `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indices de la tabla `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indices de la tabla `estado`
--
ALTER TABLE `estado`
  ADD PRIMARY KEY (`idEstado`);

--
-- Indices de la tabla `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indices de la tabla `grupo`
--
ALTER TABLE `grupo`
  ADD PRIMARY KEY (`idGrupo`),
  ADD KEY `idProgramaEstudio` (`idProgramaEstudio`);

--
-- Indices de la tabla `institucion`
--
ALTER TABLE `institucion`
  ADD PRIMARY KEY (`idInstitucion`);

--
-- Indices de la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD PRIMARY KEY (`idInventario`),
  ADD KEY `idProgramaEstudio` (`idProgramaEstudio`),
  ADD KEY `idSala` (`idSala`),
  ADD KEY `idCoordinadorArea` (`idCoordinadorArea`),
  ADD KEY `idAsistenteAreaT1` (`idAsistenteAreaT1`),
  ADD KEY `idAsistenteAreaT2` (`idAsistenteAreaT2`);

--
-- Indices de la tabla `inventario_detalle`
--
ALTER TABLE `inventario_detalle`
  ADD PRIMARY KEY (`idInventarioDetalle`),
  ADD KEY `idInventario` (`idInventario`),
  ADD KEY `idBien` (`idBien`),
  ADD KEY `idGrupo` (`idGrupo`),
  ADD KEY `idTipo` (`idTipo`),
  ADD KEY `idMarca` (`idMarca`),
  ADD KEY `idModelo` (`idModelo`),
  ADD KEY `idEstado` (`idEstado`);

--
-- Indices de la tabla `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indices de la tabla `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `marca`
--
ALTER TABLE `marca`
  ADD PRIMARY KEY (`idMarca`),
  ADD KEY `idProgramaEstudio` (`idProgramaEstudio`);

--
-- Indices de la tabla `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `modelo`
--
ALTER TABLE `modelo`
  ADD PRIMARY KEY (`idModelo`),
  ADD KEY `idProgramaEstudio` (`idProgramaEstudio`);

--
-- Indices de la tabla `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indices de la tabla `personal`
--
ALTER TABLE `personal`
  ADD PRIMARY KEY (`idPersonal`);

--
-- Indices de la tabla `personals`
--
ALTER TABLE `personals`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `programaestudio`
--
ALTER TABLE `programaestudio`
  ADD PRIMARY KEY (`idProgramaEstudio`),
  ADD KEY `idInstitucion` (`idInstitucion`),
  ADD KEY `idCoordinadorArea` (`idCoordinadorArea`),
  ADD KEY `idAsistenteAreaT1` (`idAsistenteAreaT1`),
  ADD KEY `idAsistenteAreaT2` (`idAsistenteAreaT2`);

--
-- Indices de la tabla `sala`
--
ALTER TABLE `sala`
  ADD PRIMARY KEY (`idSala`),
  ADD KEY `idProgramaEstudio` (`idProgramaEstudio`);

--
-- Indices de la tabla `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indices de la tabla `tipo`
--
ALTER TABLE `tipo`
  ADD PRIMARY KEY (`idTipo`),
  ADD KEY `idProgramaEstudio` (`idProgramaEstudio`);

--
-- Indices de la tabla `toma_inventarios`
--
ALTER TABLE `toma_inventarios`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idUsuario`),
  ADD KEY `idPersonal` (`idPersonal`);

--
-- Indices de la tabla `usuario_programaestudio`
--
ALTER TABLE `usuario_programaestudio`
  ADD PRIMARY KEY (`idUsuarioProgramaEstudio`),
  ADD KEY `idProgramaEstudio` (`idProgramaEstudio`),
  ADD KEY `idUsuario` (`idUsuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `bien`
--
ALTER TABLE `bien`
  MODIFY `idBien` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1024;

--
-- AUTO_INCREMENT de la tabla `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `grupo`
--
ALTER TABLE `grupo`
  MODIFY `idGrupo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT de la tabla `institucion`
--
ALTER TABLE `institucion`
  MODIFY `idInstitucion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `inventario`
--
ALTER TABLE `inventario`
  MODIFY `idInventario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `inventario_detalle`
--
ALTER TABLE `inventario_detalle`
  MODIFY `idInventarioDetalle` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `marca`
--
ALTER TABLE `marca`
  MODIFY `idMarca` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT de la tabla `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `modelo`
--
ALTER TABLE `modelo`
  MODIFY `idModelo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT de la tabla `personal`
--
ALTER TABLE `personal`
  MODIFY `idPersonal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `personals`
--
ALTER TABLE `personals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `posts`
--
ALTER TABLE `posts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `programaestudio`
--
ALTER TABLE `programaestudio`
  MODIFY `idProgramaEstudio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `sala`
--
ALTER TABLE `sala`
  MODIFY `idSala` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `tipo`
--
ALTER TABLE `tipo`
  MODIFY `idTipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT de la tabla `toma_inventarios`
--
ALTER TABLE `toma_inventarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuario_programaestudio`
--
ALTER TABLE `usuario_programaestudio`
  MODIFY `idUsuarioProgramaEstudio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `bien`
--
ALTER TABLE `bien`
  ADD CONSTRAINT `bien_ibfk_1` FOREIGN KEY (`idSala`) REFERENCES `sala` (`idSala`),
  ADD CONSTRAINT `bien_ibfk_2` FOREIGN KEY (`idGrupo`) REFERENCES `grupo` (`idGrupo`),
  ADD CONSTRAINT `bien_ibfk_3` FOREIGN KEY (`idTipo`) REFERENCES `tipo` (`idTipo`),
  ADD CONSTRAINT `bien_ibfk_4` FOREIGN KEY (`idMarca`) REFERENCES `marca` (`idMarca`),
  ADD CONSTRAINT `bien_ibfk_5` FOREIGN KEY (`idModelo`) REFERENCES `modelo` (`idModelo`),
  ADD CONSTRAINT `bien_ibfk_6` FOREIGN KEY (`idEstado`) REFERENCES `estado` (`idEstado`);

--
-- Filtros para la tabla `grupo`
--
ALTER TABLE `grupo`
  ADD CONSTRAINT `grupo_ibfk_1` FOREIGN KEY (`idProgramaEstudio`) REFERENCES `programaestudio` (`idProgramaEstudio`);

--
-- Filtros para la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD CONSTRAINT `inventario_ibfk_1` FOREIGN KEY (`idProgramaEstudio`) REFERENCES `programaestudio` (`idProgramaEstudio`),
  ADD CONSTRAINT `inventario_ibfk_2` FOREIGN KEY (`idSala`) REFERENCES `sala` (`idSala`),
  ADD CONSTRAINT `inventario_ibfk_3` FOREIGN KEY (`idCoordinadorArea`) REFERENCES `personal` (`idPersonal`),
  ADD CONSTRAINT `inventario_ibfk_4` FOREIGN KEY (`idAsistenteAreaT1`) REFERENCES `personal` (`idPersonal`),
  ADD CONSTRAINT `inventario_ibfk_5` FOREIGN KEY (`idAsistenteAreaT2`) REFERENCES `personal` (`idPersonal`);

--
-- Filtros para la tabla `inventario_detalle`
--
ALTER TABLE `inventario_detalle`
  ADD CONSTRAINT `fk_detalle_toma_inventarios` FOREIGN KEY (`idInventario`) REFERENCES `toma_inventarios` (`id`),
  ADD CONSTRAINT `inventario_detalle_ibfk_2` FOREIGN KEY (`idBien`) REFERENCES `bien` (`idBien`),
  ADD CONSTRAINT `inventario_detalle_ibfk_3` FOREIGN KEY (`idGrupo`) REFERENCES `grupo` (`idGrupo`),
  ADD CONSTRAINT `inventario_detalle_ibfk_4` FOREIGN KEY (`idTipo`) REFERENCES `tipo` (`idTipo`),
  ADD CONSTRAINT `inventario_detalle_ibfk_5` FOREIGN KEY (`idMarca`) REFERENCES `marca` (`idMarca`),
  ADD CONSTRAINT `inventario_detalle_ibfk_6` FOREIGN KEY (`idModelo`) REFERENCES `modelo` (`idModelo`),
  ADD CONSTRAINT `inventario_detalle_ibfk_7` FOREIGN KEY (`idEstado`) REFERENCES `estado` (`idEstado`);

--
-- Filtros para la tabla `marca`
--
ALTER TABLE `marca`
  ADD CONSTRAINT `marca_ibfk_1` FOREIGN KEY (`idProgramaEstudio`) REFERENCES `programaestudio` (`idProgramaEstudio`);

--
-- Filtros para la tabla `modelo`
--
ALTER TABLE `modelo`
  ADD CONSTRAINT `modelo_ibfk_1` FOREIGN KEY (`idProgramaEstudio`) REFERENCES `programaestudio` (`idProgramaEstudio`);

--
-- Filtros para la tabla `programaestudio`
--
ALTER TABLE `programaestudio`
  ADD CONSTRAINT `programaestudio_ibfk_1` FOREIGN KEY (`idInstitucion`) REFERENCES `institucion` (`idInstitucion`),
  ADD CONSTRAINT `programaestudio_ibfk_2` FOREIGN KEY (`idCoordinadorArea`) REFERENCES `personal` (`idPersonal`),
  ADD CONSTRAINT `programaestudio_ibfk_3` FOREIGN KEY (`idAsistenteAreaT1`) REFERENCES `personal` (`idPersonal`),
  ADD CONSTRAINT `programaestudio_ibfk_4` FOREIGN KEY (`idAsistenteAreaT2`) REFERENCES `personal` (`idPersonal`);

--
-- Filtros para la tabla `sala`
--
ALTER TABLE `sala`
  ADD CONSTRAINT `sala_ibfk_1` FOREIGN KEY (`idProgramaEstudio`) REFERENCES `programaestudio` (`idProgramaEstudio`);

--
-- Filtros para la tabla `tipo`
--
ALTER TABLE `tipo`
  ADD CONSTRAINT `tipo_ibfk_1` FOREIGN KEY (`idProgramaEstudio`) REFERENCES `programaestudio` (`idProgramaEstudio`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`idPersonal`) REFERENCES `personal` (`idPersonal`);

--
-- Filtros para la tabla `usuario_programaestudio`
--
ALTER TABLE `usuario_programaestudio`
  ADD CONSTRAINT `usuario_programaestudio_ibfk_1` FOREIGN KEY (`idProgramaEstudio`) REFERENCES `programaestudio` (`idProgramaEstudio`),
  ADD CONSTRAINT `usuario_programaestudio_ibfk_2` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
