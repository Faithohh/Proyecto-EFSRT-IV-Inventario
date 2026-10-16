
document.addEventListener("DOMContentLoaded", function () {
    let cargandoInventarios = false;

    async function cargarInventarios() {
        const combo = document.getElementById("cbInventario");

        if (!combo || cargandoInventarios) {
            return;
        }

        cargandoInventarios = true;

        const seleccionAnterior = combo.value;

        try {
            combo.innerHTML = `
                <option value="">Cargando inventarios...</option>
            `;

            const response = await fetch("/reportes/inventarios", {
                cache: "no-store"
            });

            if (!response.ok) {
                throw new Error("Error al consultar los inventarios.");
            }

            const data = await response.json();

            if (!data.ok) {
                combo.innerHTML = `
                    <option value="">No se pudieron cargar los inventarios</option>
                `;

                mostrarError(
                    data.msg || "No se pudieron cargar los inventarios."
                );

                return;
            }

            const inventarios = data.data || [];

            combo.innerHTML = `
                <option value="">Seleccione un inventario cerrado</option>
            `;

            if (inventarios.length === 0) {
                combo.innerHTML = `
                    <option value="">No hay inventarios cerrados disponibles</option>
                `;

                return;
            }

            inventarios.forEach(function (inventario) {
                const option = document.createElement("option");

                option.value = inventario.idInventario;

                option.textContent =
                    inventario.INVENTARIO + " - " + inventario.SALA;

                combo.appendChild(option);
            });

            if (
                seleccionAnterior &&
                inventarios.some(
                    inventario =>
                        String(inventario.idInventario) === seleccionAnterior
                )
            ) {
                combo.value = seleccionAnterior;
            }
        } catch (error) {
            console.error(error);

            combo.innerHTML = `
                <option value="">Error al cargar inventarios</option>
            `;

            mostrarError("No se pudieron cargar los inventarios.");
        } finally {
            cargandoInventarios = false;
        }
    }

    cargarInventarios();

    const comboInventario = document.getElementById("cbInventario");

    if (comboInventario) {
        comboInventario.addEventListener("focus", cargarInventarios);
    }

    document.addEventListener("visibilitychange", function () {
        if (!document.hidden) {
            cargarInventarios();
        }
    });

    window.addEventListener("focus", cargarInventarios);

    const btnCargarDatos = document.getElementById("btnCargarDatos");

    if (btnCargarDatos) {
        btnCargarDatos.addEventListener("click", function () {
            const combo = document.getElementById("cbInventario");

            if (!combo || !combo.value) {
                mostrarAdvertencia(
                    "Seleccione un inventario",
                    "Debe seleccionar un inventario antes de continuar."
                );

                return;
            }

            cargarInforme(combo.value);
        });
    }

    function cargarInforme(idInventario) {
        document.getElementById("contenedorReporte").innerHTML = `
            <div class="reporte-cargando">
                <div class="spinner-border" role="status"></div>
                <p>Cargando informe...</p>
            </div>
        `;

        fetch("/reportes/informe/" + encodeURIComponent(idInventario))
            .then((response) => {
                if (!response.ok) {
                    throw new Error("No se pudo cargar el informe.");
                }

                return response.json();
            })
            .then((data) => {
                if (!data.ok) {
                    document.getElementById("contenedorReporte").innerHTML = `
                        <div class="alert alert-danger">
                            ${escapeHtml(data.msg || "No se pudo cargar el informe.")}
                        </div>
                    `;

                    return;
                }

                mostrarInforme(data.data);
            })
            .catch((error) => {
                console.error(error);

                document.getElementById("contenedorReporte").innerHTML = `
                    <div class="alert alert-danger">
                        No se pudo cargar el informe.
                    </div>
                `;
            });
    }

    function mostrarInforme(data) {
        const inventario = data.inventario;
        const bienes = data.bienes || [];

        const fechaActual = obtenerFechaActual();

        const totalBienes = bienes.length;

        let html = "";

        html += `
            <style>

                .reporte-documento {
                    background: #ffffff;
                    color: #1f2937;
                    padding: 35px;
                    border-radius: 10px;
                    box-shadow: 0 3px 15px rgba(0, 0, 0, 0.10);
                    font-family: Arial, Helvetica, sans-serif;
                    max-width: 1400px;
                    margin: 20px auto;
                }

                .reporte-encabezado {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    gap: 25px;
                    padding-bottom: 20px;
                    border-bottom: 3px solid #1f4e79;
                }

                .reporte-logo {
                    width: 85px;
                    height: 85px;
                    object-fit: contain;
                }

                .reporte-institucion {
                    flex: 1;
                }

                .reporte-institucion h5 {
                    margin: 0 0 5px 0;
                    font-size: 17px;
                    font-weight: 700;
                    color: #1f2937;
                }

                .reporte-institucion h6 {
                    margin: 0;
                    font-size: 13px;
                    color: #6b7280;
                    font-weight: 500;
                }

                .reporte-titulo {
                    text-align: center;
                    margin: 25px 0;
                }

                .reporte-titulo h2 {
                    margin: 0;
                    font-size: 23px;
                    font-weight: 700;
                    color: #1f4e79;
                    letter-spacing: 0.5px;
                }

                .reporte-titulo p {
                    margin: 7px 0 0 0;
                    font-size: 14px;
                    color: #6b7280;
                }

                .reporte-fecha {
                    text-align: right;
                    min-width: 170px;
                    font-size: 12px;
                    color: #6b7280;
                }

                .reporte-fecha strong {
                    display: block;
                    color: #374151;
                    font-size: 12px;
                    margin-bottom: 4px;
                }

                .reporte-seccion-titulo {
                    background: #1f4e79;
                    color: #ffffff;
                    padding: 9px 13px;
                    font-size: 13px;
                    font-weight: 700;
                    border-radius: 5px 5px 0 0;
                    text-transform: uppercase;
                    letter-spacing: 0.3px;
                }

                .reporte-info {
                    border: 1px solid #d9e0e7;
                    border-top: none;
                    border-radius: 0 0 5px 5px;
                    padding: 16px;
                    margin-bottom: 25px;
                }

                .reporte-info-grid {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 13px 30px;
                }

                .reporte-info-item {
                    font-size: 13px;
                    padding-bottom: 7px;
                    border-bottom: 1px solid #eef1f4;
                }

                .reporte-info-item strong {
                    display: inline-block;
                    min-width: 125px;
                    color: #374151;
                }

                .reporte-grupo {
                    margin-top: 20px;
                }

                .reporte-grupo-titulo {
                    background: #e8eef5;
                    color: #1f4e79;
                    border-left: 5px solid #1f4e79;
                    padding: 9px 12px;
                    font-size: 13px;
                    font-weight: 700;
                    text-transform: uppercase;
                }

                .reporte-tabla {
                    width: 100%;
                    border-collapse: collapse;
                    margin-top: 0;
                    font-size: 11px;
                }

                .reporte-tabla th {
                    background: #f3f6f9;
                    color: #263238;
                    border: 1px solid #cfd7df;
                    padding: 9px 6px;
                    text-align: center;
                    font-weight: 700;
                    vertical-align: middle;
                }

                .reporte-tabla td {
                    border: 1px solid #d7dde3;
                    padding: 8px 6px;
                    vertical-align: middle;
                    color: #374151;
                }

                .reporte-tabla tbody tr:nth-child(even) {
                    background: #fafbfc;
                }

                .reporte-tabla tbody tr:hover {
                    background: #f0f5fa;
                }

                .reporte-tabla th:nth-child(1),
                .reporte-tabla td:nth-child(1) {
                    width: 9%;
                    text-align: center;
                }

                .reporte-tabla th:nth-child(2),
                .reporte-tabla td:nth-child(2) {
                    width: 7%;
                    text-align: center;
                }

                .reporte-tabla th:nth-child(3),
                .reporte-tabla td:nth-child(3) {
                    width: 20%;
                }

                .reporte-tabla th:nth-child(4),
                .reporte-tabla td:nth-child(4) {
                    width: 10%;
                }

                .reporte-tabla th:nth-child(5),
                .reporte-tabla td:nth-child(5) {
                    width: 11%;
                }

                .reporte-tabla th:nth-child(6),
                .reporte-tabla td:nth-child(6) {
                    width: 15%;
                }

                .reporte-tabla th:nth-child(7),
                .reporte-tabla td:nth-child(7) {
                    width: 10%;
                    text-align: center;
                }

                .reporte-tabla th:nth-child(8),
                .reporte-tabla td:nth-child(8) {
                    width: 18%;
                }

                .reporte-estado {
                    display: inline-block;
                    padding: 4px 8px;
                    border-radius: 12px;
                    background: #eef2f7;
                    font-size: 10px;
                    font-weight: 600;
                    white-space: nowrap;
                }

                .reporte-total {
                    display: flex;
                    justify-content: flex-end;
                    margin-top: 22px;
                }

                .reporte-total-box {
                    border: 1px solid #cfd7df;
                    border-radius: 5px;
                    padding: 11px 18px;
                    min-width: 220px;
                    background: #f8fafc;
                    text-align: right;
                    font-size: 13px;
                }

                .reporte-total-box strong {
                    color: #1f4e79;
                    font-size: 15px;
                }

                .reporte-observacion {
                    margin-top: 20px;
                    border: 1px solid #d9e0e7;
                    border-radius: 5px;
                    padding: 14px;
                    font-size: 13px;
                    background: #fafbfc;
                }

                .reporte-observacion strong {
                    color: #1f4e79;
                }

                .reporte-pie {
                    margin-top: 30px;
                    padding-top: 12px;
                    border-top: 1px solid #d9e0e7;
                    text-align: center;
                    color: #8a929b;
                    font-size: 10px;
                }

                .reporte-sin-datos {
                    padding: 30px;
                    text-align: center;
                    color: #6b7280;
                    border: 1px solid #d9e0e7;
                    background: #fafbfc;
                }

                .reporte-cargando {
                    text-align: center;
                    padding: 60px 20px;
                    color: #6b7280;
                }

                .reporte-cargando .spinner-border {
                    width: 35px;
                    height: 35px;
                }

                .reporte-cargando p {
                    margin-top: 12px;
                    margin-bottom: 0;
                }

                @media (max-width: 900px) {

                    .reporte-documento {
                        padding: 20px;
                    }

                    .reporte-encabezado {
                        flex-direction: column;
                        text-align: center;
                    }

                    .reporte-fecha {
                        text-align: center;
                    }

                    .reporte-info-grid {
                        grid-template-columns: 1fr;
                    }

                    .table-responsive {
                        overflow-x: auto;
                    }

                }

                @media print {

                    .reporte-documento {
                        box-shadow: none;
                        margin: 0;
                        max-width: none;
                        border-radius: 0;
                        padding: 15px;
                    }

                    .reporte-tabla {
                        font-size: 9px;
                    }

                    .reporte-tabla th,
                    .reporte-tabla td {
                        padding: 5px 4px;
                    }

                    .reporte-grupo {
                        page-break-inside: avoid;
                    }

                    .reporte-encabezado {
                        page-break-inside: avoid;
                    }

                    .reporte-info {
                        page-break-inside: avoid;
                    }

                    .reporte-pie {
                        page-break-inside: avoid;
                    }

                }

            </style>

            <div class="reporte-documento">

                <div class="reporte-encabezado">

                    <div class="reporte-institucion">

                        <h5>
                            I.E.S.T.P. "JULIO CESAR TELLO"
                        </h5>

                        <h6>
                            Sistema Institucional de Inventario
                        </h6>

                    </div>

                    <div class="reporte-fecha">

                        <strong>FECHA DE REPORTE</strong>

                        ${fechaActual}

                    </div>

                </div>

                <div class="reporte-titulo">

                    <h2>
                        INFORME DE INVENTARIO
                    </h2>

                    <p>
                        Inventario N.º <strong>${escapeHtml(inventario.INVENTARIO || "-")}</strong>
                    </p>

                </div>

                <div class="reporte-seccion-titulo">
                    Información del Inventario
                </div>

                <div class="reporte-info">

                    <div class="reporte-info-grid">

                        <div class="reporte-info-item">
                            <strong>Sala:</strong>
                            ${escapeHtml(inventario.SALA || "-")}
                        </div>

                        <div class="reporte-info-item">
                            <strong>Fecha de entrega:</strong>
                            ${formatearFecha(inventario.FECHA_ENTREGA)}
                        </div>

                        <div class="reporte-info-item">
                            <strong>Coordinador:</strong>
                            ${escapeHtml(inventario.COORDINADOR || "-")}
                        </div>

                        <div class="reporte-info-item">
                            <strong>Asistente T1:</strong>
                            ${escapeHtml(inventario.ASISTENTE_T1 || "-")}
                        </div>

                        <div class="reporte-info-item">
                            <strong>Asistente T2:</strong>
                            ${escapeHtml(inventario.ASISTENTE_T2 || "-")}
                        </div>

                        <div class="reporte-info-item">
                            <strong>Estado:</strong>
                            ${escapeHtml(inventario.ESTADO || "-")}
                        </div>

                    </div>

                </div>

                <div class="reporte-seccion-titulo">
                    Detalle de Bienes
                </div>

                ${generarTablaBienes(bienes)}

                <div class="reporte-total">

                    <div class="reporte-total-box">

                        Total de bienes:
                        <strong>${totalBienes}</strong>

                    </div>

                </div>

                <div class="reporte-observacion">

                    <strong>Observaciones:</strong>

                    <span>
                        ${escapeHtml(inventario.OBSERVACION || "-")}
                    </span>

                </div>

                <div class="reporte-pie">

                    I.E.S.T.P. "JULIO CESAR TELLO" -
                    Sistema Institucional de Inventario

                </div>

            </div>
        `;

        document.getElementById("contenedorReporte").innerHTML = html;
    }

    function generarTablaBienes(bienes) {
        if (!bienes || bienes.length === 0) {
            return `
                <div class="reporte-sin-datos">
                    No existen bienes registrados para este inventario.
                </div>
            `;
        }

        let html = "";

        let grupoActual = null;

        bienes.forEach(function (bien) {
            const grupo = bien.GRUPO || "SIN GRUPO";

            if (grupo !== grupoActual) {
                if (grupoActual !== null) {
                    html += `
                        </tbody>
                        </table>
                        </div>
                    `;
                }

                grupoActual = grupo;

                html += `
                    <div class="reporte-grupo">

                        <div class="reporte-grupo-titulo">
                            Grupo: ${escapeHtml(grupo)}
                        </div>

                        <div class="table-responsive">

                            <table class="reporte-tabla">

                                <thead>

                                    <tr>
                                        <th>INV DRELM</th>
                                        <th>CBI</th>
                                        <th>DESCRIPCIÓN</th>
                                        <th>MARCA</th>
                                        <th>MODELO</th>
                                        <th>SERIE / MEDIDA</th>
                                        <th>ESTADO</th>
                                        <th>OTRAS ESPEC.</th>
                                    </tr>

                                </thead>

                                <tbody>
                `;
            }

            html += `
                <tr>

                    <td>
                        ${escapeHtml(bien.INV_DRELM || "-")}
                    </td>

                    <td>
                        ${escapeHtml(bien.CBI || "-")}
                    </td>

                    <td>
                        ${escapeHtml(bien.DESCRIPCION || "-")}
                    </td>

                    <td>
                        ${escapeHtml(bien.MARCA || "-")}
                    </td>

                    <td>
                        ${escapeHtml(bien.MODELO || "-")}
                    </td>

                    <td>
                        ${escapeHtml(bien.SERIE_MEDIDA || "-")}
                    </td>

                    <td>
                        <span class="reporte-estado">
                            ${escapeHtml(bien.ESTADO || "-")}
                        </span>
                    </td>

                    <td>
                        ${escapeHtml(bien.OTRAS_ESPECIFICACIONES || "-")}
                    </td>

                </tr>
            `;
        });

        html += `
                </tbody>
            </table>
        </div>
        </div>
        `;

        return html;
    }

    function obtenerFechaActual() {
        const fecha = new Date();

        const dia = String(fecha.getDate()).padStart(2, "0");

        const mes = String(fecha.getMonth() + 1).padStart(2, "0");

        const anio = fecha.getFullYear();

        return dia + "/" + mes + "/" + anio;
    }

    function formatearFecha(fecha) {
        if (!fecha) {
            return "-";
        }

        const partes = fecha.substring(0, 10).split("-");

        if (partes.length !== 3) {
            return fecha;
        }

        return partes[2] + "/" + partes[1] + "/" + partes[0];
    }

    function escapeHtml(texto) {
        const div = document.createElement("div");

        div.textContent = String(texto);

        return div.innerHTML;
    }

    function mostrarError(mensaje) {
        if (typeof Swal !== "undefined") {
            Swal.fire({
                icon: "error",
                title: "Error",
                text: mensaje,
            });
        } else {
            alert(mensaje);
        }
    }

    function mostrarAdvertencia(titulo, mensaje) {
        if (typeof Swal !== "undefined") {
            Swal.fire({
                icon: "warning",
                title: titulo,
                text: mensaje,
            });
        } else {
            alert(titulo + "\n\n" + mensaje);
        }
    }
});
