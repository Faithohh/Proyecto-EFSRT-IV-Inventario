let idInventarioEditando = null;
let bienesInventario = [];
let inventarioSoloLectura = false;

document.addEventListener("DOMContentLoaded", () => {
    cargarInventarios();

    window.addEventListener("modulo:abrir", function (e) {
        var mod = (e.detail || "").toLowerCase();
        if (mod.includes("inventario") || mod.includes("toma")) {
            const panel = document.getElementById("mpTomaInventario");
            if (panel) panel.hidden = false;
            cargarInventarios();
        }
    });

    const txtBuscar = document.getElementById("txtBuscarInventario");
    if (txtBuscar) {
        txtBuscar.addEventListener("input", function () {
            const criterio = this.value.toLowerCase().trim();
            const filas = document.querySelectorAll("#tblInventarios tbody tr");

            filas.forEach((fila) => {
                if (fila.cells.length === 1) return;
                fila.style.display = fila.textContent
                    .toLowerCase()
                    .includes(criterio)
                    ? ""
                    : "none";
            });
        });
    }

    const tabla = document.getElementById("tblInventarios");
    if (tabla) {
        const tbody = tabla.querySelector("tbody");

        if (tbody) {
            tbody.addEventListener("click", (e) => {
                const fila = e.target.closest("tr");
                if (!fila || fila.cells.length === 1) return;

                tbody
                    .querySelectorAll("tr")
                    .forEach((r) =>
                        r.classList.remove("sel", "selected", "table-active"),
                    );
                fila.classList.add("sel", "selected", "table-active");
            });
        }
    }

    const modalInventario = document.getElementById("modalInventario");

    if (modalInventario) {
        modalInventario.addEventListener("hidden.bs.modal", () => {
            limpiarBackdrops();
            idInventarioEditando = null;
            inventarioSoloLectura = false;

            modalInventario
                .querySelectorAll("input, select, textarea")
                .forEach((el) => {
                    el.disabled = false;
                });

            const btnGuardar = document.getElementById("btnGuardarInventario");
            if (btnGuardar) {
                btnGuardar.style.display = "inline-block";
                btnGuardar.disabled = false;
            }

            const form = document.getElementById("formInventario");
            if (form) form.reset();

            limpiarPersonalInventario();
            limpiarBienesInventario();
        });
    }

    const panelInventario = document.getElementById("mpTomaInventario");

    if (panelInventario) {
        panelInventario.querySelectorAll(".tb-btn").forEach((btn) => {
            btn.addEventListener("click", () => {
                const acc = btn.dataset.acc;

                if (acc === "nuevo") {
                    idInventarioEditando = null;
                    inventarioSoloLectura = false;

                    const form = document.getElementById("formInventario");
                    if (form) form.reset();

                    limpiarPersonalInventario();
                    limpiarBienesInventario();

                    if (modalInventario) {
                        modalInventario
                            .querySelectorAll("input, select, textarea")
                            .forEach((el) => {
                                el.disabled = false;
                            });

                        const btnGuardar = document.getElementById(
                            "btnGuardarInventario",
                        );

                        if (btnGuardar) {
                            btnGuardar.style.display = "inline-block";
                            btnGuardar.disabled = false;
                        }

                        const titulo = document.getElementById(
                            "modalInventarioTitle",
                        );

                        if (titulo) titulo.textContent = "NUEVO Inventario";
                    }

                    cargarComboboxesInventario()
                        .then(async () => {
                            const anioActual = new Date().getFullYear();
                            document.getElementById("txtSerie").value =
                                anioActual;

                            document.getElementById(
                                "cboEstadoInventario",
                            ).value = "ABIERTO";

                            const cboSala =
                                document.getElementById("cboSalaInventario");

                            if (cboSala && cboSala.options.length > 1) {
                                cboSala.selectedIndex = 1;
                                await cargarPersonalPorSala(cboSala.value);
                            }

                            actualizarCorrelativo();
                            abrirModal();
                        })
                        .catch((err) => {
                            console.error("Error al preparar inventario:", err);
                            Alert.error("Error", err.message);
                        });
                } else if (acc === "editar") {
                    const filaSel = document.querySelector(
                        "#tblInventarios tbody tr.sel",
                    );

                    if (!filaSel) {
                        Alert.advertencia(
                            "Atención",
                            "Por favor, seleccione un registro de la tabla para editar.",
                        );
                        return;
                    }

                    prepararEdicion(filaSel.dataset.id);
                } else if (
                    acc === "detalle" ||
                    acc === "ver" ||
                    acc === "imprimir"
                ) {
                    const filaSel = document.querySelector(
                        "#tblInventarios tbody tr.sel",
                    );

                    if (!filaSel) {
                        Alert.advertencia(
                            "Atención",
                            "Por favor, seleccione un registro de la tabla para visualizar.",
                        );
                        return;
                    }

                    verDetalleInventario(filaSel.dataset.id);
                } else if (acc === "recargar") {
                    cargarInventarios();
                } else if (acc === "eliminar") {
                    const filaSel = document.querySelector(
                        "#tblInventarios tbody tr.sel",
                    );

                    if (!filaSel) {
                        Alert.advertencia(
                            "Atención",
                            "Por favor, seleccione un inventario de la tabla para cerrar.",
                        );
                        return;
                    }

                    cerrarInventario(filaSel.dataset.id, filaSel);
                } else if (acc === "excel") {
                    Alert.info(
                        "Información",
                        "La exportación a Excel todavía no está implementada.",
                    );
                } else if (acc === "salir") {
                    panelInventario.hidden = true;

                    const bienvenida = document.getElementById("mpBienvenida");
                    if (bienvenida) bienvenida.hidden = false;
                }
            });
        });
    }

    const cboSala = document.getElementById("cboSalaInventario");

    if (cboSala) {
        cboSala.addEventListener("change", async () => {
            if (inventarioSoloLectura) return;

            limpiarBienesInventario();

            const idSala = cboSala.value;

            if (idSala) {
                await cargarBienesPorSala(idSala);
            }
        });
    }

    const txtAnio = document.getElementById("txtSerie");

    if (txtAnio) {
        txtAnio.addEventListener("change", actualizarCorrelativo);
    }

    const btnBuscarBienes = document.getElementById(
        "btnBuscarBienesInventario",
    );

    if (btnBuscarBienes) {
        btnBuscarBienes.addEventListener("click", async () => {
            const idSala = document.getElementById("cboSalaInventario")?.value;

            if (!idSala) {
                Alert.advertencia("Atención", "Primero debe seleccionar una sala.");
                return;
            }

            await cargarBienesPorSala(idSala);

            if (inventarioSoloLectura) {
                bloquearCamposDrelm();
            }
        });
    }

    const btnGuardar = document.getElementById("btnGuardarInventario");

    if (btnGuardar) {
        btnGuardar.addEventListener("click", async function (e) {
            e.preventDefault();

            if (inventarioSoloLectura) {
                Alert.advertencia("Atención", "Este inventario está en modo de solo lectura.");
                return;
            }

            const tokenMeta = document.querySelector('meta[name="csrf-token"]');
            const token = tokenMeta ? tokenMeta.getAttribute("content") : "";

            const data = {
                anio: document.getElementById("txtSerie")?.value,
                estado:
                    document.getElementById("cboEstadoInventario")?.value ||
                    "ABIERTO",
                sala_id: document.getElementById("cboSalaInventario")?.value,
                fecha_entrega:
                    document.getElementById("txtFechaEntrega")?.value || null,
                observacion:
                    document.getElementById("txtObservacionInventario")
                        ?.value || null,
                bienes: obtenerBienesDrelm(),
            };

            if (
                !data.anio ||
                Number(data.anio) < 2000 ||
                Number(data.anio) > 2100
            ) {
                Alert.advertencia("Atención", "Ingrese un año válido.");
                return;
            }

            if (!data.sala_id) {
                Alert.advertencia("Atención", "Por favor, seleccione una sala.");
                return;
            }

            if (!data.fecha_entrega) {
                Alert.advertencia("Atención", "Por favor, ingrese la fecha de entrega.");
                document.getElementById("txtFechaEntrega")?.focus();
                return;
            }

            if (
                !document.getElementById("cboCoordinador")?.value ||
                !document.getElementById("cboAsistente1")?.value
            ) {
                Alert.advertencia(
                    "Atención",
                    "La sala debe tener un coordinador y un Asistente T1 asignados.",
                );
                return;
            }

            const url = idInventarioEditando
                ? `/inventario/actualizar/${idInventarioEditando}`
                : "/inventario/guardar";

            const method = idInventarioEditando ? "PUT" : "POST";

            btnGuardar.disabled = true;

            try {
                const response = await fetch(url, {
                    method: method,
                    headers: {
                        "Content-Type": "application/json",
                        Accept: "application/json",
                        "X-CSRF-TOKEN": token,
                    },
                    body: JSON.stringify(data),
                });

                const resData = await response.json();

                if (!response.ok || !resData.ok) {
                    const errores = resData.errors
                        ? Object.values(resData.errors).flat().join("\n")
                        : resData.msg ||
                          resData.message ||
                          "No se pudo guardar el inventario.";

                    throw new Error(errores);
                }

                Alert.exito("¡Conseguido!", resData.msg || "Inventario guardado correctamente.", async () => {
                    if (modalInventario && typeof bootstrap !== "undefined") {
                        bootstrap.Modal.getOrCreateInstance(modalInventario).hide();
                    }
                    await cargarInventarios();
                });
            } catch (err) {
                console.error("Error al guardar inventario:", err);
                Alert.error("Error", err.message);
            } finally {
                btnGuardar.disabled = false;
            }
        });
    }
});

