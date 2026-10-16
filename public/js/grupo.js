document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelGrupo = document.getElementById("mpGrupo") || document;
        var bienvenida = document.getElementById("mpBienvenida");

        var tblBody = document.getElementById("tbody_grupo") || document.querySelector("#tblGrupo tbody");
        var txtBuscar = document.getElementById("txtBuscarGrupo");
        var grupoCache = [];
        var grupoSeleccionado = null;

        function esc(v) {
            return String(v || "").replace(/[&<">]/g, function (c) {
                return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
            });
        }

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

        function setEstadoFormularioGrupo(deshabilitado) {
            var form = document.getElementById("formGrupo") || document.getElementById("form_grupo");
            var modalEl = document.getElementById("modalGrupo") || document.getElementById("grupo_modal");
            
            if (form) {
                var elementos = form.querySelectorAll("input, select, textarea");
                elementos.forEach(function (el) {
                    el.disabled = deshabilitado;
                });
            }

            var btnGuardar = document.getElementById("btnGuardarGrupo") || 
                             document.getElementById("btn_guardar_grupo") || 
                             (form ? form.querySelector('button[type="submit"]') : null) ||
                             (modalEl ? modalEl.querySelector('.btn-primary, button[type="submit"]') : null);

            if (btnGuardar) {
                btnGuardar.style.display = deshabilitado ? "none" : "";
            }
        }

        function pintarGrupo(lista) {
            if (!tblBody) return;
            if (!lista.length) {
                tblBody.innerHTML = '<tr><td colspan="5" class="text-center">No hay registros disponibles</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(function (item) {
                return '<tr data-id="' + esc(item.idGrupo) + '">' +
                    '<td>' + esc(item.nombre || '') + '</td>' +
                    '<td>' + esc(item.idUsuarioCrea || '') + '</td>' +
                    '<td>' + esc(formatearFecha(item.fechaCreacion) || '') + '</td>' +
                    '<td>' + esc(item.idUsuarioModifica || '') + '</td>' +
                    '<td>' + esc(formatearFecha(item.fechaModificacion) || '') + '</td>' +
                    '</tr>';
            }).join("");
        }

        async function listarGrupo() {
            if (!tblBody) return;
            tblBody.innerHTML = '<tr><td colspan="5" class="text-center">Cargando...</td></tr>';
            grupoSeleccionado = null;

            try {
                var r = await fetch("/grupo/listar", { headers: { Accept: "application/json" } });
                
                if (!r.ok) {
                    throw new Error("Error HTTP " + r.status + ": No se pudo conectar con el servidor.");
                }

                var j = await r.json();
                var lista = j.data || (Array.isArray(j) ? j : []);
                if (!Array.isArray(lista)) throw new Error("Sin datos");

                grupoCache = lista;
                pintarGrupo(grupoCache);
                if (txtBuscar) txtBuscar.value = "";
            } catch (e) {
                console.error("Error al cargar grupos:", e);
                tblBody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">' + esc(e.message || "Error al cargar datos") + '</td></tr>';
            }
        }

        if (tblBody) {
            tblBody.addEventListener("click", function (e) {
                var tr = e.target.closest("tr[data-id]");
                if (!tr) return;

                tblBody.querySelectorAll("tr").forEach(function (x) { x.classList.remove("table-active", "selected", "sel"); });
                tr.classList.add("table-active", "selected", "sel");

                var id = tr.getAttribute("data-id");
                grupoSeleccionado = grupoCache.find(function (g) { return String(g.idGrupo) === String(id); });
            });
        }

        if (txtBuscar) {
            txtBuscar.addEventListener("keyup", function () {
                var q = txtBuscar.value.trim().toLowerCase();
                if (!q) return pintarGrupo(grupoCache);
                pintarGrupo(grupoCache.filter(function (item) {
                    var texto = ((item.nombre || "") + " " + (item.idUsuarioCrea || "") + " " + (item.idUsuarioModifica || "")).toLowerCase();
                    return texto.includes(q);
                }));
            });
        }

        function abrirModalNuevo() {
            var form = document.getElementById("formGrupo") || document.getElementById("form_grupo");
            if (form) form.reset();

            var inputId = document.getElementById("txtIdGrupoOriginal") || document.getElementById("grupo_id");
            if (inputId) inputId.value = "";

            var title = document.getElementById("modalGrupoTitle") || document.getElementById("modal_grupo_title");
            if (title) title.textContent = "Nuevo Grupo";

            setEstadoFormularioGrupo(false);

            var modalEl = document.getElementById("modalGrupo") || document.getElementById("grupo_modal");
            if (modalEl) {
                var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                modal.show();
            }
        }

        function abrirModalEditar() {
            if (!grupoSeleccionado) {
                var trSel = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (trSel) {
                    var id = trSel.getAttribute("data-id");
                    grupoSeleccionado = grupoCache.find(function (g) { return String(g.idGrupo) === String(id); });
                }
            }

            if (!grupoSeleccionado) {
                Alert.advertencia("Selección requerida", "Por favor, seleccione un registro de la tabla para editar.");
                return;
            }

            var txtOrig = document.getElementById("txtIdGrupoOriginal") || document.getElementById("grupo_id");
            var txtNombre = document.getElementById("txtNombreGrupo") || document.getElementById("grupo_nombre");
            var txtProg = document.getElementById("txtIdProgramaEstudio") || document.getElementById("grupo_idProgramaEstudio");
            var lblProg = document.getElementById("lblProgramaEstudio");

            if (txtOrig) txtOrig.value = grupoSeleccionado.idGrupo || "";
            if (txtNombre) txtNombre.value = grupoSeleccionado.nombre || "";
            if (txtProg) txtProg.value = grupoSeleccionado.idProgramaEstudio || "";
            if (lblProg) lblProg.textContent = grupoSeleccionado.idProgramaEstudio || "";

            var title = document.getElementById("modalGrupoTitle") || document.getElementById("modal_grupo_title");
            if (title) title.textContent = "Editar Grupo";

            setEstadoFormularioGrupo(false);

            var modalEl = document.getElementById("modalGrupo") || document.getElementById("grupo_modal");
            if (modalEl) {
                var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                modal.show();
            }
        }

        function verDetalle() {
            if (!grupoSeleccionado) {
                var trSel = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (trSel) {
                    var id = trSel.getAttribute("data-id");
                    grupoSeleccionado = grupoCache.find(function (g) { return String(g.idGrupo) === String(id); });
                }
            }

            if (!grupoSeleccionado) {
                Alert.advertencia("Selección requerida", "Por favor, seleccione un registro para consultar.");
                return;
            }

            var txtOrig = document.getElementById("txtIdGrupoOriginal") || document.getElementById("grupo_id");
            var txtNombre = document.getElementById("txtNombreGrupo") || document.getElementById("grupo_nombre");
            var txtProg = document.getElementById("txtIdProgramaEstudio") || document.getElementById("grupo_idProgramaEstudio");
            var lblProg = document.getElementById("lblProgramaEstudio");

            if (txtOrig) txtOrig.value = grupoSeleccionado.idGrupo || "";
            if (txtNombre) txtNombre.value = grupoSeleccionado.nombre || "";
            if (txtProg) txtProg.value = grupoSeleccionado.idProgramaEstudio || "";
            if (lblProg) lblProg.textContent = grupoSeleccionado.idProgramaEstudio || "";

            var title = document.getElementById("modalGrupoTitle") || document.getElementById("modal_grupo_title");
            if (title) title.textContent = "Consulta de Grupo";

            setEstadoFormularioGrupo(true);

            var modalEl = document.getElementById("modalGrupo") || document.getElementById("grupo_modal");
            if (modalEl) {
                var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                modal.show();
            }
        }

        async function guardarGrupo() {
            var txtNombre = document.getElementById("txtNombreGrupo") || document.getElementById("grupo_nombre");
            var nombre = txtNombre ? txtNombre.value.trim() : "";
            
            var txtProg = document.getElementById("txtIdProgramaEstudio") || document.getElementById("grupo_idProgramaEstudio");
            var idProgramaEstudio = txtProg ? txtProg.value : "";
            
            var cboEstado = document.getElementById("cboEstadoGrupo") || document.getElementById("grupo_estado");
            var stRegistro = cboEstado ? cboEstado.value : 1;
            
            var txtOrig = document.getElementById("txtIdGrupoOriginal") || document.getElementById("grupo_id");
            var idOriginal = txtOrig ? txtOrig.value : "";

            if (!nombre) {
                Alert.advertencia("Campo requerido", "El nombre del grupo es obligatorio.");
                return;
            }

            try {
                var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                            document.querySelector('input[name="_token"]')?.value;

                var response = await fetch("/grupo/guardar", {
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
                        idOriginal: idOriginal,
                        idGrupo: idOriginal
                    })
                });

                var data = await response.json();
                if (data.ok || data.success) {
                    var modalEl = document.getElementById("modalGrupo") || document.getElementById("grupo_modal");
                    if (modalEl) {
                        var modal = bootstrap.Modal.getInstance(modalEl);
                        if (modal) modal.hide();
                    }
                    Alert.exito("¡Guardado!", data.msg || data.message || "Registro guardado correctamente.", async function () {
                        await listarGrupo();
                    });
                } else {
                    Alert.error("Error al guardar", data.msg || data.message || "Error al guardar el grupo.");
                }
            } catch (e) {
                var modalEl = document.getElementById("modalGrupo") || document.getElementById("grupo_modal");
                if (modalEl) {
                    var modal = bootstrap.Modal.getInstance(modalEl);
                    if (modal) modal.hide();
                }
                Alert.error("Error de conexión", "Error de conexión al guardar.");
            }
        }

        function confirmarEliminar() {
            if (!grupoSeleccionado) {
                var trSel = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (trSel) {
                    var id = trSel.getAttribute("data-id");
                    grupoSeleccionado = grupoCache.find(function (g) { return String(g.idGrupo) === String(id); });
                }
            }

            if (!grupoSeleccionado) {
                Alert.advertencia("Selección requerida", "Por favor, seleccione un registro de la tabla para eliminar.");
                return;
            }

            var nombre = grupoSeleccionado.nombre || grupoSeleccionado.idGrupo || "este registro";

            Alert.confirmar("¿Eliminar registro?", '¿Está seguro de eliminar el grupo "' + nombre + '"?', async function () {
                var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || 
                            document.querySelector('input[name="_token"]')?.value;

                try {
                    var res = await fetch("/grupo/eliminar", {
                        method: "POST",
                        headers: {
                            "X-CSRF-TOKEN": token,
                            "Content-Type": "application/json",
                            Accept: "application/json"
                        },
                        body: JSON.stringify({ idGrupo: grupoSeleccionado.idGrupo })
                    });

                    var data = await res.json();
                    if (data.ok || data.success) {
                        Alert.exito("Eliminado", data.msg || data.message || "Grupo eliminado correctamente.", async function () {
                            await listarGrupo();
                        });
                    } else {
                        Alert.error("Error al eliminar", data.msg || data.message || "Error al eliminar el grupo.");
                    }
                } catch (err) {
                    console.error("Error al eliminar:", err);
                    Alert.error("Error de conexión", "Error de conexión con el servidor.");
                }
            });
        }

        function exportarExcel() {
            if (!grupoCache || !grupoCache.length) { 
                Alert.advertencia("Sin datos", "No hay datos para exportar."); 
                return; 
            }
            var csv = "Nombre,idUsuarioCrea,fechaCreacion,idUsuarioModifica,fechaModificacion\n";
            grupoCache.forEach(function (item) {
                var nombre = (item.nombre || "").replace(/"/g, '""');
                var uCrea = (item.idUsuarioCrea || "").replace(/"/g, '""');
                var fCrea = (formatearFecha(item.fechaCreacion) || "").replace(/"/g, '""');
                var uMod = (item.idUsuarioModifica || "").replace(/"/g, '""');
                var fMod = (formatearFecha(item.fechaModificacion) || "").replace(/"/g, '""');

                csv += '"' + nombre + '","' + uCrea + '","' + fCrea + '","' + uMod + '","' + fMod + '"\n';
            });

            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            var url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "grupos_" + new Date().toISOString().slice(0, 10) + ".csv");
            link.style.visibility = "hidden";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        document.getElementById("btn_nuevo_grupo")?.addEventListener("click", abrirModalNuevo);
        document.getElementById("btn_editar_grupo")?.addEventListener("click", abrirModalEditar);
        document.getElementById("btn_eliminar_grupo")?.addEventListener("click", confirmarEliminar);
        document.getElementById("btn_recargar_grupo")?.addEventListener("click", listarGrupo);
        document.getElementById("btn_detalle_grupo")?.addEventListener("click", verDetalle);

        var btnGuardarModal = document.getElementById("btnGuardarGrupo") || document.getElementById("btn_guardar_grupo");
        if (btnGuardarModal) {
            btnGuardarModal.addEventListener("click", function (e) {
                e.preventDefault();
                guardarGrupo();
            });
        }

        var formEl = document.getElementById("formGrupo") || document.getElementById("form_grupo");
        formEl?.addEventListener("submit", function (e) {
            e.preventDefault();
            guardarGrupo();
        });

        panelGrupo.querySelectorAll(".tb-btn").forEach(function (b) {
            b.addEventListener("click", function () {
                var acc = b.dataset.acc;
                if (acc === "nuevo") abrirModalNuevo();
                else if (acc === "editar") abrirModalEditar();
                else if (acc === "eliminar") confirmarEliminar();
                else if (acc === "recargar") listarGrupo();
                else if (acc === "imprimir" || acc === "consultar" || acc === "detalle") verDetalle();
                else if (acc === "excel") exportarExcel();
                else if (acc === "salir" && bienvenida) {
                    if (panelGrupo !== document) panelGrupo.hidden = true;
                    bienvenida.hidden = false;
                }
            });
        });

        window.addEventListener("modulo:abrir", function (e) {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "grupo") {
                listarGrupo();
            }
        });

        listarGrupo();
    })();
});