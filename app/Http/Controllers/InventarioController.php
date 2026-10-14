<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Exception;


class InventarioController extends Controller
{
    public function listar()
{
    try {
        $inventarios = DB::table('toma_inventarios as ti')
            ->leftJoin('sala as s', 'ti.sala_id', '=', 's.idSala')
            ->leftJoin('personal as c', 'ti.coordinador_id', '=', 'c.idPersonal')
            ->leftJoin('personal as a1', 'ti.asistente1_id', '=', 'a1.idPersonal')
            ->leftJoin('personal as a2', 'ti.asistente2_id', '=', 'a2.idPersonal')
            ->select(
                'ti.id as idInventario',
                DB::raw("CONCAT(ti.anio, '-', ti.numero) as INVENTARIO"),
                DB::raw("COALESCE(s.nombre, 'SIN SALA') as SALA"),
                
                // Nombres y Apellidos de la tabla personal
                DB::raw("TRIM(CONCAT(COALESCE(c.nombres, ''), ' ', COALESCE(c.apellidos, ''))) as COORDINADOR"),
                DB::raw("TRIM(CONCAT(COALESCE(a1.nombres, ''), ' ', COALESCE(a1.apellidos, ''))) as ASISTENTE_T1"),
                DB::raw("CASE WHEN ti.asistente2_id IS NOT NULL THEN TRIM(CONCAT(COALESCE(a2.nombres, ''), ' ', COALESCE(a2.apellidos, ''))) ELSE '-' END as ASISTENTE_T2"),
                
                'ti.fecha_entrega as FECHA_ENTREGA',
                DB::raw("COALESCE(ti.observacion, '-') as OBSERVACION"),
                
                // Conteo exacto de bienes por sala
                DB::raw("(SELECT COUNT(*) FROM bien WHERE bien.idSala = ti.sala_id) as CANTIDAD_DE_BIENES"),
                
                'ti.estado as ESTADO'
            )
            ->orderBy('ti.id', 'DESC')
            ->get();

        return response()->json(['data' => $inventarios]);

    } catch (\Exception $e) {
        return response()->json(['error' => $e->getMessage(), 'data' => []], 500);
    }
}

    public function actualizar(Request $request, $id)
{
    try {
        $request->validate([
            'anio'           => 'required|numeric|digits:4',
            'numero'         => 'required|numeric',
            'sala_id'        => 'required|numeric',
            'coordinador_id' => 'required|numeric',
            'asistente1_id'  => 'required|numeric',
            'fecha_entrega'  => 'required|date',
            'estado'         => 'required|string',
        ]);

        DB::table('toma_inventarios')
            ->where('id', $id)
            ->update([
                'anio'           => $request->anio,
                'numero'         => $request->numero,
                'sala_id'        => $request->sala_id,
                'coordinador_id' => $request->coordinador_id,
                'asistente1_id'  => $request->asistente1_id,
                'asistente2_id'  => $request->asistente2_id ?? null,
                'fecha_entrega'  => $request->fecha_entrega,
                'observacion'    => $request->observacion,
                'estado'         => $request->estado,
                'updated_at'     => now(),
            ]);

        return response()->json(['status' => true, 'message' => 'Inventario actualizado correctamente']);

    } catch (\Exception $e) {
        return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
    }
}

    public function mostrar($id)
{
    try {
        $inventario = DB::table('toma_inventarios as ti')
            ->leftJoin('sala as s', 'ti.sala_id', '=', 's.idSala')
            ->leftJoin('personal as c', 'ti.coordinador_id', '=', 'c.idPersonal')
            ->leftJoin('personal as a1', 'ti.asistente1_id', '=', 'a1.idPersonal')
            ->leftJoin('personal as a2', 'ti.asistente2_id', '=', 'a2.idPersonal')
            ->select(
                'ti.*',
                's.nombre as nombre_sala',
                DB::raw("TRIM(CONCAT(COALESCE(c.nombres, ''), ' ', COALESCE(c.apellidos, ''))) as nombre_coordinador"),
                DB::raw("TRIM(CONCAT(COALESCE(a1.nombres, ''), ' ', COALESCE(a1.apellidos, ''))) as nombre_asistente1"),
                DB::raw("TRIM(CONCAT(COALESCE(a2.nombres, ''), ' ', COALESCE(a2.apellidos, ''))) as nombre_asistente2"),
                DB::raw("(SELECT COUNT(*) FROM bien WHERE bien.idSala = ti.sala_id) as total_bienes")
            )
            ->where('ti.id', $id)
            ->first();

        if (!$inventario) {
            return response()->json(['status' => false, 'message' => 'Registro no encontrado'], 404);
        }

        return response()->json(['status' => true, 'data' => $inventario]);

    } catch (\Exception $e) {
        return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
    }
}

    public function guardar(Request $request)
{
    try {
        $request->validate([
            'sala_id' => 'required',
            'coordinador_id' => 'required',
            'asistente1_id' => 'required',
            'estado' => 'required'
        ]);

        // Calcula el último número correlativo para el año en curso
        $anio = $request->anio ?? date('Y');
        $ultimoNumero = DB::table('toma_inventarios')
            ->where('anio', $anio)
            ->max('numero');
        
        $nuevoNumero = $ultimoNumero ? ($ultimoNumero + 1) : 1;

        DB::table('toma_inventarios')->insert([
            'anio' => $anio,
            'numero' => $nuevoNumero,
            'sala_id' => $request->sala_id,
            'coordinador_id' => $request->coordinador_id,
            'asistente1_id' => $request->asistente1_id,
            'asistente2_id' => $request->asistente2_id,
            'fecha_entrega' => $request->fecha_entrega,
            'observacion' => $request->observacion,
            'estado' => $request->estado,
            'created_at' => now(),
            'updated_at' => now()
        ]);

        return response()->json(['success' => true, 'message' => 'Inventario registrado correctamente']);
    } catch (Exception $e) {
        return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
    }
}
}