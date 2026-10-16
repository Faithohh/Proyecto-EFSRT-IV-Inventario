<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use Symfony\Component\HttpFoundation\Response;

class VerificarSesion
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!Session::has('idUsuario')) {
            $response = redirect()->route('login');
        } else {
            $response = $next($request);
        }

        $response->headers->set('Cache-Control', 'no-cache, no-store, max-age=0, must-revalidate');
        $response->headers->set('Pragma', 'no-cache');
        $response->headers->set('Expires', 'Sat, 01 Jan 1990 00:00:00 GMT');

        return $response;
    }
}
