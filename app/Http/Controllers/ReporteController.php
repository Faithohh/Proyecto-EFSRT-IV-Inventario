<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Reporte;
use Exception;

class ReporteController extends Controller
{
    public function index()
    {
        return view('modulos.reportes');
    }

    public function listarInventarios()
    {
        try {

            $inventarios = Reporte::listarInventarios();

            return response()->json([
                'ok' => true,
                'data' => $inventarios
            ]);

        } catch (Exception $e) {

            return response()->json([
                'ok' => false,
                'msg' => $e->getMessage(),
                'data' => []
            ], 500);
        }
    }

    public function generarInforme($idInventario)
    {
        try {

            $informe = Reporte::generarInforme($idInventario);

            if (!$informe) {

                return response()->json([
                    'ok' => false,
                    'msg' => 'Inventario no encontrado',
                    'data' => []
                ], 404);
            }

            return response()->json([
                'ok' => true,
                'data' => $informe
            ]);

        } catch (Exception $e) {

            return response()->json([
                'ok' => false,
                'msg' => $e->getMessage(),
                'data' => []
            ], 500);
        }
    }
}