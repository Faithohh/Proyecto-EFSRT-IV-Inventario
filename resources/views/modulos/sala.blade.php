<section class="mp-panel" id="mpSala" hidden>
    <!-- CABECERA DEL MÓDULO (Icono Puerta / Salón) -->
    <div class="mp-panel-header d-flex align-items-center mb-3">
        <svg viewBox="0 0 24 24" width="24" height="24" class="me-2" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M13 4h3a2 2 0 0 1 2 2v14"></path>
            <path d="M2 20h20"></path>
            <path d="M13 20V4a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v16"></path>
            <circle cx="9.5" cy="11.5" r="0.5" fill="currentColor"></circle>
        </svg>
        <h4 class="m-0 font-weight-bold">Gestión de Sala</h4>
    </div>

    <!-- BARRA DE HERRAMIENTAS -->
    <div class="tb-bar" role="toolbar" aria-label="Acciones de sala">
        <button type="button" class="tb-btn" data-acc="nuevo" title="Nuevo"><svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg></button>
        <button type="button" class="tb-btn" data-acc="editar" title="Editar"><svg viewBox="0 0 24 24"><path d="M4 20h4L19.5 8.5a2.1 2.1 0 0 0-3-3L5 17v3z"/><path d="M13.5 6.5l3 3"/></svg></button>
        <button type="button" class="tb-btn" data-acc="eliminar" title="Eliminar"><svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"/></svg></button>
        <button type="button" class="tb-btn" data-acc="recargar" title="Recargar"><svg viewBox="0 0 24 24"><path d="M20 12a8 8 0 1 1-2.3-5.6M20 4v4h-4"/></svg></button>
        <button type="button" class="tb-btn" data-acc="imprimir" title="Ver Detalle"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg></button>
        <button type="button" class="tb-btn tb-xls" data-acc="excel" title="Excel"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M9 9.5l6 5M15 9.5l-6 5"/></svg><span>X</span></button>
        <button type="button" class="tb-btn" data-acc="salir" title="Salir"><svg viewBox="0 0 24 24"><path d="M14 4h5v16h-5M10 8l-4 4 4 4M6 12h10"/></svg></button>
    </div>

    <!-- BUSCADOR -->
    <div class="tb-search">
        <label for="txtBuscarSala">BUSCAR:</label>
        <input type="text" id="txtBuscarSala" autocomplete="off" placeholder="Escriba para filtrar...">
    </div>

    <!-- TABLA DE SALAS -->
    <div class="tb-table-wrap">
        <table class="tb-table" id="tblSala">
            <thead>
                <tr>
                    <th>Nombre</th>
                    <th>Observación</th>
                    <th>Fecha Creación</th>
                    <th>Fecha Modificación</th>
                    <th>Usuario Crea</th>
                    <th>Usuario Modifica</th>
                </tr>
            </thead>
            <tbody><tr><td colspan="6" class="text-center">Cargando...</td></tr></tbody>
        </table>
    </div>
</section>

<!-- Modal Registrar / Editar / Consultar Sala (Posicionado Arriba) -->
<div class="modal fade" id="modalSala" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalSalaTitle">Nueva Sala</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <form id="formSala">
                    <input type="hidden" id="txtIdSalaOriginal" value="">
                    
                    <!-- Programa de Estudio -->
                    <div class="row mb-3 align-items-center">
                        <div class="col-12 text-start">
                            <span class="fw-bold">Programa de estudio: </span>
                            <span id="lblProgramaEstudioSala" class="fw-bold">2</span>
                        </div>
                    </div>

                    <!-- Nombre de Sala -->
                    <div class="row mb-3 align-items-center">
                        <label for="txtNombreSala" class="col-sm-4 col-form-label text-sm-end fw-bold">Nombre de Sala:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" id="txtNombreSala" maxlength="60" required autocomplete="off" placeholder="Ej. Aula 102">
                        </div>
                    </div>

                    <!-- Observación -->
                    <div class="row mb-3 align-items-start">
                        <label for="txtObservacionSala" class="col-sm-4 col-form-label text-sm-end fw-bold">Observacion:</label>
                        <div class="col-sm-8">
                            <textarea class="form-control" id="txtObservacionSala" rows="3" maxlength="200" placeholder="Ingrese una observación opcional..."></textarea>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnGuardarSala">Guardar</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Detalle de la Sala (Posicionado Arriba) -->
<div class="modal fade" id="modalDetalleSala" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Detalle de la Sala</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <table class="table table-bordered mb-0">
                    <tbody>
                        <tr><th>ID</th><td class="det-idSala"></td></tr>
                        <tr><th>Nombre</th><td class="det-nombre"></td></tr>
                        <tr><th>Observación</th><td class="det-observacion"></td></tr>
                        <tr><th>Estado</th><td class="det-estado"></td></tr>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Eliminar Sala (Centrado al Medio) -->
<div class="modal fade" id="modalEliminarSala" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Confirmar Eliminación</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <p>¿Está seguro de eliminar la sala <strong id="txtSalaEliminar"></strong>?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-danger" id="btnConfirmarEliminarSala">Eliminar</button>
            </div>
        </div>
    </div>
</div>