document.addEventListener("DOMContentLoaded", function () {
    (function () {
        var panelUsu = document.getElementById("mpUsuarios");
        var bienvenida = document.getElementById("mpBienvenida");
        if (!panelUsu) return;

        var tblBody = document.querySelector("#tblUsuarios tbody");
        var txtBuscar = document.getElementById("txtBuscarUsuarios");
        var usuariosCache = [];

        var modalUsuario = new bootstrap.Modal(document.getElementById("modalUsuario"));
        var modalEliminar = new bootstrap.Modal(document.getElementById("modalEliminar"));

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
            tblBody.querySelectorAll("tr.sel").forEach(function (x) { x.classList.remove("sel"); });
            tr.classList.add("sel");
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
            var s = tblBody.querySelector("tr.sel");
            if (!s) { alert("Seleccione un usuario de la lista para editar."); return; }
            
            setEstadoFormulario(false);
            var idUsuario = s.getAttribute("data-id");
            var modalTitle = document.getElementById("modalUsuarioTitle");
            if (modalTitle) modalTitle.textContent = "Editar Usuario";
            
            var form = document.getElementById("formUsuario");
            if (form) form.reset();
            
            await cargarPersonal();
            var usuario = usuariosCache.find(function (u) { return String(u.idUsuario) === String(idUsuario); });
            if (usuario) {
                var txtOrig = document.getElementById("txtIdUsuarioOriginal");
                var txtId = document.getElementById("txtIdUsuario");
                var cboTipo = document.getElementById("cboTipoUsuario");
                var cboPers = document.getElementById("cboPersonal");

                if (txtOrig) txtOrig.value = usuario.idUsuario;
                if (txtId) {
                    txtId.value = usuario.idUsuario;
                    txtId.readOnly = true;
                }
                if (cboTipo) cboTipo.value = usuario.tipoUsuario || "";
                if (cboPers) cboPers.value = usuario.idPersonal || usuario.idpersonal || "";
            }
            modalUsuario.show();
        }

        function eliminarUsuario() {
            var s = tblBody.querySelector("tr.sel");
            if (!s) { alert("Seleccione un usuario de la lista para eliminar."); return; }
            
            var idUsuario = s.getAttribute("data-id");
            var elDel = document.getElementById("txtUsuarioEliminar");
            if (elDel) elDel.textContent = idUsuario;
            
            modalEliminar.show();
        }

        async function verDetalle() {
            var s = tblBody.querySelector("tr.sel");
            if (!s) { 
                alert("Seleccione un usuario de la lista para consultar su información."); 
                return; 
            }
            
            try {
                var idUsuario = s.getAttribute("data-id");
                var r = await fetch("/usuarios/buscar/" + encodeURIComponent(idUsuario), { 
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
                if (elPass) elPass.value = u.contrasena || u.clave || u.password || "";
                if (elPersonal) elPersonal.value = u.idPersonal || u.idpersonal || "";
                if (elTipo) elTipo.value = u.tipoUsuario || "";

                var modalTitle = document.getElementById("modalUsuarioTitle");
                if (modalTitle) modalTitle.textContent = "Consulta de Usuario";

                setEstadoFormulario(true); 
                modalUsuario.show();

            } catch (e) {
                console.error("Error al obtener información:", e);
                alert("Ocurrió un error al cargar los datos: " + e.message);
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
                    alert("Complete todos los campos requeridos.");
                    return;
                }
                
                try {
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");
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
                    if (data.ok) {
                        modalUsuario.hide();
                        alert(data.msg);
                        await mostrarUsuarios();
                    } else {
                        alert(data.msg || "Error al guardar");
                    }
                } catch (e) {
                    modalUsuario.hide();
                    alert("Error de conexión: " + e.message);
                }
            });
        }

        var btnEliminar = document.getElementById("btnConfirmarEliminar");
        if (btnEliminar) {
            btnEliminar.addEventListener("click", async function () {
                var idUsuario = document.getElementById("txtUsuarioEliminar").textContent.trim();
                
                if (!idUsuario) {
                    alert("No se seleccionó ningún usuario para eliminar.");
                    return;
                }

                try {
                    var token = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");
                    var response = await fetch("/usuarios/eliminar", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Accept: "application/json",
                            "X-CSRF-TOKEN": token
                        },
                        body: JSON.stringify({ idUsuario: idUsuario })
                    });
                    
                    var data = await response.json();
                    modalEliminar.hide();

                    if (data.ok) {
                        alert(data.msg || "Usuario eliminado correctamente");
                        await mostrarUsuarios();
                    } else {
                        alert(data.msg || "Error al eliminar el usuario");
                    }
                } catch (e) {
                    modalEliminar.hide();
                    alert("Error de conexión con el servidor.");
                }
            });
        }

        function exportarExcel() {
            if (!usuariosCache.length) { alert("No hay datos para exportar."); return; }
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
                else if (acc === "eliminar") eliminarUsuario();
                else if (acc === "recargar") mostrarUsuarios();
                else if (acc === "imprimir" || acc === "consultar") verDetalle();
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
    })();
});