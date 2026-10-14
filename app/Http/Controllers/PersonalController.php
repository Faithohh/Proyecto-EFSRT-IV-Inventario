<?php

namespace App\Http\Controllers;

use App\Models\Personal;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class PersonalController extends Controller
{
    public function listar()
    {
        try {
            $personal = Personal::listar();

            return response()->json([
                'ok' => true,
                'data' => $personal
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function buscar($idPersonal)
    {
        try {
            $personal = Personal::buscar($idPersonal);
            
            if (!$personal) {
                return response()->json([
                    'ok' => false,
                    'msg' => 'Personal no encontrado'
                ], 404);
            }

            return response()->json([
                'ok' => true,
                'data' => $personal
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
            
            if ($request->has('personal_id')) {
                $data['idPersonal'] = $request->input('personal_id');
            }

            $id = Personal::guardar($data);

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

    public function eliminar($idPersonal)
    {
        try {
            DB::beginTransaction();

            // 1. Limpiar referencias en la tabla "bien" si existe la columna de relación
            if (Schema::hasTable('bien')) {
                if (Schema::hasColumn('bien', 'idPersonal')) {
                    DB::table('bien')->where('idPersonal', $idPersonal)->update(['idPersonal' => null]);
                } elseif (Schema::hasColumn('bien', 'personal_id')) {
                    DB::table('bien')->where('personal_id', $idPersonal)->update(['personal_id' => null]);
                }
            }

            // 2. Limpiar referencias en la tabla "inventario"
            if (Schema::hasTable('inventario')) {
                if (Schema::hasColumn('inventario', 'idPersonal')) {
                    DB::table('inventario')->where('idPersonal', $idPersonal)->update(['idPersonal' => null]);
                } elseif (Schema::hasColumn('inventario', 'personal_id')) {
                    DB::table('inventario')->where('personal_id', $idPersonal)->update(['personal_id' => null]);
                }
            }

            // 3. Buscar usuario asociado y eliminar sus accesos y cuenta
            $usuario = DB::table('usuario')
                ->where('idPersonal', $idPersonal)
                ->first();

            if ($usuario) {
                if (Schema::hasTable('usuario_programaestudio')) {
                    DB::table('usuario_programaestudio')
                        ->where('idUsuario', $usuario->idUsuario)
                        ->delete();
                }

                DB::table('usuario')
                    ->where('idUsuario', $usuario->idUsuario)
                    ->delete();
            }

            // 4. Eliminar el registro en la tabla personal
            Personal::eliminar($idPersonal);

            DB::commit();

            return response()->json([
                'ok' => true,
                'msg' => 'Personal y registros asociados eliminados correctamente'
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