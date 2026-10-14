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
                tblBody.innerHTML = '<tr><td colspan="5" class="text-center">Sin marcas registradas.</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(function (m) {
                return '<tr data-id="' + esc(m.idMarca) + '" style="cursor:pointer;">' +
                    '<td>' + esc(m.nombre) + '</td>' +
                    '<td>' + esc(formatearFecha(m.fechaCreacion)) + '</td>' +
                    '<td>' + esc(formatearFecha(m.fechaModificacion)) + '</td>' +
                    '<td>' + esc(m.idUsuarioCrea) + '</td>' +
                    '<td>' + esc(m.idUsuarioModifica) + '</td></tr>';
            }).join("");
        }

        async function mostrarMarca() {
            if (!tblBody) return;
            tblBody.innerHTML = '<tr><td colspan="5" class="text-center">Cargando...</td></tr>';
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
                tblBody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">' + esc(e.message) + '</td></tr>';
            }
        }

        // Cargar al mostrar el panel
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

        // Seleccionar fila de la tabla
        if (tblBody) {
            tblBody.addEventListener("click", function (e) {
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

        // Filtrar con el input de búsqueda
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

        // --- ACCIONES DE FORMULARIO ---

        function nuevoMarca() {
            var form = document.getElementById("formMarca");
            if (form) form.reset();

            var txtOrig = document.getElementById("txtIdMarcaOriginal");
            if (txtOrig) txtOrig.value = "";

            var lblPrograma = document.getElementById("lblProgramaEstudioMarca");
            var txtPrograma = document.getElementById("txtIdProgramaEstudioMarca");
            if (lblPrograma) lblPrograma.textContent = "2";
            if (txtPrograma) txtPrograma.value = "2";

            var modalTitle = document.getElementById("modalMarcaTitle");
            if (modalTitle) modalTitle.textContent = "Nueva Marca";

            setEstadoFormulario(false);
            var modal = getModalMarca();
            if (modal) modal.show();
        }

        function editarMarca() {
            if (!marcaSeleccionada) { 
                alert("Por favor, seleccione una marca de la lista para editar."); 
                return; 
            }

            var txtOrig = document.getElementById("txtIdMarcaOriginal");
            var txtNombre = document.getElementById("txtNombreMarca");
            var lblPrograma = document.getElementById("lblProgramaEstudioMarca");
            var txtPrograma = document.getElementById("txtIdProgramaEstudioMarca");
            var modalTitle = document.getElementById("modalMarcaTitle");

            if (txtOrig) txtOrig.value = marcaSeleccionada.idMarca || "";
            if (txtNombre) txtNombre.value = marcaSeleccionada.nombre || "";
            
            var prog = marcaSeleccionada.idProgramaEstudio || "2";
            if (lblPrograma) lblPrograma.textContent = prog;
            if (txtPrograma) txtPrograma.value = prog;

            if (modalTitle) modalTitle.textContent = "Editar Marca";

            setEstadoFormulario(false);
            var modal = getModalMarca();
            if (modal) modal.show();
        }

        function verDetalle() {
            if (!marcaSeleccionada) { 
                alert("Por favor, seleccione una marca de la lista para consultar."); 
                return; 
            }

            var txtOrig = document.getElementById("txtIdMarcaOriginal");
            var txtNombre = document.getElementById("txtNombreMarca");
            var lblPrograma = document.getElementById("lblProgramaEstudioMarca");
            var txtPrograma = document.getElementById("txtIdProgramaEstudioMarca");
            var modalTitle = document.getElementById("modalMarcaTitle");

            if (txtOrig) txtOrig.value = marcaSeleccionada.idMarca || "";
            if (txtNombre) txtNombre.value = marcaSeleccionada.nombre || "";

            var prog = marcaSeleccionada.idProgramaEstudio || "2";
            if (lblPrograma) lblPrograma.textContent = prog;
            if (txtPrograma) txtPrograma.value = prog;

            if (modalTitle) modalTitle.textContent = "Consulta de Marca";

            setEstadoFormulario(true);
            var modal = getModalMarca();
            if (modal) modal.show();
        }

        function confirmarEliminar() {
            if (!marcaSeleccionada) {
                alert("Por favor, seleccione una marca de la tabla para eliminar.");
                return;
            }

            var nombre = marcaSeleccionada.nombre || marcaSeleccionada.idMarca;
            var msgEl = document.getElementById("txtMarcaEliminar");
            if (msgEl) msgEl.textContent = nombre;

            var modalEl = document.getElementById("modalEliminarMarca");
            if (!modalEl) return;

            var bsModal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
            var btnConfirmar = document.getElementById("btnConfirmarEliminarMarca");

            if (btnConfirmar) {
                btnConfirmar.onclick = async function () {
                    bsModal.hide();
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                                document.querySelector('input[name="_token"]')?.value;

                    try {
                        var response = await fetch("/marca/eliminar", {
                            method: "POST",
                            headers: {
                                "Content-Type": "application/json",
                                Accept: "application/json",
                                "X-CSRF-TOKEN": token
                            },
                            body: JSON.stringify({ idMarca: marcaSeleccionada.idMarca })
                        });

                        var data = await response.json();
                        if (data.ok) {
                            await mostrarMarca();
                        } else {
                            alert(data.msg || "Error al eliminar la marca.");
                        }
                    } catch (e) {
                        console.error("Error al eliminar:", e);
                        alert("Error de conexión con el servidor.");
                    }
                };
            }
            bsModal.show();
        }

        function exportarExcel() {
            if (!marcaCache.length) { alert("No hay datos para exportar."); return; }
            var csv = "Nombre,Fecha Creacion,Fecha Modificacion,Usuario Crea,Usuario Modifica\n";
            marcaCache.forEach(function (m) {
                csv += '"' + (m.nombre || "") + '","' + 
                            (formatearFecha(m.fechaCreacion) || "") + '","' + 
                            (formatearFecha(m.fechaModificacion) || "") + '","' + 
                            (m.idUsuarioCrea || "") + '","' + 
                            (m.idUsuarioModifica || "") + '"\n';
            });
            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.download = "marcas_" + new Date().toISOString().slice(0, 10) + ".csv";
            link.click();
        }

        // --- MANEJADOR DE EVENTOS EN BARRA DE HERRAMIENTAS ---
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

        // Guardar cambios desde el Modal
        var btnGuardar = document.getElementById("btnGuardarMarca");
        if (btnGuardar) {
            btnGuardar.addEventListener("click", async function () {
                var txtNombre = document.getElementById("txtNombreMarca");
                var nombre = txtNombre ? txtNombre.value.trim() : "";
                var txtPrograma = document.getElementById("txtIdProgramaEstudioMarca");
                var idProgramaEstudio = txtPrograma ? txtPrograma.value : "";
                var cboEstado = document.getElementById("cboEstadoMarca");
                var stRegistro = cboEstado ? cboEstado.value : 1;
                var txtOrig = document.getElementById("txtIdMarcaOriginal");
                var idOriginal = txtOrig ? txtOrig.value : "";

                if (!nombre) {
                    alert("El nombre de la marca es obligatorio.");
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
                            st_registro: stRegistro,
                            idOriginal: idOriginal
                        })
                    });

                    var data = await response.json();
                    if (data.ok) {
                        var modal = getModalMarca();
                        if (modal) modal.hide();
                        await mostrarMarca();
                    } else {
                        alert(data.msg || "Error al guardar la marca.");
                    }
                } catch (e) {
                    var modal = getModalMarca();
                    if (modal) modal.hide();
                    alert("Error de conexión al guardar.");
                }
            });
        }

        window.addEventListener("modulo:abrir", function (e) {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "marca") mostrarMarca();
        });
    })();
});