async function cerrarInventario(id, fila) {
    const nombreInventario = fila.cells[0]?.textContent.trim() || id;
    const estado = fila.cells[8]?.textContent.trim().toUpperCase();

    if (estado === "CERRADO") {
        Alert.advertencia("Atención", "Este inventario ya se encuentra cerrado.");
        return;
    }

    Alert.confirmar(
        "¿Está seguro?",
        `¿Está seguro de que desea cerrar el inventario ${nombreInventario}?`,
        async () => {
            const tokenMeta = document.querySelector('meta[name="csrf-token"]');
            const token = tokenMeta ? tokenMeta.getAttribute("content") : "";

            const botones = document.querySelectorAll(
                '#mpTomaInventario .tb-btn[data-acc="eliminar"]',
            );

            botones.forEach((btn) => {
                btn.disabled = true;
            });

            try {
                const response = await fetch(
                    `/inventario/cerrar/${encodeURIComponent(id)}`,
                    {
                        method: "PUT",
                        headers: {
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token,
                        },
                    },
                );

                const resData = await response.json();

                if (!response.ok || !resData.ok) {
                    throw new Error(
                        resData.msg ||
                            resData.message ||
                            "No se pudo cerrar el inventario.",
                    );
                }

                Alert.exito(
                    "¡Conseguido!",
                    resData.msg || "Inventario cerrado, proceda a generar el reporte.",
                    async () => {
                        await cargarInventarios();
                    }
                );
            } catch (err) {
                console.error("Error al cerrar inventario:", err);
                Alert.error("Error", err.message);
            } finally {
                botones.forEach((btn) => {
                    btn.disabled = false;
                });
            }
        }
    );
}

