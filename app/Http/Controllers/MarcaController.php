<?php

namespace App\Http\Controllers;

use App\Models\Marca;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;

class MarcaController extends Controller
{
    public function listar()
    {
        try {
            $data = Marca::listar();
            return response()->json(['ok' => true, 'data' => $data]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function buscar($idMarca)
    {
        try {
            $marca = Marca::buscar($idMarca);
            if (!$marca) {
                return response()->json(['ok' => false, 'msg' => 'Marca no encontrada'], 404);
            }
            return response()->json(['ok' => true, 'data' => $marca]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function guardar(Request $request)
    {
        try {
            $nombre            = trim($request->input('nombre'));
            $idProgramaEstudio = $request->input('idProgramaEstudio') ?: Session::get('idProgramaEstudio');
            $stRegistro        = $request->input('st_registro', 1);
            $idOriginal        = $request->input('idOriginal');
            $idUsuario         = Session::get('idUsuario', 'SISTEMA');

            if (empty($nombre)) {
                return response()->json(['ok' => false, 'msg' => 'El nombre de la marca es obligatorio'], 422);
            }

            if (empty($idOriginal)) {
                Marca::crear($nombre, $idProgramaEstudio, $stRegistro, $idUsuario);
                $msg = 'Marca creada correctamente';
            } else {
                Marca::actualizar($idOriginal, $nombre, $idProgramaEstudio, $stRegistro, $idUsuario);
                $msg = 'Marca actualizada correctamente';
            }

            return response()->json(['ok' => true, 'msg' => $msg]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al guardar: ' . $e->getMessage()], 500);
        }
    }

    public function eliminar(Request $request)
    {
        try {
            $idMarca = $request->input('idMarca');

            if (empty($idMarca)) {
                return response()->json(['ok' => false, 'msg' => 'ID de marca no proporcionado'], 400);
            }

            $idUsuario = Session::get('idUsuario', 'SISTEMA');

            Marca::eliminar($idMarca, $idUsuario);

            return response()->json(['ok' => true, 'msg' => 'Marca desactivada correctamente']);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al desactivar la marca: ' . $e->getMessage()], 500);
        }
    }

    public function activar(Request $request)
    {
        try {
            $idMarca = $request->input('idMarca');

            if (empty($idMarca)) {
                return response()->json(['ok' => false, 'msg' => 'ID de marca no proporcionado'], 400);
            }

            $idUsuario = Session::get('idUsuario', 'SISTEMA');

            Marca::activar($idMarca, $idUsuario);

            return response()->json(['ok' => true, 'msg' => 'Marca activada correctamente']);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al activar la marca: ' . $e->getMessage()], 500);
        }
    }
}
