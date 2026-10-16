document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelBien = document.getElementById("mpBien") || document;
        var bienvenida = document.getElementById("mpBienvenida");
        var tblBody = document.getElementById("tbody_bien") || document.querySelector("#tblBien tbody");
        var txtBuscar = document.getElementById("txtBuscarBien");
        var cboFiltroSala = document.getElementById("cboFiltroSala");

        var bienCache = [];
        var bienSeleccionado = null;

        function esc(v) {
            return String(v || "").replace(/[&<">]/g, function (c) {
                return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
            });
        }

        function getCsrfToken() {
            return document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                   document.querySelector('input[name="_token"]')?.value || "";
        }

        function formatearFecha(f) {
            if (!f) return "";
            var fechaStr = String(f).trim();
            var regex = /^(\d{4})[-/](\d{1,2})[-/](\d{1,2})(?:[ T](\d{1,2}):(\d{1,2}))?/;
            var match = fechaStr.match(regex);
            var d;

            if (match) {
                d = new Date(match[1], match[2] - 1, match[3], match[4] || 0, match[5] || 0);
            } else {
                d = new Date(f);
                if (isNaN(d.getTime())) return f;
            }

            d.setHours(d.getHours() - 5);

            var dia = String(d.getDate()).padStart(2, '0');
            var mes = String(d.getMonth() + 1).padStart(2, '0');
            var anio = d.getFullYear();
            var h24 = d.getHours();
            var min = String(d.getMinutes()).padStart(2, '0');
            var ampm = h24 >= 12 ? 'PM' : 'AM';
            var h12 = String(h24 % 12 || 12).padStart(2, '0');

            return `${dia}/${mes}/${anio} ${h12}:${min} ${ampm}`;
        }

        function llenarSelect(selectEl, lista, valKey, textKey, defaultText) {
            if (!selectEl || !Array.isArray(lista)) return;
            var html = `<option value="">-- ${defaultText} --</option>`;
            html += lista.map(item => `<option value="${esc(item[valKey])}">${esc(item[textKey])}</option>`).join('');
            selectEl.innerHTML = html;
        }

        function setEstadoFormularioBien(deshabilitado) {
            var form = document.getElementById("formBien");
            if (form) {
                form.querySelectorAll("input, select, textarea").forEach(el => el.disabled = deshabilitado);
            }
            var btnGuardar = document.getElementById("btnGuardarBien");
            if (btnGuardar) btnGuardar.style.display = deshabilitado ? "none" : "";
        }

        function cargarCamposFormulario(data) {
            data = data || {};
            var mapaCampos = {
                "txtIdBienOriginal": data.idBien || "",
                "txtCbi": data.cbi || "",
                "txtDescripcionBien": data.descripcion || "",
                "txtSerieMedida": data.serieMedida || "",
                "txtOtrasEspecificaciones": data.otrasEspecificaciones || "",
                "cboSala": data.idSala || (cboFiltroSala ? cboFiltroSala.value : ""),
                "cboGrupo": data.idGrupo || "",
                "cboTipo": data.idTipo || "",
                "cboMarca": data.idMarca || "",
                "cboModelo": data.idModelo || "",
                "cboEstado": data.idEstado || ""
            };

            Object.keys(mapaCampos).forEach(id => {
                var el = document.getElementById(id);
                if (el) el.value = mapaCampos[id];
            });
        }

        function obtenerSeleccionado() {
            if (!bienSeleccionado && tblBody) {
                var trSel = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (trSel) {
                    var id = trSel.getAttribute("data-id");
                    bienSeleccionado = bienCache.find(g => String(g.idBien) === String(id));
                }
            }
            return bienSeleccionado;
        }

        function pintarBien(lista) {
            if (!tblBody) return;
            if (!lista.length) {
                tblBody.innerHTML = '<tr><td colspan="13" class="text-center">No hay registros disponibles</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(item => `
                <tr data-id="${esc(item.idBien)}" style="cursor:pointer;">
                    <td>${esc(item.cbi)}</td>
                    <td>${esc(item.descripcion)}</td>
                    <td>${esc(item.tipo)}</td>
                    <td>${esc(item.marca)}</td>
                    <td>${esc(item.modelo)}</td>
                    <td>${esc(item.estado)}</td>
                    <td>${esc(item.grupo)}</td>
                    <td>${esc(item.serieMedida)}</td>
                    <td>${esc(item.otrasEspecificaciones)}</td>
                    <td>${esc(formatearFecha(item.fechaCreacion))}</td>
                    <td>${esc(formatearFecha(item.fechaModificacion))}</td>
                    <td>${esc(item.idUsuarioCrea)}</td>
                    <td>${esc(item.idUsuarioModifica)}</td>
                </tr>
            `).join("");
        }

        async function cargarSalasFiltro() {
            if (!cboFiltroSala) return;
            try {
                var r = await fetch("/bienes/salas", { headers: { Accept: "application/json" } });
                var j = await r.json();
                if (j.ok) llenarSelect(cboFiltroSala, j.data, "idSala", "descripcion", "TODAS LAS SALAS");
            } catch (e) {
                console.error("Error al cargar salas en filtro:", e);
            }
        }

        async function cargarCombosModal() {
            try {
                var [rSala, rCombos] = await Promise.all([
                    fetch("/bienes/salas", { headers: { Accept: "application/json" } }),
                    fetch("/bienes/combos", { headers: { Accept: "application/json" } })
                ]);

                var jSala = await rSala.json();
                if (jSala.ok) llenarSelect(document.getElementById("cboSala"), jSala.data, "idSala", "descripcion", "SELECCIONE SALA");

                var jCombos = await rCombos.json();
                if (jCombos.ok && jCombos.data) {
                    var d = jCombos.data;
                    llenarSelect(document.getElementById("cboGrupo"), d.grupos, "idGrupo", "nombre", "SELECCIONE GRUPO");
                    llenarSelect(document.getElementById("cboTipo"), d.tipos, "idTipo", "nombre", "SELECCIONE TIPO");
                    llenarSelect(document.getElementById("cboMarca"), d.marcas, "idMarca", "nombre", "SELECCIONE MARCA");
                    llenarSelect(document.getElementById("cboModelo"), d.modelos, "idModelo", "nombre", "SELECCIONE MODELO");
                    llenarSelect(document.getElementById("cboEstado"), d.estados, "idEstado", "nombre", "SELECCIONE ESTADO");
                }
            } catch (e) {
                console.error("Error al cargar combos del modal:", e);
            }
        }

        async function listarBien() {
            if (!tblBody) return;
            tblBody.innerHTML = '<tr><td colspan="13" class="text-center">Cargando...</td></tr>';
            bienSeleccionado = null;

            try {
                var r = await fetch("/bienes/listar", { headers: { Accept: "application/json" } });
                if (!r.ok) throw new Error("Error HTTP " + r.status + ": No se pudo conectar con el servidor.");

                var j = await r.json();
                var lista = j.data || (Array.isArray(j) ? j : []);
                if (!Array.isArray(lista)) throw new Error("Sin datos");

                bienCache = lista;
                aplicarFiltros();
            } catch (e) {
                console.error("Error al cargar bienes:", e);
                tblBody.innerHTML = `<tr><td colspan="13" class="text-center text-danger">${esc(e.message || "Error al cargar datos")}</td></tr>`;
            }
        }

        function aplicarFiltros() {
            var q = txtBuscar ? txtBuscar.value.trim().toLowerCase() : "";
            var idSalaSel = cboFiltroSala ? cboFiltroSala.value : "";

            var filtrados = bienCache.filter(item => {
                var texto = Object.values(item).join(" ").toLowerCase();
                var coincideTexto = !q || texto.includes(q);
                var coincideSala = !idSalaSel || String(item.idSala) === String(idSalaSel);
                return coincideTexto && coincideSala;
            });

            pintarBien(filtrados);
        }

        function mostrarModal(titulo, esSoloLectura) {
            var title = document.getElementById("modalBienTitle");
            if (title) title.textContent = titulo;

            setEstadoFormularioBien(esSoloLectura);

            var modalEl = document.getElementById("modalBien");
            if (modalEl) {
                (bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl)).show();
            }
        }

        async function abrirModalNuevo() {
            var salaSeleccionadaFiltro = cboFiltroSala ? cboFiltroSala.value : "";
            if (!salaSeleccionadaFiltro) {
                Alert.advertencia("Selección requerida", "Seleccione una sala antes de agregar.");
                return;
            }

            document.getElementById("formBien")?.reset();
            await cargarCombosModal();
            cargarCamposFormulario({});
            
            var cboModalSala = document.getElementById("cboSala");
            if (cboModalSala) cboModalSala.value = salaSeleccionadaFiltro;

            mostrarModal("Nuevo Bien", false);
        }

        async function abrirModalFormulario(titulo, esSoloLectura) {
            var item = obtenerSeleccionado();
            if (!item) {
                Alert.advertencia("Selección requerida", "Por favor, seleccione un registro de la tabla.");
                return;
            }
            await cargarCombosModal();
            cargarCamposFormulario(item);
            mostrarModal(titulo, esSoloLectura);
        }

        async function guardarBien() {
            var cbi = document.getElementById("txtCbi")?.value.trim();
            var descripcion = document.getElementById("txtDescripcionBien")?.value.trim();
            var serieMedida = document.getElementById("txtSerieMedida")?.value.trim();
            var otrasEspecificaciones = document.getElementById("txtOtrasEspecificaciones")?.value.trim();
            var idSala = document.getElementById("cboSala")?.value;
            var idGrupo = document.getElementById("cboGrupo")?.value;
            var idTipo = document.getElementById("cboTipo")?.value;
            var idMarca = document.getElementById("cboMarca")?.value;
            var idModelo = document.getElementById("cboModelo")?.value;
            var idEstado = document.getElementById("cboEstado")?.value;

            // VALIDACIÓN DE CAMPOS OBLIGATORIOS
            if (!cbi) {
                Alert.advertencia("Campo requerido", "El CBI es obligatorio.");
                return;
            }
            if (!descripcion) {
                Alert.advertencia("Campo requerido", "La descripción del bien es obligatoria.");
                return;
            }
            if (!idSala) {
                Alert.advertencia("Campo requerido", "Debe seleccionar una sala.");
                return;
            }
            if (!idGrupo) {
                Alert.advertencia("Campo requerido", "Debe seleccionar un grupo.");
                return;
            }
            if (!idTipo) {
                Alert.advertencia("Campo requerido", "Debe seleccionar un tipo.");
                return;
            }
            if (!idMarca) {
                Alert.advertencia("Campo requerido", "Debe seleccionar una marca.");
                return;
            }
            if (!idModelo) {
                Alert.advertencia("Campo requerido", "Debe seleccionar un modelo.");
                return;
            }
            if (!idEstado) {
                Alert.advertencia("Campo requerido", "Debe seleccionar un estado.");
                return;
            }
            if (!serieMedida) {
                Alert.advertencia("Campo requerido", "La serie / medida es obligatoria.");
                return;
            }
            if (!otrasEspecificaciones) {
                Alert.advertencia("Campo requerido", "Las otras especificaciones son obligatorias.");
                return;
            }

            try {
                var response = await fetch("/bienes/guardar", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        Accept: "application/json",
                        "X-CSRF-TOKEN": getCsrfToken()
                    },
                    body: JSON.stringify({
                        idOriginal: document.getElementById("txtIdBienOriginal")?.value,
                        cbi: cbi,
                        descripcion: descripcion,
                        serieMedida: serieMedida,
                        otrasEspecificaciones: otrasEspecificaciones,
                        idSala: idSala,
                        idGrupo: idGrupo,
                        idTipo: idTipo,
                        idMarca: idMarca,
                        idModelo: idModelo,
                        idEstado: idEstado
                    })
                });

                var data = await response.json();
                if (data.ok) {
                    var modalEl = document.getElementById("modalBien");
                    if (modalEl) bootstrap.Modal.getInstance(modalEl)?.hide();
                    Alert.exito("¡Guardado!", data.msg || "Bien guardado correctamente.", async function () {
                        await listarBien();
                    });
                } else {
                    Alert.error("Error al guardar", data.msg || "Error al guardar el bien.");
                }
            } catch (e) {
                Alert.error("Error de conexión", "Error de conexión al guardar.");
            }
        }

        function confirmarEliminar() {
            var item = obtenerSeleccionado();
            if (!item) {
                Alert.advertencia("Selección requerida", "Por favor, seleccione un registro de la tabla para eliminar.");
                return;
            }

            var nombre = item.descripcion || item.idBien || "este bien";

            Alert.confirmar("¿Eliminar registro?", `¿Está seguro de eliminar el bien "${nombre}"?`, async function () {
                try {
                    var res = await fetch("/bienes/eliminar", {
                        method: "POST",
                        headers: {
                            "X-CSRF-TOKEN": getCsrfToken(),
                            "Content-Type": "application/json",
                            Accept: "application/json"
                        },
                        body: JSON.stringify({ idBien: item.idBien })
                    });

                    var data = await res.json();
                    if (data.ok) {
                        bienSeleccionado = null;
                        Alert.exito("Eliminado", data.msg || "Bien eliminado correctamente.", async function () {
                            await listarBien();
                        });
                    } else {
                        Alert.error("Error al eliminar", data.msg || "Error al eliminar el bien.");
                    }
                } catch (err) {
                    console.error("Error al eliminar:", err);
                    Alert.error("Error de conexión", "Error de conexión con el servidor.");
                }
            });
        }

        function exportarExcel() {
            if (!bienCache || !bienCache.length) { 
                Alert.advertencia("Sin datos", "No hay datos para exportar."); 
                return; 
            }
            var csv = "cbi,descripcion,Tipo,Marca,Modelo,Estado,Grupo,serieMedida,otrasEspecificaciones,fechaCreacion,fechaModificacion,idUsuarioCrea,idUsuarioModifica\n";
            bienCache.forEach(item => {
                var cols = [
                    item.cbi, item.descripcion, item.tipo, item.marca, item.modelo,
                    item.estado, item.grupo, item.serieMedida, item.otrasEspecificaciones,
                    formatearFecha(item.fechaCreacion), formatearFecha(item.fechaModificacion),
                    item.idUsuarioCrea, item.idUsuarioModifica
                ];
                csv += cols.map(c => `"${String(c || "").replace(/"/g, '""')}"`).join(",") + "\n";
            });

            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.download = `bienes_${new Date().toISOString().slice(0, 10)}.csv`;
            link.click();
        }

        if (tblBody) {
            tblBody.addEventListener("click", function (e) {
                var tr = e.target.closest("tr[data-id]");
                if (!tr) return;
                tblBody.querySelectorAll("tr").forEach(x => x.classList.remove("table-active", "selected", "sel"));
                tr.classList.add("table-active", "selected", "sel");
                var id = tr.getAttribute("data-id");
                bienSeleccionado = bienCache.find(g => String(g.idBien) === String(id));
            });
        }

        if (txtBuscar) txtBuscar.addEventListener("keyup", aplicarFiltros);
        if (cboFiltroSala) cboFiltroSala.addEventListener("change", aplicarFiltros);

        document.getElementById("btnGuardarBien")?.addEventListener("click", e => { e.preventDefault(); guardarBien(); });
        document.getElementById("formBien")?.addEventListener("submit", e => { e.preventDefault(); guardarBien(); });

        panelBien.querySelectorAll(".tb-btn").forEach(b => {
            b.addEventListener("click", function () {
                var acc = b.dataset.acc;
                if (acc === "nuevo") abrirModalNuevo();
                else if (acc === "editar") abrirModalFormulario("Editar Bien", false);
                else if (acc === "eliminar") confirmarEliminar();
                else if (acc === "recargar") listarBien();
                else if (["imprimir", "consultar", "detalle"].includes(acc)) abrirModalFormulario("Consulta de Bien", true);
                else if (acc === "excel") exportarExcel();
                else if (acc === "salir" && bienvenida) {
                    if (panelBien !== document) panelBien.hidden = true;
                    bienvenida.hidden = false;
                }
            });
        });

        window.addEventListener("modulo:abrir", e => {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "bienes" || mod === "bien") listarBien();
        });

        cargarSalasFiltro();
        listarBien();
    })();
});