function abrirModal() {
    const elModal = document.getElementById("modalInventario");

    if (elModal && typeof bootstrap !== "undefined") {
        bootstrap.Modal.getOrCreateInstance(elModal).show();
    }
}

function actualizarCorrelativo() {
    const txtAnio = document.getElementById("txtSerie");
    const txtNumero = document.getElementById("txtNumero");

    if (!txtAnio || !txtNumero) return;

    const anio = String(txtAnio.value || "").trim();

    if (!/^\d{4}$/.test(anio)) {
        txtNumero.value = "";
        return;
    }

    let mayorNumero = 0;

    document.querySelectorAll("#tblInventarios tbody tr").forEach((fila) => {
        const texto = fila.cells[0]?.textContent.trim() || "";
        const coincidencia = texto.match(/^(\d{4})-(\d+)$/);

        if (coincidencia && coincidencia[1] === anio) {
            mayorNumero = Math.max(mayorNumero, Number(coincidencia[2]));
        }
    });

    txtNumero.value = mayorNumero + 1;
}

function rellenarFormulario(d) {
    document.getElementById("txtSerie").value = d.anio || "";
    document.getElementById("txtNumero").value = d.numero || "";
    document.getElementById("cboEstadoInventario").value =
        d.estado || "ABIERTO";
    document.getElementById("cboSalaInventario").value = d.sala_id || "";
    document.getElementById("cboCoordinador").value = d.coordinador_id || "";
    document.getElementById("cboAsistente1").value = d.asistente1_id || "";
    document.getElementById("cboAsistente2").value = d.asistente2_id || "";
    document.getElementById("txtCoordinador").value =
        d.nombre_coordinador || "";
    document.getElementById("txtAsistente1").value = d.nombre_asistente1 || "";
    document.getElementById("txtAsistente2").value = d.nombre_asistente2 || "";
    document.getElementById("txtFechaEntrega").value = d.fecha_entrega || "";
    document.getElementById("txtObservacionInventario").value =
        d.observacion || "";
}

