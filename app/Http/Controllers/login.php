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

            $pdo = DB::getPdo();

            $stmt = $pdo->prepare("CALL sp_login_acceso_Q01(:user, :pass, @p_valid)");
            $stmt->bindParam(':user', $usuario);
            $stmt->bindParam(':pass', $contrasena);
            $stmt->execute();
            $stmt->closeCursor();

            $res = DB::select("SELECT @p_valid AS valid");
            $valid = $res[0]->valid ?? null;

            $dbgUser = DB::selectOne("SELECT COUNT(*) AS c FROM `USUARIO` WHERE `idUsuario` = ?", [$usuario]);
            $dbgRow = DB::selectOne("SELECT `idUsuario`, `activo`, `st_registro` FROM `USUARIO` WHERE `idUsuario` = ? LIMIT 1", [$usuario]);
            if ($valid !== '1') {
                return response()->json([
                    'valid' => $valid ?? 'Error de credenciales',
                    'debug' => [
                        'recibido' => $usuario,
                        'existe' => (int) ($dbgUser->c ?? 0),
                        'activo' => $dbgRow->activo ?? null,
                        'st_registro' => $dbgRow->st_registro ?? null,
                    ],
                ]);
            }

            if ($valid === '1') {
                $stmtProg = $pdo->prepare("CALL sp_login_usuarioProgramaEstudio_Q01(:user)");
                $stmtProg->bindParam(':user', $usuario);
                $stmtProg->execute();
                $programasRaw = $stmtProg->fetchAll(\PDO::FETCH_ASSOC);
                $stmtProg->closeCursor();

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
            }

            return response()->json([
                'valid' => $valid ?? 'Error de credenciales'
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

                $res = DB::select("SELECT @p_tipoUsuario AS tipoUsuario, @p_tituloSesion AS tituloSesion");

                Session::put('idUsuario', $usuario);
                Session::put('idProgramaEstudio', $idProgramaEstudio);
                Session::put('tipoUsuario', $res[0]->tipoUsuario ?? '');
                Session::put('tituloSesion', $res[0]->tituloSesion ?? '');

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