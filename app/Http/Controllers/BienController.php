<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Session;

class BienController extends Controller
{
    /**
     * Lista los bienes filtrados por la carrera activa en sesión
     * y opcionalmente por una sala en específico.
     */
    public function listar(Request $request)
    {
        try {
            // Se obtiene el idProgramaEstudio guardado en sesión
            $idProgramaEstudio = Session::get('idProgramaEstudio');
            $idSala = $request->input('idSala');

            $query = DB::table('bien as b')
                ->join('sala as s', 'b.idSala', '=', 's.idSala') // Unimos con sala para validar la carrera
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
                )
                ->where(function($q) {
                    $q->where('b.st_registro', 1)->orWhereNull('b.st_registro');
                });

            // Filtramos únicamente los bienes que pertenecen a la carrera en sesión
            if (!empty($idProgramaEstudio)) {
                $query->where('s.idProgramaEstudio', '=', $idProgramaEstudio);
            }

            // Si el usuario seleccionó una sala específica en el combobox superior:
            if (!empty($idSala)) {
                $query->where('b.idSala', '=', $idSala);
            }

            $data = $query->get();

            return response()->json(['ok' => true, 'data' => $data]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'msg' => $e->getMessage()], 500);
        }
    }

    /**
     * Obtiene únicamente las salas correspondientes a la carrera del usuario en sesión.
     */
    public function listarSalas()
    {
        try {
            $idProgramaEstudio = Session::get('idProgramaEstudio');

            $query = DB::table('sala')
                ->select('idSala', DB::raw("COALESCE(nombre, observacion, '') as descripcion"))
                ->where(function($q) {
                    $q->where('st_registro', 1)->orWhereNull('st_registro');
                });

            if (!empty($idProgramaEstudio)) {
                $query->where('idProgramaEstudio', '=', $idProgramaEstudio);
            }

            $salas = $query->orderBy('nombre', 'ASC')->get();

            return response()->json(['ok' => true, 'data' => $salas]);
        } catch (\Exception $e) {
            return response()->json(['ok' => false, 'data' => []], 500);
        }
    }

    /**
     * Carga los combos generales y filtra los tipos por la carrera activa.
     */
    public function cargarCombos()
    {
        try {
            $idProgramaEstudio = Session::get('idProgramaEstudio');

            // 1. Grupos (Filtrado por carrera)
            $qGrupos = DB::table('grupo')
                ->select('idGrupo', DB::raw("COALESCE(nombre, '') as nombre"))
                ->where(function($q) { $q->where('st_registro', 1)->orWhereNull('st_registro'); });
            if (!empty($idProgramaEstudio)) { $qGrupos->where('idProgramaEstudio', '=', $idProgramaEstudio); }

            // 2. Tipos (Filtrado por carrera)
            $qTipos = DB::table('tipo')
                ->select('idTipo', DB::raw("COALESCE(nombre, '') as nombre"))
                ->where(function($q) { $q->where('st_registro', 1)->orWhereNull('st_registro'); });
            if (!empty($idProgramaEstudio)) { $qTipos->where('idProgramaEstudio', '=', $idProgramaEstudio); }

            // 3. Marcas (Filtrado por carrera)
            $qMarcas = DB::table('marca')
                ->select('idMarca', DB::raw("COALESCE(nombre, '') as nombre"))
                ->where(function($q) { $q->where('st_registro', 1)->orWhereNull('st_registro'); });
            if (!empty($idProgramaEstudio)) { $qMarcas->where('idProgramaEstudio', '=', $idProgramaEstudio); }

            // 4. Modelos (Filtrado por carrera O NULL)
            $qModelos = DB::table('modelo')
                ->select('idModelo', DB::raw("COALESCE(nombre, '') as nombre"))
                ->where(function($q) { $q->where('st_registro', 1)->orWhereNull('st_registro'); });
            if (!empty($idProgramaEstudio)) {
                $qModelos->where(function($sub) use ($idProgramaEstudio) {
                    $sub->where('idProgramaEstudio', '=', $idProgramaEstudio)
                        ->orWhereNull('idProgramaEstudio');
                });
            }

            // 5. Estados (Catálogo Global)
            $qEstados = DB::table('estado')
                ->select('idEstado', DB::raw("COALESCE(nombre, '') as nombre"))
                ->where(function($q) { $q->where('st_registro', 1)->orWhereNull('st_registro'); });

            return response()->json([
                'ok' => true,
                'data' => [
                    'grupos'  => $qGrupos->orderBy('nombre', 'ASC')->get(),
                    'tipos'   => $qTipos->orderBy('nombre', 'ASC')->get(),
                    'marcas'  => $qMarcas->orderBy('nombre', 'ASC')->get(),
                    'modelos' => $qModelos->orderBy('nombre', 'ASC')->get(),
                    'estados' => $qEstados->orderBy('nombre', 'ASC')->get(),
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
            $pcTerminal = gethostbyaddr($_SERVER['REMOTE_ADDR']) ?? request()->ip();
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
                // EDITAR / ACTUALIZAR
                $datos['idUsuarioModifica']  = $idUsuario;
                $datos['fechaModificacion'] = $fechaAhora;
                $datos['pcTerminalModifica'] = $pcTerminal;

                DB::table('bien')
                    ->where('idBien', $idOriginal)
                    ->update($datos);

                return response()->json(['ok' => true, 'msg' => 'Bien actualizado correctamente']);
            } else {
                // NUEVO REGISTRO
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
            $idUsuario = Session::get('idUsuario', 'AZUÑIGA');

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
