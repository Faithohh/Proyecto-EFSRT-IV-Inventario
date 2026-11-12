
document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelMarca = document.getElementById("mpMarca");
        var bienvenida = document.getElementById("mpBienvenida");
        if (!panelMarca) return;

        var tblBody = document.querySelector("#tblMarca tbody");
        var txtBuscar = document.getElementById("txtBuscarMarca");
        var marcaCache = [];
        var marcaSeleccionada = null;

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

        function getModalMarca() {
            var el = document.getElementById("modalMarca");
            if (!el) return null;
            return bootstrap.Modal.getInstance(el) || new bootstrap.Modal(el);
        }

        function esc(v) {
            return String(v || "").replace(/[&<">]/g, function (c) {
                return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
            });
        }

        function setEstadoFormulario(deshabilitado) {
            var form = document.getElementById("formMarca");
            if (form) {
                var elementos = form.querySelectorAll("input, select, textarea");
                elementos.forEach(function (el) { el.disabled = deshabilitado; });
            }
            var btnGuardar = document.getElementById("btnGuardarMarca");
            if (btnGuardar) btnGuardar.style.display = deshabilitado ? "none" : "";
        }

        function pintarMarca(lista) {
            if (!tblBody) return;

            if (!lista || !lista.length) {
                tblBody.innerHTML = '<tr><td colspan="7" class="text-center">Sin marcas registradas.</td></tr>';
                return;
            }

            tblBody.innerHTML = lista.map(function (m) {
                var activo = Number(m.st_registro) === 1;

                return '<tr data-id="' + esc(m.idMarca) + '" style="cursor:pointer;">' +
                    '<td>' + esc(m.nombre) + '</td>' +
                    '<td>' + esc(formatearFecha(m.fechaCreacion)) + '</td>' +
                    '<td>' + esc(formatearFecha(m.fechaModificacion)) + '</td>' +
                    '<td>' + esc(m.idUsuarioCrea) + '</td>' +
                    '<td>' + esc(m.idUsuarioModifica) + '</td>' +
                    '<td class="text-center align-middle">' +
                        (activo
                            ? '<span class="badge bg-success" title="Activo"><i class="bi bi-check-circle-fill"></i></span>'
                            : '<span class="badge bg-secondary" title="Inactivo"><i class="bi bi-x-circle-fill"></i></span>') +
                    '</td>' +
                    '<td class="text-center align-middle">' +
                        '<button type="button" class="btn btn-sm ' + (activo ? 'btn-outline-danger' : 'btn-outline-success') + ' btn-cambiar-estado-marca" data-id="' + esc(m.idMarca) + '" data-estado="' + (activo ? '0' : '1') + '" title="' + (activo ? 'Desactivar' : 'Activar') + '">' +
                            (activo ? '<i class="bi bi-trash"></i>' : '<i class="bi bi-check-lg"></i>') +
                        '</button>' +
                    '</td>' +
                '</tr>';
            }).join("");
        }

        async function mostrarMarca() {
            if (!tblBody) return;

            tblBody.innerHTML = '<tr><td colspan="7" class="text-center">Cargando...</td></tr>';
            marcaSeleccionada = null;

            try {
                var r = await fetch("/marca/listar", { headers: { Accept: "application/json" } });
                if (!r.ok) throw new Error("Error HTTP " + r.status);

                var j = await r.json();
                if (!j.ok) throw new Error(j.msg || "Sin datos");

                marcaCache = j.data || [];
                pintarMarca(marcaCache);
                if (txtBuscar) txtBuscar.value = "";
            } catch (e) {
                console.error("Error al cargar marcas:", e);
                tblBody.innerHTML = '<tr><td colspan="7" class="text-center text-danger">' + esc(e.message) + '</td></tr>';
            }
        }

        if (!panelMarca.hidden && panelMarca.style.display !== "none") {
            mostrarMarca();
        }

        var observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                if (mutation.attributeName === "hidden" || mutation.attributeName === "style") {
                    if (!panelMarca.hidden && panelMarca.style.display !== "none") {
                        mostrarMarca();
                    }
                }
            });
        });
        observer.observe(panelMarca, { attributes: true });

        if (tblBody) {
            tblBody.addEventListener("click", function (e) {
                var btnEstado = e.target.closest(".btn-cambiar-estado-marca");

                if (btnEstado) {
                    e.stopPropagation();
                    cambiarEstadoMarca(btnEstado.dataset.id, btnEstado.dataset.estado === "1");
                    return;
                }

                var tr = e.target.closest("tr[data-id]");
                if (!tr) return;

                tblBody.querySelectorAll("tr").forEach(function (x) {
                    x.classList.remove("sel", "selected", "table-active");
                });
                tr.classList.add("table-active", "selected");

                var id = tr.getAttribute("data-id");
                marcaSeleccionada = marcaCache.find(function (item) {
                    return String(item.idMarca) === String(id);
                });
            });
        }

        if (txtBuscar) {
            txtBuscar.addEventListener("input", function () {
                var q = txtBuscar.value.trim().toLowerCase();
                if (!q) return pintarMarca(marcaCache);

                pintarMarca(marcaCache.filter(function (m) {
                    return (m.nombre || "").toLowerCase().includes(q) ||
                           (m.idUsuarioCrea || "").toLowerCase().includes(q) ||
                           (m.idUsuarioModifica || "").toLowerCase().includes(q);
                }));
            });
        }

        function nuevoMarca() {
            var form = document.getElementById("formMarca");
            if (form) form.reset();

            var txtOrig = document.getElementById("txtIdMarcaOriginal");
            if (txtOrig) txtOrig.value = "";

            var modalTitle = document.getElementById("modalMarcaTitle");
            if (modalTitle) modalTitle.textContent = "Nueva Marca";

            setEstadoFormulario(false);
            var modal = getModalMarca();
            if (modal) modal.show();
        }

        function editarMarca() {
            if (!marcaSeleccionada) {
                Alert.advertencia("Selección requerida", "Por favor, seleccione una marca de la lista para editar.");
                return;
            }

            if (Number(marcaSeleccionada.st_registro) !== 1) {
                Alert.advertencia("Marca inactiva", "No se puede editar una marca desactivada. Primero debe activarla.");
                return;
            }

            var txtOrig = document.getElementById("txtIdMarcaOriginal");
            var txtNombre = document.getElementById("txtNombreMarca");
            var lblPrograma = document.getElementById("lblProgramaEstudioMarca");
            var txtPrograma = document.getElementById("txtIdProgramaEstudioMarca");
            var modalTitle = document.getElementById("modalMarcaTitle");

            if (txtOrig) txtOrig.value = marcaSeleccionada.idMarca || "";
            if (txtNombre) txtNombre.value = marcaSeleccionada.nombre || "";

            var prog = marcaSeleccionada.idProgramaEstudio || "";
            if (lblPrograma) lblPrograma.textContent = prog;
            if (txtPrograma) txtPrograma.value = prog;

            if (modalTitle) modalTitle.textContent = "Editar Marca";

            setEstadoFormulario(false);
            var modal = getModalMarca();
            if (modal) modal.show();
        }

        function verDetalle() {
            if (!marcaSeleccionada) {
                Alert.advertencia("Selección requerida", "Por favor, seleccione una marca de la lista para consultar.");
                return;
            }

            var txtOrig = document.getElementById("txtIdMarcaOriginal");
            var txtNombre = document.getElementById("txtNombreMarca");
            var lblPrograma = document.getElementById("lblProgramaEstudioMarca");
            var txtPrograma = document.getElementById("txtIdProgramaEstudioMarca");
            var modalTitle = document.getElementById("modalMarcaTitle");

            if (txtOrig) txtOrig.value = marcaSeleccionada.idMarca || "";
            if (txtNombre) txtNombre.value = marcaSeleccionada.nombre || "";

            var prog = marcaSeleccionada.idProgramaEstudio || "";
            if (lblPrograma) lblPrograma.textContent = prog;
            if (txtPrograma) txtPrograma.value = prog;

            if (modalTitle) modalTitle.textContent = "Consulta de Marca";

            setEstadoFormulario(true);
            var modal = getModalMarca();
            if (modal) modal.show();
        }

        function confirmarEliminar() {
            if (!marcaSeleccionada) {
                Alert.advertencia("Selección requerida", "Por favor, seleccione una marca de la tabla para desactivar.");
                return;
            }

            if (Number(marcaSeleccionada.st_registro) !== 1) {
                Alert.advertencia("Marca inactiva", "La marca seleccionada ya está desactivada.");
                return;
            }

            var nombre = marcaSeleccionada.nombre || marcaSeleccionada.idMarca || "este registro";

            Alert.confirmar("¿Desactivar marca?", '¿Está seguro de desactivar la marca "' + nombre + '"?', async function () {
                await enviarEstadoMarca(marcaSeleccionada.idMarca, false);
            });
        }

        async function cambiarEstadoMarca(idMarca, activar) {
            var marca = marcaCache.find(function (m) {
                return String(m.idMarca) === String(idMarca);
            });

            if (!marca) return;

            var nombre = marca.nombre || idMarca;
            var titulo = activar ? "¿Activar marca?" : "¿Desactivar marca?";
            var mensaje = activar
                ? '¿Está seguro de activar la marca "' + nombre + '"?'
                : '¿Está seguro de desactivar la marca "' + nombre + '"?';

            Alert.confirmar(titulo, mensaje, async function () {
                await enviarEstadoMarca(idMarca, activar);
            });
        }

        async function enviarEstadoMarca(idMarca, activar) {
            var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") ||
                        document.querySelector('input[name="_token"]')?.value;

            try {
                var response = await fetch(activar ? "/marca/activar" : "/marca/eliminar", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        Accept: "application/json",
                        "X-CSRF-TOKEN": token
                    },
                    body: JSON.stringify({ idMarca: idMarca })
                });

                var data = await response.json();

                if (data.ok || data.success) {
                    Alert.exito(activar ? "Activada" : "Desactivada", data.msg || data.message || "Estado actualizado correctamente.", async function () {
                        await mostrarMarca();
                    });
                } else {
                    Alert.error("Error", data.msg || data.message || "No se pudo cambiar el estado de la marca.");
                }
            } catch (e) {
                console.error("Error al cambiar estado:", e);
                Alert.error("Error de conexión", "Error de conexión con el servidor.");
            }
        }

        function exportarExcel() {
            if (!marcaCache.length) {
                Alert.advertencia("Sin datos", "No hay datos para exportar.");
                return;
            }

            var csv = "Nombre,Fecha Creacion,Fecha Modificacion,Usuario Crea,Usuario Modifica,Estado\n";

            marcaCache.forEach(function (m) {
                csv += '"' + (m.nombre || "") + '","' +
                            (formatearFecha(m.fechaCreacion) || "") + '","' +
                            (formatearFecha(m.fechaModificacion) || "") + '","' +
                            (m.idUsuarioCrea || "") + '","' +
                            (m.idUsuarioModifica || "") + '","' +
                            (Number(m.st_registro) === 1 ? "Activo" : "Inactivo") + '"\n';
            });

            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.download = "marcas_" + new Date().toISOString().slice(0, 10) + ".csv";
            link.click();
            URL.revokeObjectURL(link.href);
        }

        panelMarca.addEventListener("click", function (e) {
            var btn = e.target.closest(".tb-btn");
            if (!btn) return;

            var acc = btn.dataset.acc;

            if (acc === "nuevo") nuevoMarca();
            else if (acc === "editar") editarMarca();
            else if (acc === "eliminar") confirmarEliminar();
            else if (acc === "recargar") mostrarMarca();
            else if (acc === "imprimir" || acc === "consultar") verDetalle();
            else if (acc === "excel") exportarExcel();
            else if (acc === "salir") {
                panelMarca.hidden = true;
                if (bienvenida) bienvenida.hidden = false;
            }
        });

        var btnGuardar = document.getElementById("btnGuardarMarca");
        if (btnGuardar) {
            btnGuardar.addEventListener("click", async function () {
                var txtNombre = document.getElementById("txtNombreMarca");
                var nombre = txtNombre ? txtNombre.value.trim() : "";
                var txtPrograma = document.getElementById("txtIdProgramaEstudioMarca");
                var idProgramaEstudio = txtPrograma ? txtPrograma.value : "";
                var txtOrig = document.getElementById("txtIdMarcaOriginal");
                var idOriginal = txtOrig ? txtOrig.value : "";

                if (!nombre) {
                    Alert.advertencia("Campo requerido", "El nombre de la marca es obligatorio.");
                    return;
                }

                try {
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") ||
                                document.querySelector('input[name="_token"]')?.value;

                    var response = await fetch("/marca/guardar", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token
                        },
                        body: JSON.stringify({
                            nombre: nombre,
                            idProgramaEstudio: idProgramaEstudio,
                            st_registro: 1,
                            idOriginal: idOriginal
                        })
                    });

                    var data = await response.json();

                    if (data.ok || data.success) {
                        var modal = getModalMarca();
                        if (modal) modal.hide();

                        Alert.exito("¡Guardado!", data.msg || data.message || "Registro guardado correctamente.", async function () {
                            await mostrarMarca();
                        });
                    } else {
                        Alert.error("Error al guardar", data.msg || data.message || "Error al guardar la marca.");
                    }
                } catch (e) {
                    console.error("Error al guardar:", e);
                    Alert.error("Error de conexión", "Error de conexión al guardar.");
                }
            });
        }

        window.addEventListener("modulo:abrir", function (e) {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "marca") mostrarMarca();
        });
    })();
});
