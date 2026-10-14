-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 02-10-2026 a las 03:58:57
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

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
(1, 1, 1, 'CBI001', 9, 'MONITOR LED 19 PULGADAS', 3, 3, 'SN-009823', 2, 'CON CABLE DE PODER Y VGA', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(2, 1, 1, 'CBI002', 1, 'CASE TOWER PARA SERVIDOR', 1, 2, 'SN-HP9911', 1, 'PROCESADOR I7 10MA GEN', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(3, 3, 3, 'CBI003', 23, 'TALADRO PERCUTOR', 5, 4, 'BOS-2023-X1', 2, 'COLOR AZUL PROFESIONAL', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(4, 1, 1, 'CBI010', 9, 'MONITOR LED 21.5', 3, 3, 'LGN-99201', 2, 'CONEXIÓN HDMI', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(5, 1, 1, 'CBI011', 1, 'CPU CORE I5 12va GEN', 1, 1, 'HP-SER-881', 1, '16GB RAM, 512GB SSD', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(6, 1, 1, 'CBI012', 16, 'TECLADO USB ESPAÑOL', 1, NULL, 'SN-88221', 2, 'COLOR NEGRO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(7, 1, 1, 'CBI013', 10, 'MOUSE OPTICO USB', 2, NULL, 'SN-77332', 2, 'COLOR NEGRO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(8, 1, 2, 'CBI014', 3, 'ESCRITORIO DE MADERA LAMINADO', NULL, NULL, 'S/N', 3, '1.20m x 0.60m', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(9, 1, 2, 'CBI015', 13, 'SILLA FIJA METALICA', NULL, NULL, 'S/N', 2, 'TAPIZADO AZUL', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(10, 2, 1, 'CBI016', 15, 'SWITCH 24 PUERTOS GIGABIT', 3, NULL, 'SW-LG-554', 2, 'ADMINISTRABLE', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(11, 2, 1, 'CBI017', 4, 'ESTABILIZADOR SOLIDO', NULL, NULL, 'EST-990', 2, '1000VA', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(12, 3, 3, 'CBI020', 20, 'MOTOR TOYOTA 22R', 4, NULL, 'ENG-554433', 3, 'PARA PRÁCTICAS DE ARMADO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(13, 3, 3, 'CBI021', 18, 'AMOLADORA ANGULAR 4 1/2', 5, 5, 'BOS-AM-99', 2, 'INCLUYE GUARDA DE PROTECCIÓN', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(14, 3, 3, 'CBI022', 22, 'MAQUINA DE SOLDAR ELECTRICA', 7, NULL, 'TRU-8877', 2, 'TIPO ARCO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(15, 3, 4, 'CBI023', 21, 'GATA HIDRAULICA TIPO COCODRILO', 7, NULL, 'TRU-GAT-01', 2, 'CAPACIDAD 3 TONELADAS', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(16, 3, 4, 'CBI024', 19, 'LLAVE FRANCESA 12 PULGADAS', 6, NULL, 'STA-12-P', 2, 'ACERO CROMO VANADIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(17, 3, 4, 'CBI025', 19, 'JUEGO DE LLAVES MIXTAS', 6, NULL, 'STA-MIX-10', 1, 'SET DE 12 PIEZAS', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(18, 3, 3, 'CBI026', 24, 'PRENSA HIDRAULICA DE BANCO', 5, NULL, 'BOS-PRE-44', 3, 'FUERZA 10 TONELADAS', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(19, 1, 5, 'CBI-MAQ-01', 1, 'CPU DE COMPUTO - MAQUINA 01', 1, 17, 'SERIE-5', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(20, 1, 6, 'CBI-MAQ-02', 1, 'CPU DE COMPUTO - MAQUINA 02', 1, 17, 'SERIE-6', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(21, 1, 7, 'CBI-MAQ-03', 1, 'CPU DE COMPUTO - MAQUINA 03', 1, 17, 'SERIE-7', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(22, 1, 8, 'CBI-MAQ-04', 1, 'CPU DE COMPUTO - MAQUINA 04', 1, 17, 'SERIE-8', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(23, 1, 9, 'CBI-MAQ-05', 1, 'CPU DE COMPUTO - MAQUINA 05', 1, 17, 'SERIE-9', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(24, 1, 10, 'CBI-MAQ-06', 1, 'CPU DE COMPUTO - MAQUINA 06', 1, 17, 'SERIE-10', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(25, 1, 11, 'CBI-MAQ-07', 1, 'CPU DE COMPUTO - MAQUINA 07', 1, 17, 'SERIE-11', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(26, 1, 12, 'CBI-MAQ-08', 1, 'CPU DE COMPUTO - MAQUINA 08', 1, 17, 'SERIE-12', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(27, 1, 13, 'CBI-MAQ-09', 1, 'CPU DE COMPUTO - MAQUINA 09', 1, 17, 'SERIE-13', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(28, 1, 14, 'CBI-MAQ-10', 1, 'CPU DE COMPUTO - MAQUINA 10', 1, 17, 'SERIE-14', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(29, 1, 15, 'CBI-MAQ-11', 1, 'CPU DE COMPUTO - MAQUINA 11', 1, 17, 'SERIE-15', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(30, 1, 16, 'CBI-MAQ-12', 1, 'CPU DE COMPUTO - MAQUINA 12', 1, 17, 'SERIE-16', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(31, 1, 17, 'CBI-MAQ-13', 1, 'CPU DE COMPUTO - MAQUINA 13', 1, 17, 'SERIE-17', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(32, 1, 18, 'CBI-MAQ-14', 1, 'CPU DE COMPUTO - MAQUINA 14', 1, 17, 'SERIE-18', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(33, 1, 19, 'CBI-MAQ-15', 1, 'CPU DE COMPUTO - MAQUINA 15', 1, 17, 'SERIE-19', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(34, 1, 20, 'CBI-MAQ-16', 1, 'CPU DE COMPUTO - MAQUINA 16', 1, 17, 'SERIE-20', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(35, 1, 21, 'CBI-MAQ-17', 1, 'CPU DE COMPUTO - MAQUINA 17', 1, 17, 'SERIE-21', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(36, 1, 22, 'CBI-MAQ-18', 1, 'CPU DE COMPUTO - MAQUINA 18', 1, 17, 'SERIE-22', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(37, 1, 23, 'CBI-MAQ-19', 1, 'CPU DE COMPUTO - MAQUINA 19', 1, 17, 'SERIE-23', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(38, 1, 24, 'CBI-MAQ-20', 1, 'CPU DE COMPUTO - MAQUINA 20', 1, 17, 'SERIE-24', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(39, 1, 25, 'CBI-MAQ-21', 1, 'CPU DE COMPUTO - MAQUINA 21', 1, 17, 'SERIE-25', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(40, 1, 26, 'CBI-MAQ-22', 1, 'CPU DE COMPUTO - MAQUINA 22', 1, 17, 'SERIE-26', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(41, 1, 27, 'CBI-MAQ-23', 1, 'CPU DE COMPUTO - MAQUINA 23', 1, 17, 'SERIE-27', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(42, 1, 28, 'CBI-MAQ-24', 1, 'CPU DE COMPUTO - MAQUINA 24', 1, 17, 'SERIE-28', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(43, 1, 29, 'CBI-MAQ-25', 1, 'CPU DE COMPUTO - MAQUINA 25', 1, 17, 'SERIE-29', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(50, 2, 5, 'L2-01', 1, 'CPU DE COMPUTO - MAQUINA 01', 1, 17, 'SERIE-L2-5', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(51, 2, 6, 'L2-02', 1, 'CPU DE COMPUTO - MAQUINA 02', 1, 17, 'SERIE-L2-6', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(52, 2, 7, 'L2-03', 1, 'CPU DE COMPUTO - MAQUINA 03', 1, 17, 'SERIE-L2-7', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(53, 2, 8, 'L2-04', 1, 'CPU DE COMPUTO - MAQUINA 04', 1, 17, 'SERIE-L2-8', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(54, 2, 9, 'L2-05', 1, 'CPU DE COMPUTO - MAQUINA 05', 1, 17, 'SERIE-L2-9', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(55, 2, 10, 'L2-06', 1, 'CPU DE COMPUTO - MAQUINA 06', 1, 17, 'SERIE-L2-10', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(56, 2, 11, 'L2-07', 1, 'CPU DE COMPUTO - MAQUINA 07', 1, 17, 'SERIE-L2-11', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(57, 2, 12, 'L2-08', 1, 'CPU DE COMPUTO - MAQUINA 08', 1, 17, 'SERIE-L2-12', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(58, 2, 13, 'L2-09', 1, 'CPU DE COMPUTO - MAQUINA 09', 1, 17, 'SERIE-L2-13', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(59, 2, 14, 'L2-10', 1, 'CPU DE COMPUTO - MAQUINA 10', 1, 17, 'SERIE-L2-14', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(60, 2, 15, 'L2-11', 1, 'CPU DE COMPUTO - MAQUINA 11', 1, 17, 'SERIE-L2-15', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(61, 2, 16, 'L2-12', 1, 'CPU DE COMPUTO - MAQUINA 12', 1, 17, 'SERIE-L2-16', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(62, 2, 17, 'L2-13', 1, 'CPU DE COMPUTO - MAQUINA 13', 1, 17, 'SERIE-L2-17', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(63, 2, 18, 'L2-14', 1, 'CPU DE COMPUTO - MAQUINA 14', 1, 17, 'SERIE-L2-18', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(64, 2, 19, 'L2-15', 1, 'CPU DE COMPUTO - MAQUINA 15', 1, 17, 'SERIE-L2-19', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(65, 2, 20, 'L2-16', 1, 'CPU DE COMPUTO - MAQUINA 16', 1, 17, 'SERIE-L2-20', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(66, 2, 21, 'L2-17', 1, 'CPU DE COMPUTO - MAQUINA 17', 1, 17, 'SERIE-L2-21', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(67, 2, 22, 'L2-18', 1, 'CPU DE COMPUTO - MAQUINA 18', 1, 17, 'SERIE-L2-22', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(68, 2, 23, 'L2-19', 1, 'CPU DE COMPUTO - MAQUINA 19', 1, 17, 'SERIE-L2-23', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(69, 2, 24, 'L2-20', 1, 'CPU DE COMPUTO - MAQUINA 20', 1, 17, 'SERIE-L2-24', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(70, 2, 25, 'L2-21', 1, 'CPU DE COMPUTO - MAQUINA 21', 1, 17, 'SERIE-L2-25', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(71, 2, 26, 'L2-22', 1, 'CPU DE COMPUTO - MAQUINA 22', 1, 17, 'SERIE-L2-26', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(72, 2, 27, 'L2-23', 1, 'CPU DE COMPUTO - MAQUINA 23', 1, 17, 'SERIE-L2-27', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(73, 2, 28, 'L2-24', 1, 'CPU DE COMPUTO - MAQUINA 24', 1, 17, 'SERIE-L2-28', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(74, 2, 29, 'L2-25', 1, 'CPU DE COMPUTO - MAQUINA 25', 1, 17, 'SERIE-L2-29', 1, 'EQUIPO DE COMPUTO PARA LABORATORIO 2', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(81, 2, 6, '000002', 2, 'ninguna descripcion 2', 16, 19, '00000123', 4, 'ninguna otra especificaon 2', 0, 'FAI', '2026-09-17 22:28:23', 'DESKTOP-DKN38QG', 'FAI', '2026-09-17 22:30:47', 'DESKTOP-DKN38QG'),
(82, 3, 4, '000011123', 21, 'rapidoasdasd', 31, 16, '0000142434523412', 4, 'nadaaseqaweqw', 1, 'FAI', '2026-09-17 22:32:42', 'DESKTOP-DKN38QG', 'FAI', '2026-09-17 22:32:53', 'DESKTOP-DKN38QG'),
(83, 4, 6, '123123', 4, '12312', 53, 17, '123', 4, '1231', 1, 'FAI', '2026-09-23 21:44:12', 'DESKTOP-07IOB2G', NULL, NULL, NULL);

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
(1, 2, 'EQUIPOS DE CÓMPUTO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', 'AZUñIGA', '2026-09-16 00:56:41', NULL),
(2, 2, 'MOBILIARIO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(3, 5, 'HERRAMIENTAS ELÉCTRICAS', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(4, 5, 'HERRAMIENTAS MANUALES', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(5, 2, 'MAQUINA 01', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', 'FAI', '2026-09-16 04:10:06', NULL),
(6, 2, 'MAQUINA 02', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(7, 2, 'MAQUINA 03', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(8, 2, 'MAQUINA 04', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(9, 2, 'MAQUINA 05', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(10, 2, 'MAQUINA 06', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(11, 2, 'MAQUINA 07', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(12, 2, 'MAQUINA 08', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(13, 2, 'MAQUINA 09', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(14, 2, 'MAQUINA 10', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(15, 2, 'MAQUINA 11', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(16, 2, 'MAQUINA 12', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(17, 2, 'MAQUINA 13', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(18, 2, 'MAQUINA 14', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(19, 2, 'MAQUINA 15', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(20, 2, 'MAQUINA 16', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(21, 2, 'MAQUINA 17', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(22, 2, 'MAQUINA 18', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(23, 2, 'MAQUINA 19', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(24, 2, 'MAQUINA 20', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(25, 2, 'MAQUINA 21', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(26, 2, 'MAQUINA 22', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(27, 2, 'MAQUINA 23', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(28, 2, 'MAQUINA 24', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(29, 2, 'MAQUINA 25', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(35, 2, 'sadddd', 1, 'AZUñIGA', '2026-09-15 23:14:57', NULL, 'AZUñIGA', '2026-09-15 23:16:06', NULL),
(39, 2, 'a', 1, 'AZUñIGA', '2026-09-16 00:25:35', NULL, NULL, NULL, NULL);

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
(1, 2, 'HP', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(2, 2, 'DELL', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(3, 2, 'LG', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(4, 2, 'SAMSUNG', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(5, 5, 'BOSCH', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(6, 5, 'STANLEY', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(7, 5, 'TRUPER', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(8, 2, 'LENOVO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(9, 2, 'ASUS', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(10, 2, 'ACER', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(11, 2, 'MSI', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(12, 2, 'APPLE', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(13, 2, 'TOSHIBA', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(14, 2, 'SONY', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(15, 2, 'INTEL', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(16, 2, 'AMD', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(17, 2, 'KINGSTON', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(18, 2, 'CORSAIR', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(19, 2, 'LOGITECH', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(20, 2, 'GENIUS', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(21, 2, 'TP-LINK', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(22, 2, 'D-LINK', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(23, 2, 'CISCO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(24, 2, 'UBIQUITI', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(25, 2, 'EPSON', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(26, 2, 'CANON', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(27, 2, 'BROTHER', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(28, 2, 'VIEWSONIC', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(29, 2, 'AOC', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(30, 5, 'MAKITA', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(31, 5, 'DEWALT', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(32, 5, 'HILTI', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(33, 5, 'BLACK+DECKER', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(34, 5, 'MILWAUKEE', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(35, 5, 'INGCO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(36, 5, 'TOTAL', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(37, 5, 'PRETUL', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(38, 5, 'URREA', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(39, 5, 'KAMASA', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(40, 5, 'IRIMO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(41, 5, 'BAHCO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(42, 5, 'TRAMONTINA', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(43, 5, 'SKF', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(44, 5, 'TOYOTA', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(45, 5, 'NISSAN', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(46, 5, 'HYUNDAI', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(47, 5, 'KIA', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(48, 5, 'CHEVROLET', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(49, 5, 'FORD', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(51, 2, 'RAZERR', 1, 'AZUñIGA', '2026-09-15 23:43:55', NULL, 'AZUñIGA', '2026-09-15 23:44:07', NULL),
(52, 2, 'a', 1, 'AZUñIGA', '2026-09-16 00:16:36', NULL, NULL, NULL, NULL),
(53, 2, 'aaa', 1, 'AZUñIGA', '2026-09-16 00:29:01', NULL, 'AZUñIGA', '2026-09-16 00:29:09', NULL);

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
(1, 2, 'PROBOOK 450 G8', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(2, 2, 'OPTIPLEX 7070', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(3, 2, 'FLATRON E1942', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(4, 5, 'GSB 13 RE', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(5, 5, 'GWS 7-115', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(6, 2, 'MONITOR LED 19\"', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(7, 2, 'MONITOR LED 21.5\"', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(8, 2, 'MONITOR LED 22\"', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(9, 2, 'MONITOR LED 24\"', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(10, 2, 'MONITOR LED 27\"', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(11, 2, 'MONITOR LED FULL HD', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(12, 2, 'MONITOR LED QHD', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(13, 2, 'GABINETE ATX', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(14, 2, 'GABINETE MICRO ATX', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(15, 2, 'GABINETE MINI ATX', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(16, 2, 'CPU CORE I3', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(17, 2, 'CPU CORE I5', 1, '', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(18, 2, 'CPU CORE I7', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(19, 2, 'CPU CORE I9', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(20, 2, 'CPU AMD RYZEN 5', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(21, 2, 'TECLADO USB BASICO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(22, 2, 'TECLADO USB MULTIMEDIA', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(23, 2, 'TECLADO MECANICO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(24, 2, 'TECLADO INALAMBRICO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(25, 2, 'TECLADO ERGONOMICO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(26, 2, 'MOUSE OPTICO USB', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(27, 2, 'MOUSE OPTICO INALAMBRICO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(28, 2, 'MOUSE LASER', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(29, 2, 'MOUSE GAMER', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(30, 2, 'MOUSE ERGONOMICO', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(31, 2, 'Optiplex 2323x', NULL, 'AZUñIGA', '2026-09-15 23:57:55', NULL, 'AZUñIGA', '2026-09-15 23:58:03', NULL);

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
(1, 2, 'LABORATORIO L1', 'Laboratorio de cómputo principal', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(2, 2, 'LABORATORIO L2', 'Laboratorio de redes', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(3, 5, 'TALLER DE MECÁNICA', 'Taller de motores', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(4, 2, 'LABORATORIO L3', 'Laboratorio de programación', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(5, 2, 'LABORATORIO L4', 'Laboratorio de base de datos', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(6, 2, 'LABORATORIO L5', 'Laboratorio de hardware', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(7, 2, 'LABORATORIO L6', 'Laboratorio de redes avanzadas', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(8, 5, 'TALLER M1', 'Taller de motores', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(9, 5, 'TALLER M2', 'Taller de transmisión', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(10, 5, 'TALLER M3', 'Taller eléctrico automotriz', 1, 'AZUÑIGA', '2026-09-10 10:42:18', 'SERVER', NULL, NULL, NULL),
(15, 2, 'a', 'a', 1, 'AZUñIGA', '2026-09-16 00:31:42', NULL, NULL, NULL, NULL);

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
('DAIIzhJZ2wAG8v2Xmd2mwsP20IVMWRvEZOEBeHTx', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'YTo3OntzOjY6Il90b2tlbiI7czo0MDoiWjhSUTI3bW9vRUl6THhNQzNSdzdwTVBLZFJxUWcxNDhrT2twWVowQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzk6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9pbnZlbnRhcmlvL2xpc3RhciI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJpZFVzdWFyaW8iO3M6MzoiRkFJIjtzOjE3OiJpZFByb2dyYW1hRXN0dWRpbyI7czoxOiIyIjtzOjExOiJ0aXBvVXN1YXJpbyI7czoxMzoiQURNSU5JU1RSQURPUiI7czoxMjoidGl0dWxvU2VzaW9uIjtzOjExMjoiWyBTSUlOLTIwMjYtMSBdIC0gWyBERVNBUlJPTExPIERFIFNJU1RFTUFTIERFIElORk9STUFDScOTTiBdIC0gWyBGQUkgXSAtIFsgTFVDQVMgTUFUSElBUyBGQUlUSCBPUk1Fw5FPIEhFUlJFUkEgXSI7fQ==', 1790904798),
('iU0xUiOZ4ETDZvEoz8JEVxMui8kkT6hdiU4npCot', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'YTo3OntzOjY6Il90b2tlbiI7czo0MDoiNmVuNHJ0MFlaUXlvM0Fwb3ByY2pnYlZ3UWh3S0RUWFRVSFNXTFBPQiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9wZXJzb25hbC9saXN0YXIiO3M6NToicm91dGUiO3M6MTU6InBlcnNvbmFsLmxpc3RhciI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6OToiaWRVc3VhcmlvIjtzOjM6IkZBSSI7czoxNzoiaWRQcm9ncmFtYUVzdHVkaW8iO3M6MToiMiI7czoxMToidGlwb1VzdWFyaW8iO3M6MTM6IkFETUlOSVNUUkFET1IiO3M6MTI6InRpdHVsb1Nlc2lvbiI7czoxMTI6IlsgU0lJTi0yMDI2LTEgXSAtIFsgREVTQVJST0xMTyBERSBTSVNURU1BUyBERSBJTkZPUk1BQ0nDk04gXSAtIFsgRkFJIF0gLSBbIExVQ0FTIE1BVEhJQVMgRkFJVEggT1JNRcORTyBIRVJSRVJBIF0iO30=', 1790901974);

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
(1, 2, 'CASE', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', 'AZUñIGA', '2026-09-16 00:56:18', NULL),
(2, 2, 'EQUIPO DE SONIDO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(3, 2, 'ESCRITORIO DE MADERA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(4, 2, 'ESTABILIZADOR', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(5, 2, 'EXTINTOR', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(6, 2, 'GABINETE DE METAL', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(7, 2, 'LUZ DE EMERGENCIA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(8, 2, 'MODULO COMP.', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(9, 2, 'MONITOR', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(10, 2, 'MOUSE', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(11, 2, 'PATCH PANEL', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(12, 2, 'PIZARRA ACRILICA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(13, 2, 'SILLA FIJA DE BASE METAL', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(14, 2, 'SILLA FIJA DE MADERA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(15, 2, 'SWITCH', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(16, 2, 'TECLADO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(17, 2, 'VENTILADOR ELECTRICO AEREO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(18, 5, 'MOLADORA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(19, 5, 'LLAVE FRANCESA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(20, 5, 'MOTOR', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(21, 5, 'GATA HIDRAULICA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(22, 5, 'MAQUINA DE SOLDAR', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(23, 5, 'TALADRO', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL),
(24, 5, 'PRENSA HIDRAULICA', 1, 'AZUÑIGA', '2026-09-10 10:42:17', 'SERVER', NULL, NULL, NULL);

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

--
-- Volcado de datos para la tabla `toma_inventarios`
--

INSERT INTO `toma_inventarios` (`id`, `anio`, `numero`, `sala_id`, `coordinador_id`, `asistente1_id`, `asistente2_id`, `fecha_entrega`, `observacion`, `estado`, `created_at`, `updated_at`) VALUES
(1, '2026', 1, 1, 1, 1, NULL, '2026-09-18', 'REGISTRO DE PRUEBA', 'ABIERTO', '2026-09-18 21:01:34', '2026-09-18 21:01:34'),
(2, '123', 1, 4, 3, 7, 2, '2026-09-02', 'asd', 'ABIERTO', '2026-09-19 02:17:35', '2026-09-19 02:17:35'),
(3, '2023', 1, 4, 7, 7, 7, '2026-09-09', 'ninguna observacion', 'ABIERTO', '2026-09-19 02:18:09', '2026-09-19 02:18:09'),
(4, '2000', 1, 1, 2, 1, 3, '2026-09-08', 'asdasd', 'ABIERTO', '2026-09-19 02:30:21', '2026-09-19 02:30:21'),
(5, '2001', 1, 9, 3, 6, 7, '2026-09-17', 'asdasd', 'ABIERTO', '2026-09-19 02:30:51', '2026-09-19 02:35:36');

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
  MODIFY `idBien` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=84;

--
-- AUTO_INCREMENT de la tabla `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `grupo`
--
ALTER TABLE `grupo`
  MODIFY `idGrupo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

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
  MODIFY `idMarca` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT de la tabla `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `modelo`
--
ALTER TABLE `modelo`
  MODIFY `idModelo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

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
  MODIFY `idSala` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `tipo`
--
ALTER TABLE `tipo`
  MODIFY `idTipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de la tabla `toma_inventarios`
--
ALTER TABLE `toma_inventarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
  ADD CONSTRAINT `inventario_detalle_ibfk_1` FOREIGN KEY (`idInventario`) REFERENCES `inventario` (`idInventario`),
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
