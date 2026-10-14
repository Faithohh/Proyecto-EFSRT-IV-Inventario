document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelPersonal = document.getElementById("mpPersonal") || document;
        var bienvenida = document.getElementById("mpBienvenida");

        var tblBody = document.getElementById("tbody_personal");
        var txtBuscar = document.getElementById("txtBuscarPersonal");
        var personalCache = [];
        var personalSeleccionado = null;

        function esc(v) {
            return String(v || "").replace(/[&<">]/g, function (c) {
                return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
            });
        }

        // Función helper para remover palabras duplicadas consecutivas en el nombre (ej. "TEO TEO" -> "TEO")
        function limpiarNombreDuplicado(texto) {
            if (!texto) return "";
            var palabras = texto.trim().split(/\s+/);
            var resultado = [];
            palabras.forEach(function (p) {
                if (resultado.length === 0 || resultado[resultado.length - 1].toLowerCase() !== p.toLowerCase()) {
                    resultado.push(p);
                }
            });
            return resultado.join(" ");
        }

        function setEstadoFormularioPersonal(deshabilitado) {
            var form = document.getElementById("form_personal");
            var modalEl = document.getElementById("personal_modal");
            
            if (form) {
                var elementos = form.querySelectorAll("input, select, textarea");
                elementos.forEach(function (el) {
                    el.disabled = deshabilitado;
                });
            }

            var btnGuardar = document.getElementById("btnGuardarPersonal") || 
                             document.getElementById("btn_guardar_personal") || 
                             (form ? form.querySelector('button[type="submit"]') : null) ||
                             (modalEl ? modalEl.querySelector('.btn-primary, button[type="submit"]') : null);

            if (btnGuardar) {
                btnGuardar.style.display = deshabilitado ? "none" : "";
            }
        }

        function pintarPersonal(lista) {
            if (!tblBody) return;
            if (!lista.length) {
                tblBody.innerHTML = '<tr><td colspan="5" class="text-center">No hay registros disponibles</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(function (item) {
                var isChecked = (item.st_registro == 1 || item.st_registro == true) ? 'checked' : '';
                var nombreMostrar = limpiarNombreDuplicado(item.nombreCompleto || ((item.apellidos || '') + ' ' + (item.nombres || '')));

                return '<tr data-id="' + esc(item.idPersonal) + '">' +
                    '<td>' + esc(nombreMostrar || '-') + '</td>' +
                    '<td>' + esc(item.dni || '-') + '</td>' +
                    '<td>' + esc(item.celular || '-') + '</td>' +
                    '<td>' + esc(item.email || '-') + '</td>' +
                    '<td class="text-center"><input type="checkbox" disabled ' + isChecked + '></td></tr>';
            }).join("");
        }

        async function listarPersonal() {
            if (!tblBody) return;
            tblBody.innerHTML = '<tr><td colspan="5" class="text-center">Cargando...</td></tr>';
            personalSeleccionado = null;

            try {
                var r = await fetch("/personal/listar", { headers: { Accept: "application/json" } });
                var j = await r.json();
                var lista = j.data || (Array.isArray(j) ? j : []);
                if (!Array.isArray(lista)) throw new Error("Sin datos");

                personalCache = lista;
                pintarPersonal(personalCache);
                if (txtBuscar) txtBuscar.value = "";
            } catch (e) {
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
                personalSeleccionado = personalCache.find(function (p) { return String(p.idPersonal) === String(id); });
            });
        }

        if (txtBuscar) {
            txtBuscar.addEventListener("keyup", function () {
                var q = txtBuscar.value.trim().toLowerCase();
                if (!q) return pintarPersonal(personalCache);
                pintarPersonal(personalCache.filter(function (item) {
                    var nombre = limpiarNombreDuplicado(item.nombreCompleto || ((item.apellidos || '') + ' ' + (item.nombres || '')));
                    var texto = (nombre + " " + (item.dni || "") + " " + (item.email || "")).toLowerCase();
                    return texto.includes(q);
                }));
            });
        }

        function abrirModalNuevo() {
            var form = document.getElementById("form_personal");
            if (form) form.reset();

            var inputId = document.getElementById("personal_id");
            if (inputId) inputId.value = "";

            var title = document.getElementById("modal_personal_title");
            if (title) title.textContent = "Registrar Personal";

            setEstadoFormularioPersonal(false);

            var modalEl = document.getElementById("personal_modal");
            if (modalEl) {
                var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                modal.show();
            }
        }

        function cargarDatosFormulario() {
            if (!personalSeleccionado) return;

            var nombreLimpio = limpiarNombreDuplicado(personalSeleccionado.nombreCompleto || personalSeleccionado.nombres || "");

            if (document.getElementById("personal_id")) document.getElementById("personal_id").value = personalSeleccionado.idPersonal || "";
            if (document.getElementById("personal_dni")) document.getElementById("personal_dni").value = personalSeleccionado.dni || "";
            if (document.getElementById("personal_nombreCompleto")) document.getElementById("personal_nombreCompleto").value = nombreLimpio;
            if (document.getElementById("personal_nombres")) document.getElementById("personal_nombres").value = personalSeleccionado.nombres || "";
            if (document.getElementById("personal_apellidos")) document.getElementById("personal_apellidos").value = personalSeleccionado.apellidos || "";
            if (document.getElementById("personal_celular")) document.getElementById("personal_celular").value = personalSeleccionado.celular || "";
            if (document.getElementById("personal_email")) document.getElementById("personal_email").value = personalSeleccionado.email || "";
            if (document.getElementById("personal_st_registro")) document.getElementById("personal_st_registro").value = personalSeleccionado.st_registro ?? 1;
        }

        function abrirModalEditar() {
            if (!personalSeleccionado) {
                alert("Por favor, seleccione un registro de la tabla.");
                return;
            }

            cargarDatosFormulario();

            var title = document.getElementById("modal_personal_title");
            if (title) title.textContent = "Editar Personal";

            setEstadoFormularioPersonal(false);

            var modalEl = document.getElementById("personal_modal");
            if (modalEl) {
                var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                modal.show();
            }
        }

        function verDetalle() {
            if (!personalSeleccionado) {
                var trSel = tblBody ? tblBody.querySelector("tr.sel, tr.selected, tr.table-active") : null;
                if (trSel) {
                    var id = trSel.getAttribute("data-id");
                    personalSeleccionado = personalCache.find(function (p) { return String(p.idPersonal) === String(id); });
                }
            }

            if (!personalSeleccionado) {
                alert("Por favor, seleccione un registro para consultar.");
                return;
            }

            cargarDatosFormulario();

            var title = document.getElementById("modal_personal_title");
            if (title) title.textContent = "Consulta de Personal";

            setEstadoFormularioPersonal(true);

            var modalEl = document.getElementById("personal_modal");
            if (modalEl) {
                var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                modal.show();
            }
        }

        async function guardarPersonal() {
            var form = document.getElementById("form_personal");
            if (!form) return;

            var formData = new FormData(form);
            var token = document.querySelector('meta[name="csrf-token"]')?.content || document.querySelector('input[name="_token"]')?.value;

            try {
                var response = await fetch("/personal/guardar", {
                    method: "POST",
                    body: formData,
                    headers: { "X-CSRF-TOKEN": token }
                });
                var data = await response.json();

                if (data.ok || data.success) {
                    var modalEl = document.getElementById("personal_modal");
                    var modal = bootstrap.Modal.getInstance(modalEl);
                    if (modal) modal.hide();
                    await listarPersonal();
                } else {
                    alert(data.msg || data.message || "Error al guardar el registro.");
                }
            } catch (error) {
                console.error("Error al guardar:", error);
                alert("Error de conexión al guardar.");
            }
        }

        function confirmarEliminar() {
            if (!personalSeleccionado) {
                alert("Por favor, seleccione un registro de la tabla.");
                return;
            }

            var nombre = limpiarNombreDuplicado(personalSeleccionado.nombreCompleto || personalSeleccionado.nombres || "este registro");
            
            var msgEl = document.getElementById("msgConfirmarEliminar");
            if (msgEl) {
                msgEl.textContent = "¿Está seguro de eliminar a " + nombre + "?";
            }

            var modalEl = document.getElementById("modalConfirmarEliminar");
            var btnEliminar = document.getElementById("btnConfirmarEliminarAccion");

            if (!modalEl) return;

            var bsModal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);

            btnEliminar.onclick = async function () {
                bsModal.hide();

                var token = document.querySelector('meta[name="csrf-token"]')?.content || document.querySelector('input[name="_token"]')?.value;

                try {
                    var res = await fetch("/personal/eliminar/" + personalSeleccionado.idPersonal, {
                        method: "DELETE",
                        headers: {
                            "X-CSRF-TOKEN": token,
                            "Content-Type": "application/json",
                            Accept: "application/json"
                        }
                    });
                    var data = await res.json();
                    if (data.ok || data.success) {
                        await listarPersonal();
                    }
                } catch (err) {
                    console.error("Error al eliminar:", err);
                }
            };

            bsModal.show();
        }

        function exportarExcel() {
            if (!personalCache || !personalCache.length) { 
                alert("No hay datos para exportar."); 
                return; 
            }
            var csv = "Nombre Completo,DNI,Celular,Email,Estado\n";
            personalCache.forEach(function (item) {
                var estado = (item.st_registro == 1 || item.st_registro == true) ? "ACTIVO" : "INACTIVO";
                var nombre = limpiarNombreDuplicado(item.nombreCompleto || ((item.apellidos || '') + ' ' + (item.nombres || ''))).replace(/"/g, '""');
                var dni = (item.dni || "").replace(/"/g, '""');
                var celular = (item.celular || "").replace(/"/g, '""');
                var email = (item.email || "").replace(/"/g, '""');

                csv += '"' + nombre + '","' + dni + '","' + celular + '","' + email + '","' + estado + '"\n';
            });

            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            var url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "personal_" + new Date().toISOString().slice(0, 10) + ".csv");
            link.style.visibility = "hidden";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        document.getElementById("btn_nuevo_personal")?.addEventListener("click", abrirModalNuevo);
        document.getElementById("btn_editar_personal")?.addEventListener("click", abrirModalEditar);
        document.getElementById("btn_eliminar_personal")?.addEventListener("click", confirmarEliminar);
        document.getElementById("btn_recargar_personal")?.addEventListener("click", listarPersonal);
        document.getElementById("btn_detalle_personal")?.addEventListener("click", verDetalle);

        document.getElementById("form_personal")?.addEventListener("submit", function (e) {
            e.preventDefault();
            guardarPersonal();
        });

        panelPersonal.querySelectorAll(".tb-btn").forEach(function (b) {
            b.addEventListener("click", function () {
                var acc = b.dataset.acc;
                if (acc === "nuevo") abrirModalNuevo();
                else if (acc === "editar") abrirModalEditar();
                else if (acc === "eliminar") confirmarEliminar();
                else if (acc === "recargar") listarPersonal();
                else if (acc === "imprimir" || acc === "consultar" || acc === "detalle") verDetalle();
                else if (acc === "excel") exportarExcel();
                else if (acc === "salir" && bienvenida) {
                    if (panelPersonal !== document) panelPersonal.hidden = true;
                    bienvenida.hidden = false;
                }
            });
        });

        window.addEventListener("modulo:abrir", function (e) {
            var mod = (e.detail || "").toLowerCase();
            if (mod === "personal") {
                listarPersonal();
            }
        });

        listarPersonal();
    })();
});