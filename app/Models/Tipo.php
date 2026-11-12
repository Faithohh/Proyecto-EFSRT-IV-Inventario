<?php

namespace App\Models;

use Illuminate\Support\Facades\DB;
use Exception;

class Tipo
{
    public static function listar()
    {
        return DB::table('tipo')
            ->select(
                'NOMBRE',
                'st_registro'
            )
            ->orderBy('NOMBRE')
            ->get()
            ->toArray();
    }

    public static function buscar($nombre)
    {
        return DB::table('tipo')
            ->select(
                'NOMBRE',
                'st_registro'
            )
            ->where('NOMBRE', $nombre)
            ->first();
    }

    public static function crear($nombre, $idUsuario)
    {
        $existe = DB::table('tipo')
            ->where('NOMBRE', $nombre)
            ->exists();

        if ($existe) {
            throw new Exception("Ya existe un tipo registrado con ese nombre.");
        }

        return DB::table('tipo')->insert([
            'NOMBRE'        => $nombre,
            'st_registro'   => 1,
            'idUsuarioCrea' => $idUsuario,
            'fechaCreacion' => now(),
        ]);
    }

    public static function actualizar($nombreOriginal, $nuevoNombre, $idUsuario)
    {
        if ($nombreOriginal !== $nuevoNombre) {
            $existe = DB::table('tipo')
                ->where('NOMBRE', $nuevoNombre)
                ->exists();

            if ($existe) {
                throw new Exception("Ya existe otro tipo registrado con ese nombre.");
            }
        }

        return DB::table('tipo')
            ->where('NOMBRE', $nombreOriginal)
            ->update([
                'NOMBRE'            => $nuevoNombre,
                'idUsuarioModifica' => $idUsuario,
                'fechaModificacion' => now(),
            ]);
    }

    public static function eliminar($nombre, $idUsuario)
    {
        return DB::table('tipo')
            ->where('NOMBRE', $nombre)
            ->update([
                'st_registro'       => 0,
                'idUsuarioModifica' => $idUsuario,
                'fechaModificacion' => now(),
            ]);
    }

    public static function activar($nombre, $idUsuario)
    {
        return DB::table('tipo')
            ->where('NOMBRE', $nombre)
            ->update([
                'st_registro'       => 1,
                'idUsuarioModifica' => $idUsuario,
                'fechaModificacion' => now(),
            ]);
    }
}
