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
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold" id="modalInventarioTitle">NUEVO Inventario</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>

            <div class="modal-body">
                <form id="formInventario">
                    <input type="hidden" id="txtIdInventarioOriginal" value="">

                    <!-- DATOS GENERALES -->
                    <div class="p-3 mb-4">
                        <h6 class="fw-bold mb-3">DATOS GENERALES:</h6>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="txtSerie" class="form-label fw-bold">Inventario:</label>
                                <div class="input-group">
                                    <input type="number" class="form-control" id="txtSerie" min="2000" max="9999" placeholder="Año" style="max-width: 130px;">
                                    <span class="input-group-text">-</span>
                                    <input type="number" class="form-control" id="txtNumero" placeholder="N.º" readonly>
                                </div>
                            </div>

                            <div class="col-md-6">
                                <label for="cboEstadoInventario" class="form-label fw-bold">Estado:</label>
                                <select class="form-select" id="cboEstadoInventario">
                                    <option value="ABIERTO" selected>ABIERTO</option>
                                    <option value="CERRADO">CERRADO</option>
                                </select>
                            </div>

                            <!-- SALA -->
                            <div class="col-md-6">
                                <label for="cboSalaInventario" class="form-label fw-bold">Sala:</label>
                                <select class="form-select" id="cboSalaInventario">
                                    <option value="">Seleccione una sala...</option>
                                </select>
                            </div>

                            <div class="col-md-6">
                                <label for="txtCoordinador" class="form-label fw-bold">Coordinador:</label>
                                <input type="text" class="form-control" id="txtCoordinador" placeholder="Se asignará automáticamente" readonly>
                                <input type="hidden" id="cboCoordinador">
                            </div>

                            <div class="col-md-6">
                                <label for="txtFechaEntrega" class="form-label fw-bold">Fecha Entrega:</label>
                                <input type="date" class="form-control" id="txtFechaEntrega">
                            </div>

                            <div class="col-md-6">
                                <label for="txtAsistente1" class="form-label fw-bold">Asistente T1:</label>
                                <input type="text" class="form-control" id="txtAsistente1" placeholder="Se asignará automáticamente" readonly>
                                <input type="hidden" id="cboAsistente1">
                            </div>

                            <div class="col-md-6">
                                <label for="txtObservacionInventario" class="form-label fw-bold">Observación:</label>
                                <input type="text" class="form-control" id="txtObservacionInventario" placeholder="Ingrese una observación">
                            </div>

                            <div class="col-md-6">
                                <label for="txtAsistente2" class="form-label fw-bold">Asistente T2:</label>
                                <input type="text" class="form-control" id="txtAsistente2" placeholder="Sin asignar" readonly>
                                <input type="hidden" id="cboAsistente2">
                            </div>
                        </div>
                    </div>

                    <!-- BIENES DEL INVENTARIO -->
                    <div class="p-3">
                        <h6 class="fw-bold mb-3">BIENES DEL INVENTARIO:</h6>

                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                            <span class="text-muted small">Seleccione una sala para cargar automáticamente sus bienes.</span>
                            <span class="badge bg-secondary" id="lblCantidadBienesInventario">0 bienes</span>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-sm table-hover align-middle mb-0" id="tblBienesInventario" style="min-width: 1500px;">
                                <thead class="table-dark">
                                    <tr>
                                        <th>GRUPO</th>
                                        <th>CBI</th>
                                        <th>DESCRIPCIÓN</th>
                                        <th>MARCA</th>
                                        <th>MODELO</th>
                                        <th>SERIE_MEDIDA</th>
                                        <th>OTRAS ESPECIFICACIONES</th>
                                        <th>ESTADO</th>
                                        <th style="min-width: 150px;">NRO_DRELM</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td colspan="9" class="text-center text-muted py-4">Seleccione una sala para cargar automáticamente sus bienes.</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </form>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-1">
                        <path d="M18 6 6 18M6 6l12 12"></path>
                    </svg>
                    Cancelar
                </button>
                <button type="button" class="btn btn-primary" id="btnGuardarInventario">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-1">
                        <path d="m5 12 4 4L19 6"></path>
                    </svg>
                    Guardar
                </button>
            </div>
        </div>
    </div>
</div>
