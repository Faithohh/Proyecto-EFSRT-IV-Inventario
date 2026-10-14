<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Session;
use App\Http\Controllers\Login;
use App\Http\Controllers\UsuarioController;
use App\Http\Controllers\PersonalController;

Route::redirect('/', '/login');

Route::get('/login', [Login::class, 'index'])->name('login');
Route::post('/login/acceso', [Login::class, 'validarAcceso'])->name('login.acceso');
Route::post('/login/sesion', [Login::class, 'crearSesion'])->name('login.sesion');
Route::post('/login', [Login::class, 'validarAcceso']);

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