async function cargarDatosYMostrar(id, esSoloLectura) {
    try {
        await cargarComboboxesInventario();

        const response = await fetch(`/inventario/mostrar/${id}`, {
            headers: { Accept: "application/json" },
        });

        const resData = await response.json();

        if (!response.ok || !resData.ok || !resData.data) {
            throw new Error(
                resData.msg || "No se pudieron obtener los datos del registro.",
            );
        }

        const d = resData.data;
        idInventarioEditando = esSoloLectura ? null : d.id;
        inventarioSoloLectura = esSoloLectura;

        const modalEl = document.getElementById("modalInventario");

        if (modalEl) {
            modalEl
                .querySelectorAll("input, select, textarea")
                .forEach((el) => {
                    el.disabled = esSoloLectura;
                });

            const btnGuardar = document.getElementById("btnGuardarInventario");

            if (btnGuardar) {
                btnGuardar.style.display = esSoloLectura
                    ? "none"
                    : "inline-block";
                btnGuardar.disabled = esSoloLectura;
            }

            const titulo = document.getElementById("modalInventarioTitle");

            if (titulo) {
                titulo.textContent = esSoloLectura
                    ? "DETALLE Inventario"
                    : "EDITAR Inventario";
            }
        }

        rellenarFormulario(d);

        limpiarBienesInventario();

        if (d.sala_id) {
            await cargarBienesPorSala(d.sala_id);

            const detalles = Array.isArray(d.bienes) ? d.bienes : [];

            if (detalles.length > 0) {
                const porBien = new Map(
                    detalles.map((detalle) => [
                        String(detalle.idBien),
                        detalle.nroDRELM ?? detalle.nroDrelm ?? "",
                    ]),
                );

                document
                    .querySelectorAll("#tblBienesInventario tbody tr[data-id-bien]")
                    .forEach((fila) => {
                        const input = fila.querySelector(".txtNroDrelm");

                        if (input) {
                            input.value =
                                porBien.get(String(fila.dataset.idBien)) || "";
                        }
                    });
            }
        }

        if (esSoloLectura) {
            bloquearCamposDrelm();
        }

        abrirModal();
    } catch (err) {
        console.error("Error al obtener inventario:", err);
        Alert.error("Error", err.message);
    }
}

function prepararEdicion(id) {
    cargarDatosYMostrar(id, false);
}

function verDetalleInventario(id) {
    cargarDatosYMostrar(id, true);
}

function bloquearCamposDrelm() {
    document
        .querySelectorAll("#tblBienesInventario .txtNroDrelm")
        .forEach((input) => {
            input.disabled = true;
        });

    const btnBuscar = document.getElementById("btnBuscarBienesInventario");
    if (btnBuscar) btnBuscar.disabled = true;
}

function obtenerBienesDrelm() {
    return Array.from(
        document.querySelectorAll(
            "#tblBienesInventario tbody tr[data-id-bien]",
        ),
    ).map((fila) => ({
        idBien: Number(fila.dataset.idBien),
        nroDRELM: fila.querySelector(".txtNroDrelm")?.value.trim() || "",
    }));
}

function limpiarBackdrops() {
    document.querySelectorAll(".modal-backdrop").forEach((b) => b.remove());
    document.body.classList.remove("modal-open");
    document.body.style.removeProperty("padding-right");
    document.body.style.removeProperty("overflow");
}

