<?php

namespace App\Models;

use Illuminate\Support\Facades\DB;
use Exception;

class Estado
{
    public static function listar()
    {
        return DB::table('estado')
            ->select('idEstado', 'nombre')
            ->orderBy('nombre')
            ->get()
            ->toArray();
    }

    public static function buscar($idEstado)
    {
        return DB::table('estado')
            ->select('idEstado', 'nombre')
            ->where('idEstado', $idEstado)
            ->first();
    }

    public static function crear($nombre)
    {
        $existe = DB::table('estado')->where('nombre', $nombre)->exists();
        if ($existe) {
            throw new Exception("Ya existe un estado registrado con ese nombre.");
        }

        return DB::table('estado')->insert([
            'nombre' => $nombre,
        ]);
    }

    public static function actualizar($idEstado, $nombre)
    {
        $existe = DB::table('estado')
            ->where('nombre', $nombre)
            ->where('idEstado', '!=', $idEstado)
            ->exists();

        if ($existe) {
            throw new Exception("Ya existe otro estado registrado con ese nombre.");
        }

        return DB::table('estado')
            ->where('idEstado', $idEstado)
            ->update([
                'nombre' => $nombre,
            ]);
    }

    public static function eliminar($idEstado)
    {
        return DB::table('estado')->where('idEstado', $idEstado)->delete();
    }
}