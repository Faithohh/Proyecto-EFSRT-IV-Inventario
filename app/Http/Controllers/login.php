<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LoginController extends Controller
{
    public function validarAcceso(Request $request)
    {
        $usuario = $request->input('usuario');
        $clave = $request->input('contrasena');

        // Llamada al Stored Procedure traducido
        $resultado = DB::select("CALL sp_login_acceso_Q01(?, ?, @p_valid)", [$usuario, $clave]);
        $validOutput = DB::select("SELECT @p_valid AS valid")[0]->valid;

        // Si el login es correcto (@p_valid es vacío o "1")
        if (empty($validOutput) || $validOutput == "1") {
            // Consulta de programas de estudio asignados
            $programas = DB::select("CALL sp_login_programasEstudio(?)", [$usuario]);

            return response()->json([
                'valid' => '1',
                'programas' => $programas
            ]);
        }

        return response()->json([
            'valid' => $validOutput
        ]);
    }

    public function iniciarSesion(Request $request)
    {
        // Guardar variables en la sesión de Laravel
        session([
            'idUsuario' => $request->input('idUsuario'),
            'idProgramaEstudio' => $request->input('idProgramaEstudio')
        ]);

        return response()->json([
            'success' => true,
            'redirectUrl' => route('principal') // Asegúrate de tener esta ruta definida
        ]);
    }
}
