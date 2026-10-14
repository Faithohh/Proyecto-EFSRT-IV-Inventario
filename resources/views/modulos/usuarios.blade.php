<section class="mp-panel" id="mpUsuarios" hidden>
    <div class="tb-bar" role="toolbar" aria-label="Acciones de usuarios">
        <button type="button" class="tb-btn" data-acc="nuevo" title="Nuevo"><svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg></button>
        <button type="button" class="tb-btn" data-acc="editar" title="Editar"><svg viewBox="0 0 24 24"><path d="M4 20h4L19.5 8.5a2.1 2.1 0 0 0-3-3L5 17v3z"/><path d="M13.5 6.5l3 3"/></svg></button>
        <button type="button" class="tb-btn" data-acc="eliminar" title="Eliminar"><svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"/></svg></button>
        <button type="button" class="tb-btn" data-acc="recargar" title="Recargar"><svg viewBox="0 0 24 24"><path d="M20 12a8 8 0 1 1-2.3-5.6M20 4v4h-4"/></svg></button>
        <button type="button" class="tb-btn" data-acc="imprimir" title="Ver Detalle"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg></button>
        <button type="button" class="tb-btn tb-xls" data-acc="excel" title="Excel"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M9 9.5l6 5M15 9.5l-6 5"/></svg><span>X</span></button>
        <button type="button" class="tb-btn" data-acc="salir" title="Salir"><svg viewBox="0 0 24 24"><path d="M14 4h5v16h-5M10 8l-4 4 4 4M6 12h10"/></svg></button>
    </div>
    <div class="tb-search">
        <label for="txtBuscarUsuarios">BUSCAR:</label>
        <input type="text" id="txtBuscarUsuarios" autocomplete="off" placeholder="Escriba para filtrar...">
    </div>
    <div class="tb-table-wrap">
        <table class="tb-table" id="tblUsuarios">
            <thead>
                <tr><th>ID</th><th>Personal Asociado</th><th>Tipo de Usuario</th></tr>
            </thead>
            <tbody><tr><td colspan="3" class="text-center">Cargando...</td></tr></tbody>
        </table>
    </div>
</section>

<!-- Modal Registrar / Editar Usuario -->
<div class="modal fade" id="modalUsuario" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalUsuarioTitle">Nuevo Usuario</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <form id="formUsuario">
                    <input type="hidden" id="txtIdUsuarioOriginal" value="">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="txtIdUsuario" class="form-label">ID Usuario</label>
                            <input type="text" class="form-control" id="txtIdUsuario" maxlength="15" required>
                        </div>
                        <div class="col-md-6">
                            <label for="txtContrasena" class="form-label">Contraseña</label>
                            <input type="text" class="form-control" id="txtContrasena" maxlength="15" required>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="cboTipoUsuario" class="form-label">Tipo de Usuario</label>
                            <select class="form-select" id="cboTipoUsuario" required>
                                <option value="">Seleccione...</option>
                                <option value="ADMINISTRADOR">ADMINISTRADOR</option>
                                <option value="COORDINADOR">COORDINADOR</option>
                                <option value="ASISTENTE">ASISTENTE</option>
                                <option value="CONSULTA">CONSULTA</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label for="cboPersonal" class="form-label">Personal Asociado</label>
                            <select class="form-select" id="cboPersonal" required>
                                <option value="">Cargando...</option>
                            </select>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnGuardarUsuario">Guardar</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Detalle del Usuario -->
<div class="modal fade" id="modalDetalleUsuario" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Detalle del Usuario</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <table class="table table-bordered">
                    <tbody>
                        <tr><th>ID Usuario</th><td class="det-idUsuario"></td></tr>
                        <tr><th>Contraseña</th><td class="det-contrasena"></td></tr>
                        <tr><th>Tipo de Usuario</th><td class="det-tipoUsuario"></td></tr>
                        <tr><th>Personal</th><td class="det-personal"></td></tr>
                        <tr><th>Estado</th><td class="det-activo"></td></tr>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Eliminar Usuario -->
<div class="modal fade" id="modalEliminar" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirmar Eliminación</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <p>¿Está seguro de eliminar al usuario <strong id="txtUsuarioEliminar"></strong>?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">No</button>
                <button type="button" class="btn btn-danger" id="btnConfirmarEliminar">Sí, Eliminar</button>
            </div>
        </div>
    </div>
</div>