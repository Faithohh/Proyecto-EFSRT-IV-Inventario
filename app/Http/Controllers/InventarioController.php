<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Exception;

class InventarioController extends Controller
{
    private function baseQuery()
    {
        return DB::table('toma_inventarios as ti')
            ->leftJoin('sala as s', 'ti.sala_id', '=', 's.idSala')
            ->leftJoin('personal as c', 'ti.coordinador_id', '=', 'c.idPersonal')
            ->leftJoin('personal as a1', 'ti.asistente1_id', '=', 'a1.idPersonal')
            ->leftJoin('personal as a2', 'ti.asistente2_id', '=', 'a2.idPersonal')
            ->leftJoin('bien as b', 'ti.sala_id', '=', 'b.idSala');
    }

    public function listar()
    {
        try {
            $inventarios = $this->baseQuery()
                ->select(
                    'ti.id as idInventario',
                    DB::raw("CONCAT(ti.anio, '-', ti.numero) as INVENTARIO"),
                    DB::raw("COALESCE(s.nombre, 'SIN SALA') as SALA"),
                    DB::raw("TRIM(CONCAT(COALESCE(c.nombres, ''), ' ', COALESCE(c.apellidos, ''))) as COORDINADOR"),
                    DB::raw("TRIM(CONCAT(COALESCE(a1.nombres, ''), ' ', COALESCE(a1.apellidos, ''))) as ASISTENTE_T1"),
                    DB::raw("CASE WHEN ti.asistente2_id IS NOT NULL THEN TRIM(CONCAT(COALESCE(a2.nombres, ''), ' ', COALESCE(a2.apellidos, ''))) ELSE '-' END as ASISTENTE_T2"),
                    'ti.fecha_entrega as FECHA_ENTREGA',
                    DB::raw("COALESCE(ti.observacion, '-') as OBSERVACION"),
                    DB::raw("COUNT(b.idBien) as CANTIDAD_DE_BIENES"),
                    'ti.estado as ESTADO'
                )
                ->groupBy(
                    'ti.id', 'ti.anio', 'ti.numero', 's.nombre', 
                    'c.nombres', 'c.apellidos', 'a1.nombres', 'a1.apellidos', 
                    'a2.nombres', 'a2.apellidos', 'ti.asistente2_id', 
                    'ti.fecha_entrega', 'ti.observacion', 'ti.estado'
                )
                ->orderBy('ti.id', 'DESC')
                ->get();

            return response()->json(['ok' => true, 'data' => $inventarios]);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage(), 'data' => []], 500);
        }
    }

    public function mostrar($id)
    {
        try {
            $inventario = $this->baseQuery()
                ->select(
                    'ti.*',
                    's.nombre as nombre_sala',
                    DB::raw("TRIM(CONCAT(COALESCE(c.nombres, ''), ' ', COALESCE(c.apellidos, ''))) as nombre_coordinador"),
                    DB::raw("TRIM(CONCAT(COALESCE(a1.nombres, ''), ' ', COALESCE(a1.apellidos, ''))) as nombre_asistente1"),
                    DB::raw("TRIM(CONCAT(COALESCE(a2.nombres, ''), ' ', COALESCE(a2.apellidos, ''))) as nombre_asistente2"),
                    DB::raw("COUNT(b.idBien) as total_bienes")
                )
                ->where('ti.id', $id)
                ->groupBy(
                    'ti.id', 's.nombre', 'c.nombres', 'c.apellidos', 
                    'a1.nombres', 'a1.apellidos', 'a2.nombres', 'a2.apellidos'
                )
                ->first();

            if (!$inventario) {
                return response()->json(['ok' => false, 'msg' => 'Registro no encontrado'], 404);
            }

            return response()->json(['ok' => true, 'data' => $inventario]);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function guardar(Request $request)
    {
        try {
            $request->validate([
                'sala_id'        => 'required|numeric',
                'coordinador_id' => 'required|numeric',
                'asistente1_id'  => 'required|numeric',
                'estado'         => 'required|string'
            ]);

            DB::transaction(function () use ($request) {
                $anio = $request->anio ?? date('Y');
                $ultimoNumero = DB::table('toma_inventarios')
                    ->where('anio', $anio)
                    ->lockForUpdate()
                    ->max('numero');

                $nuevoNumero = $ultimoNumero ? ($ultimoNumero + 1) : 1;

                DB::table('toma_inventarios')->insert([
                    'anio'           => $anio,
                    'numero'         => $nuevoNumero,
                    'sala_id'        => $request->sala_id,
                    'coordinador_id' => $request->coordinador_id,
                    'asistente1_id'  => $request->asistente1_id,
                    'asistente2_id'  => $request->asistente2_id ?? null,
                    'fecha_entrega'  => $request->fecha_entrega ?? null,
                    'observacion'    => $request->observacion ?? null,
                    'estado'         => $request->estado,
                    'created_at'     => now(),
                    'updated_at'     => now()
                ]);
            });

            return response()->json(['ok' => true, 'msg' => 'Inventario registrado correctamente']);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function actualizar(Request $request, $id)
    {
        try {
            $request->validate([
                'sala_id'        => 'required|numeric',
                'coordinador_id' => 'required|numeric',
                'asistente1_id'  => 'required|numeric',
                'estado'         => 'required|string',
            ]);

            DB::table('toma_inventarios')
                ->where('id', $id)
                ->update([
                    'sala_id'        => $request->sala_id,
                    'coordinador_id' => $request->coordinador_id,
                    'asistente1_id'  => $request->asistente1_id,
                    'asistente2_id'  => $request->asistente2_id ?? null,
                    'fecha_entrega'  => $request->fecha_entrega ?? null,
                    'observacion'    => $request->observacion ?? null,
                    'estado'         => $request->estado,
                    'updated_at'     => now(),
                ]);

            return response()->json(['ok' => true, 'msg' => 'Inventario actualizado correctamente']);
        } catch (Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }
}