<?php

namespace App\Models;

use Illuminate\Support\Facades\DB;
use Exception;

class Modelo
{
    public static function listar()
    {
        $idProgramaEstudio = session('idProgramaEstudio');

        return DB::table('modelo')
            ->select('idModelo', 'idProgramaEstudio', 'nombre', 'fechaCreacion', 'fechaModificacion', 'idUsuarioCrea', 'idUsuarioModifica')
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('idProgramaEstudio', $idProgramaEstudio);
            })
            ->orderBy('nombre')
            ->get()
            ->toArray();
    }

    public static function buscar($idModelo)
    {
        return DB::table('modelo')
            ->select('idModelo', 'idProgramaEstudio', 'nombre', 'fechaCreacion', 'fechaModificacion', 'idUsuarioCrea', 'idUsuarioModifica')
            ->where('idModelo', $idModelo)
            ->first();
    }

    public static function crear($nombre)
    {
        $idProgramaEstudio = session('idProgramaEstudio');
        $idUsuario = session('idUsuario', 'SISTEMA');

        $existe = DB::table('modelo')
            ->where('nombre', $nombre)
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('idProgramaEstudio', $idProgramaEstudio);
            })
            ->exists();

        if ($existe) {
            throw new Exception("Ya existe un modelo registrado con ese nombre.");
        }

        return DB::table('modelo')->insert([
            'nombre'            => $nombre,
            'idProgramaEstudio' => $idProgramaEstudio ?: null,
            'idUsuarioCrea'     => $idUsuario,
            'fechaCreacion'     => now(),
        ]);
    }

    public static function actualizar($idModelo, $nombre)
    {
        $idProgramaEstudio = session('idProgramaEstudio');
        $idUsuario = session('idUsuario', 'SISTEMA');

        $existe = DB::table('modelo')
            ->where('nombre', $nombre)
            ->where('idModelo', '!=', $idModelo)
            ->when($idProgramaEstudio, function ($query) use ($idProgramaEstudio) {
                return $query->where('idProgramaEstudio', $idProgramaEstudio);
            })
            ->exists();

        if ($existe) {
            throw new Exception("Ya existe otro modelo registrado con ese nombre.");
        }

        return DB::table('modelo')
            ->where('idModelo', $idModelo)
            ->update([
                'nombre'            => $nombre,
                'idUsuarioModifica' => $idUsuario,
                'fechaModificacion' => now(),
            ]);
    }

    public static function eliminar($idModelo)
    {
        return DB::table('modelo')->where('idModelo', $idModelo)->delete();
    }
}