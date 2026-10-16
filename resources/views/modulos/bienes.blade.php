<style>
    #mpBien, .mp-panel {
        max-width: 100% !important;
        overflow: hidden !important; 
    }

    .tb-table-wrap {
        width: 100% !important;
        max-height: calc(100vh - 220px) !important; /* Limita la altura para no empujar la pantalla */
        overflow-x: auto !important;
        overflow-y: auto !important;
        display: block !important;
        border-radius: 6px;
        position: relative;
    }

    .tb-table {
        width: 100% !important;
        min-width: 1700px !important;
        border-collapse: separate !important;
        border-spacing: 0;
        table-layout: auto !important;
    }

    .tb-table thead th {
        position: sticky !important;
        top: 0 !important;
        z-index: 10 !important;
        background-color: #0f172a !important; 
        box-shadow: 0 1px 2px rgba(0,0,0,0.5);
    }

    .tb-table th, 
    .tb-table td {
        white-space: nowrap !important;
        padding: 8px 12px !important;
    }

    .tb-table-wrap::-webkit-scrollbar {
        height: 12px !important; 
        width: 10px !important;  
    }

    .tb-table-wrap::-webkit-scrollbar-track {
        background: #0d131f !important;
    }

    .tb-table-wrap::-webkit-scrollbar-thumb {
        background: #334155 !important;
        border-radius: 6px !important;
        border: 2px solid #0d131f !important;
    }

    .tb-table-wrap::-webkit-scrollbar-thumb:hover {
        background: #3b82f6 !important; 
    }
</style>

<section class="mp-panel" id="mpBien" hidden>
    <!-- Cabecera del Módulo -->
    <div class="mp-panel-header d-flex align-items-center mb-3">
        <svg viewBox="0 0 24 24" width="24" height="24" class="me-2" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
            <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
            <line x1="12" y1="22.08" x2="12" y2="12"></line>
        </svg>
        <h4 class="m-0 font-weight-bold">Gestión de Bienes</h4>
    </div>

    <!-- Barra de Herramientas -->
    <div class="tb-bar" role="toolbar" aria-label="Acciones de bienes">
        <button type="button" class="tb-btn" data-acc="nuevo" title="Nuevo"><svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg></button>
        <button type="button" class="tb-btn" data-acc="editar" title="Editar"><svg viewBox="0 0 24 24"><path d="M4 20h4L19.5 8.5a2.1 2.1 0 0 0-3-3L5 17v3z"/><path d="M13.5 6.5l3 3"/></svg></button>
        <button type="button" class="tb-btn" data-acc="eliminar" title="Eliminar"><svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"/></svg></button>
        <button type="button" class="tb-btn" data-acc="recargar" title="Recargar"><svg viewBox="0 0 24 24"><path d="M20 12a8 8 0 1 1-2.3-5.6M20 4v4h-4"/></svg></button>
        <button type="button" class="tb-btn" data-acc="imprimir" title="Ver Detalle"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg></button>
        <button type="button" class="tb-btn tb-xls" data-acc="excel" title="Excel"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M9 9.5l6 5M15 9.5l-6 5"/></svg><span>X</span></button>
        <button type="button" class="tb-btn" data-acc="salir" title="Salir"><svg viewBox="0 0 24 24"><path d="M14 4h5v16h-5M10 8l-4 4 4 4M6 12h10"/></svg></button>
    </div>

    <!-- Buscador y Filtro por Sala -->
    <div class="tb-search d-flex align-items-center gap-3">
        <div class="flex-grow-1 d-flex align-items-center gap-2">
            <label for="txtBuscarBien" class="m-0 fw-bold">BUSCAR:</label>
            <input type="text" id="txtBuscarBien" autocomplete="off" placeholder="Escriba para filtrar...">
        </div>
        <div class="d-flex align-items-center gap-2 ms-auto">
            <label for="cboFiltroSala" class="m-0 fw-bold">Sala:</label>
            <select id="cboFiltroSala" class="form-select form-select-sm w-auto">
                <option value="">-- TODAS LAS SALAS --</option>
            </select>
        </div>
    </div>

    <!-- Tabla con Scroll Fijo -->
    <div class="tb-table-wrap">
        <table class="tb-table" id="tblBien">
            <thead>
                <tr>
                    <th>cbi</th>
                    <th>descripcion</th>
                    <th>Tipo</th>
                    <th>Marca</th>
                    <th>Modelo</th>
                    <th>Estado</th>
                    <th>Grupo</th>
                    <th>serieMedida</th>
                    <th>otrasEspecificaciones</th>
                    <th>fechaCreacion</th>
                    <th>fechaModificacion</th>
                    <th>idUsuarioCrea</th>
                    <th>idUsuarioModifica</th>
                </tr>
            </thead>
            <tbody id="tbody_bien">
                <tr><td colspan="13" class="text-center">Cargando...</td></tr>
            </tbody>
        </table>
    </div>
</section>

<!-- Modal Registrar / Editar Bien -->
<div class="modal fade" id="modalBien" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalBienTitle">Nuevo Bien</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <form id="formBien">
                    <input type="hidden" id="txtIdBienOriginal" name="idBien" value="">
                    <div class="row g-2">
                        <div class="col-md-4">
                            <label class="form-label">CBI</label>
                            <input type="text" class="form-control form-control-sm" name="cbi" id="txtCbi" placeholder="Ej. CBI-2024-001" autocomplete="off">
                        </div>
                        <div class="col-md-8">
                            <label class="form-label">Descripción</label>
                            <input type="text" class="form-control form-control-sm" name="descripcion" id="txtDescripcionBien" placeholder="Ej. Monitor LED 24 pulgadas" autocomplete="off">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Serie / Medida</label>
                            <input type="text" class="form-control form-control-sm" name="serieMedida" id="txtSerieMedida" placeholder="Ej. SN-8930214 / 24 Pulgadas" autocomplete="off">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Otras Especificaciones</label>
                            <input type="text" class="form-control form-control-sm" name="otrasEspecificaciones" id="txtOtrasEspecificaciones" placeholder="Ej. Incluye cable HDMI y fuente de poder" autocomplete="off">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Sala</label>
                            <select class="form-select form-select-sm" name="idSala" id="cboSala"></select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Grupo</label>
                            <select class="form-select form-select-sm" name="idGrupo" id="cboGrupo"></select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Tipo</label>
                            <select class="form-select form-select-sm" name="idTipo" id="cboTipo"></select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Marca</label>
                            <select class="form-select form-select-sm" name="idMarca" id="cboMarca"></select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Modelo</label>
                            <select class="form-select form-select-sm" name="idModelo" id="cboModelo"></select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Estado</label>
                            <select class="form-select form-select-sm" name="idEstado" id="cboEstado"></select>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnGuardarBien">Guardar</button>
            </div>
        </div>
    </div>
</div>