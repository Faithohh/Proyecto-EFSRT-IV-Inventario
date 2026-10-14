<?php

namespace App\Http\Controllers;

use App\Models\UsuarioSistema;
use App\Models\Personal;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UsuarioController extends Controller
{
    public function listar()
    {
        try {
            $data = UsuarioSistema::listar();
            return response()->json(['ok' => true, 'data' => $data]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function listarPersonal()
    {
        try {
            $personal = Personal::listar(); 
            return response()->json(['ok' => true, 'data' => $personal]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function buscar($idUsuario)
    {
        try {
            $usuario = UsuarioSistema::buscar($idUsuario);
            if (!$usuario) {
                return response()->json(['ok' => false, 'msg' => 'Usuario no encontrado'], 404);
            }
            return response()->json(['ok' => true, 'data' => $usuario]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function guardar(Request $request)
    {
        try {
            $idUsuario   = $request->input('idUsuario');
            $contrasena  = $request->input('contrasena');
            $tipoUsuario = $request->input('tipoUsuario');
            $idPersonal  = $request->input('idPersonal');
            $idOriginal  = $request->input('idOriginal');

            if (empty($idOriginal)) {
                UsuarioSistema::crear($idUsuario, $contrasena, $tipoUsuario, $idPersonal);
                $msg = 'Usuario creado correctamente';
            } else {
                UsuarioSistema::actualizar($idOriginal, $idUsuario, $contrasena, $tipoUsuario, $idPersonal);
                $msg = 'Usuario actualizado correctamente';
            }

            return response()->json(['ok' => true, 'msg' => $msg]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al guardar: ' . $e->getMessage()], 500);
        }
    }

    public function eliminar(Request $request)
    {
        try {
            $idUsuario = $request->input('idUsuario');

            if (empty($idUsuario)) {
                return response()->json(['ok' => false, 'msg' => 'ID de usuario no proporcionado'], 400);
            }

            DB::beginTransaction();

            DB::table('usuario_programaestudio')->where('idUsuario', $idUsuario)->delete();
            UsuarioSistema::eliminar($idUsuario);

            DB::commit();

            return response()->json([
                'ok' => true, 
                'msg' => 'Usuario eliminado correctamente'
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'ok' => false, 
                'msg' => 'Error al eliminar el usuario: ' . $e->getMessage()
            ], 500);
        }
    }
}