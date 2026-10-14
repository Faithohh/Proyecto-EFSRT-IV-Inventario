<?php

namespace App\Http\Controllers;

use App\Models\Modelo;
use Illuminate\Http\Request;

class ModeloController extends Controller
{
    public function listar()
    {
        try {
            $data = Modelo::listar();
            return response()->json(['ok' => true, 'data' => $data]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function buscar($idModelo)
    {
        try {
            $modelo = Modelo::buscar($idModelo);
            if (!$modelo) {
                return response()->json(['ok' => false, 'msg' => 'Modelo no encontrado'], 404);
            }
            return response()->json(['ok' => true, 'data' => $modelo]);
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
                return response()->json(['ok' => false, 'msg' => 'El nombre del modelo es obligatorio'], 422);
            }

            if (empty($idOriginal)) {
                Modelo::crear($nombre);
                $msg = 'Modelo registrado correctamente';
            } else {
                Modelo::actualizar($idOriginal, $nombre);
                $msg = 'Modelo actualizado correctamente';
            }

            return response()->json(['ok' => true, 'msg' => $msg]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al guardar: ' . $e->getMessage()], 500);
        }
    }

    public function eliminar(Request $request)
    {
        try {
            $idModelo = $request->input('idModelo');
            if (empty($idModelo)) {
                return response()->json(['ok' => false, 'msg' => 'ID de modelo no proporcionado'], 400);
            }

            Modelo::eliminar($idModelo);
            return response()->json(['ok' => true, 'msg' => 'Modelo eliminado correctamente']);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al eliminar el modelo: ' . $e->getMessage()], 500);
        }
    }
}