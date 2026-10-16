document.addEventListener("DOMContentLoaded", () => {
    const txtUsuario = document.getElementById("txt_usuario");
    const txtContrasena = document.getElementById("txt_contraseña");
    const cbxProgramaEstudio = document.getElementById("cbx_programaEstudio");
    const gbxProgramaEstudio = document.getElementById("gbx_programaEstudio");
    const btnIngresar = document.getElementById("btn_ingresar");
    const btnCancelar = document.getElementById("btn_cancelar");

    const csrfToken = document
        .querySelector('meta[name="csrf-token"]')
        ?.getAttribute("content");

    function validarDatosCompletos() {
        const usuario = txtUsuario.value.trim();
        const contrasena = txtContrasena.value.trim();

        if (usuario.length === 0) {
            Alert.advertencia("Datos Incompletos", "Falta ingresar usuario");
            txtUsuario.focus();
            return false;
        }
        if (contrasena.length === 0) {
            Alert.advertencia("Datos Incompletos", "Falta ingresar contraseña");
            txtContrasena.focus();
            return false;
        }
        return true;
    }

    async function validarUsuario() {
        try {
            const response = await fetch("/login/acceso", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    Accept: "application/json",
                    "X-CSRF-TOKEN": csrfToken,
                },
                body: JSON.stringify({
                    usuario: txtUsuario.value.trim(),
                    contrasena: txtContrasena.value.trim(),
                }),
            });

            const data = await response.json();

            if (data.valid === "1") {
                cbxProgramaEstudio.innerHTML = "";

                if (data.programas && data.programas.length > 0) {
                    data.programas.forEach((prog) => {
                        const option = document.createElement("option");
                        option.value = prog.idProgramaEstudio;
                        option.textContent = prog.programaEstudio;
                        cbxProgramaEstudio.appendChild(option);
                    });

                    if (gbxProgramaEstudio)
                        gbxProgramaEstudio.style.display = "block";
                    btnIngresar.disabled = false;
                    cbxProgramaEstudio.focus();
                } else {
                    Alert.advertencia(
                        "Acceso Denegado",
                        "No tiene acceso a programa(s) de estudio\nConsulte con el Administrador de Sistemas"
                    );
                }
                return true;
            } else {
                Alert.error(
                    "Datos Inválidos",
                    data.valid || "Error de credenciales"
                );
                txtUsuario.value = "";
                txtContrasena.value = "";
                resetearFormulario();
                txtUsuario.focus();
                return false;
            }
        } catch (error) {
            console.error("Error en la petición:", error);
            Alert.error("Error de conexión", "Ocurrió un error al procesar la solicitud con el servidor.");
            return false;
        }
    }

    async function iniciarSesion() {
        if (!validarDatosCompletos()) return;

        if (cbxProgramaEstudio.options.length > 0 && cbxProgramaEstudio.value) {
            try {
                const response = await fetch("/login/sesion", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        Accept: "application/json",
                        "X-CSRF-TOKEN": csrfToken,
                    },
                    body: JSON.stringify({
                        idUsuario: txtUsuario.value.trim(),
                        idProgramaEstudio: cbxProgramaEstudio.value,
                    }),
                });

                const data = await response.json();

                if (data.success) {
                    window.location.href = data.redirectUrl || "/principal";
                } else {
                    Alert.error("Error de Sesión", data.message || "No se pudo iniciar sesión.");
                }
            } catch (error) {
                console.error("Error en la sesión:", error);
                Alert.error("Error de conexión", "Error al conectar para iniciar sesión.");
            }
        } else {
            Alert.advertencia(
                "Acceso Denegado",
                "No tiene acceso a programa(s) de estudio\nConsulte con el Administrador de Sistemas"
            );
        }
    }

    btnIngresar.addEventListener("click", (e) => {
        e.preventDefault();
        iniciarSesion();
    });

    btnCancelar?.addEventListener("click", (e) => {
        e.preventDefault();
        window.location.href = "/login";
    });

    txtUsuario.addEventListener("keypress", (e) => {
        if (e.key === "Enter") {
            e.preventDefault();
            txtContrasena.focus();
        }
    });

    txtContrasena.addEventListener("keypress", (e) => {
        if (e.key === "Enter") {
            e.preventDefault();
            if (validarDatosCompletos()) {
                validarUsuario();
            }
        }
    });

    cbxProgramaEstudio.addEventListener("keypress", (e) => {
        if (e.key === "Enter") {
            e.preventDefault();
            btnIngresar.focus();
        }
    });

    const resetearFormulario = () => {
        btnIngresar.disabled = true;
        if (gbxProgramaEstudio) gbxProgramaEstudio.style.display = "none";
        cbxProgramaEstudio.innerHTML = "";
    };

    txtUsuario.addEventListener("input", () => {
        resetearFormulario();
        txtContrasena.value = "";
    });

    txtContrasena.addEventListener("input", resetearFormulario);

    cbxProgramaEstudio.addEventListener("change", () => {
        btnIngresar.disabled = false;
    });

    [txtUsuario, txtContrasena].forEach((input) => {
        if (input) {
            input.addEventListener("focus", () => input.classList.add("lit"));
            input.addEventListener("blur", () => input.classList.remove("lit"));
        }
    });
});