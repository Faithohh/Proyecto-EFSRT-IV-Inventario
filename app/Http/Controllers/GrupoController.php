<?php

namespace App\Http\Controllers;

use App\Models\Grupo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;

class GrupoController extends Controller
{
    public function listar()
    {
        try {
            $data = Grupo::listar();
            return response()->json(['ok' => true, 'data' => $data]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function buscar($idGrupo)
    {
        try {
            $grupo = Grupo::buscar($idGrupo);
            if (!$grupo) {
                return response()->json(['ok' => false, 'msg' => 'Grupo no encontrado'], 404);
            }
            return response()->json(['ok' => true, 'data' => $grupo]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function guardar(Request $request)
    {
        try {
            $nombre            = $request->input('nombre');
            $idProgramaEstudio = $request->input('idProgramaEstudio') ?: Session::get('idProgramaEstudio');
            $stRegistro        = $request->input('st_registro', 1);
            $idOriginal        = $request->input('idOriginal');
            $idUsuario         = Session::get('idUsuario', 'AZUÑIGA');

            if (empty($nombre)) {
                return response()->json(['ok' => false, 'msg' => 'El nombre del grupo es obligatorio'], 422);
            }

            if (empty($idOriginal)) {
                Grupo::crear($nombre, $idProgramaEstudio, $stRegistro, $idUsuario);
                $msg = 'Grupo creado correctamente';
            } else {
                Grupo::actualizar($idOriginal, $nombre, $idProgramaEstudio, $stRegistro, $idUsuario);
                $msg = 'Grupo actualizado correctamente';
            }

            return response()->json(['ok' => true, 'msg' => $msg]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al guardar: ' . $e->getMessage()], 500);
        }
    }

    public function eliminar(Request $request)
    {
        try {
            $idGrupo = $request->input('idGrupo');
            if (empty($idGrupo)) {
                return response()->json(['ok' => false, 'msg' => 'ID de grupo no proporcionado'], 400);
            }

            Grupo::eliminar($idGrupo);
            return response()->json(['ok' => true, 'msg' => 'Grupo eliminado correctamente']);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al eliminar el grupo: ' . $e->getMessage()], 500);
        }
    }
}