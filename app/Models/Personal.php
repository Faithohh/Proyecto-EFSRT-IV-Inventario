<?php

namespace App\Models;

use Illuminate\Support\Facades\DB;

class Personal
{
    public static function listar()
    {
        return DB::table('personal')
            ->orderBy('idPersonal', 'desc')
            ->get()
            ->map(function ($p) {
                return [
                    'idPersonal' => $p->idPersonal ?? null,
                    'nombreCompleto' => trim(($p->nombres ?? '') . ' ' . ($p->ap_paterno ?? $p->apellidos ?? '') . ' ' . ($p->ap_materno ?? '')),
                    'dni' => $p->dni ?? $p->num_doc ?? '',
                    'celular' => $p->celular ?? $p->telefono ?? '',
                    'email' => $p->email ?? $p->correo ?? '',
                    'st_registro' => $p->st_registro ?? $p->estado ?? 1,
                ];
            })->toArray();
    }

    public static function buscar($idPersonal)
    {
        $p = DB::table('personal')
            ->where('idPersonal', $idPersonal)
            ->first();

        if (!$p) return null;

        return [
            'idPersonal' => $p->idPersonal ?? null,
            'nombres' => $p->nombres ?? '',
            'apellidos' => $p->apellidos ?? $p->ap_paterno ?? '',
            'nombreCompleto' => trim(($p->nombres ?? '') . ' ' . ($p->ap_paterno ?? $p->apellidos ?? '') . ' ' . ($p->ap_materno ?? '')),
            'dni' => $p->dni ?? $p->num_doc ?? '',
            'celular' => $p->celular ?? $p->telefono ?? '',
            'email' => $p->email ?? $p->correo ?? '',
            'st_registro' => $p->st_registro ?? $p->estado ?? 1,
        ];
    }

    public static function guardar($data)
    {
        $id = $data['idPersonal'] ?? null;

        $datosInsertarActualizar = [
            'dni' => $data['dni'] ?? null,
            'nombres' => $data['nombres'] ?? $data['nombreCompleto'] ?? '',
            'celular' => $data['celular'] ?? null,
            'email' => $data['email'] ?? null,
            'st_registro' => $data['st_registro'] ?? 1,
        ];

        if ($id) {
            DB::table('personal')
                ->where('idPersonal', $id)
                ->update($datosInsertarActualizar);
            return $id;
        } else {
            return DB::table('personal')->insertGetId($datosInsertarActualizar);
        }
    }

    public static function eliminar($idPersonal)
    {
        return DB::table('personal')
            ->where('idPersonal', $idPersonal)
            ->delete();
    }
}