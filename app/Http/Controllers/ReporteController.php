<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Reporte;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\ReporteExport;
use Barryvdh\DomPDF\Facade\Pdf;
use Exception;
use Illuminate\Support\Facades\Log;

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

    public function exportarExcel($idInventario)
    {
        try {

            $idProgramaEstudio = Session::get('idProgramaEstudio');

            $informe = Reporte::generarInforme($idInventario, $idProgramaEstudio);

            if (!$informe) {
                abort(404, 'No se encontró el informe del inventario.');
            }

            $nombreArchivo = 'Informe_Inventario_' . $informe['inventario']->INVENTARIO . '.xlsx';

            return Excel::download(new ReporteExport($informe), $nombreArchivo);
        } catch (Exception $e) {
            abort(500, 'No se pudo generar el archivo Excel.');
        }
    }

    public function exportarPDF($idInventario)
    {
        try {

            $idProgramaEstudio = Session::get('idProgramaEstudio');

            $informe = Reporte::generarInforme($idInventario, $idProgramaEstudio);

            if (!$informe) {
                abort(404, 'No se encontró el informe del inventario.');
            }

            $nombreArchivo = 'Informe_Inventario_' . $informe['inventario']->INVENTARIO . '.pdf';

            $pdf = Pdf::loadView('pdf', [
                'informe' => $informe
            ])->setPaper('a4', 'landscape');
            return $pdf->download($nombreArchivo);
        } catch (Exception $e) {
            abort(500, 'No se pudo generar el archivo PDF.');
        }
    }
}
