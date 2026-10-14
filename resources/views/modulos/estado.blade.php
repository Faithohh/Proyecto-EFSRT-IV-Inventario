<section class="mp-panel" id="mpEstado" hidden>
    <!-- Cabecera del Módulo -->
    <div class="mp-panel-header d-flex align-items-center mb-3">
        <svg viewBox="0 0 24 24" width="24" height="24" class="me-2" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
            <polyline points="22 4 12 14.01 9 11.01"></polyline>
        </svg>
        <h4 class="m-0 font-weight-bold">Gestión de Estado</h4>
    </div>

    <div class="tb-bar" role="toolbar" aria-label="Acciones de estado">
        <button type="button" class="tb-btn" data-acc="nuevo" title="Nuevo" disabled style="opacity: 0.5; cursor: not-allowed;"><svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg></button>
        <button type="button" class="tb-btn" data-acc="editar" title="Editar" disabled style="opacity: 0.5; cursor: not-allowed;"><svg viewBox="0 0 24 24"><path d="M4 20h4L19.5 8.5a2.1 2.1 0 0 0-3-3L5 17v3z"/><path d="M13.5 6.5l3 3"/></svg></button>
        <button type="button" class="tb-btn" data-acc="eliminar" title="Eliminar" disabled style="opacity: 0.5; cursor: not-allowed;"><svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"/></svg></button>
        
        <button type="button" class="tb-btn" data-acc="recargar" title="Recargar"><svg viewBox="0 0 24 24"><path d="M20 12a8 8 0 1 1-2.3-5.6M20 4v4h-4"/></svg></button>
        <button type="button" class="tb-btn" data-acc="imprimir" title="Ver Detalle"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg></button>
        <button type="button" class="tb-btn tb-xls" data-acc="excel" title="Excel"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M9 9.5l6 5M15 9.5l-6 5"/></svg><span>X</span></button>
        <button type="button" class="tb-btn" data-acc="salir" title="Salir"><svg viewBox="0 0 24 24"><path d="M14 4h5v16h-5M10 8l-4 4 4 4M6 12h10"/></svg></button>
    </div>

    <div class="tb-search">
        <label for="txtBuscarEstado">BUSCAR:</label>
        <input type="text" id="txtBuscarEstado" autocomplete="off" placeholder="Escriba para filtrar...">
    </div>

    <div class="tb-table-wrap">
        <table class="tb-table" id="tblEstado">
            <thead>
                <tr><th>nombre</th></tr>
            </thead>
            <tbody><tr><td class="text-center">Cargando...</td></tr></tbody>
        </table>
    </div>
</section>

<div class="modal fade" id="modalEstado" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalEstadoTitle">Nuevo Estado</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <form id="formEstado">
                    <input type="hidden" id="txtIdEstadoOriginal" value="">
                    <div class="mb-3">
                        <label for="txtNombreEstado" class="form-label">Nombre</label>
                        <input type="text" class="form-control" id="txtNombreEstado" maxlength="50" required disabled>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnGuardarEstado" disabled>Guardar</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalDetalleEstado" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Detalle del Estado</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <table class="table table-bordered mb-0">
                    <tbody>
                        <tr><th style="width: 30%;">Nombre</th><td class="det-nombre"></td></tr>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>