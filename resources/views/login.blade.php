<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Acceder al Sistema - SIIN</title>
    <script>
        (function() {
            try {
                var t = localStorage.getItem("siin-tema");
                if (t === "light" || t === "dark") document.documentElement.dataset.theme = t;
                else document.documentElement.dataset.theme = "dark"
            } catch (e) {
                document.documentElement.dataset.theme = "dark"
            }
        })();
    </script>
    <link rel="stylesheet" href="{{ asset('css/estilos.Login.min.css') }}?v={{ time() }}">
    <!-- SweetAlert2 CSS CDN -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
</head>

<body class="mn">
    <button type="button" id="btnTema" class="tema-btn" aria-label="Cambiar modo"><svg class="tema-sol" viewBox="0 0 24 24">
            <circle cx="12" cy="12" r="4.2" />
            <path d="M12 2.8v2.4M12 18.8v2.4M2.8 12h2.4M18.8 12h2.4M4.9 4.9l1.7 1.7M17.4 17.4l1.7 1.7M19.1 4.9l-1.7 1.7M6.6 17.4l-1.7 1.7" />
        </svg><svg class="tema-luna" viewBox="0 0 24 24">
            <path d="M20.4 14.2A8.5 8.5 0 0 1 9.8 3.6a.7.7 0 0 0-.9-.9 10 10 0 1 0 12.4 12.4.7.7 0 0 0-.9-.9z" />
        </svg></button>
    <div class="mn-card">
        <div class="mn-logo">S</div>
        <p class="mn-eyebrow">SISTEMA DE INVENTARIOS</p>
        <h1>Bienvenido</h1>
        <p class="mn-sub">Ingrese sus credenciales para continuar</p>
        <form id="formLogin" onsubmit="return false;">
            @csrf
            <div class="mn-f">
                <label for="txt_usuario">USUARIO</label>
                <input type="text" id="txt_usuario" name="usuario" autocomplete="off" placeholder="Ingrese su usuario" required autofocus>
            </div>
            <div class="mn-f">
                <label for="txt_contraseña">CONTRASEÑA</label>
                <input type="password" id="txt_contraseña" name="contrasena" placeholder="Ingrese su contraseña" required>
            </div>
            <div class="mn-f" id="gbx_programaEstudio" style="display:none;">
                <label for="cbx_programaEstudio">PROGRAMA DE ESTUDIO</label>
                <select id="cbx_programaEstudio" name="programa"></select>
            </div>
            <button type="button" id="btn_ingresar" class="mn-btn mn-btn-p" disabled>INGRESAR</button>
            <button type="button" id="btn_cancelar" class="mn-btn mn-btn-g">CANCELAR</button>
        </form>
        <p class="mn-foot">&copy; {{ date('Y') }} SIIN</p>
    </div>

    <!-- SweetAlert2 JS CDN -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="{{ asset('js/alert.js') }}?v={{ time() }}"></script>
    <script src="{{ asset('js/tema.js') }}?v={{ time() }}"></script>
    <script src="{{ asset('js/login.js') }}?v={{ time() }}"></script>
</body>

</html>