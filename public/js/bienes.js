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

        // --- FUNCIÓN DE FECHA IDENTICA A GRUPO.JS (UTC-5 AM/PM) ---
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

        function setEstadoFormularioBien(deshabilitado) {
            var form = document.getElementById("formBien");
            if (form) {
                var elementos = form.querySelectorAll("input, select, textarea");
                elementos.forEach(function (el) { el.disabled = deshabilitado; });
            }

            var btnGuardar = document.getElementById("btnGuardarBien");
            if (btnGuardar) {
                btnGuardar.style.display = deshabilitado ? "none" : "";
            }
        }

        function pintarBien(lista) {
            if (!tblBody) return;
            if (!lista.length) {
                tblBody.innerHTML = '<tr><td colspan="13" class="text-center">No hay registros disponibles</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(function (item) {
                return '<tr data-id="' + esc(item.idBien) + '">' +
                    '<td>' + esc(item.cbi || '') + '</td>' +
                    '<td>' + esc(item.descripcion || '') + '</td>' +
                    '<td>' + esc(item.tipo || '') + '</td>' +
                    '<td>' + esc(item.marca || '') + '</td>' +
                    '<td>' + esc(item.modelo || '') + '</td>' +
                    '<td>' + esc(item.estado || '') + '</td>' +
                    '<td>' + esc(item.grupo || '') + '</td>' +
                    '<td>' + esc(item.serieMedida || '') + '</td>' +
                    '<td>' + esc(item.otrasEspecificaciones || '') + '</td>' +
                    '<td>' + esc(formatearFecha(item.fechaCreacion) || '') + '</td>' +
                    '<td>' + esc(formatearFecha(item.fechaModificacion) || '') + '</td>' +
                    '<td>' + esc(item.idUsuarioCrea || '') + '</td>' +
                    '<td>' + esc(item.idUsuarioModifica || '') + '</td>' +
                    '</tr>';
            }).join("");
        }

        // --- CARGAR SALAS PARA EL FILTRO SUPERIOR ---
        async function cargarSalasFiltro() {
            if (!cboFiltroSala) return;
            try {
                var r = await fetch("/bienes/salas", { headers: { Accept: "application/json" } });
                var j = await r.json();
                if (j.ok && Array.isArray(j.data)) {
                    cboFiltroSala.innerHTML = '<option value="">-- TODAS LAS SALAS --</option>';
                    j.data.forEach(function (s) {
                        cboFiltroSala.innerHTML += '<option value="' + esc(s.idSala) + '">' + esc(s.descripcion) + '</option>';
                    });
                }
            } catch (e) {
                console.error("Error al cargar salas en filtro:", e);
            }
        }

        // --- CARGAR LOS 6 COMBOS DEL MODAL DESDE /bienes/combos ---
        async function cargarCombosModal() {
            try {
                // Llenar Sala del modal
                var rSala = await fetch("/bienes/salas", { headers: { Accept: "application/json" } });
                var jSala = await rSala.json();
                var cboSala = document.getElementById("cboSala");
                if (cboSala && jSala.ok && Array.isArray(jSala.data)) {
                    cboSala.innerHTML = '<option value="">-- SELECCIONE SALA --</option>';
                    jSala.data.forEach(function (s) {
                        cboSala.innerHTML += '<option value="' + esc(s.idSala) + '">' + esc(s.descripcion) + '</option>';
                    });
                }

                // Llenar Grupos, Tipos, Marcas, Modelos, Estados
                var rCombos = await fetch("/bienes/combos", { headers: { Accept: "application/json" } });
                var jCombos = await rCombos.json();

                if (jCombos.ok && jCombos.data) {
                    var d = jCombos.data;

                    var cboGrupo = document.getElementById("cboGrupo");
                    if (cboGrupo && Array.isArray(d.grupos)) {
                        cboGrupo.innerHTML = '<option value="">-- SELECCIONE GRUPO --</option>';
                        d.grupos.forEach(function (g) {
                            cboGrupo.innerHTML += '<option value="' + esc(g.idGrupo) + '">' + esc(g.nombre) + '</option>';
                        });
                    }

                    var cboTipo = document.getElementById("cboTipo");
                    if (cboTipo && Array.isArray(d.tipos)) {
                        cboTipo.innerHTML = '<option value="">-- SELECCIONE TIPO --</option>';
                        d.tipos.forEach(function (t) {
                            cboTipo.innerHTML += '<option value="' + esc(t.idTipo) + '">' + esc(t.nombre) + '</option>';
                        });
                    }

                    var cboMarca = document.getElementById("cboMarca");
                    if (cboMarca && Array.isArray(d.marcas)) {
                        cboMarca.innerHTML = '<option value="">-- SELECCIONE MARCA --</option>';
                        d.marcas.forEach(function (m) {
                            cboMarca.innerHTML += '<option value="' + esc(m.idMarca) + '">' + esc(m.nombre) + '</option>';
                        });
                    }

                    var cboModelo = document.getElementById("cboModelo");
                    if (cboModelo && Array.isArray(d.modelos)) {
                        cboModelo.innerHTML = '<option value="">-- SELECCIONE MODELO --</option>';
                        d.modelos.forEach(function (mo) {
                            cboModelo.innerHTML += '<option value="' + esc(mo.idModelo) + '">' + esc(mo.nombre) + '</option>';
                        });
                    }

                    var cboEstado = document.getElementById("cboEstado");
                    if (cboEstado && Array.isArray(d.estados)) {
                        cboEstado.innerHTML = '<option value="">-- SELECCIONE ESTADO --</option>';
                        d.estados.forEach(function (e) {
                            cboEstado.innerHTML += '<option value="' + esc(e.idEstado) + '">' + esc(e.nombre) + '</option>';
                        });
                    }
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
                tblBody.innerHTML = '<tr><td colspan="13" class="text-center text-danger">' + esc(e.message || "Error al cargar datos") + '</td></tr>';
            }
        }

        function aplicarFiltros() {
            var q = txtBuscar ? txtBuscar.value.trim().toLowerCase() : "";
            var idSalaSel = cboFiltroSala ? cboFiltroSala.value : "";

            var filtrados = bienCache.filter(function (item) {
                var texto = Object.values(item).join(" ").toLowerCase();
                var coincideTexto = !q || texto.includes(q);
                var coincideSala = !idSalaSel || String(item.idSala) === String(idSalaSel);
                return coincideTexto && coincideSala;
            });

            pintarBien(filtrados);
        }

        if (tblBody) {
            tblBody.addEventListener("click", function (e) {
                var tr = e.target.closest("tr[data-id]");
                if (!tr) return;

                tblBody.querySelectorAll("tr").forEach(function (x) { x.classList.remove("table-active", "selected", "sel"); });
                tr.classList.add("table-active", "selected", "sel");

                var id = tr.getAttribute("data-id");
                bienSeleccionado = bienCache.find(function (g) { return String(g.idBien) === String(id); });
            });
        }

        if (txtBuscar) txtBuscar.addEventListener("keyup", aplicarFiltros);
        if (cboFiltroSala) cboFiltroSala.addEventListener("change", aplicarFiltros);

        async function abrirModalNuevo() {
            var form = document.getElementById("formBien");
            if (form) form.reset();

            await cargarCombosModal();

            var inputId = document.getElementById("txtIdBienOriginal");
            if (inputId) inputId.value = "";

            var title = document.getElementById("modalBienTitle");
            if (title) title.textContent = "Nuevo Bien";

            setEstadoFormularioBien(false);

            var modalEl = document.getElementById("modalBien");
            if (modalEl) {
                var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                modal.show();
            }
        }

        async function abrirModalEditar() {
            if (!bienSeleccionado) {
                var trSel = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (trSel) {
                    var id = trSel.getAttribute("data-id");
                    bienSeleccionado = bienCache.find(function (g) { return String(g.idBien) === String(id); });
                }
            }

            if (!bienSeleccionado) {
                alert("Por favor, seleccione un registro de la tabla para editar.");
                return;
            }

            await cargarCombosModal();

            document.getElementById("txtIdBienOriginal").value = bienSeleccionado.idBien || "";
            document.getElementById("txtCbi").value = bienSeleccionado.cbi || "";
            document.getElementById("txtDescripcionBien").value = bienSeleccionado.descripcion || "";
            document.getElementById("txtSerieMedida").value = bienSeleccionado.serieMedida || "";
            document.getElementById("txtOtrasEspecificaciones").value = bienSeleccionado.otrasEspecificaciones || "";

            // Seleccionar los valores guardados en los combos
            if (document.getElementById("cboSala")) document.getElementById("cboSala").value = bienSeleccionado.idSala || "";
            if (document.getElementById("cboGrupo")) document.getElementById("cboGrupo").value = bienSeleccionado.idGrupo || "";
            if (document.getElementById("cboTipo")) document.getElementById("cboTipo").value = bienSeleccionado.idTipo || "";
            if (document.getElementById("cboMarca")) document.getElementById("cboMarca").value = bienSeleccionado.idMarca || "";
            if (document.getElementById("cboModelo")) document.getElementById("cboModelo").value = bienSeleccionado.idModelo || "";
            if (document.getElementById("cboEstado")) document.getElementById("cboEstado").value = bienSeleccionado.idEstado || "";

            var title = document.getElementById("modalBienTitle");
            if (title) title.textContent = "Editar Bien";

            setEstadoFormularioBien(false);

            var modalEl = document.getElementById("modalBien");
            if (modalEl) {
                var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                modal.show();
            }
        }

        async function verDetalle() {
            if (!bienSeleccionado) {
                var trSel = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (trSel) {
                    var id = trSel.getAttribute("data-id");
                    bienSeleccionado = bienCache.find(function (g) { return String(g.idBien) === String(id); });
                }
            }

            if (!bienSeleccionado) {
                alert("Por favor, seleccione un registro para consultar.");
                return;
            }

            await cargarCombosModal();

            document.getElementById("txtIdBienOriginal").value = bienSeleccionado.idBien || "";
            document.getElementById("txtCbi").value = bienSeleccionado.cbi || "";
            document.getElementById("txtDescripcionBien").value = bienSeleccionado.descripcion || "";
            document.getElementById("txtSerieMedida").value = bienSeleccionado.serieMedida || "";
            document.getElementById("txtOtrasEspecificaciones").value = bienSeleccionado.otrasEspecificaciones || "";

            if (document.getElementById("cboSala")) document.getElementById("cboSala").value = bienSeleccionado.idSala || "";
            if (document.getElementById("cboGrupo")) document.getElementById("cboGrupo").value = bienSeleccionado.idGrupo || "";
            if (document.getElementById("cboTipo")) document.getElementById("cboTipo").value = bienSeleccionado.idTipo || "";
            if (document.getElementById("cboMarca")) document.getElementById("cboMarca").value = bienSeleccionado.idMarca || "";
            if (document.getElementById("cboModelo")) document.getElementById("cboModelo").value = bienSeleccionado.idModelo || "";
            if (document.getElementById("cboEstado")) document.getElementById("cboEstado").value = bienSeleccionado.idEstado || "";

            var title = document.getElementById("modalBienTitle");
            if (title) title.textContent = "Consulta de Bien";

            setEstadoFormularioBien(true);

            var modalEl = document.getElementById("modalBien");
            if (modalEl) {
                var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                modal.show();
            }
        }

        async function guardarBien() {
            var descripcion = document.getElementById("txtDescripcionBien")?.value.trim();
            if (!descripcion) {
                alert("La descripción del bien es obligatoria.");
                return;
            }

            try {
                var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                            document.querySelector('input[name="_token"]')?.value;

                var response = await fetch("/bienes/guardar", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        Accept: "application/json",
                        "X-CSRF-TOKEN": token
                    },
                    body: JSON.stringify({
                        idOriginal: document.getElementById("txtIdBienOriginal")?.value,
                        cbi: document.getElementById("txtCbi")?.value,
                        descripcion: descripcion,
                        serieMedida: document.getElementById("txtSerieMedida")?.value,
                        otrasEspecificaciones: document.getElementById("txtOtrasEspecificaciones")?.value,
                        idSala: document.getElementById("cboSala")?.value,
                        idGrupo: document.getElementById("cboGrupo")?.value,
                        idTipo: document.getElementById("cboTipo")?.value,
                        idMarca: document.getElementById("cboMarca")?.value,
                        idModelo: document.getElementById("cboModelo")?.value,
                        idEstado: document.getElementById("cboEstado")?.value
                    })
                });

                var data = await response.json();
                if (data.ok) {
                    var modalEl = document.getElementById("modalBien");
                    if (modalEl) {
                        var modal = bootstrap.Modal.getInstance(modalEl);
                        if (modal) modal.hide();
                    }
                    await listarBien();
                } else {
                    alert(data.msg || "Error al guardar el bien.");
                }
            } catch (e) {
                alert("Error de conexión al guardar.");
            }
        }

        function confirmarEliminar() {
            if (!bienSeleccionado) {
                var trSel = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (trSel) {
                    var id = trSel.getAttribute("data-id");
                    bienSeleccionado = bienCache.find(function (g) { return String(g.idBien) === String(id); });
                }
            }

            if (!bienSeleccionado) {
                alert("Por favor, seleccione un registro de la tabla para eliminar.");
                return;
            }

            var modalEl = document.getElementById("modalConfirmarEliminar");
            var msgEl = document.getElementById("msgConfirmarEliminar");
            var btnEliminar = document.getElementById("btnConfirmarEliminarAccion");

            if (!modalEl) return;

            var nombre = bienSeleccionado.descripcion || bienSeleccionado.idBien;
            if (msgEl) msgEl.textContent = '¿Está seguro de eliminar el bien "' + nombre + '"?';

            var bsModal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);

            if (btnEliminar) {
                btnEliminar.onclick = async function () {
                    bsModal.hide();
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                                document.querySelector('input[name="_token"]')?.value;

                    try {
                        var res = await fetch("/bienes/eliminar", {
                            method: "POST",
                            headers: {
                                "X-CSRF-TOKEN": token,
                                "Content-Type": "application/json",
                                Accept: "application/json"
                            },
                            body: JSON.stringify({ idBien: bienSeleccionado.idBien })
                        });

                        var data = await res.json();
                        if (data.ok) {
                            await listarBien();
                        } else {
                            alert(data.msg || "Error al eliminar el bien.");
                        }
                    } catch (err) {
                        alert("Error de conexión con el servidor.");
                    }
                };
            }

            bsModal.show();
        }

        function exportarExcel() {
            if (!bienCache || !bienCache.length) { 
                alert("No hay datos para exportar."); 
                return; 
            }
            var csv = "cbi,descripcion,Tipo,Marca,Modelo,Estado,Grupo,serieMedida,otrasEspecificaciones,fechaCreacion,fechaModificacion,idUsuarioCrea,idUsuarioModifica\n";
            bienCache.forEach(function (item) {
                var cbi = (item.cbi || "").replace(/"/g, '""');
                var des = (item.descripcion || "").replace(/"/g, '""');
                var tip = (item.tipo || "").replace(/"/g, '""');
                var mar = (item.marca || "").replace(/"/g, '""');
                var mod = (item.modelo || "").replace(/"/g, '""');
                var est = (item.estado || "").replace(/"/g, '""');
                var gru = (item.grupo || "").replace(/"/g, '""');
                var ser = (item.serieMedida || "").replace(/"/g, '""');
                var esp = (item.otrasEspecificaciones || "").replace(/"/g, '""');
                var fCrea = (formatearFecha(item.fechaCreacion) || "").replace(/"/g, '""');
                var fMod = (formatearFecha(item.fechaModificacion) || "").replace(/"/g, '""');
                var uCrea = (item.idUsuarioCrea || "").replace(/"/g, '""');
                var uMod = (item.idUsuarioModifica || "").replace(/"/g, '""');

                csv += '"' + cbi + '","' + des + '","' + tip + '","' + mar + '","' + mod + '","' + est + '","' + gru + '","' + ser + '","' + esp + '","' + fCrea + '","' + fMod + '","' + uCrea + '","' + uMod + '"\n';
            });

            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            var url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "bienes_" + new Date().toISOString().slice(0, 10) + ".csv");
            link.style.visibility = "hidden";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        var btnGuardarModal = document.getElementById("btnGuardarBien");
        if (btnGuardarModal) {
            btnGuardarModal.addEventListener("click", function (e) {
                e.preventDefault();
                guardarBien();
            });
        }

        var formEl = document.getElementById("formBien");
        formEl?.addEventListener("submit", function (e) {
            e.preventDefault();
            guardarBien();
        });

        panelBien.querySelectorAll(".tb-btn").forEach(function (b) {
            b.addEventListener("click", function () {
                var acc = b.dataset.acc;
                if (acc === "nuevo") abrirModalNuevo();
                else if (acc === "editar") abrirModalEditar();
                else if (acc === "eliminar") confirmarEliminar();
                else if (acc === "recargar") listarBien();
                else if (acc === "imprimir" || acc === "consultar" || acc === "detalle") verDetalle();
                else if (acc === "excel") exportarExcel();
                else if (acc === "salir" && bienvenida) {
                    if (panelBien !== document) panelBien.hidden = true;
                    bienvenida.hidden = false;
                }
            });
        });

        window.addEventListener("modulo:abrir", function (e) {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "bienes" || mod === "bien") {
                listarBien();
            }
        });

        cargarSalasFiltro();
        listarBien();
    })();
});