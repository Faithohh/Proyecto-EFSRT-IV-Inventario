<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Reporte;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\DB;
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
        $idProgramaEstudio = Session::get('idProgramaEstudio');

        $inventarios = DB::table('toma_inventarios as ti')
            ->join('sala as s', 'ti.sala_id', '=', 's.idSala')
            ->select(
                'ti.id as idInventario',
                DB::raw("CONCAT(ti.anio, '-', ti.numero) as INVENTARIO"),
                DB::raw("COALESCE(s.nombre, 'SIN SALA') as SALA")
            )
            ->whereRaw("UPPER(TRIM(ti.estado)) = ?", ['CERRADO'])
            ->where('s.idProgramaEstudio', $idProgramaEstudio)
            ->orderByDesc('ti.id')
            ->get();

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

            $idProgramaEstudio = Session::get('idProgramaEstudio');

            $inventario = DB::table('toma_inventarios')
                ->where('id', $idInventario)
                ->where('estado', 'CERRADO')
                ->first();

            if (!$inventario) {

                return response()->json([
                    'ok' => false,
                    'msg' => 'El inventario no existe o todavía no está cerrado.',
                    'data' => []
                ], 404);
            }

            $informe = Reporte::generarInforme($idInventario, $idProgramaEstudio);

            if (!$informe) {

                return response()->json([
                    'ok' => false,
                    'msg' => 'No se pudo encontrar la información del inventario.',
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