document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelTipo = document.getElementById("mpTipo");
        var bienvenida = document.getElementById("mpBienvenida");
        if (!panelTipo) return;

        var tblBody = document.querySelector("#tblTipo tbody");
        var txtBuscar = document.getElementById("txtBuscarTipo");
        var tipoCache = [];
        var tipoSeleccionado = null;

        function getModalTipo() {
            var el = document.getElementById("modalTipo");
            if (!el) return null;
            return bootstrap.Modal.getInstance(el) || new bootstrap.Modal(el);
        }

        function esc(v) {
            return String(v || "").replace(/[&<">]/g, function (c) {
                return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
            });
        }

        function setEstadoFormularioTipo(deshabilitado) {
            var form = document.getElementById("formTipo");
            var modalEl = document.getElementById("modalTipo");

            if (form) {
                var elementos = form.querySelectorAll("input, select, textarea");
                elementos.forEach(function (el) {
                    el.disabled = deshabilitado;
                });
            }

            var btnGuardar = document.getElementById("btnGuardarTipo") || 
                             (form ? form.querySelector('button[type="submit"]') : null) ||
                             (modalEl ? modalEl.querySelector('.btn-primary') : null);

            if (btnGuardar) {
                btnGuardar.style.display = deshabilitado ? "none" : "";
            }
        }

        function pintarTipo(lista) {
            if (!tblBody) return;
            if (!lista.length) {
                tblBody.innerHTML = '<tr><td class="text-center">Sin tipos registrados.</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(function (t) {
                return '<tr data-id="' + esc(t.NOMBRE) + '" style="cursor:pointer;">' +
                    '<td>' + esc(t.NOMBRE) + '</td></tr>';
            }).join("");
        }

        async function mostrarTipo() {
            if (!tblBody) return;
            tblBody.innerHTML = '<tr><td class="text-center">Cargando...</td></tr>';
            tipoSeleccionado = null;

            try {
                var r = await fetch("/tipo/listar", { headers: { Accept: "application/json" } });
                var j = await r.json();
                if (!j.ok) throw new Error(j.msg || "Sin datos");
                tipoCache = j.data || [];
                pintarTipo(tipoCache);
                if (txtBuscar) txtBuscar.value = "";
            } catch (e) {
                tblBody.innerHTML = '<tr><td class="text-center text-danger">' + esc(e.message) + '</td></tr>';
            }
        }

        if (!panelTipo.hidden && panelTipo.style.display !== "none") {
            mostrarTipo();
        }

        var observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                if (mutation.attributeName === "hidden" || mutation.attributeName === "style") {
                    if (!panelTipo.hidden && panelTipo.style.display !== "none") {
                        mostrarTipo();
                    }
                }
            });
        });
        observer.observe(panelTipo, { attributes: true });

        if (tblBody) {
            tblBody.addEventListener("click", function (e) {
                var tr = e.target.closest("tr[data-id]");
                if (!tr) return;
                tblBody.querySelectorAll("tr").forEach(function (x) { x.classList.remove("sel", "selected", "table-active"); });
                tr.classList.add("sel", "selected", "table-active");

                var id = tr.getAttribute("data-id");
                tipoSeleccionado = tipoCache.find(function (item) { return String(item.NOMBRE) === String(id); });
            });
        }

        if (txtBuscar) {
            txtBuscar.addEventListener("input", function () {
                var q = txtBuscar.value.trim().toLowerCase();
                if (!q) return pintarTipo(tipoCache);
                pintarTipo(tipoCache.filter(function (t) {
                    return (t.NOMBRE || "").toLowerCase().includes(q);
                }));
            });
        }

        function nuevoTipo() {
            var form = document.getElementById("formTipo");
            if (form) form.reset();

            var txtOrig = document.getElementById("txtIdTipoOriginal");
            if (txtOrig) txtOrig.value = "";

            var modalTitle = document.getElementById("modalTipoTitle");
            if (modalTitle) modalTitle.textContent = "Nuevo Tipo";

            setEstadoFormularioTipo(false);
            var modal = getModalTipo();
            if (modal) modal.show();
        }

        function editarTipo() {
            if (!tipoSeleccionado) {
                var s = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (s) {
                    var id = s.getAttribute("data-id");
                    tipoSeleccionado = tipoCache.find(function (t) { return String(t.NOMBRE) === String(id); });
                }
            }

            if (!tipoSeleccionado) {
                Alert.advertencia("Selección requerida", "Seleccione un tipo de la lista para editar.");
                return;
            }

            var txtOrig = document.getElementById("txtIdTipoOriginal");
            var txtNombre = document.getElementById("txtNombreTipo");
            var modalTitle = document.getElementById("modalTipoTitle");

            if (txtOrig) txtOrig.value = tipoSeleccionado.NOMBRE || "";
            if (txtNombre) txtNombre.value = tipoSeleccionado.NOMBRE || "";
            if (modalTitle) modalTitle.textContent = "Editar Tipo";

            setEstadoFormularioTipo(false);
            var modal = getModalTipo();
            if (modal) modal.show();
        }

        function verDetalle() {
            if (!tipoSeleccionado) {
                var s = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (s) {
                    var id = s.getAttribute("data-id");
                    tipoSeleccionado = tipoCache.find(function (t) { return String(t.NOMBRE) === String(id); });
                }
            }

            if (!tipoSeleccionado) {
                Alert.advertencia("Selección requerida", "Seleccione un tipo de la lista para consultar.");
                return;
            }

            var txtOrig = document.getElementById("txtIdTipoOriginal");
            var txtNombre = document.getElementById("txtNombreTipo");
            var modalTitle = document.getElementById("modalTipoTitle");

            if (txtOrig) txtOrig.value = tipoSeleccionado.NOMBRE || "";
            if (txtNombre) txtNombre.value = tipoSeleccionado.NOMBRE || "";
            if (modalTitle) modalTitle.textContent = "Consulta de Tipo";

            setEstadoFormularioTipo(true);
            var modal = getModalTipo();
            if (modal) modal.show();
        }

        function eliminarTipo() {
            if (!tipoSeleccionado) {
                var s = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (s) {
                    var id = s.getAttribute("data-id");
                    tipoSeleccionado = tipoCache.find(function (t) { return String(t.NOMBRE) === String(id); });
                }
            }

            if (!tipoSeleccionado) {
                Alert.advertencia("Selección requerida", "Por favor, seleccione un tipo de la tabla para eliminar.");
                return;
            }

            var nombre = tipoSeleccionado.NOMBRE || "este tipo";

            Alert.confirmar("¿Eliminar registro?", '¿Está seguro de eliminar el tipo "' + nombre + '"?', async function () {
                var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                            document.querySelector('input[name="_token"]')?.value;

                try {
                    var response = await fetch("/tipo/eliminar", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token
                        },
                        body: JSON.stringify({ nombre: nombre })
                    });

                    var data = await response.json();

                    if (data.ok || data.success) {
                        tipoSeleccionado = null;
                        Alert.exito("Eliminado", data.msg || data.message || "Tipo eliminado correctamente.", async function () {
                            await mostrarTipo();
                        });
                    } else {
                        Alert.error("Error al eliminar", data.msg || data.message || "Error al eliminar el tipo.");
                    }
                } catch (e) {
                    console.error("Error al eliminar:", e);
                    Alert.error("Error de conexión", "Error de conexión con el servidor.");
                }
            });
        }

        var btnGuardar = document.getElementById("btnGuardarTipo");
        if (btnGuardar) {
            btnGuardar.addEventListener("click", async function () {
                var form = document.getElementById("formTipo");
                if (form && !form.checkValidity()) {
                    form.reportValidity();
                    return;
                }

                var txtNombre = document.getElementById("txtNombreTipo");
                var nombre = txtNombre ? txtNombre.value.trim() : "";
                var txtOrig = document.getElementById("txtIdTipoOriginal");
                var idOriginal = txtOrig ? txtOrig.value : "";

                if (!nombre) {
                    Alert.advertencia("Campo requerido", "El nombre del tipo es obligatorio.");
                    return;
                }

                try {
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                                document.querySelector('input[name="_token"]')?.value;
                    var response = await fetch("/tipo/guardar", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token
                        },
                        body: JSON.stringify({
                            nombre: nombre,
                            idOriginal: idOriginal
                        })
                    });

                    var data = await response.json();
                    if (data.ok || data.success) {
                        var modal = getModalTipo();
                        if (modal) modal.hide();
                        Alert.exito("¡Guardado!", data.msg || data.message || "Registro guardado correctamente.", async function () {
                            await mostrarTipo();
                        });
                    } else {
                        Alert.error("Error al guardar", data.msg || data.message || "Error al guardar el tipo.");
                    }
                } catch (e) {
                    var modal = getModalTipo();
                    if (modal) modal.hide();
                    Alert.error("Error de conexión", "Error de conexión al guardar.");
                }
            });
        }

        function exportarExcel() {
            if (!tipoCache.length) { 
                Alert.advertencia("Sin datos", "No hay datos para exportar."); 
                return; 
            }
            var csv = "Nombre\n";
            tipoCache.forEach(function (t) {
                csv += '"' + (t.NOMBRE || "") + '"\n';
            });
            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            var url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "tipos_" + new Date().toISOString().slice(0, 10) + ".csv");
            link.style.visibility = "hidden";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        panelTipo.addEventListener("click", function (e) {
            var btn = e.target.closest(".tb-btn");
            if (!btn) return;

            var acc = btn.dataset.acc;

            if (acc === "nuevo") nuevoTipo();
            else if (acc === "editar") editarTipo();
            else if (acc === "eliminar") eliminarTipo();
            else if (acc === "recargar") mostrarTipo();
            else if (acc === "imprimir" || acc === "consultar" || acc === "detalle") verDetalle();
            else if (acc === "excel") exportarExcel();
            else if (acc === "salir") {
                panelTipo.hidden = true;
                if (bienvenida) bienvenida.hidden = false;
            }
        });

        window.addEventListener("modulo:abrir", function (e) {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "tipo") mostrarTipo();
        });
    })();
});