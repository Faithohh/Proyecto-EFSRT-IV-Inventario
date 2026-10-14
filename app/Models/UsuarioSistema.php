<?php

namespace App\Models;

use Illuminate\Support\Facades\DB;
use Exception;

class UsuarioSistema
{
    public static function listar()
    {
        return DB::table('usuario as u')
            ->leftJoin('personal as p', 'u.idPersonal', '=', 'p.idPersonal')
            ->select(
                'u.idUsuario', 
                'u.tipoUsuario', 
                'u.activo', 
                'u.idPersonal', 
                DB::raw("NULLIF(TRIM(CONCAT(COALESCE(p.apellidos, ''), ' ', COALESCE(p.nombres, ''))), '') as personal")
            )
            ->orderBy('u.idUsuario')
            ->get()
            ->map(function ($u) {
                $arr = (array) $u;
                $low = [];
                foreach ($arr as $k => $v) {
                    $low[strtolower($k)] = $v;
                }
                
                $nombrePersonal = isset($low['personal']) && !empty(trim($low['personal'])) 
                    ? trim($low['personal']) 
                    : 'Sin asignar';

                return [
                    'idUsuario'   => $low['idusuario'] ?? '',
                    'tipoUsuario' => $low['tipousuario'] ?? '',
                    'activo'      => $low['activo'] ?? 0,
                    'idPersonal'  => $low['idpersonal'] ?? null,
                    'personal'    => $nombrePersonal,
                ];
            })
            ->values()
            ->toArray();
    }

    public static function buscar($idUsuario)
    {
        return DB::table('usuario as u')
            ->leftJoin('personal as p', 'u.idPersonal', '=', 'p.idPersonal')
            ->select(
                'u.idUsuario', 
                DB::raw('u.`contraseña` as contrasena'), 
                'u.tipoUsuario', 
                'u.activo', 
                'u.idPersonal', 
                DB::raw("NULLIF(TRIM(CONCAT(COALESCE(p.apellidos, ''), ' ', COALESCE(p.nombres, ''))), '') as personal")
            )
            ->where('u.idUsuario', $idUsuario)
            ->first();
    }

    public static function crear($idUsuario, $contrasena, $tipoUsuario, $idPersonal)
    {
        if (!empty($idPersonal)) {
            $existe = DB::table('usuario')
                ->where('idPersonal', $idPersonal)
                ->exists();

            if ($existe) {
                throw new Exception("El personal seleccionado ya está asignado a otro usuario.");
            }
        }

        return DB::table('usuario')->insert([
            'idUsuario'   => strtoupper($idUsuario),
            'contraseña'  => $contrasena,
            'tipoUsuario' => $tipoUsuario,
            'idPersonal'  => $idPersonal ?: null,
            'activo'      => 1,
            'st_registro' => 1,
        ]);
    }

    public static function actualizar($idOriginal, $idUsuario, $contrasena, $tipoUsuario, $idPersonal)
    {
        if (!empty($idPersonal)) {
            $existe = DB::table('usuario')
                ->where('idPersonal', $idPersonal)
                ->where('idUsuario', '!=', $idOriginal)
                ->exists();

            if ($existe) {
                throw new Exception("El personal seleccionado ya está asignado a otro usuario.");
            }
        }

        return DB::table('usuario')
            ->where('idUsuario', $idOriginal)
            ->update([
                'idUsuario'   => strtoupper($idUsuario),
                'contraseña'  => $contrasena,
                'tipoUsuario' => $tipoUsuario,
                'idPersonal'  => $idPersonal ?: null,
            ]);
    }

    public static function eliminar($idUsuario)
    {
        return DB::table('usuario')
            ->where('idUsuario', $idUsuario)
            ->delete();
    }
}