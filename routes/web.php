<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Session;
use App\Http\Controllers\Login;
use App\Http\Controllers\UsuarioController;
use App\Http\Controllers\PersonalController;
use App\Http\Controllers\GrupoController;
use App\Http\Controllers\EstadoController;
use App\Http\Controllers\MarcaController;
use App\Http\Controllers\ModeloController;
use App\Http\Controllers\SalaController;
use App\Http\Controllers\TipoController;
use App\Http\Controllers\ProgramaEstudioController;
use App\Http\Controllers\BienController;
use App\Http\Controllers\InventarioController;
use App\Http\Controllers\ReporteController;


Route::get('/inventario/exportar-excel/{id}', [InventarioController::class, 'exportarExcel']);

Route::get('/inventario/mostrar/{id}', [InventarioController::class, 'mostrar']);
Route::put('/inventario/actualizar/{id}', [InventarioController::class, 'actualizar']);
Route::get('/inventario/listar', [InventarioController::class, 'listar']);
Route::post('/inventario/guardar', [InventarioController::class, 'guardar']);


// Rutas de Módulo Reportes
Route::get('/reportes', [ReporteController::class, 'index'])->name('reportes.index');
Route::get('/reportes/inventarios', [ReporteController::class, 'listarInventarios'])->name('reportes.inventarios');
Route::get('/reportes/informe/{idInventario}', [ReporteController::class, 'generarInforme'])->name('reportes.informe');


Route::redirect('/', '/login');


Route::get('/login', [Login::class, 'index'])->name('login');
Route::post('/login/acceso', [Login::class, 'validarAcceso'])->name('login.acceso');
Route::post('/login/sesion', [Login::class, 'crearSesion'])->name('login.sesion');


Route::get('/principal', function () {
    $titulo = str_replace('2025', '2026', Session::get('tituloSesion', 'SIIN'));

    return view('principal', [
        'titulo'   => $titulo,
        'usuario'  => Session::get('idUsuario', ''),
        'tipo'     => Session::get('tipoUsuario', ''),
        'programa' => Session::get('idProgramaEstudio', ''),
    ]);
})->name('principal');


// Rutas de Módulo Usuarios
Route::get('/usuarios', function () {
    return view('modulos.usuarios');
})->name('usuarios.index');

Route::get('/usuarios/listar', [UsuarioController::class, 'listar'])->name('usuarios.listar');
Route::get('/usuarios/personal', [UsuarioController::class, 'listarPersonal'])->name('usuarios.personal');
Route::get('/usuarios/buscar/{idUsuario}', [UsuarioController::class, 'buscar'])->name('usuarios.buscar');
Route::post('/usuarios/guardar', [UsuarioController::class, 'guardar'])->name('usuarios.guardar');
Route::post('/usuarios/eliminar', [UsuarioController::class, 'eliminar'])->name('usuarios.eliminar');


// Rutas de Módulo Personal
Route::get('/personal', function () {
    return view('modulos.personal');
})->name('personal.index');

Route::get('/personal/listar', [PersonalController::class, 'listar'])->name('personal.listar');
Route::get('/personal/buscar/{idPersonal}', [PersonalController::class, 'buscar'])->name('personal.buscar');
Route::post('/personal/guardar', [PersonalController::class, 'guardar'])->name('personal.guardar');
Route::delete('/personal/eliminar/{idPersonal}', [PersonalController::class, 'eliminar'])->name('personal.eliminar');


// Rutas de Módulo Grupo
Route::get('/grupo', function () {
    return view('modulos.grupo');
})->name('grupo.index');

Route::get('/grupo/listar', [GrupoController::class, 'listar'])->name('grupo.listar');
Route::get('/grupo/buscar/{idGrupo}', [GrupoController::class, 'buscar'])->name('grupo.buscar');
Route::post('/grupo/guardar', [GrupoController::class, 'guardar'])->name('grupo.guardar');
Route::post('/grupo/eliminar', [GrupoController::class, 'eliminar'])->name('grupo.eliminar');


// Rutas de Módulo Estado
Route::get('/estado', function () {
    return view('modulos.estado');
})->name('estado.index');