async function cargarInventarios() {
    const tbody = document.querySelector("#tblInventarios tbody");
    if (!tbody) return;

    tbody.innerHTML =
        '<tr><td colspan="9" class="text-center">Cargando...</td></tr>';

    try {
        const response = await fetch("/inventario/listar", {
            headers: { Accept: "application/json" },
        });

        const resData = await response.json();

        if (!response.ok || !resData.ok) {
            throw new Error(
                resData.msg || "No se pudieron cargar los inventarios.",
            );
        }

        const items = resData.data || [];

        if (items.length === 0) {
            tbody.innerHTML =
                '<tr><td colspan="9" class="text-center text-muted">No hay registros de inventario.</td></tr>';
            return;
        }

        const fragment = document.createDocumentFragment();

        items.forEach((item) => {
            const tr = document.createElement("tr");
            tr.dataset.id = item.idInventario;

            [
                item.INVENTARIO,
                item.SALA,
                item.COORDINADOR,
                item.ASISTENTE_T1,
                item.ASISTENTE_T2,
                item.FECHA_ENTREGA,
                item.OBSERVACION,
                item.CANTIDAD_DE_BIENES,
                item.ESTADO,
            ].forEach((valor) => {
                const td = document.createElement("td");
                td.textContent = valor ?? "";
                tr.appendChild(td);
            });

            fragment.appendChild(tr);
        });

        tbody.innerHTML = "";
        tbody.appendChild(fragment);
    } catch (err) {
        console.error("Error al listar inventarios:", err);
        tbody.innerHTML = `<tr><td colspan="9" class="text-center text-danger">${escaparHTML(err.message || "Error al cargar datos.")}</td></tr>`;
    }
}

function cargarComboboxesInventario() {
    const select = document.getElementById("cboSalaInventario");
    if (!select) return Promise.resolve();

    return fetch("/sala/listar", {
        headers: { Accept: "application/json" },
    })
        .then(async (response) => {
            const resData = await response.json();

            if (!response.ok) {
                throw new Error(
                    resData.msg ||
                        resData.message ||
                        "No se pudieron cargar las salas.",
                );
            }

            const items =
                resData.data || (Array.isArray(resData) ? resData : []);

            const valorActual = select.value;
            select.innerHTML =
                '<option value="">Seleccione una sala...</option>';

            items.forEach((i) => {
                const valor = i.idSala ?? i.id ?? "";
                const nombre =
                    i.nombreSala ?? i.nombre ?? i.NOMBRE ?? i.descripcion ?? "";

                if (valor !== "") {
                    const option = document.createElement("option");
                    option.value = valor;
                    option.textContent = nombre || `Sala ${valor}`;
                    select.appendChild(option);
                }
            });

            if (
                [...select.options].some(
                    (option) => option.value === String(valorActual),
                )
            ) {
                select.value = valorActual;
            }
        })
        .catch((err) => {
            console.error("Error al cargar salas:", err);
            throw err;
        });
}

async function cargarPersonalPorSala(idSala) {
    try {
        const response = await fetch(`/inventario/personal-sala/${idSala}`, {
            headers: { Accept: "application/json" },
        });

        const resData = await response.json();

        if (!response.ok || !resData.ok) {
            throw new Error(
                resData.msg || "No se pudo cargar el personal asignado.",
            );
        }

        const personal = resData.data || {};

        document.getElementById("cboCoordinador").value =
            personal.coordinador?.idPersonal || "";
        document.getElementById("txtCoordinador").value =
            personal.coordinador?.nombre || "";

        document.getElementById("cboAsistente1").value =
            personal.asistente1?.idPersonal || "";
        document.getElementById("txtAsistente1").value =
            personal.asistente1?.nombre || "";

        document.getElementById("cboAsistente2").value =
            personal.asistente2?.idPersonal || "";
        document.getElementById("txtAsistente2").value =
            personal.asistente2?.nombre || "";

        if (!personal.coordinador || !personal.asistente1) {
            Alert.advertencia(
                "Atención",
                "La sala seleccionada no tiene coordinador o Asistente T1 asignado.",
            );
        }
    } catch (err) {
        console.error("Error al cargar personal:", err);
        limpiarPersonalInventario();
        Alert.error("Error", "Error al cargar el personal de la sala: " + err.message);
    }
}

