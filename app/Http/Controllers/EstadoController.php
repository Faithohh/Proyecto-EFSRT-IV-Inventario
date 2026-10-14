<?php

namespace App\Http\Controllers;

use App\Models\Estado;
use Illuminate\Http\Request;

class EstadoController extends Controller
{
    public function listar()
    {
        try {
            $data = Estado::listar();
            return response()->json(['ok' => true, 'data' => $data]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function buscar($idEstado)
    {
        try {
            $estado = Estado::buscar($idEstado);
            if (!$estado) {
                return response()->json(['ok' => false, 'msg' => 'Estado no encontrado'], 404);
            }
            return response()->json(['ok' => true, 'data' => $estado]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function guardar(Request $request)
    {
        try {
            $nombre     = $request->input('nombre');
            $idOriginal = $request->input('idOriginal');

            if (empty($nombre)) {
                return response()->json(['ok' => false, 'msg' => 'El nombre del estado es obligatorio'], 422);
            }

            if (empty($idOriginal)) {
                Estado::crear($nombre);
                $msg = 'Estado creado correctamente';
            } else {
                Estado::actualizar($idOriginal, $nombre);
                $msg = 'Estado actualizado correctamente';
            }

            return response()->json(['ok' => true, 'msg' => $msg]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al guardar: ' . $e->getMessage()], 500);
        }
    }

    public function eliminar(Request $request)
    {
        try {
            $idEstado = $request->input('idEstado');
            if (empty($idEstado)) {
                return response()->json(['ok' => false, 'msg' => 'ID de estado no proporcionado'], 400);
            }

            Estado::eliminar($idEstado);
            return response()->json(['ok' => true, 'msg' => 'Estado eliminado correctamente']);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al eliminar el estado: ' . $e->getMessage()], 500);
        }
    }
}