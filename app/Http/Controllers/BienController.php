<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;

class BienController extends Controller
{
    private function aplicarFiltroEstado($query, $campo = 'st_registro')
    {
        return $query->where(function ($q) use ($campo) {
            $q->where($campo, 1)->orWhereNull($campo);
        });
    }

    private function obtenerCatalogoBase($tabla, $idKey, $idProgramaEstudio = null, $permitirNullPrograma = false)
    {
        $query = DB::table($tabla)
            ->select($idKey, DB::raw("COALESCE(nombre, '') as nombre"));

        $this->aplicarFiltroEstado($query);

        if (!empty($idProgramaEstudio)) {
            if ($permitirNullPrograma) {
                $query->where(function ($sub) use ($idProgramaEstudio) {
                    $sub->where('idProgramaEstudio', '=', $idProgramaEstudio)
                        ->orWhereNull('idProgramaEstudio');
                });
            } else {
                $query->where('idProgramaEstudio', '=', $idProgramaEstudio);
            }
        }

        return $query->orderBy('nombre', 'ASC')->get();
    }

    public function listar(Request $request)
    {
        try {
            $idProgramaEstudio = Session::get('idProgramaEstudio');
            $idSala = $request->input('idSala');

            $query = DB::table('bien as b')
                ->join('sala as s', 'b.idSala', '=', 's.idSala')
                ->leftJoin('tipo as t', 'b.idTipo', '=', 't.idTipo')
                ->leftJoin('marca as m', 'b.idMarca', '=', 'm.idMarca')
                ->leftJoin('modelo as mo', 'b.idModelo', '=', 'mo.idModelo')
                ->leftJoin('estado as e', 'b.idEstado', '=', 'e.idEstado')
                ->leftJoin('grupo as g', 'b.idGrupo', '=', 'g.idGrupo')
                ->select(
                    'b.idBien',
                    'b.cbi',
                    'b.descripcion',
                    'b.serieMedida',
                    'b.otrasEspecificaciones',
                    'b.idSala',
                    'b.idGrupo',
                    'b.idTipo',
                    'b.idMarca',
                    'b.idModelo',
                    'b.idEstado',
                    'b.idUsuarioCrea',
                    'b.fechaCreacion',
                    'b.idUsuarioModifica',
                    'b.fechaModificacion',
                    DB::raw("COALESCE(s.nombre, '') as sala"),
                    DB::raw("COALESCE(t.nombre, '') as tipo"),
                    DB::raw("COALESCE(m.nombre, '') as marca"),
                    DB::raw("COALESCE(mo.nombre, '') as modelo"),
                    DB::raw("COALESCE(e.nombre, '') as estado"),
                    DB::raw("COALESCE(g.nombre, '') as grupo")
                );

            $this->aplicarFiltroEstado($query, 'b.st_registro');

            if (!empty($idProgramaEstudio)) {
                $query->where('s.idProgramaEstudio', '=', $idProgramaEstudio);
            }

            if (!empty($idSala)) {
                $query->where('b.idSala', '=', $idSala);
            }

            return response()->json(['ok' => true, 'data' => $query->get()]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function listarSalas()
    {
        try {
            $idProgramaEstudio = Session::get('idProgramaEstudio');

            $query = DB::table('sala')
                ->select('idSala', DB::raw("COALESCE(nombre, observacion, '') as descripcion"));

            $this->aplicarFiltroEstado($query);

            if (!empty($idProgramaEstudio)) {
                $query->where('idProgramaEstudio', '=', $idProgramaEstudio);
            }

            return response()->json(['ok' => true, 'data' => $query->orderBy('nombre', 'ASC')->get()]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'data' => []], 500);
        }
    }

    public function cargarCombos()
    {
        try {
            $prog = Session::get('idProgramaEstudio');

            return response()->json([
                'ok' => true,
                'data' => [
                    'grupos'  => $this->obtenerCatalogoBase('grupo', 'idGrupo', $prog),
                    'tipos'   => $this->obtenerCatalogoBase('tipo', 'idTipo', $prog),
                    'marcas'  => $this->obtenerCatalogoBase('marca', 'idMarca', $prog),
                    'modelos' => $this->obtenerCatalogoBase('modelo', 'idModelo', $prog, true),
                    'estados' => $this->obtenerCatalogoBase('estado', 'idEstado'),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function buscar($idBien)
    {
        try {
            $bien = DB::table('bien')->where('idBien', $idBien)->first();
            if (!$bien) {
                return response()->json(['ok' => false, 'msg' => 'Bien no encontrado'], 404);
            }
            return response()->json(['ok' => true, 'data' => $bien]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    public function guardar(Request $request)
    {
        try {
            $idOriginal = $request->input('idOriginal');
            $idUsuario = Session::get('idUsuario', 'ADMIN');
            $pcTerminal = $request->ip();
            $fechaAhora = now();

            $datos = [
                'cbi'                   => $request->input('cbi'),
                'descripcion'           => $request->input('descripcion'),
                'serieMedida'           => $request->input('serieMedida'),
                'otrasEspecificaciones' => $request->input('otrasEspecificaciones'),
                'idSala'                => $request->input('idSala') ?: null,
                'idGrupo'               => $request->input('idGrupo') ?: null,
                'idTipo'                => $request->input('idTipo') ?: null,
                'idMarca'               => $request->input('idMarca') ?: null,
                'idModelo'              => $request->input('idModelo') ?: null,
                'idEstado'              => $request->input('idEstado') ?: null,
                'st_registro'           => 1,
            ];

            if (!empty($idOriginal)) {
                $datos['idUsuarioModifica']  = $idUsuario;
                $datos['fechaModificacion'] = $fechaAhora;
                $datos['pcTerminalModifica'] = $pcTerminal;

                DB::table('bien')->where('idBien', $idOriginal)->update($datos);

                return response()->json(['ok' => true, 'msg' => 'Bien actualizado correctamente']);
            } else {
                $datos['idUsuarioCrea']   = $idUsuario;
                $datos['fechaCreacion']   = $fechaAhora;
                $datos['pcTerminalCrea']  = $pcTerminal;

                DB::table('bien')->insert($datos);

                return response()->json(['ok' => true, 'msg' => 'Bien registrado correctamente']);
            }
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al guardar: ' . $e->getMessage()], 500);
        }
    }

    public function eliminar(Request $request)
    {
        try {
            $idBien = $request->input('idBien');
            $idUsuario = Session::get('idUsuario', 'ADMIN');

            if (empty($idBien)) {
                return response()->json(['ok' => false, 'msg' => 'ID de bien no proporcionado'], 400);
            }

            DB::table('bien')->where('idBien', $idBien)->update([
                'st_registro' => 0,
                'idUsuarioModifica' => $idUsuario,
                'fechaModificacion' => now()
            ]);

            return response()->json(['ok' => true, 'msg' => 'Bien eliminado correctamente']);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => 'Error al eliminar el bien: ' . $e->getMessage()], 500);
        }
    }
}