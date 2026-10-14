<section class="mp-panel" id="mpTomaInventario" hidden>
    <!-- CABECERA -->
    <div class="mp-panel-header d-flex align-items-center mb-3">
        <svg viewBox="0 0 24 24" width="24" height="24" class="me-2" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2"></path>
            <rect x="9" y="3" width="6" height="4" rx="1"></rect>
            <path d="M9 14l2 2 4-4"></path>
        </svg>
        <h4 class="m-0 font-weight-bold">Toma de Inventario</h4>
    </div>

    <!-- BARRA DE HERRAMIENTAS -->
    <div class="tb-bar" role="toolbar" aria-label="Acciones de inventario">
        <button type="button" class="tb-btn" data-acc="nuevo" title="Nuevo"><svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg></button>
        <button type="button" class="tb-btn" data-acc="editar" title="Editar"><svg viewBox="0 0 24 24"><path d="M4 20h4L19.5 8.5a2.1 2.1 0 0 0-3-3L5 17v3z"/><path d="M13.5 6.5l3 3"/></svg></button>
        <button type="button" class="tb-btn" data-acc="eliminar" title="Eliminar"><svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"/></svg></button>
        <button type="button" class="tb-btn" data-acc="recargar" title="Recargar"><svg viewBox="0 0 24 24"><path d="M20 12a8 8 0 1 1-2.3-5.6M20 4v4h-4"/></svg></button>
        <button type="button" class="tb-btn" data-acc="imprimir" title="Ver Detalle"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg></button>
        <button type="button" class="tb-btn tb-xls" data-acc="excel" title="Excel"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M9 9.5l6 5M15 9.5l-6 5"/></svg><span>X</span></button>
        <button type="button" class="tb-btn" data-acc="salir" title="Salir"><svg viewBox="0 0 24 24"><path d="M14 4h5v16h-5M10 8l-4 4 4 4M6 12h10"/></svg></button>
    </div>

    <!-- BUSCADOR -->
    <div class="tb-search">
        <label for="txtBuscarInventario">BUSCAR:</label>
        <input type="text" id="txtBuscarInventario" autocomplete="off" placeholder="Escriba para filtrar...">
    </div>

    <!-- TABLA DE INVENTARIOS -->
    <div class="tb-table-wrap">
        <table class="tb-table" id="tblInventarios">
            <thead>
                <tr>
                    <th>INVENTARIO</th>
                    <th>SALA</th>
                    <th>COORDINADOR</th>
                    <th>ASISTENTE T1</th>
                    <th>ASISTENTE T2</th>
                    <th>FECHA ENTREGA</th>
                    <th>OBSERVACION</th>
                    <th>CANTIDAD DE BIENES</th>
                    <th>ESTADO</th>
                </tr>
            </thead>
            <tbody>
                <tr><td colspan="9" class="text-center">Cargando...</td></tr>
            </tbody>
        </table>
    </div>
</section>

<!-- MODAL NUEVO INVENTARIO -->
<div class="modal fade" id="modalInventario" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalInventarioTitle">NUEVO Inventario</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <form id="formInventario">
                    <input type="hidden" id="txtIdInventarioOriginal" value="">
                    
                    <fieldset class="border p-3 rounded mb-3">
                        <legend class="float-none w-auto px-2 fs-6 fw-bold">DATOS GENERALES:</legend>
                        
                        <div class="row g-3">
                            <div class="col-md-6">
                                <div class="d-flex align-items-center">
                                    <label for="txtSerie" class="form-label me-2 mb-0 fw-bold" style="white-space: nowrap;">Inventario:</label>
                                    <input type="text" class="form-control me-1" id="txtSerie" placeholder="2026" style="width: 80px;">
                                    <input type="text" class="form-control" id="txtNumero" placeholder="1">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="d-flex align-items-center">
                                    <label for="cboEstadoInventario" class="form-label me-2 mb-0 fw-bold">Estado:</label>
                                    <select class="form-select" id="cboEstadoInventario">
                                        <option value="ABIERTO">ABIERTO</option>
                                        <option value="CERRADO">CERRADO</option>
                                    </select>
                                </div>
                            </div>

                            <div class="col-md-12">
                                <div class="row align-items-center mb-2">
                                    <label for="cboSalaInventario" class="col-sm-2 col-form-label fw-bold">Sala:</label>
                                    <div class="col-sm-4">
                                        <select class="form-select" id="cboSalaInventario"></select>
                                    </div>
                                    <label for="cboCoordinador" class="col-sm-2 col-form-label fw-bold">Coordinador:</label>
                                    <div class="col-sm-4">
                                        <select class="form-select" id="cboCoordinador"></select>
                                    </div>
                                </div>

                                <div class="row align-items-center mb-2">
                                    <label for="txtFechaEntrega" class="col-sm-2 col-form-label fw-bold">Fecha Entrega:</label>
                                    <div class="col-sm-4">
                                        <input type="date" class="form-control" id="txtFechaEntrega">
                                    </div>
                                    <label for="cboAsistente1" class="col-sm-2 col-form-label fw-bold">Asistente T1:</label>
                                    <div class="col-sm-4">
                                        <select class="form-select" id="cboAsistente1"></select>
                                    </div>
                                </div>

                                <div class="row align-items-center">
                                    <label for="txtObservacionInventario" class="col-sm-2 col-form-label fw-bold">Observación:</label>
                                    <div class="col-sm-4">
                                        <input type="text" class="form-control" id="txtObservacionInventario">
                                    </div>
                                    <label for="cboAsistente2" class="col-sm-2 col-form-label fw-bold">Asistente T2:</label>
                                    <div class="col-sm-4">
                                        <select class="form-select" id="cboAsistente2"></select>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </fieldset>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnGuardarInventario">Guardar</button>
            </div>
        </div>
    </div>
</div>