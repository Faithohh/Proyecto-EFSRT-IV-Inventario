<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ $titulo }} - SIIN</title>
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
    <link rel="stylesheet" href="{{ asset('css/estilos.Principal.css') }}?v={{ time() }}">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>

<body class="mp">
    <header class="mp-top">
        <div class="mp-title"><span class="mp-dot"></span><strong>{{ $titulo }}</strong></div>
        <div class="mp-user"><button type="button" id="btnTema" class="tema-btn" aria-label="Cambiar modo"><svg class="tema-sol" viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="4.2" />
                    <path d="M12 2.8v2.4M12 18.8v2.4M2.8 12h2.4M18.8 12h2.4M4.9 4.9l1.7 1.7M17.4 17.4l1.7 1.7M19.1 4.9l-1.7 1.7M6.6 17.4l-1.7 1.7" />
                </svg><svg class="tema-luna" viewBox="0 0 24 24">
                    <path d="M20.4 14.2A8.5 8.5 0 0 1 9.8 3.6a.7.7 0 0 0-.9-.9 10 10 0 1 0 12.4 12.4.7.7 0 0 0-.9-.9z" />
                </svg></button><span>{{ $usuario }}</span><em>{{ $tipo }}</em><a href="/login">Salir</a></div>
    </header>
    <div class="mp-body">
        <nav class="mp-nav">
            @if($tipo === 'ADMINISTRADOR')
            <div class="mp-item">
                <button type="button" class="mp-link" data-menu="m-sistema"><svg viewBox="0 0 24 24">
                        <rect x="3" y="3" width="7" height="7" rx="1.5" />
                        <rect x="14" y="3" width="7" height="7" rx="1.5" />
                        <rect x="3" y="14" width="7" height="7" rx="1.5" />
                        <rect x="14" y="14" width="7" height="7" rx="1.5" />
                    </svg>Sistema</button>
                <div class="mp-menu" id="m-sistema">
                    <div class="mp-has">
                        <button type="button" class="mp-opt" data-sub="s-archivo"><span>Archivo</span><span class="mp-arrow">›</span></button>
                        <div class="mp-sub" id="s-archivo">
                            <button type="button" class="mp-opt" data-modulo="usuarios">Usuarios</button>
                            <button type="button" class="mp-opt" data-modulo="personal">Personal</button>
                            <button type="button" class="mp-opt">Programa de Estudio</button>
                        </div>
                    </div>
                    <div class="mp-sep"></div>
                    <a class="mp-opt" href="/login"><span class="mp-out"><svg viewBox="0 0 24 24">
                                <path d="M14 4h5v16h-5M10 8l-4 4 4 4M6 12h10" />
                            </svg></span>Salir</a>
                </div>
            </div>
            @endif
            <div class="mp-item">
                <button type="button" class="mp-link" data-menu="m-almacen"><svg viewBox="0 0 24 24">
                        <path d="M3 8l9-4 9 4v8l-9 4-9-4z" />
                        <path d="M3 8l9 4 9-4M12 12v8" />
                    </svg>Almacen</button>
                <div class="mp-menu" id="m-almacen">
                    <div class="mp-has">
                        <button type="button" class="mp-opt" data-sub="s-tablas"><span>Tablas Generales</span><span class="mp-arrow">›</span></button>
                        <div class="mp-sub" id="s-tablas">
                            <button type="button" class="mp-opt">Grupo</button>
                            <button type="button" class="mp-opt">Estado</button>
                            <button type="button" class="mp-opt">Marca</button>
                            <button type="button" class="mp-opt">Modelo</button>
                            <button type="button" class="mp-opt">Sala</button>
                            <button type="button" class="mp-opt">Tipo</button>
                        </div>
                    </div>
                    <div class="mp-sep"></div>
                    <button type="button" class="mp-opt">Bienes</button>
                    <button type="button" class="mp-opt">Toma de Inventario</button>
                    <button type="button" class="mp-opt">Reporte bien</button>
                </div>
            </div>
            <div class="mp-item">
                <a class="mp-link" href="/principal"><svg viewBox="0 0 24 24">
                        <path d="M4 20V10M10 20V4M16 20v-8M22 20H2" />
                    </svg>Reportes</a>
            </div>
            <div class="mp-item">
                <button type="button" class="mp-link" data-menu="m-ventana"><svg viewBox="0 0 24 24">
                        <rect x="2" y="4" width="20" height="13" rx="2" />
                        <path d="M8 21h8M12 17v4" />
                    </svg>Ventana</button>
                <div class="mp-menu" id="m-ventana">
                    <button type="button" class="mp-opt">Mosaico Vertical</button>
                    <button type="button" class="mp-opt">Mosaico Horizontal</button>
                    <button type="button" class="mp-opt">Cascada</button>
                    <button type="button" class="mp-opt">Capas</button>
                    <button type="button" class="mp-opt">Minimizar Todas</button>
                    <button type="button" class="mp-opt">Cerrar Todas</button>
                </div>
            </div>
            <div class="mp-item">
                <button type="button" class="mp-link" data-menu="m-ayuda"><svg viewBox="0 0 24 24">
                        <circle cx="12" cy="12" r="9" />
                        <path d="M9.5 9.5a2.5 2.5 0 0 1 4.9.8c0 1.7-2.4 2-2.4 3.7M12 17h.01" />
                    </svg>Ayuda</button>
                <div class="mp-menu" id="m-ayuda">
                    <button type="button" class="mp-opt">Acerca de..</button>
                </div>
            </div>
        </nav>
        <main class="mp-main">
            <section class="mp-welcome" id="mpBienvenida">
                <h1>Bienvenido, {{ $usuario }}</h1>
                <p>Seleccione una opción del menú lateral para comenzar a trabajar.</p>
                <div class="mp-cards">
                    <div><span>PROGRAMA</span><strong>{{ $programa }}</strong></div>
                    <div><span>TIPO DE USUARIO</span><strong>{{ $tipo }}</strong></div>
                    <div><span>SESIÓN</span><strong>Activa</strong></div>
                </div>
            </section>
            @include('modulos.usuarios')
            @include('modulos.personal')
        </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="{{ asset('js/tema.js') }}?v={{ time() }}"></script>
    <script src="{{ asset('js/principal.js') }}?v={{ time() }}"></script>
    <script src="{{ asset('js/usuarios.js') }}?v={{ time() }}"></script>
    <script src="{{ asset('js/personal.js') }}?v={{ time() }}"></script>
</body>

</html>