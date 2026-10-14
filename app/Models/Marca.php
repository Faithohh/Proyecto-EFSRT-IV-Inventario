<?php

namespace App\Models;

use Illuminate\Support\Facades\DB;
use Exception;

class Marca
{
    public static function listar()
    {
        $idProgramaEstudio = session('idProgramaEstudio');

        return DB::table('marca')
            ->select('idMarca', 'nombre', 'fechaCreacion', 'fechaModificacion', 'idUsuarioCrea', 'idUsuarioModifica', 'idProgramaEstudio', 'st_registro')
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('idProgramaEstudio', $idProgramaEstudio);
            })
            ->orderBy('nombre')
            ->get()
            ->toArray();
    }

    public static function buscar($idMarca)
    {
        return DB::table('marca')
            ->select('idMarca', 'nombre', 'fechaCreacion', 'fechaModificacion', 'idUsuarioCrea', 'idUsuarioModifica', 'idProgramaEstudio', 'st_registro')
            ->where('idMarca', $idMarca)
            ->first();
    }

    public static function crear($nombre, $idProgramaEstudio, $stRegistro, $idUsuario)
    {
        $idProgramaEstudio = $idProgramaEstudio ?: session('idProgramaEstudio');

        $existe = DB::table('marca')
            ->where('nombre', $nombre)
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('idProgramaEstudio', $idProgramaEstudio);
            })
            ->exists();

        if ($existe) {
            throw new Exception("Ya existe una marca registrada con ese nombre para este programa de estudio.");
        }

        return DB::table('marca')->insert([
            'nombre'            => $nombre,
            'idProgramaEstudio' => $idProgramaEstudio ?: null,
            'st_registro'       => $stRegistro ?? 1,
            'idUsuarioCrea'     => $idUsuario,
            'fechaCreacion'     => now(),
        ]);
    }

    public static function actualizar($idMarca, $nombre, $idProgramaEstudio, $stRegistro, $idUsuario)
    {
        $idProgramaEstudio = $idProgramaEstudio ?: session('idProgramaEstudio');

        $existe = DB::table('marca')
            ->where('nombre', $nombre)
            ->where('idMarca', '!=', $idMarca)
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('idProgramaEstudio', $idProgramaEstudio);
            })
            ->exists();

        if ($existe) {
            throw new Exception("Ya existe otra marca registrada con ese nombre para este programa de estudio.");
        }

        return DB::table('marca')
            ->where('idMarca', $idMarca)
            ->update([
                'nombre'             => $nombre,
                'idProgramaEstudio'  => $idProgramaEstudio ?: null,
                'st_registro'        => $stRegistro ?? 1,
                'idUsuarioModifica'  => $idUsuario,
                'fechaModificacion'  => now(),
            ]);
    }

    public static function eliminar($idMarca)
    {
        return DB::table('marca')->where('idMarca', $idMarca)->delete();
    }
}