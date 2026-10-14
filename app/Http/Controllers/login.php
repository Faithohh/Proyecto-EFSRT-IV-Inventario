<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;

class login extends Controller
{
    public function index()
    {
        return view('login');
    }

    public function validarAcceso(Request $request)
    {
        try {
            $usuario = strtoupper(trim($request->input('usuario', '')));
            $contrasena = trim($request->input('contrasena', ''));

            if (empty($usuario) || empty($contrasena)) {
                return response()->json([
                    'valid' => 'Debe completar los campos de usuario y contraseña.'
                ]);
            }

            $datosUsuario = DB::selectOne("
                SELECT u.`idUsuario`, u.`tipoUsuario`, u.`activo`, u.`st_registro`, p.`st_registro` AS `personal_activo`
                FROM `USUARIO` u
                LEFT JOIN `personal` p ON u.`idPersonal` = p.`idPersonal`
                WHERE u.`idUsuario` = ? LIMIT 1
            ", [$usuario]);

            if ($datosUsuario) {
                $usuarioActivo = (int)($datosUsuario->activo ?? 1);
                $stRegistroUser = (int)($datosUsuario->st_registro ?? 1);
                $stRegistroPersonal = isset($datosUsuario->personal_activo) ? (int)$datosUsuario->personal_activo : 1;

                if ($usuarioActivo === 0 || $stRegistroUser === 0 || $stRegistroPersonal === 0) {
                    return response()->json([
                        'valid' => 'Su cuenta se encuentra desactivada. Contacte al administrador.'
                    ]);
                }
            }

            $pdo = DB::getPdo();

            $stmt = $pdo->prepare("CALL sp_login_acceso_Q01(:user, :pass, @p_valid)");
            $stmt->bindParam(':user', $usuario);
            $stmt->bindParam(':pass', $contrasena);
            $stmt->execute();
            $stmt->closeCursor();

            $res = DB::select("SELECT @p_valid AS valid");
            $valid = $res[0]->valid ?? null;

            if ($valid !== '1') {
                return response()->json([
                    'valid' => 'Usuario o contraseña incorrectos.'
                ]);
            }

            $tipoUsuario = strtoupper(trim($datosUsuario->tipoUsuario ?? ''));
            $programasRaw = [];

            if ($tipoUsuario === 'ADMINISTRADOR' || $tipoUsuario === 'ADMIN') {
                $programasRaw = DB::select("SELECT `idProgramaEstudio`, `nombre` AS `programaEstudio` FROM `programaestudio` WHERE `st_registro` = 1");
                $programasRaw = array_map(function ($item) {
                    return (array) $item;
                }, $programasRaw);
            } else {
                $stmtProg = $pdo->prepare("CALL sp_login_usuarioProgramaEstudio_Q01(:user)");
                $stmtProg->bindParam(':user', $usuario);
                $stmtProg->execute();
                $programasRaw = $stmtProg->fetchAll(\PDO::FETCH_ASSOC);
                $stmtProg->closeCursor();
            }

            $programas = array_map(function ($prog) {
                return [
                    'idProgramaEstudio' => $prog['idProgramaEstudio'] ?? null,
                    'programaEstudio'   => $prog['programaEstudio'] ?? ''
                ];
            }, $programasRaw);

            return response()->json([
                'valid' => '1',
                'programas' => $programas
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'valid' => 'Error de BD: ' . $e->getMessage()
            ]);
        }
    }

    public function crearSesion(Request $request)
    {
        try {
            $usuario = strtoupper(trim($request->input('idUsuario', '')));
            $idProgramaEstudio = (int) $request->input('idProgramaEstudio');

            if (!empty($usuario) && $idProgramaEstudio > 0) {
                $pdo = DB::getPdo();
                $stmt = $pdo->prepare("CALL sp_login_sesion_Q01(:user, :idProg, @p_tipoUsuario, @p_tituloSesion)");
                $stmt->bindParam(':user', $usuario);
                $stmt->bindParam(':idProg', $idProgramaEstudio);
                $stmt->execute();
                $stmt->closeCursor();

                $res = DB::select("SELECT @p_tipoUsuario AS tipoUsuario");

                $prog = DB::selectOne("SELECT `nombre` FROM `programaestudio` WHERE `idProgramaEstudio` = ? LIMIT 1", [$idProgramaEstudio]);
                $nombrePrograma = $prog->nombre ?? '';

                $persona = DB::selectOne("
                    SELECT p.`apellidos`, p.`nombres` 
                    FROM `USUARIO` u
                    LEFT JOIN `personal` p ON u.`idPersonal` = p.`idPersonal`
                    WHERE u.`idUsuario` = ? LIMIT 1
                ", [$usuario]);

                $nombreCompleto = trim(($persona->apellidos ?? '') . ' ' . ($persona->nombres ?? ''));
                if (empty($nombreCompleto)) {
                    $nombreCompleto = $usuario;
                }

                $tituloSesion = "[ SIIN-2026-1 ] - [ " . mb_strtoupper($nombrePrograma) . " ] - [ " . $usuario . " ] - [ " . mb_strtoupper($nombreCompleto) . " ]";

                Session::put('idUsuario', $usuario);
                Session::put('idProgramaEstudio', $idProgramaEstudio);
                Session::put('tipoUsuario', $res[0]->tipoUsuario ?? '');
                Session::put('tituloSesion', $tituloSesion);

                return response()->json([
                    'success' => true,
                    'redirectUrl' => route('principal')
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Parámetros de sesión no válidos.'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al crear sesión: ' . $e->getMessage()
            ]);
        }
    }
}