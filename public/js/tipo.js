document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelTipo = document.getElementById("mpTipo");
        var bienvenida = document.getElementById("mpBienvenida");
        if (!panelTipo) return;

        var tblBody = document.querySelector("#tblTipo tbody");
        var txtBuscar = document.getElementById("txtBuscarTipo");
        var tipoCache = [];
        var tipoSeleccionado = null;

        var modalTipo = new bootstrap.Modal(document.getElementById("modalTipo"));

        // Modal global/reutilizable de eliminación
        var elemModalEliminar = document.getElementById("modalConfirmarEliminar");
        var modalEliminar = elemModalEliminar ? new bootstrap.Modal(elemModalEliminar) : null;

        function esc(v) {
            return String(v || "").replace(/[&<">]/g, function (c) {
                return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
            });
        }

        // Habilita o inhabilita el formulario modal de Tipo
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
            if (!lista.length) {
                tblBody.innerHTML = '<tr><td class="text-center">Sin tipos registrados.</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(function (t) {
                return '<tr data-id="' + esc(t.NOMBRE) + '">' +
                    '<td>' + esc(t.NOMBRE) + '</td></tr>';
            }).join("");
        }

        async function mostrarTipo() {
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
                tblBody.innerHTML = '<tr><td class="text-center">' + esc(e.message) + '</td></tr>';
            }
        }

        tblBody.addEventListener("click", function (e) {
            var tr = e.target.closest("tr[data-id]");
            if (!tr) return;
            tblBody.querySelectorAll("tr").forEach(function (x) { x.classList.remove("sel", "selected", "table-active"); });
            tr.classList.add("sel", "selected", "table-active");

            var id = tr.getAttribute("data-id");
            tipoSeleccionado = tipoCache.find(function (item) { return String(item.NOMBRE) === String(id); });
        });

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
            modalTipo.show();
        }

        function editarTipo() {
            if (!tipoSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    tipoSeleccionado = tipoCache.find(function (t) { return String(t.NOMBRE) === String(id); });
                }
            }

            if (!tipoSeleccionado) {
                alert("Seleccione un tipo de la lista para editar.");
                return;
            }

            var txtOrig = document.getElementById("txtIdTipoOriginal");
            var txtNombre = document.getElementById("txtNombreTipo");
            var modalTitle = document.getElementById("modalTipoTitle");

            if (txtOrig) txtOrig.value = tipoSeleccionado.NOMBRE || "";
            if (txtNombre) txtNombre.value = tipoSeleccionado.NOMBRE || "";
            if (modalTitle) modalTitle.textContent = "Editar Tipo";

            setEstadoFormularioTipo(false);
            modalTipo.show();
        }

        function verDetalle() {
            if (!tipoSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    tipoSeleccionado = tipoCache.find(function (t) { return String(t.NOMBRE) === String(id); });
                }
            }

            if (!tipoSeleccionado) {
                alert("Seleccione un tipo de la lista para consultar.");
                return;
            }

            var txtOrig = document.getElementById("txtIdTipoOriginal");
            var txtNombre = document.getElementById("txtNombreTipo");
            var modalTitle = document.getElementById("modalTipoTitle");

            if (txtOrig) txtOrig.value = tipoSeleccionado.NOMBRE || "";
            if (txtNombre) txtNombre.value = tipoSeleccionado.NOMBRE || "";
            if (modalTitle) modalTitle.textContent = "Consulta de Tipo";

            setEstadoFormularioTipo(true);
            modalTipo.show();
        }

        function eliminarTipo() {
            if (!tipoSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    tipoSeleccionado = tipoCache.find(function (t) { return String(t.NOMBRE) === String(id); });
                }
            }

            if (!tipoSeleccionado) {
                alert("Por favor, seleccione un tipo de la tabla para eliminar.");
                return;
            }

            var nombre = tipoSeleccionado.NOMBRE || "este tipo";

            var msgElem = document.getElementById("msgConfirmarEliminar");
            if (msgElem) {
                msgElem.innerHTML = '¿Está seguro de eliminar el tipo <strong>' + esc(nombre) + '</strong>?';
            }

            var btnConfirmar = document.getElementById("btnConfirmarEliminarAccion");
            if (btnConfirmar) {
                btnConfirmar.dataset.id = tipoSeleccionado.NOMBRE;
                btnConfirmar.dataset.modulo = "tipo";
            }

            if (modalEliminar) modalEliminar.show();
        }

        var btnGuardar = document.getElementById("btnGuardarTipo");
        if (btnGuardar) {
            btnGuardar.addEventListener("click", async function () {
                var form = document.getElementById("formTipo");
                if (form && !form.checkValidity()) {
                    form.reportValidity();
                    return;
                }

                var nombre = document.getElementById("txtNombreTipo").value.trim();
                var idOriginal = document.getElementById("txtIdTipoOriginal").value;

                if (!nombre) {
                    alert("El nombre del tipo es obligatorio.");
                    return;
                }

                try {
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || document.querySelector('input[name="_token"]')?.value;
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
                        modalTipo.hide();
                        await mostrarTipo();
                    } else {
                        alert(data.msg || data.message || "Error al guardar el tipo.");
                    }
                } catch (e) {
                    modalTipo.hide();
                    alert("Error de conexión al guardar.");
                }
            });
        }

        var btnConfirmarAccion = document.getElementById("btnConfirmarEliminarAccion");
        if (btnConfirmarAccion) {
            btnConfirmarAccion.addEventListener("click", async function () {
                if (btnConfirmarAccion.dataset.modulo !== "tipo") return;

                var nombre = btnConfirmarAccion.dataset.id;
                if (!nombre) return;

                try {
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || document.querySelector('input[name="_token"]')?.value;
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
                    if (modalEliminar) modalEliminar.hide();

                    if (data.ok || data.success) {
                        await mostrarTipo();
                    } else {
                        alert(data.msg || data.message || "Error al eliminar el tipo.");
                    }
                } catch (e) {
                    if (modalEliminar) modalEliminar.hide();
                    alert("Error de conexión con el servidor.");
                }
            });
        }

        function exportarExcel() {
            if (!tipoCache.length) { alert("No hay datos para exportar."); return; }
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

        panelTipo.querySelectorAll(".tb-btn").forEach(function (b) {
            b.addEventListener("click", function () {
                var acc = b.dataset.acc;
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
        });

        window.addEventListener("modulo:abrir", function (e) {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "tipo") mostrarTipo();
        });
    })();
});