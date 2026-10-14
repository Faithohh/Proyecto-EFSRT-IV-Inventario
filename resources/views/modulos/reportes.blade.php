<section class="mp-panel" id="mpReportes" hidden> 
 
    <!-- Cabecera del Módulo --> 
 
    <div class="mp-panel-header d-flex align-items-center mb-3"> 
 
        <svg viewBox="0 0 24 24" 
            width="24" 
            height="24" 
            class="me-2" 
            fill="none" 
            stroke="currentColor" 
            stroke-width="2" 
            stroke-linecap="round" 
            stroke-linejoin="round"> 
 
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path> 
 
            <polyline points="14 2 14 8 20 8"></polyline> 
 
            <line x1="16" y1="13" x2="8" y2="13"></line> 
 
            <line x1="16" y1="17" x2="8" y2="17"></line> 
 
            <polyline points="10 9 9 9 8 9"></polyline> 
 
        </svg> 
 
        <h4 class="m-0 font-weight-bold"> 
            Gestión de Reportes 
        </h4> 
 
    </div> 
 
 
    <!-- PARÁMETROS DEL REPORTE --> 
 
    <div class="tb-search"> 
 
        <label for="cbInventario"> 
            SELECCIONE INVENTARIO: 
        </label> 
 
        <select id="cbInventario" 
            class="form-select" 
            autocomplete="off"> 
 
            <option value=""> 
                Seleccione un inventario 
            </option> 
 
        </select> 
 
        <button type="button" 
            class="btn btn-primary" 
            id="btnCargarDatos"> 
 
            Cargar Datos 
 
        </button> 
 
    </div> 
 
 
    <!-- INFORME PRINCIPAL --> 
 
    <div class="tb-table-wrap"> 
 
        <div id="contenedorReporte"> 
 
            <div class="text-center py-5 text-muted"> 
 
                <svg viewBox="0 0 24 24" 
                    width="48" 
                    height="48" 
                    fill="none" 
                    stroke="currentColor" 
                    stroke-width="1.5" 
                    stroke-linecap="round" 
                    stroke-linejoin="round"> 
 
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path> 
 
                    <polyline points="14 2 14 8 20 8"></polyline> 
 
                    <line x1="16" y1="13" x2="8" y2="13"></line> 
 
                    <line x1="16" y1="17" x2="8" y2="17"></line> 
 
                </svg> 
 
                <p class="mt-2 mb-0"> 
                    Seleccione un inventario y presione "Cargar Datos". 
                </p> 
 
            </div> 
 
        </div> 
 
    </div> 
 
</section>