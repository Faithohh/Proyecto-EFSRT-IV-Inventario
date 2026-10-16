<?php
namespace App\Http\Controllers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Exception;

class InventarioController extends Controller
{
    private function baseQuery()
    {
        return DB::table('toma_inventarios as ti')
            ->leftJoin('sala as s', 'ti.sala_id', '=', 's.idSala')
            ->leftJoin('personal as c', 'ti.coordinador_id', '=', 'c.idPersonal')
            ->leftJoin('personal as a1', 'ti.asistente1_id', '=', 'a1.idPersonal')
            ->leftJoin('personal as a2', 'ti.asistente2_id', '=', 'a2.idPersonal');
    }

    private function validarDatos(Request $request)
    {
        return $request->validate([
            'anio' => 'required|integer|min:2000|max:2100',
            'sala_id' => 'required|integer|exists:sala,idSala',
            'fecha_entrega' => 'nullable|date',
            'observacion' => 'nullable|string|max:1000',
            'estado' => 'required|in:ABIERTO,CERRADO',
            'bienes' => 'nullable|array',
            'bienes.*.idBien' => 'required|integer|distinct|exists:bien,idBien',
            'bienes.*.nroDRELM' => 'nullable|string|max:10'
        ]);
    }

    private function guardarDetallesInventario($idInventario, $idSala, $bienesEnviados)
    {
        $bienesDrelm = collect($bienesEnviados ?? [])
            ->keyBy(function ($bien) {
                return (string) $bien['idBien'];
            });

        $bienes = DB::table('bien as b')
            ->leftJoin('grupo as g', 'b.idGrupo', '=', 'g.idGrupo')
            ->leftJoin('tipo as t', 'b.idTipo', '=', 't.idTipo')
            ->leftJoin('marca as ma', 'b.idMarca', '=', 'ma.idMarca')
            ->leftJoin('modelo as mo', 'b.idModelo', '=', 'mo.idModelo')
            ->leftJoin('estado as e', 'b.idEstado', '=', 'e.idEstado')
            ->where('b.idSala', $idSala)
            ->where(function ($query) {
                $query->where('b.st_registro', 1)
                    ->orWhereNull('b.st_registro');
            })
            ->select(
                'b.idBien',
                'b.idGrupo',
                'g.nombre as nombreGrupo',
                'b.cbi',
                'b.idTipo',
                't.nombre as nombreTipo',
                'b.descripcion',
                'b.idMarca',
                'ma.nombre as nombreMarca',
                'b.idModelo',
                'mo.nombre as nombreModelo',
                'b.serieMedida',
                'b.idEstado',
                'e.nombre as nombreEstado',
                'b.otrasEspecificaciones'
            )
            ->get();

        $idsBienes = $bienes->pluck('idBien')->all();

        $detallesExistentes = DB::table('inventario_detalle')
            ->where('idInventario', $idInventario)
            ->pluck('idBien')
            ->map(function ($idBien) {
                return (string) $idBien;
            })
            ->all();

        DB::table('inventario_detalle')
            ->where('idInventario', $idInventario)
            ->when(count($idsBienes) > 0, function ($query) use ($idsBienes) {
                $query->whereNotIn('idBien', $idsBienes);
            })
            ->when(count($idsBienes) === 0, function ($query) {
                $query->whereNotNull('idBien');
            })
            ->delete();

        foreach ($bienes as $bien) {
            $datoDrelm = $bienesDrelm->get((string) $bien->idBien);
            $nroDRELM = $datoDrelm
                ? trim((string) ($datoDrelm['nroDRELM'] ?? ''))
                : '';

            $detalle = [
                'idInventario' => $idInventario,
                'idBien' => $bien->idBien,
                'idGrupo' => $bien->idGrupo,
                'nombreGrupo' => $bien->nombreGrupo,
                'nroDRELM' => $nroDRELM !== '' ? $nroDRELM : null,
                'cbi' => $bien->cbi,
                'idTipo' => $bien->idTipo,
                'nombreTipo' => $bien->nombreTipo,
                'descripcion' => $bien->descripcion,
                'idMarca' => $bien->idMarca,
                'nombreMarca' => $bien->nombreMarca,
                'idModelo' => $bien->idModelo,
                'nombreModelo' => $bien->nombreModelo,
                'serieMedida' => $bien->serieMedida,
                'idEstado' => $bien->idEstado,
                'nombreEstado' => $bien->nombreEstado,
                'otrasEspecificaciones' => $bien->otrasEspecificaciones,
                'st_registro' => 1
            ];

            $existe = DB::table('inventario_detalle')
                ->where('idInventario', $idInventario)
                ->where('idBien', $bien->idBien)
                ->exists();

            if ($existe) {
                $detalle['fechaModificacion'] = now();

                DB::table('inventario_detalle')
                    ->where('idInventario', $idInventario)
                    ->where('idBien', $bien->idBien)
                    ->update($detalle);
            } else {
                $detalle['fechaCreacion'] = now();

                DB::table('inventario_detalle')->insert($detalle);
            }
        }
    }

