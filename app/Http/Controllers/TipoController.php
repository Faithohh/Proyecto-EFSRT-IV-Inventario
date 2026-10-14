<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\DB;
use App\Models\Tipo;
use Exception;

class TipoController extends Controller
{
    public function listar()
    {
        try {
            $data = Tipo::listar();
            return response()->json(['ok' => true, 'data' => $data]);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function buscar($nombre)
    {
        try {
            $data = Tipo::buscar($nombre);
            if (!$data) {
                return response()->json(['ok' => false, 'msg' => 'Tipo no encontrado']);
            }
            return response()->json(['ok' => true, 'data' => $data]);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function guardar(Request $request)
    {
        try {
            $idOriginal = $request->input('idOriginal');
            $nombre     = $request->input('nombre');
            $idUsuario  = Session::get('idUsuario', 'SISTEMA');

            if (empty($idOriginal)) {
                Tipo::crear($nombre, $idUsuario);
                $msg = 'Tipo registrado correctamente';
            } else {
                Tipo::actualizar($idOriginal, $nombre, $idUsuario);
                $msg = 'Tipo actualizado correctamente';
            }

            return response()->json(['ok' => true, 'msg' => $msg]);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()]);
        }
    }

    public function eliminar(Request $request)
    {
        try {
            $nombre = $request->input('nombre');
            DB::table('tipo')->where('NOMBRE', $nombre)->delete();
            return response()->json(['ok' => true, 'msg' => 'Tipo eliminado correctamente']);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al eliminar el tipo: ' . $e->getMessage()]);
        }
    }
}