Route::get('/estado/listar', [EstadoController::class, 'listar'])->name('estado.listar');
Route::get('/estado/buscar/{idEstado}', [EstadoController::class, 'buscar'])->name('estado.buscar');
Route::post('/estado/guardar', [EstadoController::class, 'guardar'])->name('estado.guardar');
Route::post('/estado/eliminar', [EstadoController::class, 'eliminar'])->name('estado.eliminar');


// Rutas de Módulo Marca
Route::get('/marca', function () {
    return view('modulos.marca');
})->name('marca.index');

Route::get('/marca/listar', [MarcaController::class, 'listar'])->name('marca.listar');
Route::get('/marca/buscar/{idMarca}', [MarcaController::class, 'buscar'])->name('marca.buscar');
Route::post('/marca/guardar', [MarcaController::class, 'guardar'])->name('marca.guardar');
Route::post('/marca/eliminar', [MarcaController::class, 'eliminar'])->name('marca.eliminar');


// Endpoints del Módulo Modelo
Route::get('/modelo', function () {
    return view('modulos.modelo');
})->name('modelo.index');

Route::get('/modelo/listar', [ModeloController::class, 'listar'])->name('modelo.listar');
Route::get('/modelo/buscar/{idModelo}', [ModeloController::class, 'buscar'])->name('modelo.buscar');
Route::post('/modelo/guardar', [ModeloController::class, 'guardar'])->name('modelo.guardar');
Route::post('/modelo/eliminar', [ModeloController::class, 'eliminar'])->name('modelo.eliminar');


// Rutas de Módulo Sala
Route::get('/sala', function () {
    return view('modulos.sala');
})->name('sala.index');

Route::get('/sala/listar', [SalaController::class, 'listar'])->name('sala.listar');
Route::get('/sala/buscar/{idSala}', [SalaController::class, 'buscar'])->name('sala.buscar');
Route::post('/sala/guardar', [SalaController::class, 'guardar'])->name('sala.guardar');
Route::post('/sala/eliminar', [SalaController::class, 'eliminar'])->name('sala.eliminar');


// Rutas de Módulo Tipo
Route::get('/tipo', function () {
    return view('modulos.tipo');
})->name('tipo.index');

Route::get('/tipo/listar', [TipoController::class, 'listar'])->name('tipo.listar');
Route::get('/tipo/buscar/{idTipo}', [TipoController::class, 'buscar'])->name('tipo.buscar');
Route::post('/tipo/guardar', [TipoController::class, 'guardar'])->name('tipo.guardar');
Route::post('/tipo/eliminar', [TipoController::class, 'eliminar'])->name('tipo.eliminar');


// Rutas de Módulo Programa de Estudio
Route::get('/programa-estudio', function () {
    return view('modulos.programaestudio');
})->name('programa.index');

Route::get('/programa-estudio/listar', [ProgramaEstudioController::class, 'listar'])->name('programa.listar');
Route::get('/programa-estudio/usuarios', [ProgramaEstudioController::class, 'listarUsuarios'])->name('programa.usuarios');
Route::get('/programa-estudio/buscar/{idProgramaEstudio}', [ProgramaEstudioController::class, 'buscar'])->name('programa.buscar');
Route::post('/programa-estudio/guardar', [ProgramaEstudioController::class, 'guardar'])->name('programa.guardar');
Route::delete('/programa-estudio/eliminar/{idProgramaEstudio}', [ProgramaEstudioController::class, 'eliminar'])->name('programa.eliminar');


// Rutas de Módulo Bienes
Route::get('/bienes', function () {
    return view('modulos.bienes');
})->name('bienes.index');

Route::get('/bienes/listar', [BienController::class, 'listar'])->name('bienes.listar');
Route::get('/bienes/salas', [BienController::class, 'listarSalas'])->name('bienes.salas');
Route::get('/bienes/combos', [BienController::class, 'cargarCombos'])->name('bienes.combos');
Route::get('/bienes/buscar/{idBien}', [BienController::class, 'buscar'])->name('bienes.buscar');
Route::post('/bienes/guardar', [BienController::class, 'guardar'])->name('bienes.guardar');
Route::post('/bienes/eliminar', [BienController::class, 'eliminar'])->name('bienes.eliminar');