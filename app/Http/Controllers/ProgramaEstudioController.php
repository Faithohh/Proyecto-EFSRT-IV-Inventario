<?php

namespace App\Http\Controllers;

use App\Models\ProgramaEstudio;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class ProgramaEstudioController extends Controller
{
    public function listar()
    {
        try {
            $programaEstudio = ProgramaEstudio::listar();

            return response()->json([
                'ok' => true,
                'data' => $programaEstudio
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function listarUsuarios()
    {
        try {
            // Se realiza la consulta trayendo 'u.idPersonal as id' (ID entero) para evitar el error MySQL 1366
            $usuarios = DB::table('usuario as u')
                ->join('personal as p', 'u.idPersonal', '=', 'p.idPersonal')
                ->select(
                    'u.idPersonal as id',
                    DB::raw("TRIM(CONCAT(COALESCE(p.apellidos, ''), ', ', COALESCE(p.nombres, ''))) as nombre_completo")
                )
                ->where('u.st_registro', 1)
                ->orderBy('p.apellidos', 'asc')
                ->get();

            return response()->json([
                'ok' => true,
                'data' => $usuarios
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error al listar usuarios: ' . $e->getMessage()
            ], 500);
        }
    }

    public function buscar($idProgramaEstudio)
    {
        try {
            $programaEstudio = ProgramaEstudio::buscar($idProgramaEstudio);
            
            if (!$programaEstudio) {
                return response()->json([
                    'ok' => false,
                    'msg' => 'Programa de estudio no encontrado'
                ], 404);
            }

            return response()->json([
                'ok' => true,
                'data' => $programaEstudio
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function guardar(Request $request)
    {
        try {
            $data = $request->all();
            
            if ($request->has('programaestudio_id')) {
                $data['idProgramaEstudio'] = $request->input('programaestudio_id');
            }

            $id = ProgramaEstudio::guardar($data);

            return response()->json([
                'ok' => true,
                'msg' => 'Registro guardado correctamente',
                'id' => $id
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error al guardar: ' . $e->getMessage()
            ], 500);
        }
    }

    public function eliminar($idProgramaEstudio)
    {
        try {
            DB::beginTransaction();

            if (Schema::hasTable('usuario_programaestudio')) {
                if (Schema::hasColumn('usuario_programaestudio', 'idProgramaEstudio')) {
                    DB::table('usuario_programaestudio')->where('idProgramaEstudio', $idProgramaEstudio)->delete();
                } elseif (Schema::hasColumn('usuario_programaestudio', 'programaestudio_id')) {
                    DB::table('usuario_programaestudio')->where('programaestudio_id', $idProgramaEstudio)->delete();
                }
            }

            if (Schema::hasTable('bien')) {
                if (Schema::hasColumn('bien', 'idProgramaEstudio')) {
                    DB::table('bien')->where('idProgramaEstudio', $idProgramaEstudio)->update(['idProgramaEstudio' => null]);
                } elseif (Schema::hasColumn('bien', 'programaestudio_id')) {
                    DB::table('bien')->where('programaestudio_id', $idProgramaEstudio)->update(['programaestudio_id' => null]);
                }
            }

            if (Schema::hasTable('inventario')) {
                if (Schema::hasColumn('inventario', 'idProgramaEstudio')) {
                    DB::table('inventario')->where('idProgramaEstudio', $idProgramaEstudio)->update(['idProgramaEstudio' => null]);
                } elseif (Schema::hasColumn('inventario', 'programaestudio_id')) {
                    DB::table('inventario')->where('programaestudio_id', $idProgramaEstudio)->update(['programaestudio_id' => null]);
                }
            }

            ProgramaEstudio::eliminar($idProgramaEstudio);

            DB::commit();

            return response()->json([
                'ok' => true,
                'msg' => 'Programa de estudio y registros asociados eliminados correctamente'
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'ok' => false,
                'msg' => 'Error al eliminar: ' . $e->getMessage()
            ], 500);
        }
    }
}