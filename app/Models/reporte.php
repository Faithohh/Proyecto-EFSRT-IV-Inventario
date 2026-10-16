<?php

namespace App\Models;

use Illuminate\Support\Facades\DB;

class Reporte
{
    public static function listarInventarios($idProgramaEstudio)
    {
        return DB::table('toma_inventarios as ti')
            ->leftJoin('sala as s', 'ti.sala_id', '=', 's.idSala')
            ->leftJoin('personal as c', 'ti.coordinador_id', '=', 'c.idPersonal')
            ->leftJoin('personal as a1', 'ti.asistente1_id', '=', 'a1.idPersonal')
            ->leftJoin('personal as a2', 'ti.asistente2_id', '=', 'a2.idPersonal')
            ->select(
                'ti.id as idInventario',
                DB::raw("CONCAT(ti.anio, '-', ti.numero) as INVENTARIO"),
                DB::raw("COALESCE(s.nombre, 'SIN SALA') as SALA"),
                DB::raw("TRIM(CONCAT(
                    COALESCE(c.nombres, ''), ' ',
                    COALESCE(c.apellidos, '')
                )) as COORDINADOR"),
                DB::raw("TRIM(CONCAT(
                    COALESCE(a1.nombres, ''), ' ',
                    COALESCE(a1.apellidos, '')
                )) as ASISTENTE_T1"),
                DB::raw("CASE
                    WHEN ti.asistente2_id IS NOT NULL
                    THEN TRIM(CONCAT(
                        COALESCE(a2.nombres, ''), ' ',
                        COALESCE(a2.apellidos, '')
                    ))
                    ELSE '-'
                END as ASISTENTE_T2"),
                'ti.fecha_entrega as FECHA_ENTREGA',
                DB::raw("COALESCE(ti.observacion, '-') as OBSERVACION"),
                DB::raw("(
                    SELECT COUNT(*)
                    FROM bien AS b
                    WHERE b.idSala = ti.sala_id
                    AND b.st_registro = 1
                ) as CANTIDAD_DE_BIENES"),
                'ti.estado as ESTADO'
            )
            ->where('s.idProgramaEstudio', $idProgramaEstudio)
            ->where('ti.estado', 'CERRADO')
            ->orderByDesc('ti.id')
            ->get()
            ->toArray();
    }

    public static function generarInforme($idInventario, $idProgramaEstudio)
    {
        $inventario = DB::table('toma_inventarios as ti')
            ->leftJoin('sala as s', 'ti.sala_id', '=', 's.idSala')
            ->leftJoin('personal as c', 'ti.coordinador_id', '=', 'c.idPersonal')
            ->leftJoin('personal as a1', 'ti.asistente1_id', '=', 'a1.idPersonal')
            ->leftJoin('personal as a2', 'ti.asistente2_id', '=', 'a2.idPersonal')
            ->select(
                'ti.id as idInventario',
                'ti.sala_id',
                DB::raw("CONCAT(ti.anio, '-', ti.numero) as INVENTARIO"),
                's.nombre as SALA',
                DB::raw("TRIM(CONCAT(
                    COALESCE(c.nombres, ''), ' ',
                    COALESCE(c.apellidos, '')
                )) as COORDINADOR"),
                DB::raw("TRIM(CONCAT(
                    COALESCE(a1.nombres, ''), ' ',
                    COALESCE(a1.apellidos, '')
                )) as ASISTENTE_T1"),
                DB::raw("CASE
                    WHEN ti.asistente2_id IS NOT NULL
                    THEN TRIM(CONCAT(
                        COALESCE(a2.nombres, ''), ' ',
                        COALESCE(a2.apellidos, '')
                    ))
                    ELSE '-'
                END as ASISTENTE_T2"),
                'ti.fecha_entrega as FECHA_ENTREGA',
                'ti.observacion as OBSERVACION',
                'ti.estado as ESTADO'
            )
            ->where('ti.id', $idInventario)
            ->where('s.idProgramaEstudio', $idProgramaEstudio)
            ->where('ti.estado', 'CERRADO')
            ->first();

        if (!$inventario) {
            return null;
        }

        $bienes = DB::table('bien as b')
            ->join('inventario_detalle as d', function ($join) use ($idInventario) {
                $join->on('d.idBien', '=', 'b.idBien')
                    ->where('d.idInventario', '=', $idInventario);
            })
            ->leftJoin('grupo as g', 'b.idGrupo', '=', 'g.idGrupo')
            ->leftJoin('marca as m', 'b.idMarca', '=', 'm.idMarca')
            ->leftJoin('modelo as mo', 'b.idModelo', '=', 'mo.idModelo')
            ->leftJoin('estado as e', 'b.idEstado', '=', 'e.idEstado')
            ->select(
                'b.idBien',
                DB::raw("COALESCE(g.nombre, 'SIN GRUPO') as GRUPO"),
                DB::raw("COALESCE(NULLIF(TRIM(d.nroDRELM), ''), '-') as INV_DRELM"),
                'b.cbi as CBI',
                'b.descripcion as DESCRIPCION',
                'm.nombre as MARCA',
                'mo.nombre as MODELO',
                'b.serieMedida as SERIE_MEDIDA',
                'e.nombre as ESTADO',
                'b.otrasEspecificaciones as OTRAS_ESPECIFICACIONES'
            )
            ->where('b.st_registro', 1)
            ->orderBy('g.nombre')
            ->orderBy('b.descripcion')
            ->orderBy('b.cbi')
            ->get()
            ->toArray();

        return [
            'inventario' => $inventario,
            'bienes' => $bienes
        ];
    }
}
