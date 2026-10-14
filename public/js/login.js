document.addEventListener('DOMContentLoaded', () => {
    // Selección de elementos del DOM
    const txtUsuario = document.getElementById('txt_usuario');
    const txtContrasena = document.getElementById('txt_contraseña');
    const cbxProgramaEstudio = document.getElementById('cbx_programaEstudio');
    const gbxProgramaEstudio = document.getElementById('gbx_programaEstudio');
    const btnIngresar = document.getElementById('btn_ingresar');
    const btnCancelar = document.getElementById('btn_cancelar');

    // Token CSRF obligatorio en Laravel para peticiones POST
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

    // Validación de campos obligatorios
    function validarDatosCompletos() {
        const usuario = txtUsuario.value.trim();
        const contrasena = txtContrasena.value.trim();

        if (usuario.length === 0) {
            alert("Datos Incompletos\nFalta ingresar usuario");
            txtUsuario.focus();
            return false;
        }
        if (contrasena.length === 0) {
            alert("Datos Incompletos\nFalta ingresar contraseña");
            txtContrasena.focus();
            return false;
        }
        return true;
    }

    // Validar usuario y cargar ComboBox / Select mediante AJAX
    async function validarUsuario() {
        try {
            const response = await fetch('/login/acceso', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrfToken
                },
                body: JSON.stringify({
                    usuario: txtUsuario.value,
                    contrasena: txtContrasena.value
                })
            });

            const data = await response.json();

            if (data.valid === "1") {
                // Limpiar selector previo
                cbxProgramaEstudio.innerHTML = '';

                // Llenar el desplegable con la lista de programas de estudio
                if (data.programas && data.programas.length > 0) {
                    data.programas.forEach(prog => {
                        const option = document.createElement('option');
                        option.value = prog.idProgramaEstudio;
                        option.textContent = prog.programaEstudio;
                        cbxProgramaEstudio.appendChild(option);
                    });

                    // Mostrar el contenedor del desplegable y habilitar botón
                    gbxProgramaEstudio.style.display = 'block';
                    btnIngresar.disabled = false;
                    cbxProgramaEstudio.focus();
                } else {
                    alert("No tiene acceso a programa(s) de estudio\nConsulte con el Administrador de Sistemas");
                }
                return true;
            } else {
                alert(data.valid || "Error de credenciales");
                txtUsuario.value = '';
                txtContrasena.value = '';
                txtUsuario.focus();
                return false;
            }
        } catch (error) {
            console.error('Error en la petición:', error);
            alert('Ocurrió un error al procesar la solicitud.');
            return false;
        }
    }

    // Iniciar sesión con el programa de estudio seleccionado
    async function iniciarSesion() {
        if (!validarDatosCompletos()) return;

        if (cbxProgramaEstudio.options.length > 0 && cbxProgramaEstudio.value) {
            try {
                const response = await fetch('/login/sesion', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': csrfToken
                    },
                    body: JSON.stringify({
                        idUsuario: txtUsuario.value,
                        idProgramaEstudio: cbxProgramaEstudio.value
                    })
                });

                const data = await response.json();

                if (data.success) {
                    // Redireccionar a la vista principal
                    window.location.href = data.redirectUrl || '/principal';
                } else {
                    alert(data.message || 'No se pudo iniciar sesión.');
                }
            } catch (error) {
                console.error('Error en la sesión:', error);
            }
        } else {
            alert("No tiene acceso a programa(s) de estudio\nConsulte con el Administrador de Sistemas");
        }
    }

    // Eventos de Botones
    btnIngresar.addEventListener('click', (e) => {
        e.preventDefault();
        iniciarSesion();
    });

    btnCancelar?.addEventListener('click', (e) => {
        e.preventDefault();
        window.location.href = '/';
    });

    // Manejo de eventos de teclado (Enter = KeyCode 13)
    txtUsuario.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            txtContrasena.focus();
        }
    });

    txtContrasena.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            if (validarDatosCompletos()) {
                validarUsuario();
            }
        }
    });

    cbxProgramaEstudio.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            btnIngresar.focus();
        }
    });

    // Resetear formulario al cambiar usuario o contraseña
    const resetearFormulario = () => {
        btnIngresar.disabled = true;
        gbxProgramaEstudio.style.display = 'none';
        cbxProgramaEstudio.innerHTML = '';
    };

    txtUsuario.addEventListener('input', () => {
        resetearFormulario();
        txtContrasena.value = '';
    });

    txtContrasena.addEventListener('input', resetearFormulario);

    cbxProgramaEstudio.addEventListener('change', () => {
        btnIngresar.disabled = false;
    });

    // Estilos de enfoque (Lógica equivalentes a BackColor = LightYellow)
    [txtUsuario, txtContrasena].forEach(input => {
        input.addEventListener('focus', () => input.style.backgroundColor = '#FFFFE0');
        input.addEventListener('blur', () => input.style.backgroundColor = '');
    });
});