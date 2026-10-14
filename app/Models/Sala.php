<?php

namespace App\Models;

use Illuminate\Support\Facades\DB;
use Exception;

class Sala
{
    public static function listar()
    {
        $idProgramaEstudio = session('idProgramaEstudio');

        return DB::table('sala as s')
            ->leftJoin('programaestudio as pe', 's.idProgramaEstudio', '=', 'pe.idProgramaEstudio')
            ->select(
                's.idSala',
                's.nombre',
                's.observacion',
                's.fechaCreacion',
                's.fechaModificacion',
                's.idUsuarioCrea',
                's.idUsuarioModifica',
                's.idProgramaEstudio',
                'pe.nombre as nombreProgramaEstudio',
                's.st_registro'
            )
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('s.idProgramaEstudio', $idProgramaEstudio);
            })
            ->orderBy('s.nombre')
            ->get()
            ->toArray();
    }

    public static function buscar($idSala)
    {
        return DB::table('sala as s')
            ->leftJoin('programaestudio as pe', 's.idProgramaEstudio', '=', 'pe.idProgramaEstudio')
            ->select(
                's.idSala',
                's.nombre',
                's.observacion',
                's.fechaCreacion',
                's.fechaModificacion',
                's.idUsuarioCrea',
                's.idUsuarioModifica',
                's.idProgramaEstudio',
                'pe.nombre as nombreProgramaEstudio',
                's.st_registro'
            )
            ->where('s.idSala', $idSala)
            ->first();
    }

    public static function crear($nombre, $observacion, $idProgramaEstudio, $stRegistro, $idUsuario)
    {
        $idProgramaEstudio = $idProgramaEstudio ?: session('idProgramaEstudio');

        $existe = DB::table('sala')
            ->where('nombre', $nombre)
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('idProgramaEstudio', $idProgramaEstudio);
            })
            ->exists();

        if ($existe) {
            throw new Exception("Ya existe una sala registrada con ese nombre para este programa de estudio.");
        }

        return DB::table('sala')->insert([
            'nombre'            => $nombre,
            'observacion'       => $observacion ?: null,
            'idProgramaEstudio' => $idProgramaEstudio ?: null,
            'st_registro'       => $stRegistro ?? 1,
            'idUsuarioCrea'     => $idUsuario,
            'fechaCreacion'     => now(),
        ]);
    }

    public static function actualizar($idSala, $nombre, $observacion, $idProgramaEstudio, $stRegistro, $idUsuario)
    {
        $idProgramaEstudio = $idProgramaEstudio ?: session('idProgramaEstudio');

        $existe = DB::table('sala')
            ->where('nombre', $nombre)
            ->where('idSala', '!=', $idSala)
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('idProgramaEstudio', $idProgramaEstudio);
            })
            ->exists();

        if ($existe) {
            throw new Exception("Ya existe otra sala registrada con ese nombre para este programa de estudio.");
        }

        return DB::table('sala')
            ->where('idSala', $idSala)
            ->update([
                'nombre'             => $nombre,
                'observacion'        => $observacion ?: null,
                'idProgramaEstudio'  => $idProgramaEstudio ?: null,
                'st_registro'        => $stRegistro ?? 1,
                'idUsuarioModifica'  => $idUsuario,
                'fechaModificacion'  => now(),
            ]);
    }
}