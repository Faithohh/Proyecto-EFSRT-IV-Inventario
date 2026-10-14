<section class="mp-panel" id="mpProgramaEstudio" hidden>
    <!-- CABECERA DEL MÓDULO -->
    <div class="mp-panel-header d-flex align-items-center mb-3">
        <svg viewBox="0 0 24 24" width="24" height="24" class="me-2" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path>
            <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path>
        </svg>
        <h4 class="m-0 font-weight-bold">Gestión de Programa de Estudio</h4>
    </div>

    <!-- BARRA DE HERRAMIENTAS -->
    <div class="tb-bar" role="toolbar" aria-label="Acciones de Programa de Estudio">
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
        <label for="txtBuscarProgramaEstudio">BUSCAR:</label>
        <input type="text" id="txtBuscarProgramaEstudio" autocomplete="off" placeholder="Escriba para filtrar...">
    </div>

    <!-- TABLA DE PROGRAMA DE ESTUDIO -->
    <div class="tb-table-wrap">
        <table class="tb-table" id="tblProgramaEstudio">
            <thead>
                <tr>
                    <th>Nombre</th>
                    <th>Estado</th>
                </tr>
            </thead>
            <tbody>
                <tr><td colspan="2" class="text-center">Cargando...</td></tr>
            </tbody>
        </table>
    </div>
</section>

<!-- Modal Registrar / Editar Programa de Estudio -->
<div class="modal fade" id="modalProgramaEstudio" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalProgramaEstudioTitle">Nuevo Programa de Estudio</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body py-4">
                <form id="formProgramaEstudio">
                    <input type="hidden" id="txtIdProgramaEstudioOriginal" value="">
                    
                    <div class="row mb-3 align-items-center justify-content-center">
                        <label for="txtNombreProgramaEstudio" class="col-sm-4 col-md-3 col-form-label text-sm-end">Nombre del Programa:</label>
                        <div class="col-sm-7 col-md-8">
                            <input type="text" class="form-control" id="txtNombreProgramaEstudio" maxlength="100" required>
                        </div>
                    </div>

                    <div class="row mb-3 align-items-center justify-content-center">
                        <label for="cboCoordinadorArea" class="col-sm-4 col-md-3 col-form-label text-sm-end">Coordinador de Area:</label>
                        <div class="col-sm-7 col-md-8">
                            <select class="form-select" id="cboCoordinadorArea" name="idCoordinadorArea">
                                <option value="">-- Seleccione --</option>
                            </select>
                        </div>
                    </div>

                    <div class="row mb-3 align-items-center justify-content-center">
                        <label for="cboAsistenteAreaT1" class="col-sm-4 col-md-3 col-form-label text-sm-end">Asistente Area T1:</label>
                        <div class="col-sm-7 col-md-8">
                            <select class="form-select" id="cboAsistenteAreaT1" name="idAsistenteAreaT1">
                                <option value="">-- Seleccione --</option>
                            </select>
                        </div>
                    </div>

                    <div class="row mb-3 align-items-center justify-content-center">
                        <label for="cboAsistenteAreaT2" class="col-sm-4 col-md-3 col-form-label text-sm-end">Asistente Area T2:</label>
                        <div class="col-sm-7 col-md-8">
                            <select class="form-select" id="cboAsistenteAreaT2" name="idAsistenteAreaT2">
                                <option value="">-- Seleccione --</option>
                            </select>
                        </div>
                    </div>

                    <div class="row mb-3 justify-content-center">
                        <label for="txtObservacionProgramaEstudio" class="col-sm-4 col-md-3 col-form-label text-sm-end">Observacion:</label>
                        <div class="col-sm-7 col-md-8">
                            <textarea class="form-control" id="txtObservacionProgramaEstudio" rows="3"></textarea>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnGuardarProgramaEstudio">Guardar</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Detalle del Programa de Estudio -->
<div class="modal fade" id="modalDetalleProgramaEstudio" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Detalle del Programa de Estudio</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <table class="table table-bordered mb-0">
                    <tbody>
                        <tr><th>ID</th><td class="det-idProgramaEstudio"></td></tr>
                        <tr><th>Nombre</th><td class="det-nombre"></td></tr>
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

<!-- Modal Eliminar Programa de Estudio -->
<div class="modal fade" id="modalEliminarProgramaEstudio" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Confirmar Eliminación</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <p>¿Está seguro de eliminar el programa <strong id="txtProgramaEstudioEliminar"></strong>?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-danger" id="btnConfirmarEliminarProgramaEstudio">Eliminar</button>
            </div>
        </div>
    </div>
</div>