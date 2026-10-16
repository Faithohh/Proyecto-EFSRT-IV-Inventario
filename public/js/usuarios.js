document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelUsu = document.getElementById("mpUsuarios");
        var bienvenida = document.getElementById("mpBienvenida");
        if (!panelUsu) return;

        var tblBody = document.querySelector("#tblUsuarios tbody");
        var txtBuscar = document.getElementById("txtBuscarUsuarios");
        var usuariosCache = [];
        var usuarioSeleccionado = null;

        var modalUsuario = new bootstrap.Modal(document.getElementById("modalUsuario"));

        function esc(v) {
            return String(v || "").replace(/[&<">]/g, function (c) {
                return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
            });
        }

        function pintarUsuarios(lista) {
            if (!lista.length) {
                tblBody.innerHTML = '<tr><td colspan="3" class="text-center">Sin usuarios registrados.</td></tr>';
                return;
            }
            tblBody.innerHTML = lista.map(function (u) {
                var nombrePersonal = u.personal || u.personalAsociado || u.nombrePersonal || "Sin asignar";
                return '<tr data-id="' + esc(u.idUsuario) + '">' +
                    '<td>' + esc(u.idUsuario) + '</td>' +
                    '<td>' + esc(nombrePersonal) + '</td>' +
                    '<td>' + esc(u.tipoUsuario) + '</td></tr>';
            }).join("");
        }

        async function cargarPersonal() {
            try {
                var r = await fetch("/usuarios/personal", { headers: { Accept: "application/json" } });
                var j = await r.json();
                var personal = j.ok ? j.data : [];
                var cbo = document.getElementById("cboPersonal");
                if (cbo) {
                    cbo.innerHTML = '<option value="">Seleccione...</option>';
                    personal.forEach(function (p) {
                        var option = document.createElement("option");
                        var id = p.idPersonal || p.idpersonal || p.id || p.ID;
                        var nombre = p.nombreCompleto || p.personal || ((p.apellidos || p.apellido || '') + ' ' + (p.nombres || p.nombre || '')).trim() || id;
                        
                        option.value = id;
                        option.textContent = nombre;
                        cbo.appendChild(option);
                    });
                }
            } catch (e) {
                console.error("Error cargando personal:", e);
            }
        }

        function setEstadoFormulario(deshabilitar) {
            var form = document.getElementById("formUsuario");
            if (!form) return;

            var elementos = form.querySelectorAll("input, select, textarea, button");
            elementos.forEach(function (el) {
                if (el.classList.contains("btn-close") || el.dataset.bsDismiss === "modal") {
                    return;
                }
                el.disabled = deshabilitar;
            });

            var btnGuardar = document.getElementById("btnGuardarUsuario");
            if (btnGuardar) {
                btnGuardar.style.display = deshabilitar ? "none" : "inline-block";
            }
        }

        async function mostrarUsuarios() {
            if (!panelUsu) return;
            tblBody.innerHTML = '<tr><td colspan="3" class="text-center">Cargando...</td></tr>';
            usuarioSeleccionado = null;

            try {
                var r = await fetch("/usuarios/listar", { headers: { Accept: "application/json" } });
                var j = await r.json();
                if (!j.ok) throw new Error(j.msg || "Sin datos");
                usuariosCache = j.data || [];
                pintarUsuarios(usuariosCache);
                if (txtBuscar) txtBuscar.value = "";
            } catch (e) {
                tblBody.innerHTML = '<tr><td colspan="3" class="text-center">' + esc(e.message) + '</td></tr>';
            }
        }

        tblBody.addEventListener("click", function (e) {
            var tr = e.target.closest("tr[data-id]");
            if (!tr) return;
            tblBody.querySelectorAll("tr").forEach(function (x) { x.classList.remove("table-active", "selected", "sel"); });
            tr.classList.add("table-active", "selected", "sel");

            var id = tr.getAttribute("data-id");
            usuarioSeleccionado = usuariosCache.find(function (u) { return String(u.idUsuario) === String(id); });
        });

        if (txtBuscar) {
            txtBuscar.addEventListener("input", function () {
                var q = txtBuscar.value.trim().toLowerCase();
                if (!q) return pintarUsuarios(usuariosCache);
                pintarUsuarios(usuariosCache.filter(function (u) {
                    var personalText = u.personal || u.personalAsociado || u.nombrePersonal || "";
                    return (u.idUsuario || "").toLowerCase().includes(q) ||
                        (u.tipoUsuario || "").toLowerCase().includes(q) ||
                        personalText.toLowerCase().includes(q);
                }));
            });
        }

        async function nuevoUsuario() {
            setEstadoFormulario(false);
            var modalTitle = document.getElementById("modalUsuarioTitle");
            if (modalTitle) modalTitle.textContent = "Nuevo Usuario";
            
            var form = document.getElementById("formUsuario");
            if (form) form.reset();
            
            var txtOrig = document.getElementById("txtIdUsuarioOriginal");
            if (txtOrig) txtOrig.value = "";
            
            var txtId = document.getElementById("txtIdUsuario");
            if (txtId) txtId.readOnly = false;
            
            await cargarPersonal();
            modalUsuario.show();
        }

        async function editarUsuario() {
            if (!usuarioSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    usuarioSeleccionado = usuariosCache.find(function (u) { return String(u.idUsuario) === String(id); });
                }
            }

            if (!usuarioSeleccionado) { 
                Alert.advertencia("Selección requerida", "Seleccione un usuario de la lista para editar."); 
                return; 
            }
            
            setEstadoFormulario(false);
            var modalTitle = document.getElementById("modalUsuarioTitle");
            if (modalTitle) modalTitle.textContent = "Editar Usuario";
            
            var form = document.getElementById("formUsuario");
            if (form) form.reset();
            
            await cargarPersonal();

            var u = usuarioSeleccionado;

            try {
                var r = await fetch("/usuarios/buscar/" + encodeURIComponent(usuarioSeleccionado.idUsuario), { 
                    headers: { Accept: "application/json" } 
                });
                var j = await r.json();
                if (j.ok && j.data) {
                    u = j.data;
                }
            } catch (e) {
                console.warn("No se pudo obtener el detalle extenso, usando datos en caché.", e);
            }
            
            var txtOrig = document.getElementById("txtIdUsuarioOriginal");
            var txtId = document.getElementById("txtIdUsuario");
            var txtPass = document.getElementById("txtContrasena");
            var cboTipo = document.getElementById("cboTipoUsuario");
            var cboPers = document.getElementById("cboPersonal");

            if (txtOrig) txtOrig.value = u.idUsuario || "";
            if (txtId) {
                txtId.value = u.idUsuario || "";
                txtId.readOnly = true;
            }
            
            if (txtPass) {
                txtPass.value = u.contrasena || u.contraseña || u.clave || u.password || "";
            }

            if (cboTipo) cboTipo.value = u.tipoUsuario || "";
            if (cboPers) cboPers.value = u.idPersonal || u.idpersonal || "";

            modalUsuario.show();
        }

        function confirmarEliminar() {
            if (!usuarioSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    usuarioSeleccionado = usuariosCache.find(function (u) { return String(u.idUsuario) === String(id); });
                }
            }

            if (!usuarioSeleccionado) {
                Alert.advertencia("Selección requerida", "Por favor, seleccione un usuario de la tabla para eliminar.");
                return;
            }

            var nombre = usuarioSeleccionado.idUsuario || "este usuario";

            Alert.confirmar("¿Eliminar usuario?", "¿Está seguro de eliminar al usuario " + nombre + "?", async function () {
                var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || document.querySelector('input[name="_token"]')?.value;

                try {
                    var response = await fetch("/usuarios/eliminar", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token
                        },
                        body: JSON.stringify({ idUsuario: usuarioSeleccionado.idUsuario })
                    });
                    
                    var data = await response.json();

                    if (data.ok || data.success) {
                        Alert.exito("Eliminado", data.msg || "Usuario eliminado correctamente.", async function () {
                            await mostrarUsuarios();
                        });
                    } else {
                        Alert.error("Error al eliminar", data.msg || data.message || "Error al eliminar el usuario.");
                    }
                } catch (e) {
                    console.error("Error al eliminar:", e);
                    Alert.error("Error de conexión", "Error de conexión con el servidor.");
                }
            });
        }

        async function verDetalle() {
            if (!usuarioSeleccionado) {
                var s = tblBody.querySelector("tr.sel, tr.selected, tr.table-active");
                if (s) {
                    var id = s.getAttribute("data-id");
                    usuarioSeleccionado = usuariosCache.find(function (u) { return String(u.idUsuario) === String(id); });
                }
            }

            if (!usuarioSeleccionado) { 
                Alert.advertencia("Selección requerida", "Seleccione un usuario de la lista para consultar su información."); 
                return; 
            }
            
            try {
                var r = await fetch("/usuarios/buscar/" + encodeURIComponent(usuarioSeleccionado.idUsuario), { 
                    headers: { Accept: "application/json" } 
                });
                var j = await r.json();
                
                if (!j.ok) throw new Error(j.msg || "Error al consultar usuario");
                
                var u = j.data;
                await cargarPersonal();

                var elId = document.getElementById("txtIdUsuario");
                var elPass = document.getElementById("txtContrasena");
                var elPersonal = document.getElementById("cboPersonal");
                var elTipo = document.getElementById("cboTipoUsuario");

                if (elId) elId.value = u.idUsuario || "";
                if (elPass) elPass.value = u.contrasena || u.contraseña || u.clave || u.password || "";
                if (elPersonal) elPersonal.value = u.idPersonal || u.idpersonal || "";
                if (elTipo) elTipo.value = u.tipoUsuario || "";

                var modalTitle = document.getElementById("modalUsuarioTitle");
                if (modalTitle) modalTitle.textContent = "Consulta de Usuario";

                setEstadoFormulario(true); 
                modalUsuario.show();

            } catch (e) {
                console.error("Error al obtener información:", e);
                Alert.error("Error de consulta", "Ocurrió un error al cargar los datos: " + e.message);
            }
        }

        var btnGuardar = document.getElementById("btnGuardarUsuario");
        if (btnGuardar) {
            btnGuardar.addEventListener("click", async function () {
                var idUsuario = document.getElementById("txtIdUsuario").value.trim().toUpperCase();
                var contrasena = document.getElementById("txtContrasena").value.trim();
                var tipoUsuario = document.getElementById("cboTipoUsuario").value;
                var idPersonal = document.getElementById("cboPersonal").value;
                var idOriginal = document.getElementById("txtIdUsuarioOriginal").value;
                
                if (!idUsuario || (!idOriginal && !contrasena) || !tipoUsuario || !idPersonal) {
                    Alert.advertencia("Campos incompletos", "Complete todos los campos requeridos.");
                    return;
                }
                
                try {
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || document.querySelector('input[name="_token"]')?.value;
                    var response = await fetch("/usuarios/guardar", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token
                        },
                        body: JSON.stringify({
                            idUsuario: idUsuario,
                            contrasena: contrasena,
                            tipoUsuario: tipoUsuario,
                            idPersonal: idPersonal,
                            idOriginal: idOriginal
                        })
                    });
                    
                    var data = await response.json();
                    if (data.ok || data.success) {
                        modalUsuario.hide();
                        Alert.exito("¡Guardado!", data.msg || "Usuario guardado correctamente.", async function () {
                            await mostrarUsuarios();
                        });
                    } else {
                        Alert.error("Error al guardar", data.msg || data.message || "Error al guardar");
                    }
                } catch (e) {
                    modalUsuario.hide();
                    Alert.error("Error de conexión", "Ocurrió un problema: " + e.message);
                }
            });
        }

        function exportarExcel() {
            if (!usuariosCache.length) { 
                Alert.advertencia("Sin datos", "No hay datos para exportar."); 
                return; 
            }
            var csv = "ID Usuario,Personal Asociado,Tipo de Usuario\n";
            usuariosCache.forEach(function (u) {
                var personalText = u.personal || u.personalAsociado || u.nombrePersonal || "Sin asignar";
                csv += '"' + (u.idUsuario || "") + '","' + personalText + '","' + (u.tipoUsuario || "") + '"\n';
            });
            var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            var url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "usuarios_" + new Date().toISOString().slice(0, 10) + ".csv");
            link.style.visibility = "hidden";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        panelUsu.querySelectorAll(".tb-btn").forEach(function (b) {
            b.addEventListener("click", function () {
                var acc = b.dataset.acc;
                if (acc === "nuevo") nuevoUsuario();
                else if (acc === "editar") editarUsuario();
                else if (acc === "eliminar") confirmarEliminar();
                else if (acc === "recargar") mostrarUsuarios();
                else if (acc === "imprimir" || acc === "consultar" || acc === "detalle") verDetalle();
                else if (acc === "excel") exportarExcel();
                else if (acc === "salir") {
                    panelUsu.hidden = true;
                    if (bienvenida) bienvenida.hidden = false;
                }
            });
        });

        window.addEventListener("modulo:abrir", function (e) {
            if (e.detail === "usuarios") mostrarUsuarios();
        });

        mostrarUsuarios();
    })();
});