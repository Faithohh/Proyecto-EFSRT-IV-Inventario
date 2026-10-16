document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelSala = document.getElementById("mpSala");
        var bienvenida = document.getElementById("mpBienvenida");
        if (!panelSala) return;

        var tblBody = document.querySelector("#tblSala tbody");
        var txtBuscar = document.getElementById("txtBuscarSala");
        var salaCache = [];
        var salaSeleccionada = null;

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

        function getModalSala() {
            var el = document.getElementById("modalSala");
            if (!el) return null;
            return bootstrap.Modal.getInstance(el) || new bootstrap.Modal(el);
        }

        function esc(v) {
            return String(v || "").replace(/[&<">]/g, function (c) {
                return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
            });
        }

        function setEstadoFormularioSala(deshabilitado) {
            var form = document.getElementById("formSala");
            var modalEl = document.getElementById("modalSala");

            if (form) {
                var elementos = form.querySelectorAll("input, select, textarea");
                elementos.forEach(function (el) {
                    el.disabled = deshabilitado;
                });
            }

            var btnGuardar = document.getElementById("btnGuardarSala") || 
                             (form ? form.querySelector('button[type="submit"]') : null) ||
                             (modalEl ? modalEl.querySelector('.btn-primary') : null);

            if (btnGuardar) {
                btnGuardar.style.display = deshabilitado ? "none" : "";
            }
        }

        function pintarSala(lista) {
            if (!tblBody) return;
            if (!lista || !lista.length) {
                tblBody.innerHTML = '<tr><td colspan="6" class="text-center">Sin salas registradas.</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(function (s) {
                return '<tr data-id="' + esc(s.idSala) + '" style="cursor:pointer;">' +
                    '<td>' + esc(s.nombre) + '</td>' +
                    '<td>' + esc(s.observacion) + '</td>' +
                    '<td>' + esc(formatearFecha(s.fechaCreacion)) + '</td>' +
                    '<td>' + esc(formatearFecha(s.fechaModificacion)) + '</td>' +
                    '<td>' + esc(s.idUsuarioCrea) + '</td>' +
                    '<td>' + esc(s.idUsuarioModifica) + '</td>' +
                    '</tr>';
            }).join("");
        }

        async function mostrarSala() {
            if (!tblBody) return;
            tblBody.innerHTML = '<tr><td colspan="6" class="text-center">Cargando...</td></tr>';
            salaSeleccionada = null;

            try {
                var r = await fetch("/sala/listar", { headers: { Accept: "application/json" } });
                if (!r.ok) throw new Error("Error HTTP " + r.status);

                var j = await r.json();
                if (!j.ok) throw new Error(j.msg || "Sin datos");

                salaCache = j.data || [];
                pintarSala(salaCache);
                if (txtBuscar) txtBuscar.value = "";
            } catch (e) {
                console.error("Error al cargar salas:", e);
                tblBody.innerHTML = '<tr><td colspan="6" class="text-center text-danger">' + esc(e.message) + '</td></tr>';
            }
        }

        if (!panelSala.hidden && panelSala.style.display !== "none") {
            mostrarSala();
        }

        var observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                if (mutation.attributeName === "hidden" || mutation.attributeName === "style") {
                    if (!panelSala.hidden && panelSala.style.display !== "none") {
                        mostrarSala();
                    }
                }
            });
        });
        observer.observe(panelSala, { attributes: true });

        if (tblBody) {
            tblBody.addEventListener("click", function (e) {
                var tr = e.target.closest("tr[data-id]");
                if (!tr) return;

                tblBody.querySelectorAll("tr").forEach(function (x) { 
                    x.classList.remove("sel", "selected", "table-active"); 
                });
                tr.classList.add("sel", "selected", "table-active");

                var id = tr.getAttribute("data-id");
                salaSeleccionada = salaCache.find(function (item) { 
                    return String(item.idSala) === String(id); 
                });
            });
        }

        if (txtBuscar) {
            txtBuscar.addEventListener("input", function () {
                var q = txtBuscar.value.trim().toLowerCase();
                if (!q) return pintarSala(salaCache);
                pintarSala(salaCache.filter(function (s) {
                    return (s.nombre || "").toLowerCase().includes(q) ||
                           (s.observacion || "").toLowerCase().includes(q) ||
                           (s.idUsuarioCrea || "").toLowerCase().includes(q) ||
                           (s.idUsuarioModifica || "").toLowerCase().includes(q);
                }));
            });
        }

        function nuevaSala() {
            var form = document.getElementById("formSala");
            if (form) form.reset();

            var txtOrig = document.getElementById("txtIdSalaOriginal");
            if (txtOrig) txtOrig.value = "";

            var modalTitle = document.getElementById("modalSalaTitle");
            if (modalTitle) modalTitle.textContent = "Nueva Sala";

            setEstadoFormularioSala(false);
            var modal = getModalSala();
            if (modal) modal.show();
        }

        function editarSala() {
            if (!salaSeleccionada) {
                var s = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (s) {
                    var id = s.getAttribute("data-id");
                    salaSeleccionada = salaCache.find(function (item) { return String(item.idSala) === String(id); });
                }
            }

            if (!salaSeleccionada) { 
                Alert.advertencia("Selección requerida", "Seleccione una sala de la lista para editar."); 
                return; 
            }

            var txtOrig = document.getElementById("txtIdSalaOriginal");
            var txtNombre = document.getElementById("txtNombreSala");
            var txtObs = document.getElementById("txtObservacionSala");
            var lblProg = document.getElementById("lblProgramaEstudioSala");
            var modalTitle = document.getElementById("modalSalaTitle");

            if (txtOrig) txtOrig.value = salaSeleccionada.idSala || "";
            if (txtNombre) txtNombre.value = salaSeleccionada.nombre || "";
            if (txtObs) txtObs.value = salaSeleccionada.observacion || "";
            if (lblProg && salaSeleccionada.idProgramaEstudio) {
                lblProg.textContent = salaSeleccionada.idProgramaEstudio;
            }
            if (modalTitle) modalTitle.textContent = "Editar Sala";

            setEstadoFormularioSala(false);
            var modal = getModalSala();
            if (modal) modal.show();
        }

        function verDetalle() {
            if (!salaSeleccionada) {
                var s = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (s) {
                    var id = s.getAttribute("data-id");
                    salaSeleccionada = salaCache.find(function (item) { return String(item.idSala) === String(id); });
                }
            }

            if (!salaSeleccionada) { 
                Alert.advertencia("Selección requerida", "Seleccione una sala de la lista para consultar."); 
                return; 
            }

            var txtOrig = document.getElementById("txtIdSalaOriginal");
            var txtNombre = document.getElementById("txtNombreSala");
            var txtObs = document.getElementById("txtObservacionSala");
            var lblProg = document.getElementById("lblProgramaEstudioSala");
            var modalTitle = document.getElementById("modalSalaTitle");

            if (txtOrig) txtOrig.value = salaSeleccionada.idSala || "";
            if (txtNombre) txtNombre.value = salaSeleccionada.nombre || "";
            if (txtObs) txtObs.value = salaSeleccionada.observacion || "";
            if (lblProg && salaSeleccionada.idProgramaEstudio) {
                lblProg.textContent = salaSeleccionada.idProgramaEstudio;
            }
            if (modalTitle) modalTitle.textContent = "Consulta de Sala";

            setEstadoFormularioSala(true);
            var modal = getModalSala();
            if (modal) modal.show();
        }

        function confirmarEliminar() {
            if (!salaSeleccionada) {
                var s = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (s) {
                    var id = s.getAttribute("data-id");
                    salaSeleccionada = salaCache.find(function (item) { return String(item.idSala) === String(id); });
                }
            }

            if (!salaSeleccionada) {
                Alert.advertencia("Selección requerida", "Por favor, seleccione una sala de la tabla para eliminar.");
                return;
            }

            var nombre = salaSeleccionada.nombre || "esta sala";

            Alert.confirmar("¿Eliminar registro?", '¿Está seguro de eliminar la sala "' + nombre + '"?', async function () {
                var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                            document.querySelector('input[name="_token"]')?.value;

                try {
                    var response = await fetch("/sala/eliminar", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token
                        },
                        body: JSON.stringify({ idSala: salaSeleccionada.idSala })
                    });

                    var data = await response.json();

                    if (data.ok || data.success) {
                        salaSeleccionada = null;
                        Alert.exito("Eliminado", data.msg || data.message || "Sala eliminada correctamente.", async function () {
                            await mostrarSala();
                        });
                    } else {
                        Alert.error("Error al eliminar", data.msg || data.message || "Error al eliminar la sala.");
                    }
                } catch (e) {
                    console.error("Error al eliminar:", e);
                    Alert.error("Error de conexión", "Error de conexión con el servidor.");
                }
            });
        }

        var btnGuardar = document.getElementById("btnGuardarSala");
        if (btnGuardar) {
            btnGuardar.addEventListener("click", async function () {
                var form = document.getElementById("formSala");
                if (form && !form.checkValidity()) {
                    form.reportValidity();
                    return;
                }

                var nombre = document.getElementById("txtNombreSala")?.value.trim() || "";
                var observacion = document.getElementById("txtObservacionSala")?.value.trim() || "";
                var lblPrograma = document.getElementById("lblProgramaEstudioSala");
                var idProgramaEstudio = lblPrograma ? lblPrograma.textContent.trim() : "";
                var idOriginal = document.getElementById("txtIdSalaOriginal")?.value || "";

                if (!nombre) {
                    Alert.advertencia("Campo requerido", "El nombre de la sala es obligatorio.");
                    return;
                }

                try {
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                                document.querySelector('input[name="_token"]')?.value;
                    var response = await fetch("/sala/guardar", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token
                        },
                        body: JSON.stringify({
                            nombre: nombre,
                            observacion: observacion,
                            idProgramaEstudio: idProgramaEstudio,
                            idOriginal: idOriginal
                        })
                    });

                    var data = await response.json();
                    if (data.ok || data.success) {
                        var modal = getModalSala();
                        if (modal) modal.hide();
                        Alert.exito("¡Guardado!", data.msg || data.message || "Registro guardado correctamente.", async function () {
                            await mostrarSala();
                        });
                    } else {
                        Alert.error("Error al guardar", data.msg || data.message || "Error al guardar la sala.");
                    }
                } catch (e) {
                    var modal = getModalSala();
                    if (modal) modal.hide();
                    Alert.error("Error de conexión", "Error de conexión al guardar.");
                }
            });
        }

        function exportarExcel() {
            if (!salaCache.length) { 
                Alert.advertencia("Sin datos", "No hay datos para exportar."); 
                return; 
            }
            var csv = "Nombre,Observacion,Fecha Creacion,Fecha Modificación,Usuario Crea,Usuario Modifica\n";
            salaCache.forEach(function (s) {
                csv += '"' + (s.nombre || "") + '",' +
                       '"' + (s.observacion || "") + '",' +
                       '"' + (formatearFecha(s.fechaCreacion) || "") + '",' +
                       '"' + (formatearFecha(s.fechaModificacion) || "") + '",' +
                       '"' + (s.idUsuarioCrea || "") + '",' +
                       '"' + (s.idUsuarioModifica || "") + '"\n';
            });
            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            var url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "salas_" + new Date().toISOString().slice(0, 10) + ".csv");
            link.style.visibility = "hidden";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        panelSala.addEventListener("click", function (e) {
            var btn = e.target.closest(".tb-btn");
            if (!btn) return;

            var acc = btn.dataset.acc;

            if (acc === "nuevo") nuevaSala();
            else if (acc === "editar") editarSala();
            else if (acc === "eliminar") confirmarEliminar();
            else if (acc === "recargar") mostrarSala();
            else if (acc === "imprimir" || acc === "consultar" || acc === "detalle") verDetalle();
            else if (acc === "excel") exportarExcel();
            else if (acc === "salir") {
                panelSala.hidden = true;
                if (bienvenida) bienvenida.hidden = false;
            }
        });

        window.addEventListener("modulo:abrir", function (e) {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "sala") mostrarSala();
        });
    })();
});