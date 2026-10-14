<?php

namespace App\Models;

use Illuminate\Support\Facades\DB;
use Exception;

class Grupo
{
    public static function listar()
    {
        $idProgramaEstudio = session('idProgramaEstudio');

        return DB::table('grupo')
            ->select('idGrupo', 'nombre', 'idProgramaEstudio', 'st_registro', 'idUsuarioCrea', 'fechaCreacion', 'idUsuarioModifica', 'fechaModificacion')
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('idProgramaEstudio', $idProgramaEstudio);
            })
            ->orderBy('nombre')
            ->get()
            ->toArray();
    }

    public static function buscar($idGrupo)
    {
        return DB::table('grupo')
            ->select('idGrupo', 'nombre', 'idProgramaEstudio', 'st_registro', 'idUsuarioCrea', 'fechaCreacion', 'idUsuarioModifica', 'fechaModificacion')
            ->where('idGrupo', $idGrupo)
            ->first();
    }

    public static function crear($nombre, $idProgramaEstudio, $stRegistro, $idUsuario)
    {
        $idProgramaEstudio = $idProgramaEstudio ?: session('idProgramaEstudio');

        $existe = DB::table('grupo')
            ->where('nombre', $nombre)
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('idProgramaEstudio', $idProgramaEstudio);
            })
            ->exists();

        if ($existe) {
            throw new Exception("Ya existe un grupo registrado con ese nombre para este programa de estudio.");
        }

        return DB::table('grupo')->insert([
            'nombre'            => $nombre,
            'idProgramaEstudio' => $idProgramaEstudio ?: null,
            'st_registro'       => $stRegistro ?? 1,
            'idUsuarioCrea'     => $idUsuario,
            'fechaCreacion'     => now(),
        ]);
    }

    public static function actualizar($idGrupo, $nombre, $idProgramaEstudio, $stRegistro, $idUsuario)
    {
        $idProgramaEstudio = $idProgramaEstudio ?: session('idProgramaEstudio');

        $existe = DB::table('grupo')
            ->where('nombre', $nombre)
            ->where('idGrupo', '!=', $idGrupo)
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('idProgramaEstudio', $idProgramaEstudio);
            })
            ->exists();

        if ($existe) {
            throw new Exception("Ya existe otro grupo registrado con ese nombre para este programa de estudio.");
        }

        return DB::table('grupo')
            ->where('idGrupo', $idGrupo)
            ->update([
                'nombre'            => $nombre,
                'idProgramaEstudio' => $idProgramaEstudio ?: null,
                'st_registro'       => $stRegistro ?? 1,
                'idUsuarioModifica' => $idUsuario,
                'fechaModificacion' => now(),
            ]);
    }

    public static function eliminar($idGrupo)
    {
        return DB::table('grupo')->where('idGrupo', $idGrupo)->delete();
    }
}