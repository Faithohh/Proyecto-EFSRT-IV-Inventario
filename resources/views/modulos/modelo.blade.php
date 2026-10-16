<section class="mp-panel" id="mpModelo" hidden>
    <!-- CABECERA DEL MÓDULO -->
    <div class="mp-panel-header d-flex align-items-center mb-3">
        <svg viewBox="0 0 24 24" width="24" height="24" class="me-2" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
            <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
            <line x1="12" y1="22.08" x2="12" y2="12"></line>
        </svg>
        <h4 class="m-0 font-weight-bold">Gestión de Modelo</h4>
    </div>

    <!-- BARRA DE HERRAMIENTAS -->
    <div class="tb-bar" role="toolbar" aria-label="Acciones de modelo">
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
        <label for="txtBuscarModelo">BUSCAR:</label>
        <input type="text" id="txtBuscarModelo" autocomplete="off" placeholder="Escriba para filtrar...">
    </div>

    <!-- TABLA -->
    <div class="tb-table-wrap">
        <table class="tb-table" id="tblModelo">
            <thead>
                <tr>
                    <th>ID Prog. Estudio</th>
                    <th>Nombre</th>
                    <th>Fecha Creación</th>
                    <th>Fecha Modificación</th>
                    <th>Usuario Crea</th>
                    <th>Usuario Modifica</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td colspan="6" class="text-center">Cargando...</td>
                </tr>
            </tbody>
        </table>
    </div>
</section>

<!-- Modal Único Registrar / Editar / Consultar Modelo (Posicionado ARRIBA) -->
<div class="modal fade" id="modalModelo" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalModeloTitle">Nuevo Modelo</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <form id="formModelo">
                    <input type="hidden" id="txtIdModeloOriginal" value="">
                    
                    <!-- PROGRAMA DE ESTUDIO -->
                    <div class="mb-3">
                        <span>Programa de estudio: <strong id="lblProgramaEstudioModelo">2</strong></span>
                        <input type="hidden" id="txtIdProgramaEstudioModelo" value="2">
                    </div>

                    <!-- NOMBRE DE MODELO HORIZONTAL -->
                    <div class="mb-3 row align-items-center">
                        <label for="txtNombreModelo" class="col-sm-4 col-form-label">Nombre del Modelo:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" id="txtNombreModelo" maxlength="60" autocomplete="off" placeholder="Ej. FLATRON E1942">
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnGuardarModelo">Guardar</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Confirmar Eliminación (Posicionado EN EL MEDIO) -->
<div class="modal fade" id="modalConfirmarEliminarModelo" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Confirmar Eliminación</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <p id="msgConfirmarEliminarModelo">¿Está seguro de eliminar este modelo?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-danger" id="btnConfirmarEliminarModeloAccion">Eliminar</button>
            </div>
        </div>
    </div>
</div>