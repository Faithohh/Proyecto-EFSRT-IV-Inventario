<section class="mp-panel" id="mpGrupo" hidden>
    <!-- Cabecera del Módulo -->
    <div class="mp-panel-header d-flex align-items-center mb-3">
        <svg viewBox="0 0 24 24" width="24" height="24" class="me-2" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
            <circle cx="9" cy="7" r="4"></circle>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
            <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
        </svg>
        <h4 class="m-0 font-weight-bold">Gestión de Grupo</h4>
    </div>

    <div class="tb-bar" role="toolbar" aria-label="Acciones de grupo">
        <button type="button" class="tb-btn" data-acc="nuevo" title="Nuevo"><svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg></button>
        <button type="button" class="tb-btn" data-acc="editar" title="Editar"><svg viewBox="0 0 24 24"><path d="M4 20h4L19.5 8.5a2.1 2.1 0 0 0-3-3L5 17v3z"/><path d="M13.5 6.5l3 3"/></svg></button>
        <button type="button" class="tb-btn" data-acc="eliminar" title="Eliminar"><svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"/></svg></button>
        <button type="button" class="tb-btn" data-acc="recargar" title="Recargar"><svg viewBox="0 0 24 24"><path d="M20 12a8 8 0 1 1-2.3-5.6M20 4v4h-4"/></svg></button>
        <button type="button" class="tb-btn" data-acc="imprimir" title="Ver Detalle"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg></button>
        <button type="button" class="tb-btn tb-xls" data-acc="excel" title="Excel"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M9 9.5l6 5M15 9.5l-6 5"/></svg><span>X</span></button>
        <button type="button" class="tb-btn" data-acc="salir" title="Salir"><svg viewBox="0 0 24 24"><path d="M14 4h5v16h-5M10 8l-4 4 4 4M6 12h10"/></svg></button>
    </div>

    <div class="tb-search">
        <label for="txtBuscarGrupo">BUSCAR:</label>
        <input type="text" id="txtBuscarGrupo" autocomplete="off" placeholder="Escriba para filtrar por nombre o usuario...">
    </div>

    <div class="tb-table-wrap">
        <table class="tb-table" id="tblGrupo">
            <thead>
                <tr>
                    <th>Nombre</th>
                    <th>idUsuarioCrea</th>
                    <th>fechaCreacion</th>
                    <th>idUsuarioModifica</th>
                    <th>fechaModificacion</th>
                </tr>
            </thead>
            <tbody><tr><td colspan="5" class="text-center">Cargando...</td></tr></tbody>
        </table>
    </div>
</section>

<!-- Modal Registrar / Editar Grupo (Posición Superior) -->
<div class="modal fade" id="modalGrupo" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalGrupoTitle">Nuevo Grupo</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <form id="formGrupo">
                    <input type="hidden" id="txtIdGrupoOriginal" name="idGrupo" value="">
                    
                    <!-- Fila Programa de Estudio (Número en negrita) -->
                    <div class="mb-3">
                        <span>Programa de estudio: </span>
                        <span id="lblProgramaEstudio" class="fw-bold fs-6">{{ session('idProgramaEstudio', 2) }}</span>
                        <input type="hidden" id="txtIdProgramaEstudio" name="idProgramaEstudio" value="{{ session('idProgramaEstudio', 2) }}">
                    </div>

                    <!-- Fila Nombre del Grupo -->
                    <div class="row align-items-center mb-3">
                        <label for="txtNombreGrupo" class="col-sm-4 col-form-label">Nombre del Grupo:</label>
                        <div class="col-sm-8">
                            <input type="text" class="form-control" id="txtNombreGrupo" name="nombre" maxlength="60" required placeholder="Ingrese el nombre del grupo">
                        </div>
                    </div>

                    <!-- Estado por defecto activo -->
                    <input type="hidden" id="cboEstadoGrupo" name="estado" value="1">
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnGuardarGrupo">Guardar</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Detalle del Grupo -->
<div class="modal fade" id="modalDetalleGrupo" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Detalle del Grupo</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <table class="table table-bordered">
                    <tbody>
                        <tr><th>ID</th><td id="det-idGrupo"></td></tr>
                        <tr><th>Nombre</th><td id="det-nombre"></td></tr>
                        <tr><th>Usuario Crea</th><td id="det-usuarioCrea"></td></tr>
                        <tr><th>Fecha Creación</th><td id="det-fechaCrea"></td></tr>
                        <tr><th>Usuario Modifica</th><td id="det-usuarioMod"></td></tr>
                        <tr><th>Fecha Modificación</th><td id="det-fechaMod"></td></tr>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Eliminar Grupo (Centrado al Medio) -->
<div class="modal fade" id="modalEliminarGrupo" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">Confirmar Eliminación</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <p>¿Está seguro de eliminar el grupo <strong id="txtGrupoEliminar"></strong>?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-danger" id="btnConfirmarEliminarGrupo">Eliminar</button>
            </div>
        </div>
    </div>
</div>