    public function listar()
    {
        try {
            $inventarios = $this->baseQuery()
                ->select(
                    'ti.id as idInventario',
                    DB::raw("CONCAT(ti.anio, '-', ti.numero) as INVENTARIO"),
                    DB::raw("COALESCE(s.nombre, 'SIN SALA') as SALA"),
                    DB::raw("TRIM(CONCAT(COALESCE(c.nombres, ''), ' ', COALESCE(c.apellidos, ''))) as COORDINADOR"),
                    DB::raw("TRIM(CONCAT(COALESCE(a1.nombres, ''), ' ', COALESCE(a1.apellidos, ''))) as ASISTENTE_T1"),
                    DB::raw("CASE WHEN ti.asistente2_id IS NOT NULL THEN TRIM(CONCAT(COALESCE(a2.nombres, ''), ' ', COALESCE(a2.apellidos, ''))) ELSE '-' END as ASISTENTE_T2"),
                    'ti.fecha_entrega as FECHA_ENTREGA',
                    DB::raw("COALESCE(ti.observacion, '-') as OBSERVACION"),
                    DB::raw("(
                        SELECT COUNT(*)
                        FROM bien b
                        WHERE b.idSala = ti.sala_id
                        AND (b.st_registro = 1 OR b.st_registro IS NULL)
                    ) as CANTIDAD_DE_BIENES"),
                    'ti.estado as ESTADO'
                )
                ->orderByDesc('ti.id')
                ->get();

            return response()->json([
                'ok' => true,
                'data' => $inventarios
            ]);
        } catch (Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error al listar los inventarios: ' . $e->getMessage(),
                'data' => []
            ], 500);
        }
    }

    public function mostrar($id)
    {
        try {
            $inventario = $this->baseQuery()
                ->select(
                    'ti.*',
                    's.nombre as nombre_sala',
                    DB::raw("TRIM(CONCAT(COALESCE(c.nombres, ''), ' ', COALESCE(c.apellidos, ''))) as nombre_coordinador"),
                    DB::raw("TRIM(CONCAT(COALESCE(a1.nombres, ''), ' ', COALESCE(a1.apellidos, ''))) as nombre_asistente1"),
                    DB::raw("TRIM(CONCAT(COALESCE(a2.nombres, ''), ' ', COALESCE(a2.apellidos, ''))) as nombre_asistente2")
                )
                ->where('ti.id', $id)
                ->first();

            if (!$inventario) {
                return response()->json([
                    'ok' => false,
                    'msg' => 'Inventario no encontrado.'
                ], 404);
            }

            $inventario->total_bienes = DB::table('bien')
                ->where('idSala', $inventario->sala_id)
                ->where(function ($query) {
                    $query->where('st_registro', 1)
                        ->orWhereNull('st_registro');
                })
                ->count();

            $inventario->bienes = DB::table('inventario_detalle')
                ->where('idInventario', $inventario->id)
                ->select('idBien', 'nroDRELM')
                ->get();

            return response()->json([
                'ok' => true,
                'data' => $inventario
            ]);
        } catch (Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error al consultar el inventario: ' . $e->getMessage()
            ], 500);
        }
    }

    public function obtenerPersonalPorSala($idSala)
    {
        try {
            $sala = DB::table('sala as s')
                ->join('programaestudio as pe', 's.idProgramaEstudio', '=', 'pe.idProgramaEstudio')
                ->where('s.idSala', $idSala)
                ->select(
                    'pe.idCoordinadorArea',
                    'pe.idAsistenteAreaT1',
                    'pe.idAsistenteAreaT2'
                )
                ->first();

            if (!$sala) {
                return response()->json([
                    'ok' => false,
                    'msg' => 'No se encontró la sala o su Programa de Estudio.'
                ], 404);
            }

            $personal = [];

            foreach ([
                'coordinador' => $sala->idCoordinadorArea,
                'asistente1' => $sala->idAsistenteAreaT1,
                'asistente2' => $sala->idAsistenteAreaT2
            ] as $cargo => $idPersonal) {
                $persona = $idPersonal
                    ? DB::table('personal')
                        ->where('idPersonal', $idPersonal)
                        ->select(
                            'idPersonal',
                            DB::raw("TRIM(CONCAT(COALESCE(nombres, ''), ' ', COALESCE(apellidos, ''))) as nombre")
                        )
                        ->first()
                    : null;

                $personal[$cargo] = $persona;
            }

            return response()->json([
                'ok' => true,
                'data' => $personal
            ]);
        } catch (Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error al consultar el personal: ' . $e->getMessage()
            ], 500);
        }
    }

    public function listarBienesPorSala($idSala)
    {
        try {
            $bienes = DB::table('bien as b')
                ->leftJoin('grupo as g', 'b.idGrupo', '=', 'g.idGrupo')
                ->leftJoin('marca as ma', 'b.idMarca', '=', 'ma.idMarca')
                ->leftJoin('modelo as mo', 'b.idModelo', '=', 'mo.idModelo')
                ->leftJoin('estado as e', 'b.idEstado', '=', 'e.idEstado')
                ->where('b.idSala', $idSala)
                ->where(function ($query) {
                    $query->where('b.st_registro', 1)
                        ->orWhereNull('b.st_registro');
                })
                ->select(
                    'b.idBien',
                    'g.idGrupo',
                    'g.nombre as GRUPO',
                    'b.cbi as CBI',
                    'b.descripcion as DESCRIPCION',
                    'ma.idMarca',
                    'ma.nombre as MARCA',
                    'mo.idModelo',
                    'mo.nombre as MODELO',
                    'b.serieMedida as SERIE_MEDIDA',
                    'b.idEstado',
                    'b.otrasEspecificaciones as OTRAS_ESPECIFICACIONES',
                    'e.nombre as ESTADO'
                )
                ->orderBy('g.nombre')
                ->orderBy('b.cbi')
                ->get();

            return response()->json([
                'ok' => true,
                'data' => $bienes
            ]);
        } catch (Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error al cargar los bienes: ' . $e->getMessage(),
                'data' => []
            ], 500);
        }
    }

    public function guardar(Request $request)
    {
        $datos = $this->validarDatos($request);

        try {
            $idInventario = DB::transaction(function () use ($datos) {
                $sala = DB::table('sala')
                    ->where('idSala', $datos['sala_id'])
                    ->lockForUpdate()
                    ->first();

                if (!$sala) {
                    throw ValidationException::withMessages([
                        'sala_id' => 'La sala seleccionada no existe.'
                    ]);
                }

                $programa = DB::table('programaestudio')
                    ->where('idProgramaEstudio', $sala->idProgramaEstudio)
                    ->first();

                if (!$programa || !$programa->idCoordinadorArea || !$programa->idAsistenteAreaT1) {
                    throw ValidationException::withMessages([
                        'sala_id' => 'El Programa de Estudio debe tener coordinador y Asistente T1 asignados.'
                    ]);
                }

                $ultimoNumero = DB::table('toma_inventarios')
                    ->where('anio', $datos['anio'])
                    ->lockForUpdate()
                    ->max('numero');

                $nuevoNumero = $ultimoNumero ? $ultimoNumero + 1 : 1;

                $idInventario = DB::table('toma_inventarios')->insertGetId([
                    'anio' => $datos['anio'],
                    'numero' => $nuevoNumero,
                    'sala_id' => $datos['sala_id'],
                    'coordinador_id' => $programa->idCoordinadorArea,
                    'asistente1_id' => $programa->idAsistenteAreaT1,
                    'asistente2_id' => $programa->idAsistenteAreaT2,
                    'fecha_entrega' => $datos['fecha_entrega'] ?? null,
                    'observacion' => $datos['observacion'] ?? null,
                    'estado' => $datos['estado'],
                    'created_at' => now(),
                    'updated_at' => now()
                ]);

                $this->guardarDetallesInventario(
                    $idInventario,
                    $datos['sala_id'],
                    $datos['bienes'] ?? []
                );

                return $idInventario;
            });

            return response()->json([
                'ok' => true,
                'msg' => 'Inventario registrado correctamente.',
                'idInventario' => $idInventario
            ]);
        } catch (ValidationException $e) {
            throw $e;
        } catch (Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error al registrar el inventario: ' . $e->getMessage()
            ], 500);
        }
    }

    public function actualizar(Request $request, $id)
    {
        $datos = $this->validarDatos($request);

        try {
            DB::transaction(function () use ($datos, $id) {
                $inventario = DB::table('toma_inventarios')
                    ->where('id', $id)
                    ->lockForUpdate()
                    ->first();

                if (!$inventario) {
                    throw ValidationException::withMessages([
                        'id' => 'Inventario no encontrado.'
                    ]);
                }

                if ($inventario->estado === 'CERRADO') {
                    throw ValidationException::withMessages([
                        'id' => 'No se puede modificar un inventario cerrado.'
                    ]);
                }

                $sala = DB::table('sala')
                    ->where('idSala', $datos['sala_id'])
                    ->first();

                $programa = $sala
                    ? DB::table('programaestudio')
                        ->where('idProgramaEstudio', $sala->idProgramaEstudio)
                        ->first()
                    : null;

                if (!$programa || !$programa->idCoordinadorArea || !$programa->idAsistenteAreaT1) {
                    throw ValidationException::withMessages([
                        'sala_id' => 'El Programa de Estudio debe tener coordinador y Asistente T1 asignados.'
                    ]);
                }

                $numero = $inventario->numero;

                if ((int) $inventario->anio !== (int) $datos['anio']) {
                    $ultimoNumero = DB::table('toma_inventarios')
                        ->where('anio', $datos['anio'])
                        ->where('id', '<>', $id)
                        ->lockForUpdate()
                        ->max('numero');

                    $numero = $ultimoNumero ? $ultimoNumero + 1 : 1;
                }

                DB::table('toma_inventarios')
                    ->where('id', $id)
                    ->update([
                        'anio' => $datos['anio'],
                        'numero' => $numero,
                        'sala_id' => $datos['sala_id'],
                        'coordinador_id' => $programa->idCoordinadorArea,
                        'asistente1_id' => $programa->idAsistenteAreaT1,
                        'asistente2_id' => $programa->idAsistenteAreaT2,
                        'fecha_entrega' => $datos['fecha_entrega'] ?? null,
                        'observacion' => $datos['observacion'] ?? null,
                        'estado' => $datos['estado'],
                        'updated_at' => now()
                    ]);

                $this->guardarDetallesInventario(
                    $id,
                    $datos['sala_id'],
                    $datos['bienes'] ?? []
                );
            });

            return response()->json([
                'ok' => true,
                'msg' => 'Inventario actualizado correctamente.'
            ]);
        } catch (ValidationException $e) {
            throw $e;
        } catch (Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error al actualizar el inventario: ' . $e->getMessage()
            ], 500);
        }
    }

    public function cerrar($id)
    {
        try {
            $resultado = DB::transaction(function () use ($id) {
                $inventario = DB::table('toma_inventarios')
                    ->where('id', $id)
                    ->lockForUpdate()
                    ->first();

                if (!$inventario) {
                    return [
                        'ok' => false,
                        'status' => 404,
                        'msg' => 'Inventario no encontrado.'
                    ];
                }

                if ($inventario->estado === 'CERRADO') {
                    return [
                        'ok' => false,
                        'status' => 409,
                        'msg' => 'Este inventario ya se encuentra cerrado.'
                    ];
                }

                $bienes = DB::table('bien as b')
                    ->leftJoin('grupo as g', 'b.idGrupo', '=', 'g.idGrupo')
                    ->leftJoin('tipo as t', 'b.idTipo', '=', 't.idTipo')
                    ->leftJoin('marca as ma', 'b.idMarca', '=', 'ma.idMarca')
                    ->leftJoin('modelo as mo', 'b.idModelo', '=', 'mo.idModelo')
                    ->leftJoin('estado as e', 'b.idEstado', '=', 'e.idEstado')
                    ->where('b.idSala', $inventario->sala_id)
                    ->where(function ($query) {
                        $query->where('b.st_registro', 1)
                            ->orWhereNull('b.st_registro');
                    })
                    ->select(
                        'b.idBien',
                        'b.idGrupo',
                        'g.nombre as nombreGrupo',
                        'b.cbi',
                        'b.idTipo',
                        't.nombre as nombreTipo',
                        'b.descripcion',
                        'b.idMarca',
                        'ma.nombre as nombreMarca',
                        'b.idModelo',
                        'mo.nombre as nombreModelo',
                        'b.serieMedida',
                        'b.idEstado',
                        'e.nombre as nombreEstado',
                        'b.otrasEspecificaciones'
                    )
                    ->get();

                foreach ($bienes as $bien) {
                    $existe = DB::table('inventario_detalle')
                        ->where('idInventario', $inventario->id)
                        ->where('idBien', $bien->idBien)
                        ->exists();

                    if (!$existe) {
                        DB::table('inventario_detalle')->insert([
                            'idInventario' => $inventario->id,
                            'idBien' => $bien->idBien,
                            'idGrupo' => $bien->idGrupo,
                            'nombreGrupo' => $bien->nombreGrupo,
                            'nroDRELM' => null,
                            'cbi' => $bien->cbi,
                            'idTipo' => $bien->idTipo,
                            'nombreTipo' => $bien->nombreTipo,
                            'descripcion' => $bien->descripcion,
                            'idMarca' => $bien->idMarca,
                            'nombreMarca' => $bien->nombreMarca,
                            'idModelo' => $bien->idModelo,
                            'nombreModelo' => $bien->nombreModelo,
                            'serieMedida' => $bien->serieMedida,
                            'idEstado' => $bien->idEstado,
                            'nombreEstado' => $bien->nombreEstado,
                            'otrasEspecificaciones' => $bien->otrasEspecificaciones,
                            'st_registro' => 1,
                            'fechaCreacion' => now()
                        ]);
                    }
                }

                DB::table('toma_inventarios')
                    ->where('id', $id)
                    ->update([
                        'estado' => 'CERRADO',
                        'updated_at' => now()
                    ]);

                return [
                    'ok' => true,
                    'status' => 200,
                    'msg' => 'Inventario cerrado, proceda a generar el reporte.'
                ];
            });

            return response()->json([
                'ok' => $resultado['ok'],
                'msg' => $resultado['msg']
            ], $resultado['status']);
        } catch (Exception $e) {
            return response()->json([
                'ok' => false,
                'msg' => 'Error al cerrar el inventario: ' . $e->getMessage()
            ], 500);
        }
    }
}
