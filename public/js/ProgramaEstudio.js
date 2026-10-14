document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelPrograma = document.getElementById("mpProgramaEstudio");
        var bienvenida = document.getElementById("mpBienvenida");
        if (!panelPrograma) return;

        var tblBody = document.querySelector("#tblProgramaEstudio tbody");
        var txtBuscar = document.getElementById("txtBuscarProgramaEstudio");
        var programaCache = [];
        var usuariosCache = [];
        var programaSeleccionado = null;

        var modalPrograma = new bootstrap.Modal(document.getElementById("modalProgramaEstudio"));

        function esc(v) {
            return String(v || "").replace(/[&<">]/g, function (c) {
                return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
            });
        }

        async function cargarUsuariosCache() {
            if (usuariosCache.length === 0) {
                try {
                    var r = await fetch("/programa-estudio/usuarios", { headers: { Accept: "application/json" } });
                    var j = await r.json();

                    if (j.ok && Array.isArray(j.data)) {
                        usuariosCache = j.data;
                    } else if (Array.isArray(j)) {
                        usuariosCache = j;
                    } else {
                        usuariosCache = [];
                    }
                } catch (e) {
                    usuariosCache = [];
                }
            }
        }

        function obtenerNombreUsuario(u) {
            if (!u) return "";
            return u.nombre_completo || u.nombre || u.nombres || u.name || 
                   (u.apellidos ? ((u.nombres || "") + " " + u.apellidos).trim() : "");
        }

        async function poblarCombosUsuarios() {
            await cargarUsuariosCache();

            var combosIds = ["cboCoordinadorArea", "cboAsistenteAreaT1", "cboAsistenteAreaT2"];

            combosIds.forEach(function (idSelect) {
                var select = document.getElementById(idSelect);
                if (!select) return;

                var html = '<option value="">-- Seleccione --</option>';

                usuariosCache.forEach(function (u) {
                    var idVal = u.id ?? u.idUsuario ?? u.idPersonal ?? u.id_usuario ?? u.id_personal ?? "";
                    var nombreTexto = obtenerNombreUsuario(u);
                    if (idVal !== "" && idVal !== null && idVal !== undefined) {
                        html += '<option value="' + esc(idVal) + '">' + esc(nombreTexto) + '</option>';
                    }
                });

                select.innerHTML = html;
            });
        }

        function setEstadoFormularioPrograma(deshabilitado) {
            var form = document.getElementById("formProgramaEstudio");
            var modalEl = document.getElementById("modalProgramaEstudio");

            if (form) {
                var elementos = form.querySelectorAll("input, select, textarea");
                elementos.forEach(function (el) {
                    el.disabled = deshabilitado;
                });
            }

            var btnGuardar = document.getElementById("btnGuardarProgramaEstudio") || 
                             (form ? form.querySelector('button[type="submit"]') : null) ||
                             (modalEl ? modalEl.querySelector('.btn-primary') : null);

            if (btnGuardar) {
                btnGuardar.style.display = deshabilitado ? "none" : "";
            }
        }

        function pintarProgramaEstudio(lista) {
            if (!lista.length) {
                tblBody.innerHTML = '<tr><td colspan="2" class="text-center">Sin programas de estudio registrados.</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(function (item) {
                var estado = (item.st_registro == 1 || item.st_registro == true) ? "ACTIVO" : "INACTIVO";
                return '<tr data-id="' + esc(item.idProgramaEstudio) + '">' +
                    '<td>' + esc(item.nombre) + '</td>' +
                    '<td>' + esc(estado) + '</td></tr>';
            }).join("");
        }

        async function mostrarProgramaEstudio() {
            tblBody.innerHTML = '<tr><td colspan="2" class="text-center">Cargando...</td></tr>';
            programaSeleccionado = null;

            try {
                var r = await fetch("/programa-estudio/listar", { headers: { Accept: "application/json" } });
                var j = await r.json();
                var lista = j.data || (Array.isArray(j) ? j : []);
                if (!Array.isArray(lista)) throw new Error("Sin datos");

                lista.sort(function (a, b) { return (a.nombre || "").localeCompare(b.nombre || ""); });
                programaCache = lista;
                pintarProgramaEstudio(programaCache);
                if (txtBuscar) txtBuscar.value = "";
            } catch (e) {
                tblBody.innerHTML = '<tr><td colspan="2" class="text-center text-danger">' + esc(e.message || "Error al cargar datos") + '</td></tr>';
            }
        }

        tblBody.addEventListener("click", function (e) {
            var tr = e.target.closest("tr[data-id]");
            if (!tr) return;
            tblBody.querySelectorAll("tr").forEach(function (x) { x.classList.remove("sel", "selected", "table-active"); });
            tr.classList.add("sel", "selected", "table-active");

            var id = tr.getAttribute("data-id");
            programaSeleccionado = programaCache.find(function (item) { return String(item.idProgramaEstudio) === String(id); });
        });

        if (txtBuscar) {
            txtBuscar.addEventListener("input", function () {
                var q = txtBuscar.value.trim().toLowerCase();
                if (!q) return pintarProgramaEstudio(programaCache);
                pintarProgramaEstudio(programaCache.filter(function (item) {
                    return (item.nombre || "").toLowerCase().includes(q);
                }));
            });
        }

        function asignarValorSelect(selectElement, val) {
            if (!selectElement) return;
            if (val === null || val === undefined || String(val).trim() === "") {
                selectElement.value = "";
                return;
            }
            var targetVal = String(val).trim().toUpperCase();
            for (var i = 0; i < selectElement.options.length; i++) {
                if (String(selectElement.options[i].value).trim().toUpperCase() === targetVal) {
                    selectElement.selectedIndex = i;
                    return;
                }
            }
            selectElement.value = "";
        }

        async function poblarFormulario(datos) {
            var detalle = datos || {};

            if (datos && datos.idProgramaEstudio) {
                try {
                    var res = await fetch("/programa-estudio/buscar/" + datos.idProgramaEstudio, {
                        headers: { Accept: "application/json" }
                    });
                    var resJson = await res.json();
                    if (resJson.ok && resJson.data) {
                        detalle = resJson.data;
                    } else if (resJson.idProgramaEstudio || resJson.nombre) {
                        detalle = resJson;
                    }
                } catch (e) {}
            }

            await poblarCombosUsuarios();

            var valCoord = detalle.idCoordinadorArea ?? detalle.id_coordinador_area ?? detalle.idCoordinador ?? "";
            var valAsis1 = detalle.idAsistenteAreaT1 ?? detalle.id_asistente_area_t1 ?? detalle.idAsistenteT1 ?? "";
            var valAsis2 = detalle.idAsistenteAreaT2 ?? detalle.id_asistente_area_t2 ?? detalle.idAsistenteT2 ?? "";

            var txtOrig = document.getElementById("txtIdProgramaEstudioOriginal");
            var txtNombre = document.getElementById("txtNombreProgramaEstudio");
            var cboCoord = document.getElementById("cboCoordinadorArea");
            var cboAsisT1 = document.getElementById("cboAsistenteAreaT1");
            var cboAsisT2 = document.getElementById("cboAsistenteAreaT2");
            var txtObs = document.getElementById("txtObservacionProgramaEstudio");

            if (txtOrig) txtOrig.value = detalle.idProgramaEstudio || "";
            if (txtNombre) txtNombre.value = detalle.nombre || "";
            if (txtObs) txtObs.value = detalle.observacion || "";

            asignarValorSelect(cboCoord, valCoord);
            asignarValorSelect(cboAsisT1, valAsis1);
            asignarValorSelect(cboAsisT2, valAsis2);
        }

        async function nuevoPrograma() {
            var form = document.getElementById("formProgramaEstudio");
            if (form) form.reset();

            await poblarCombosUsuarios();

            var txtOrig = document.getElementById("txtIdProgramaEstudioOriginal");
            if (txtOrig) txtOrig.value = "";

            var modalTitle = document.getElementById("modalProgramaEstudioTitle");
            if (modalTitle) modalTitle.textContent = "Nuevo Programa de Estudio";

            setEstadoFormularioPrograma(false);
            modalPrograma.show();
        }

        async function editarPrograma() {
            if (!programaSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    programaSeleccionado = programaCache.find(function (item) { return String(item.idProgramaEstudio) === String(id); });
                }
            }

            if (!programaSeleccionado) { 
                alert("Seleccione un programa de estudio de la lista para editar."); 
                return; 
            }

            await poblarFormulario(programaSeleccionado);

            var modalTitle = document.getElementById("modalProgramaEstudioTitle");
            if (modalTitle) modalTitle.textContent = "Editar Programa de Estudio";

            setEstadoFormularioPrograma(false);
            modalPrograma.show();
        }

        async function verDetalle() {
            if (!programaSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    programaSeleccionado = programaCache.find(function (item) { return String(item.idProgramaEstudio) === String(id); });
                }
            }

            if (!programaSeleccionado) { 
                alert("Seleccione un programa de estudio de la lista para consultar."); 
                return; 
            }

            await poblarFormulario(programaSeleccionado);

            var modalTitle = document.getElementById("modalProgramaEstudioTitle");
            if (modalTitle) modalTitle.textContent = "Consulta de Programa de Estudio";

            setEstadoFormularioPrograma(true);
            modalPrograma.show();
        }

        function confirmarEliminar() {
            if (!programaSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    programaSeleccionado = programaCache.find(function (item) { return String(item.idProgramaEstudio) === String(id); });
                }
            }

            if (!programaSeleccionado) {
                alert("Por favor, seleccione un programa de estudio de la tabla para eliminar.");
                return;
            }

            var nombre = programaSeleccionado.nombre || programaSeleccionado.idProgramaEstudio || "este registro";
            
            var msgEl = document.getElementById("txtProgramaEstudioEliminar");
            if (msgEl) {
                msgEl.textContent = nombre;
            }

            var modalEl = document.getElementById("modalEliminarProgramaEstudio");
            var btnEliminarAccion = document.getElementById("btnConfirmarEliminarProgramaEstudio");

            if (!modalEl) return;

            var bsModal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);

            btnEliminarAccion.onclick = async function () {
                bsModal.hide();

                var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || document.querySelector('input[name="_token"]')?.value;

                try {
                    var response = await fetch("/programa-estudio/eliminar/" + programaSeleccionado.idProgramaEstudio, {
                        method: "DELETE",
                        headers: {
                            "Content-Type": "application/json",
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token
                        }
                    });

                    var data = await response.json();

                    if (data.ok || data.success) {
                        await mostrarProgramaEstudio();
                    } else {
                        alert(data.msg || data.message || "Error al eliminar el programa de estudio.");
                    }
                } catch (e) {
                    alert("Error de conexión con el servidor.");
                }
            };

            bsModal.show();
        }

        var btnGuardar = document.getElementById("btnGuardarProgramaEstudio");
        if (btnGuardar) {
            btnGuardar.addEventListener("click", async function () {
                var form = document.getElementById("formProgramaEstudio");
                if (form && !form.checkValidity()) {
                    form.reportValidity();
                    return;
                }

                var nombre = document.getElementById("txtNombreProgramaEstudio").value.trim();
                var idOriginal = document.getElementById("txtIdProgramaEstudioOriginal").value;
                var idCoordinadorArea = document.getElementById("cboCoordinadorArea").value;
                var idAsistenteAreaT1 = document.getElementById("cboAsistenteAreaT1").value;
                var idAsistenteAreaT2 = document.getElementById("cboAsistenteAreaT2").value;
                var observacion = document.getElementById("txtObservacionProgramaEstudio").value.trim();

                try {
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || document.querySelector('input[name="_token"]')?.value;
                    var response = await fetch("/programa-estudio/guardar", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token
                        },
                        body: JSON.stringify({
                            idProgramaEstudio: idOriginal || null,
                            nombre: nombre,
                            idCoordinadorArea: idCoordinadorArea || null,
                            idAsistenteAreaT1: idAsistenteAreaT1 || null,
                            idAsistenteAreaT2: idAsistenteAreaT2 || null,
                            observacion: observacion
                        })
                    });

                    var data = await response.json();
                    if (data.ok || data.success) {
                        modalPrograma.hide();
                        await mostrarProgramaEstudio();
                    } else {
                        alert(data.msg || data.message || "Error al guardar el registro.");
                    }
                } catch (e) {
                    modalPrograma.hide();
                    alert("Error de conexión al guardar.");
                }
            });
        }

        function exportarExcel() {
            if (!programaCache.length) { alert("No hay datos para exportar."); return; }
            var csv = "Nombre,Estado\n";
            programaCache.forEach(function (item) {
                var estado = (item.st_registro == 1 || item.st_registro == true) ? "ACTIVO" : "INACTIVO";
                csv += '"' + (item.nombre || "") + '","' + estado + '"\n';
            });
            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            var url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "programas_estudio_" + new Date().toISOString().slice(0, 10) + ".csv");
            link.style.visibility = "hidden";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        panelPrograma.querySelectorAll(".tb-btn").forEach(function (b) {
            b.addEventListener("click", function () {
                var acc = b.dataset.acc;
                if (acc === "nuevo") nuevoPrograma();
                else if (acc === "editar") editarPrograma();
                else if (acc === "eliminar") confirmarEliminar();
                else if (acc === "recargar") mostrarProgramaEstudio();
                else if (acc === "imprimir" || acc === "consultar" || acc === "detalle") verDetalle();
                else if (acc === "excel") exportarExcel();
                else if (acc === "salir") {
                    panelPrograma.hidden = true;
                    if (bienvenida) bienvenida.hidden = false;
                }
            });
        });

        window.addEventListener("modulo:abrir", function (e) {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "programaestudio" || mod === "programa-estudio") {
                mostrarProgramaEstudio();
            }
        });
    })();
});