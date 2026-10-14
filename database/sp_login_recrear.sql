-- ============================================================
-- Recrear SPs de login para BD siinv13
-- Importar desde phpMyAdmin > siinv13 > Importar
-- ============================================================

DROP PROCEDURE IF EXISTS `sp_login_acceso_Q01`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_acceso_Q01`(
    IN `p_idUsuario` VARCHAR(15),
    IN `p_contrasena` VARCHAR(60),
    OUT `p_valid` VARCHAR(500)
)
BEGIN
    DECLARE v_count INT;

    SELECT COUNT(`idUsuario`) INTO v_count
    FROM `USUARIO`
    WHERE `idUsuario` = p_idUsuario
      AND `contraseña` = p_contrasena
      AND `activo` = 1
      AND `st_registro` = 1;

    IF v_count > 0 THEN
        SET p_valid = '1';
    ELSE
        SET p_valid = CONCAT('Datos Invalidos','',CHAR(13),'','--------------------','',CHAR(13),'Usuario y/o contrasena incorrecta(s).');
    END IF;
END;

DROP PROCEDURE IF EXISTS `sp_login_usuarioProgramaEstudio_Q01`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_usuarioProgramaEstudio_Q01`(
    IN `p_idUsuario` VARCHAR(15)
)
BEGIN
    DECLARE v_idPersonal INT;
    DECLARE v_tipoUsuario VARCHAR(20);

    SELECT `idPersonal`, `tipoUsuario` INTO v_idPersonal, v_tipoUsuario
    FROM `USUARIO`
    WHERE `idUsuario` = p_idUsuario;

    IF (v_tipoUsuario = 'COORDINADOR') THEN
        SELECT PE.`idProgramaEstudio`, PE.`nombre` AS `programaEstudio`
        FROM `PROGRAMAESTUDIO` PE
        WHERE PE.`idCoordinadorArea` = v_idPersonal;
    ELSEIF (v_tipoUsuario = 'ASISTENTE') THEN
        SELECT PE.`idProgramaEstudio`, PE.`nombre` AS `programaEstudio`
        FROM `PROGRAMAESTUDIO` PE
        WHERE PE.`idAsistenteAreaT1` = v_idPersonal
           OR PE.`idAsistenteAreaT2` = v_idPersonal;
    ELSE
        SELECT UPE.`idProgramaEstudio`, PE.`nombre` AS `programaEstudio`
        FROM `USUARIO_PROGRAMAESTUDIO` UPE
        INNER JOIN `PROGRAMAESTUDIO` PE ON PE.`idProgramaEstudio` = UPE.`idProgramaEstudio`
        WHERE UPE.`idUsuario` = p_idUsuario
          AND UPE.`acceso` = 1;
    END IF;
END;

DROP PROCEDURE IF EXISTS `sp_login_sesion_Q01`;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_sesion_Q01`(
    IN `p_idUsuario` VARCHAR(15),
    IN `p_idProgramaEstudio` INT,
    OUT `p_tipoUsuario` VARCHAR(20),
    OUT `p_tituloSesion` VARCHAR(250)
)
BEGIN
    DECLARE v_personal VARCHAR(60);
    DECLARE v_programaEstudio VARCHAR(60);
    DECLARE v_institucion VARCHAR(100);

    SELECT CONCAT(P.`apellidos`, ' ', P.`nombres`), U.`tipoUsuario`
    INTO v_personal, p_tipoUsuario
    FROM `USUARIO` U
    INNER JOIN `PERSONAL` P ON U.`idPersonal` = P.`idPersonal`
    WHERE U.`idUsuario` = p_idUsuario;

    SELECT P.`nombre`, I.`nombre`
    INTO v_programaEstudio, v_institucion
    FROM `PROGRAMAESTUDIO` P
    INNER JOIN `INSTITUCION` I ON I.`idInstitucion` = P.`idInstitucion`
    WHERE P.`idProgramaEstudio` = p_idProgramaEstudio;

    SET p_tituloSesion = CONCAT('[ SIIN-2025-1 ] - [ ', v_programaEstudio, ' ] - [ ', p_idUsuario, ' ] - [ ', v_personal, ' ]');
END;
