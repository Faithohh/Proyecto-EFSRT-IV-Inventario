document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelEstado = document.getElementById("mpEstado");
        var bienvenida = document.getElementById("mpBienvenida");
        if (!panelEstado) return;

        var tblBody = document.querySelector("#tblEstado tbody");
        var txtBuscar = document.getElementById("txtBuscarEstado");
        var estadoCache = [];
        var estadoSeleccionado = null;

        var modalEstado = new bootstrap.Modal(document.getElementById("modalEstado"));

        function esc(v) {
            return String(v || "").replace(/[&<">]/g, function (c) {
                return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
            });
        }

        function setEstadoFormularioEstado(deshabilitado) {
            var form = document.getElementById("formEstado");
            var modalEl = document.getElementById("modalEstado");

            if (form) {
                var elementos = form.querySelectorAll("input, select, textarea");
                elementos.forEach(function (el) {
                    el.disabled = deshabilitado;
                });
            }

            var btnGuardar = document.getElementById("btnGuardarEstado") || 
                             (form ? form.querySelector('button[type="submit"]') : null) ||
                             (modalEl ? modalEl.querySelector('.btn-primary') : null);

            if (btnGuardar) {
                btnGuardar.style.display = deshabilitado ? "none" : "";
            }
        }

        function pintarEstado(lista) {
            if (!lista.length) {
                tblBody.innerHTML = '<tr><td class="text-center">Sin estados registrados.</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(function (e) {
                return '<tr data-id="' + esc(e.idEstado) + '">' +
                    '<td>' + esc(e.nombre) + '</td></tr>';
            }).join("");
        }

        async function mostrarEstado() {
            tblBody.innerHTML = '<tr><td class="text-center">Cargando...</td></tr>';
            estadoSeleccionado = null;

            try {
                var r = await fetch("/estado/listar", { headers: { Accept: "application/json" } });
                var j = await r.json();
                if (!j.ok) throw new Error(j.msg || "Sin datos");
                estadoCache = j.data || [];
                pintarEstado(estadoCache);
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
            estadoSeleccionado = estadoCache.find(function (item) { return String(item.idEstado) === String(id); });
        });

        if (txtBuscar) {
            txtBuscar.addEventListener("input", function () {
                var q = txtBuscar.value.trim().toLowerCase();
                if (!q) return pintarEstado(estadoCache);
                pintarEstado(estadoCache.filter(function (e) {
                    return (e.nombre || "").toLowerCase().includes(q);
                }));
            });
        }

        function nuevoEstado() {
            var form = document.getElementById("formEstado");
            if (form) form.reset();

            var txtOrig = document.getElementById("txtIdEstadoOriginal");
            if (txtOrig) txtOrig.value = "";

            var modalTitle = document.getElementById("modalEstadoTitle");
            if (modalTitle) modalTitle.textContent = "Nuevo Estado";

            setEstadoFormularioEstado(false);
            modalEstado.show();
        }

        function editarEstado() {
            if (!estadoSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    estadoSeleccionado = estadoCache.find(function (e) { return String(e.idEstado) === String(id); });
                }
            }

            if (!estadoSeleccionado) { 
                alert("Seleccione un estado de la lista para editar."); 
                return; 
            }

            var txtOrig = document.getElementById("txtIdEstadoOriginal");
            var txtNombre = document.getElementById("txtNombreEstado");
            var modalTitle = document.getElementById("modalEstadoTitle");

            if (txtOrig) txtOrig.value = estadoSeleccionado.idEstado || "";
            if (txtNombre) txtNombre.value = estadoSeleccionado.nombre || "";
            if (modalTitle) modalTitle.textContent = "Editar Estado";

            setEstadoFormularioEstado(false);
            modalEstado.show();
        }

        function verDetalle() {
            if (!estadoSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    estadoSeleccionado = estadoCache.find(function (e) { return String(e.idEstado) === String(id); });
                }
            }

            if (!estadoSeleccionado) { 
                alert("Seleccione un estado de la lista para consultar."); 
                return; 
            }

            var txtOrig = document.getElementById("txtIdEstadoOriginal");
            var txtNombre = document.getElementById("txtNombreEstado");
            var modalTitle = document.getElementById("modalEstadoTitle");

            if (txtOrig) txtOrig.value = estadoSeleccionado.idEstado || "";
            if (txtNombre) txtNombre.value = estadoSeleccionado.nombre || "";
            if (modalTitle) modalTitle.textContent = "Consulta de Estado";

            setEstadoFormularioEstado(true);
            modalEstado.show();
        }

        function confirmarEliminar() {
            if (!estadoSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    estadoSeleccionado = estadoCache.find(function (e) { return String(e.idEstado) === String(id); });
                }
            }

            if (!estadoSeleccionado) {
                alert("Por favor, seleccione un estado de la tabla para eliminar.");
                return;
            }

            var nombre = estadoSeleccionado.nombre || "este estado";
            
            var msgEl = document.getElementById("msgConfirmarEliminar");
            if (msgEl) {
                msgEl.textContent = "¿Está seguro de eliminar el estado " + nombre + "?";
            }

            var modalEl = document.getElementById("modalConfirmarEliminar");
            var btnEliminarAccion = document.getElementById("btnConfirmarEliminarAccion");

            if (!modalEl) return;

            var bsModal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);

            btnEliminarAccion.onclick = async function () {
                bsModal.hide();

                var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || document.querySelector('input[name="_token"]')?.value;

                try {
                    var response = await fetch("/estado/eliminar", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token
                        },
                        body: JSON.stringify({ idEstado: estadoSeleccionado.idEstado })
                    });

                    var data = await response.json();

                    if (data.ok || data.success) {
                        await mostrarEstado();
                    } else {
                        alert(data.msg || data.message || "Error al eliminar el estado.");
                    }
                } catch (e) {
                    console.error("Error al eliminar:", e);
                    alert("Error de conexión con el servidor.");
                }
            };

            bsModal.show();
        }

        var btnGuardar = document.getElementById("btnGuardarEstado");
        if (btnGuardar) {
            btnGuardar.addEventListener("click", async function () {
                var form = document.getElementById("formEstado");
                if (form && !form.checkValidity()) {
                    form.reportValidity();
                    return;
                }

                var nombre = document.getElementById("txtNombreEstado").value.trim();
                var idOriginal = document.getElementById("txtIdEstadoOriginal").value;

                if (!nombre) {
                    alert("El nombre del estado es obligatorio.");
                    return;
                }

                try {
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || document.querySelector('input[name="_token"]')?.value;
                    var response = await fetch("/estado/guardar", {
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
                        modalEstado.hide();
                        await mostrarEstado();
                    } else {
                        alert(data.msg || data.message || "Error al guardar el estado.");
                    }
                } catch (e) {
                    modalEstado.hide();
                    alert("Error de conexión al guardar.");
                }
            });
        }

        function exportarExcel() {
            if (!estadoCache.length) { alert("No hay datos para exportar."); return; }
            var csv = "Nombre\n";
            estadoCache.forEach(function (e) {
                csv += '"' + (e.nombre || "") + '"\n';
            });
            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            var url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "estados_" + new Date().toISOString().slice(0, 10) + ".csv");
            link.style.visibility = "hidden";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        panelEstado.querySelectorAll(".tb-btn").forEach(function (b) {
            b.addEventListener("click", function () {
                var acc = b.dataset.acc;
                if (acc === "nuevo") nuevoEstado();
                else if (acc === "editar") editarEstado();
                else if (acc === "eliminar") confirmarEliminar();
                else if (acc === "recargar") mostrarEstado();
                else if (acc === "imprimir" || acc === "consultar" || acc === "detalle") verDetalle();
                else if (acc === "excel") exportarExcel();
                else if (acc === "salir") {
                    panelEstado.hidden = true;
                    if (bienvenida) bienvenida.hidden = false;
                }
            });
        });

        window.addEventListener("modulo:abrir", function (e) {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "estado") mostrarEstado();
        });
    })();
});