async function cargarBienesPorSala(idSala) {
    const tbody = document.querySelector("#tblBienesInventario tbody");
    const etiqueta = document.getElementById("lblCantidadBienesInventario");

    if (!tbody) return;

    tbody.innerHTML =
        '<tr><td colspan="9" class="text-center py-4">Cargando bienes...</td></tr>';

    if (etiqueta) etiqueta.textContent = "Cargando...";

    try {
        const response = await fetch(`/inventario/bienes-sala/${idSala}`, {
            headers: { Accept: "application/json" },
        });

        const resData = await response.json();

        if (!response.ok || !resData.ok) {
            throw new Error(resData.msg || "No se pudieron cargar los bienes.");
        }

        bienesInventario = resData.data || [];

        if (bienesInventario.length === 0) {
            tbody.innerHTML =
                '<tr><td colspan="9" class="text-center text-muted py-4">No hay bienes registrados en esta sala.</td></tr>';

            if (etiqueta) etiqueta.textContent = "0 bienes";
            return;
        }

        const fragment = document.createDocumentFragment();

        bienesInventario.forEach((bien) => {
            const tr = document.createElement("tr");
            tr.dataset.idBien = bien.idBien;

            const columnas = [
                bien.GRUPO,
                bien.CBI,
                bien.DESCRIPCION,
                bien.MARCA,
                bien.MODELO,
                bien.SERIE_MEDIDA,
                bien.OTRAS_ESPECIFICACIONES,
                bien.ESTADO,
            ];

            columnas.forEach((valor) => {
                const td = document.createElement("td");
                td.textContent = valor ?? "";
                tr.appendChild(td);
            });

            const tdDrelm = document.createElement("td");
            const inputDrelm = document.createElement("input");

            inputDrelm.type = "text";
            inputDrelm.inputMode = "numeric";
            inputDrelm.className = "form-control form-control-sm txtNroDrelm";
            inputDrelm.placeholder = "NRO_DRELM";
            inputDrelm.dataset.idBien = bien.idBien;
            inputDrelm.disabled = inventarioSoloLectura;

            inputDrelm.addEventListener("input", function () {
                this.value = this.value.replace(/[^0-9]/g, "");
            });

            tdDrelm.appendChild(inputDrelm);
            tr.appendChild(tdDrelm);

            fragment.appendChild(tr);
        });

        tbody.innerHTML = "";
        tbody.appendChild(fragment);

        if (etiqueta) {
            etiqueta.textContent = `${bienesInventario.length} bienes`;
        }
    } catch (err) {
        console.error("Error al cargar bienes:", err);
        tbody.innerHTML = `<tr><td colspan="9" class="text-center text-danger py-4">${escaparHTML(err.message)}</td></tr>`;

        if (etiqueta) etiqueta.textContent = "Error";
    }
}

function limpiarPersonalInventario() {
    document.getElementById("cboCoordinador").value = "";
    document.getElementById("txtCoordinador").value = "";

    document.getElementById("cboAsistente1").value = "";
    document.getElementById("txtAsistente1").value = "";

    document.getElementById("cboAsistente2").value = "";
    document.getElementById("txtAsistente2").value = "";
}

function limpiarBienesInventario() {
    bienesInventario = [];

    const tbody = document.querySelector("#tblBienesInventario tbody");

    if (tbody) {
        tbody.innerHTML =
            '<tr><td colspan="9" class="text-center text-muted py-4">Seleccione una sala y pulse la lupa para cargar los bienes.</td></tr>';
    }

    const etiqueta = document.getElementById("lblCantidadBienesInventario");
    if (etiqueta) etiqueta.textContent = "0 bienes";

    const btnBuscar = document.getElementById("btnBuscarBienesInventario");
    if (btnBuscar) btnBuscar.disabled = inventarioSoloLectura;
}

function escaparHTML(valor) {
    return String(valor ?? "").replace(
        /[&<>"']/g,
        (caracter) =>
            ({
                "&": "&amp;",
                "<": "&lt;",
                ">": "&gt;",
                '"': "&quot;",
                "'": "&#39;",
            })[caracter],
    );
}
