<section class="mp-panel" id="mpPersonal" hidden>
    <!-- Barra de Herramientas -->
    <div class="tb-bar" role="toolbar" aria-label="Acciones de personal">
        <button type="button" class="tb-btn" data-acc="nuevo" id="btn_nuevo_personal" title="Nuevo">
            <svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg>
        </button>
        <button type="button" class="tb-btn" data-acc="editar" id="btn_editar_personal" title="Editar">
            <svg viewBox="0 0 24 24"><path d="M4 20h4L19.5 8.5a2.1 2.1 0 0 0-3-3L5 17v3z"/><path d="M13.5 6.5l3 3"/></svg>
        </button>
        <button type="button" class="tb-btn" data-acc="eliminar" id="btn_eliminar_personal" title="Eliminar">
            <svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"/></svg>
        </button>
        <button type="button" class="tb-btn" data-acc="recargar" id="btn_recargar_personal" title="Recargar">
            <svg viewBox="0 0 24 24"><path d="M20 12a8 8 0 1 1-2.3-5.6M20 4v4h-4"/></svg>
        </button>
        <button type="button" class="tb-btn" data-acc="imprimir" id="btn_detalle_personal" title="Ver Detalle">
            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        </button>
        <button type="button" class="tb-btn tb-xls" data-acc="excel" id="btn_excel_personal" title="Excel">
            <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M9 9.5l6 5M15 9.5l-6 5"/></svg><span>X</span>
        </button>
        <button type="button" class="tb-btn" data-acc="salir" id="btn_salir_personal" title="Salir">
            <svg viewBox="0 0 24 24"><path d="M14 4h5v16h-5M10 8l-4 4 4 4M6 12h10"/></svg>
        </button>
    </div>

    <!-- Filtro de Búsqueda -->
    <div class="tb-search">
        <label for="txtBuscarPersonal">BUSCAR:</label>
        <input type="text" id="txtBuscarPersonal" autocomplete="off" placeholder="Escriba para filtrar...">
    </div>

    <!-- Tabla con las columnas solicitadas -->
    <div class="tb-table-wrap">
        <table class="tb-table" id="tabla_personal">
            <thead>
                <tr>
                    <th>Nombre Completo</th>
                    <th>DNI</th>
                    <th>Celular</th>
                    <th>Email</th>
                    <th class="text-center">Estado</th>
                </tr>
            </thead>
            <tbody id="tbody_personal">
                <tr><td colspan="5" class="text-center">Cargando...</td></tr>
            </tbody>
        </table>
    </div>
</section>

<!-- Modal Formulario Personal -->
<div class="modal fade" id="personal_modal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modal_personal_title">Registrar Personal</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
                <form id="form_personal">
                    @csrf
                    <input type="hidden" id="personal_id" name="id">
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="personal_dni" class="form-label">DNI</label>
                            <input type="text" class="form-control" id="personal_dni" name="dni" required maxlength="15">
                        </div>
                        <div class="col-md-6">
                            <label for="personal_nombreCompleto" class="form-label">Nombre Completo</label>
                            <input type="text" class="form-control" id="personal_nombreCompleto" name="nombreCompleto" required>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="personal_celular" class="form-label">Celular</label>
                            <input type="text" class="form-control" id="personal_celular" name="celular">
                        </div>
                        <div class="col-md-6">
                            <label for="personal_email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="personal_email" name="email">
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="personal_st_registro" class="form-label">Estado</label>
                            <select class="form-select" id="personal_st_registro" name="st_registro">
                                <option value="1">Activo</option>
                                <option value="0">Inactivo</option>
                            </select>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button type="submit" form="form_personal" class="btn btn-primary">Guardar</button>
            </div>
        </div>
    </div>
</div>