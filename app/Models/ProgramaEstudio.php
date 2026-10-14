<?php

namespace App\Models;

use Illuminate\Support\Facades\DB;

class ProgramaEstudio
{
    public static function listar()
    {
        return DB::table('programaestudio')
            ->where('st_registro', 1)
            ->orderBy('idProgramaEstudio', 'desc')
            ->get()
            ->map(function ($p) {
                return [
                    'idProgramaEstudio'   => $p->idProgramaEstudio ?? null,
                    'nombre'              => $p->nombre ?? '',
                    'idCoordinadorArea'   => $p->idCoordinadorArea ?? null,
                    'idAsistenteAreaT1'   => $p->idAsistenteAreaT1 ?? null,
                    'idAsistenteAreaT2'   => $p->idAsistenteAreaT2 ?? null,
                    'observacion'         => $p->observacion ?? '',
                    'st_programaEstudio'  => $p->st_programaEstudio ?? 'ACTIVO',
                    'st_registro'         => $p->st_registro ?? 1,
                ];
            })->toArray();
    }

    public static function obtenerUsuarios()
    {
        // Trae la lista general de usuarios/personal para poblar combos al crear/editar
        return DB::table('usuario as u')
            ->join('personal as p', 'u.idPersonal', '=', 'p.idPersonal')
            ->select(
                'u.idUsuario as id',
                DB::raw("TRIM(CONCAT(COALESCE(p.apellidos, ''), ', ', COALESCE(p.nombres, ''))) as nombre_completo")
            )
            ->where('u.st_registro', 1)
            ->orderBy('p.apellidos', 'asc')
            ->get();
    }

    public static function buscar($idProgramaEstudio)
    {
        // Hacemos JOINs con las 3 asignaciones de personal para traer los nombres garantizados
        return DB::table('programaestudio as pe')
            ->leftJoin('usuario as u_coord', 'pe.idCoordinadorArea', '=', 'u_coord.idUsuario')
            ->leftJoin('personal as p_coord', 'u_coord.idPersonal', '=', 'p_coord.idPersonal')
            
            ->leftJoin('usuario as u_t1', 'pe.idAsistenteAreaT1', '=', 'u_t1.idUsuario')
            ->leftJoin('personal as p_t1', 'u_t1.idPersonal', '=', 'p_t1.idPersonal')
            
            ->leftJoin('usuario as u_t2', 'pe.idAsistenteAreaT2', '=', 'u_t2.idUsuario')
            ->leftJoin('personal as p_t2', 'u_t2.idPersonal', '=', 'p_t2.idPersonal')
            
            ->select(
                'pe.idProgramaEstudio',
                'pe.idInstitucion',
                'pe.nombre',
                'pe.idCoordinadorArea',
                'pe.idAsistenteAreaT1',
                'pe.idAsistenteAreaT2',
                'pe.observacion',
                'pe.st_programaEstudio',
                'pe.st_registro',
                DB::raw("TRIM(CONCAT(COALESCE(p_coord.apellidos, ''), ', ', COALESCE(p_coord.nombres, ''))) as nombreCoordinador"),
                DB::raw("TRIM(CONCAT(COALESCE(p_t1.apellidos, ''), ', ', COALESCE(p_t1.nombres, ''))) as nombreAsistenteT1"),
                DB::raw("TRIM(CONCAT(COALESCE(p_t2.apellidos, ''), ', ', COALESCE(p_t2.nombres, ''))) as nombreAsistenteT2")
            )
            ->where('pe.idProgramaEstudio', $idProgramaEstudio)
            ->where('pe.st_registro', 1)
            ->first();
    }

    public static function guardar($data)
    {
        $id = $data['idProgramaEstudio'] ?? null;

        $datosInsertarActualizar = [
            'idInstitucion'      => $data['idInstitucion'] ?? 1,
            'nombre'             => $data['nombre'] ?? '',
            'idCoordinadorArea' => !empty($data['idCoordinadorArea']) ? $data['idCoordinadorArea'] : null,
            'idAsistenteAreaT1' => !empty($data['idAsistenteAreaT1']) ? $data['idAsistenteAreaT1'] : null,
            'idAsistenteAreaT2' => !empty($data['idAsistenteAreaT2']) ? $data['idAsistenteAreaT2'] : null,
            'observacion'       => $data['observacion'] ?? null,
            'st_programaEstudio' => $data['st_programaEstudio'] ?? 'ACTIVO',
            'st_registro'        => $data['st_registro'] ?? 1,
        ];

        if ($id) {
            DB::table('programaestudio')
                ->where('idProgramaEstudio', $id)
                ->update($datosInsertarActualizar);
            return $id;
        } else {
            return DB::table('programaestudio')->insertGetId($datosInsertarActualizar);
        }
    }

    public static function eliminar($idProgramaEstudio)
    {
        return DB::table('programaestudio')
            ->where('idProgramaEstudio', $idProgramaEstudio)
            ->update(['st_registro' => 0]);
    }
}