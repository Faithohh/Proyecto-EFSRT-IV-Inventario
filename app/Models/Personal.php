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
                // Se arma el nombre respetando que 'apellidos' contiene ambos apellidos
                $apellidos = trim($p->apellidos ?? '');
                $nombres = trim($p->nombres ?? '');
                $nombreCompleto = trim("{$apellidos} {$nombres}");

                return [
                    'idPersonal' => $p->idPersonal ?? null,
                    'nombreCompleto' => !empty($nombreCompleto) ? $nombreCompleto : ($p->dni ?? ''),
                    'apellidos' => $apellidos,
                    'nombres' => $nombres,
                    'dni' => $p->dni ?? '',
                    'celular' => $p->celular ?? '',
                    'email' => $p->email ?? '',
                    'st_registro' => $p->st_registro ?? 1,
                ];
            })->toArray();
    }

    public static function buscar($idPersonal)
    {
        $p = DB::table('personal')
            ->where('idPersonal', $idPersonal)
            ->first();

        if (!$p) return null;

        $apellidos = trim($p->apellidos ?? '');
        $nombres = trim($p->nombres ?? '');
        $nombreCompleto = trim("{$apellidos} {$nombres}");

        return [
            'idPersonal' => $p->idPersonal ?? null,
            'apellidos' => $apellidos,
            'nombres' => $nombres,
            'nombreCompleto' => !empty($nombreCompleto) ? $nombreCompleto : ($p->dni ?? ''),
            'dni' => $p->dni ?? '',
            'celular' => $p->celular ?? '',
            'email' => $p->email ?? '',
            'st_registro' => $p->st_registro ?? 1,
        ];
    }

    public static function guardar($data)
    {
        $id = $data['idPersonal'] ?? $data['personal_id'] ?? null;
        $st_registro = isset($data['st_registro']) ? (int)$data['st_registro'] : (isset($data['personal_st_registro']) ? (int)$data['personal_st_registro'] : 1);

        // Separación limpia de campos según la estructura de tu BD
        $datosInsertarActualizar = [
            'dni' => $data['dni'] ?? $data['personal_dni'] ?? null,
            'apellidos' => $data['apellidos'] ?? $data['personal_apellidos'] ?? null,
            'nombres' => $data['nombres'] ?? $data['personal_nombres'] ?? $data['personal_nombreCompleto'] ?? $data['nombreCompleto'] ?? '',
            'celular' => $data['celular'] ?? $data['personal_celular'] ?? null,
            'email' => $data['email'] ?? $data['personal_email'] ?? null,
            'st_registro' => $st_registro,
        ];

        if ($id) {
            DB::table('personal')
                ->where('idPersonal', $id)
                ->update($datosInsertarActualizar);
        } else {
            $id = DB::table('personal')->insertGetId($datosInsertarActualizar);
        }

        // --- SINCRONIZACIÓN DE ACCESO EN LA TABLA USUARIO ---
        // Si se inhabilita el personal (st_registro = 0), inhabilita también su cuenta de usuario para denegar el login
        DB::table('USUARIO')
            ->where('idPersonal', $id)
            ->update([
                'st_registro' => $st_registro,
                'activo' => $st_registro
            ]);

        return $id;
    }

    public static function eliminar($idPersonal)
    {
        return DB::table('personal')
            ->where('idPersonal', $idPersonal)
            ->delete();
    }
}