<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\DB;
use App\Models\Sala;
use Exception;

class SalaController extends Controller
{
    public function listar()
    {
        try {
            $data = Sala::listar();
            return response()->json(['ok' => true, 'data' => $data]);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function buscar($idSala)
    {
        try {
            $data = Sala::buscar($idSala);
            if (!$data) {
                return response()->json(['ok' => false, 'msg' => 'Sala no encontrada']);
            }
            return response()->json(['ok' => true, 'data' => $data]);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function guardar(Request $request)
    {
        try {
            $idOriginal        = $request->input('idOriginal');
            $nombre            = $request->input('nombre');
            $observacion       = $request->input('observacion');
            $idProgramaEstudio = $request->input('idProgramaEstudio') ?: Session::get('idProgramaEstudio');
            $stRegistro        = $request->input('st_registro');
            $idUsuario         = Session::get('idUsuario', 'SISTEMA');

            if (empty($idOriginal)) {
                Sala::crear($nombre, $observacion, $idProgramaEstudio, $stRegistro, $idUsuario);
                $msg = 'Sala registrada correctamente';
            } else {
                Sala::actualizar($idOriginal, $nombre, $observacion, $idProgramaEstudio, $stRegistro, $idUsuario);
                $msg = 'Sala actualizada correctamente';
            }

            return response()->json(['ok' => true, 'msg' => $msg]);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()]);
        }
    }

    public function eliminar(Request $request)
    {
        try {
            $idSala = $request->input('idSala');
            DB::table('sala')->where('idSala', $idSala)->delete();
            return response()->json(['ok' => true, 'msg' => 'Sala eliminada correctamente']);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al eliminar la sala: ' . $e->getMessage()]);
        }
    }
}