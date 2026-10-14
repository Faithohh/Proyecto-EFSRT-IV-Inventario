document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelModelo = document.getElementById("mpModelo");
        var bienvenida = document.getElementById("mpBienvenida");
        if (!panelModelo) return;

        var tblBody = document.querySelector("#tblModelo tbody");
        var txtBuscar = document.getElementById("txtBuscarModelo");
        var modeloCache = [];
        var modeloSeleccionado = null;

        function formatearFecha(f) {
            if (!f) return "";

            var fechaStr = String(f).trim();
            var regex = /^(\d{4})[-/](\d{1,2})[-/](\d{1,2})(?:[ T](\d{1,2}):(\d{1,2}))?/;
            var match = fechaStr.match(regex);

            if (match) {
                var anio = parseInt(match[1], 10);
                var mes = parseInt(match[2], 10) - 1;
                var dia = parseInt(match[3], 10);
                var horas = match[4] ? parseInt(match[4], 10) : 0;
                var minutos = match[5] ? parseInt(match[5], 10) : 0;

                var d = new Date(anio, mes, dia, horas, minutos);
                d.setHours(d.getHours() - 5);

                var dDia = String(d.getDate()).padStart(2, '0');
                var dMes = String(d.getMonth() + 1).padStart(2, '0');
                var dAnio = d.getFullYear();
                var dHoras24 = d.getHours();
                var dMin = String(d.getMinutes()).padStart(2, '0');

                var ampm = dHoras24 >= 12 ? 'PM' : 'AM';
                var dHoras12 = dHoras24 % 12;
                dHoras12 = dHoras12 ? dHoras12 : 12;

                return dDia + '/' + dMes + '/' + dAnio + ' ' + String(dHoras12).padStart(2, '0') + ':' + dMin + ' ' + ampm;
            }

            var fallbackDate = new Date(f);
            if (isNaN(fallbackDate.getTime())) return f;

            fallbackDate.setHours(fallbackDate.getHours() - 5);

            var fbDia = String(fallbackDate.getDate()).padStart(2, '0');
            var fbMes = String(fallbackDate.getMonth() + 1).padStart(2, '0');
            var fbAnio = fallbackDate.getFullYear();
            var fbHoras24 = fallbackDate.getHours();
            var fbMin = String(fallbackDate.getMinutes()).padStart(2, '0');

            var fbAmpm = fbHoras24 >= 12 ? 'PM' : 'AM';
            var fbHoras12 = fbHoras24 % 12;
            fbHoras12 = fbHoras12 ? fbHoras12 : 12;

            return fbDia + '/' + fbMes + '/' + fbAnio + ' ' + String(fbHoras12).padStart(2, '0') + ':' + fbMin + ' ' + fbAmpm;
        }

        function getModalModelo() {
            var el = document.getElementById("modalModelo");
            if (!el) return null;
            return bootstrap.Modal.getInstance(el) || new bootstrap.Modal(el);
        }

        function esc(v) {
            return String(v || "").replace(/[&<">]/g, function (c) {
                return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
            });
        }

        function setEstadoFormularioModelo(deshabilitado) {
            var form = document.getElementById("formModelo");
            var modalEl = document.getElementById("modalModelo");

            if (form) {
                var elementos = form.querySelectorAll("input, select, textarea");
                elementos.forEach(function (el) {
                    el.disabled = deshabilitado;
                });
            }

            var btnGuardar = document.getElementById("btnGuardarModelo") || 
                             (form ? form.querySelector('button[type="submit"]') : null) ||
                             (modalEl ? modalEl.querySelector('.btn-primary') : null);

            if (btnGuardar) {
                btnGuardar.style.display = deshabilitado ? "none" : "";
            }
        }

        function pintarModelo(lista) {
            if (!tblBody) return;
            if (!lista || !lista.length) {
                tblBody.innerHTML = '<tr><td colspan="6" class="text-center">Sin modelos registrados.</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(function (m) {
                return '<tr data-id="' + esc(m.idModelo) + '" style="cursor:pointer;">' +
                    '<td>' + esc(m.idProgramaEstudio) + '</td>' +
                    '<td>' + esc(m.nombre) + '</td>' +
                    '<td>' + esc(formatearFecha(m.fechaCreacion)) + '</td>' +
                    '<td>' + esc(formatearFecha(m.fechaModificacion)) + '</td>' +
                    '<td>' + esc(m.idUsuarioCrea) + '</td>' +
                    '<td>' + esc(m.idUsuarioModifica) + '</td>' +
                    '</tr>';
            }).join("");
        }

        async function mostrarModelo() {
            if (!tblBody) return;
            tblBody.innerHTML = '<tr><td colspan="6" class="text-center">Cargando...</td></tr>';
            modeloSeleccionado = null;

            try {
                var r = await fetch("/modelo/listar", { headers: { Accept: "application/json" } });
                if (!r.ok) throw new Error("Error HTTP " + r.status);

                var j = await r.json();
                if (!j.ok) throw new Error(j.msg || "Sin datos");

                modeloCache = j.data || [];
                pintarModelo(modeloCache);
                if (txtBuscar) txtBuscar.value = "";
            } catch (e) {
                console.error("Error al cargar modelos:", e);
                tblBody.innerHTML = '<tr><td colspan="6" class="text-center text-danger">' + esc(e.message) + '</td></tr>';
            }
        }

        if (!panelModelo.hidden && panelModelo.style.display !== "none") {
            mostrarModelo();
        }

        var observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                if (mutation.attributeName === "hidden" || mutation.attributeName === "style") {
                    if (!panelModelo.hidden && panelModelo.style.display !== "none") {
                        mostrarModelo();
                    }
                }
            });
        });
        observer.observe(panelModelo, { attributes: true });

        if (tblBody) {
            tblBody.addEventListener("click", function (e) {
                var tr = e.target.closest("tr[data-id]");
                if (!tr) return;

                tblBody.querySelectorAll("tr").forEach(function (x) { 
                    x.classList.remove("sel", "selected", "table-active"); 
                });
                tr.classList.add("sel", "selected", "table-active");

                var id = tr.getAttribute("data-id");
                modeloSeleccionado = modeloCache.find(function (item) { 
                    return String(item.idModelo) === String(id); 
                });
            });
        }

        if (txtBuscar) {
            txtBuscar.addEventListener("input", function () {
                var q = txtBuscar.value.trim().toLowerCase();
                if (!q) return pintarModelo(modeloCache);
                pintarModelo(modeloCache.filter(function (m) {
                    return (m.nombre || "").toLowerCase().includes(q) ||
                           (m.idProgramaEstudio || "").toString().toLowerCase().includes(q) ||
                           (m.idUsuarioCrea || "").toLowerCase().includes(q) ||
                           (m.idUsuarioModifica || "").toLowerCase().includes(q);
                }));
            });
        }

        function nuevoModelo() {
            var form = document.getElementById("formModelo");
            if (form) form.reset();

            var txtOrig = document.getElementById("txtIdModeloOriginal");
            if (txtOrig) txtOrig.value = "";

            var modalTitle = document.getElementById("modalModeloTitle");
            if (modalTitle) modalTitle.textContent = "Nuevo Modelo";

            setEstadoFormularioModelo(false);
            var modal = getModalModelo();
            if (modal) modal.show();
        }

        function editarModelo() {
            if (!modeloSeleccionado) {
                var s = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (s) {
                    var id = s.getAttribute("data-id");
                    modeloSeleccionado = modeloCache.find(function (m) { return String(m.idModelo) === String(id); });
                }
            }

            if (!modeloSeleccionado) { 
                alert("Seleccione un modelo de la lista para editar."); 
                return; 
            }

            var txtOrig = document.getElementById("txtIdModeloOriginal");
            var txtNombre = document.getElementById("txtNombreModelo");
            var modalTitle = document.getElementById("modalModeloTitle");

            if (txtOrig) txtOrig.value = modeloSeleccionado.idModelo || "";
            if (txtNombre) txtNombre.value = modeloSeleccionado.nombre || "";
            if (modalTitle) modalTitle.textContent = "Editar Modelo";

            setEstadoFormularioModelo(false);
            var modal = getModalModelo();
            if (modal) modal.show();
        }

        function verDetalle() {
            if (!modeloSeleccionado) {
                var s = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (s) {
                    var id = s.getAttribute("data-id");
                    modeloSeleccionado = modeloCache.find(function (m) { return String(m.idModelo) === String(id); });
                }
            }

            if (!modeloSeleccionado) { 
                alert("Seleccione un modelo de la lista para consultar."); 
                return; 
            }

            var txtOrig = document.getElementById("txtIdModeloOriginal");
            var txtNombre = document.getElementById("txtNombreModelo");
            var modalTitle = document.getElementById("modalModeloTitle");

            if (txtOrig) txtOrig.value = modeloSeleccionado.idModelo || "";
            if (txtNombre) txtNombre.value = modeloSeleccionado.nombre || "";
            if (modalTitle) modalTitle.textContent = "Consulta de Modelo";

            setEstadoFormularioModelo(true);
            var modal = getModalModelo();
            if (modal) modal.show();
        }

        function confirmarEliminar() {
            if (!modeloSeleccionado) {
                var s = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (s) {
                    var id = s.getAttribute("data-id");
                    modeloSeleccionado = modeloCache.find(function (m) { return String(m.idModelo) === String(id); });
                }
            }

            if (!modeloSeleccionado) {
                alert("Por favor, seleccione un modelo de la tabla para eliminar.");
                return;
            }

            var nombre = modeloSeleccionado.nombre || "este modelo";
            var msgEl = document.getElementById("msgConfirmarEliminarModelo");
            if (msgEl) {
                msgEl.textContent = "¿Está seguro de eliminar el modelo " + nombre + "?";
            }

            var modalEl = document.getElementById("modalConfirmarEliminarModelo");
            var btnEliminarAccion = document.getElementById("btnConfirmarEliminarModeloAccion");

            if (!modalEl) return;

            var bsModal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);

            if (btnEliminarAccion) {
                btnEliminarAccion.onclick = async function () {
                    bsModal.hide();

                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                                document.querySelector('input[name="_token"]')?.value;

                    try {
                        var response = await fetch("/modelo/eliminar", {
                            method: "POST",
                            headers: {
                                "Content-Type": "application/json",
                                Accept: "application/json",
                                "X-CSRF-TOKEN": token
                            },
                            body: JSON.stringify({ idModelo: modeloSeleccionado.idModelo })
                        });

                        var data = await response.json();

                        if (data.ok || data.success) {
                            modeloSeleccionado = null;
                            await mostrarModelo();
                        } else {
                            alert(data.msg || data.message || "Error al eliminar el modelo.");
                        }
                    } catch (e) {
                        console.error("Error al eliminar:", e);
                        alert("Error de conexión con el servidor.");
                    }
                };
            }

            bsModal.show();
        }

        var btnGuardar = document.getElementById("btnGuardarModelo");
        if (btnGuardar) {
            btnGuardar.addEventListener("click", async function () {
                var form = document.getElementById("formModelo");
                if (form && !form.checkValidity()) {
                    form.reportValidity();
                    return;
                }

                var txtNombre = document.getElementById("txtNombreModelo");
                var nombre = txtNombre ? txtNombre.value.trim() : "";
                var txtOrig = document.getElementById("txtIdModeloOriginal");
                var idOriginal = txtOrig ? txtOrig.value : "";

                if (!nombre) {
                    alert("El nombre del modelo es obligatorio.");
                    return;
                }

                try {
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                                document.querySelector('input[name="_token"]')?.value;
                    var response = await fetch("/modelo/guardar", {
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
                        var modal = getModalModelo();
                        if (modal) modal.hide();
                        await mostrarModelo();
                    } else {
                        alert(data.msg || data.message || "Error al guardar el modelo.");
                    }
                } catch (e) {
                    var modal = getModalModelo();
                    if (modal) modal.hide();
                    alert("Error de conexión al guardar.");
                }
            });
        }

        function exportarExcel() {
            if (!modeloCache.length) { alert("No hay datos para exportar."); return; }
            var csv = "ID Prog. Estudio,Nombre,Fecha Creación,Fecha Modificación,Usuario Crea,Usuario Modifica\n";
            modeloCache.forEach(function (m) {
                csv += '"' + (m.idProgramaEstudio || "") + '",' +
                       '"' + (m.nombre || "") + '",' +
                       '"' + (formatearFecha(m.fechaCreacion) || "") + '",' +
                       '"' + (formatearFecha(m.fechaModificacion) || "") + '",' +
                       '"' + (m.idUsuarioCrea || "") + '",' +
                       '"' + (m.idUsuarioModifica || "") + '"\n';
            });
            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            var url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "modelos_" + new Date().toISOString().slice(0, 10) + ".csv");
            link.style.visibility = "hidden";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        panelModelo.addEventListener("click", function (e) {
            var btn = e.target.closest(".tb-btn");
            if (!btn) return;

            var acc = btn.dataset.acc;

            if (acc === "nuevo") nuevoModelo();
            else if (acc === "editar") editarModelo();
            else if (acc === "eliminar") confirmarEliminar();
            else if (acc === "recargar") mostrarModelo();
            else if (acc === "imprimir" || acc === "consultar" || acc === "detalle") verDetalle();
            else if (acc === "excel") exportarExcel();
            else if (acc === "salir") {
                panelModelo.hidden = true;
                if (bienvenida) bienvenida.hidden = false;
            }
        });

        window.addEventListener("modulo:abrir", function (e) {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "modelo") mostrarModelo();
        });
    })();
});