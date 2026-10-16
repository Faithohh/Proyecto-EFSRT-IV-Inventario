const Alert = {
    toast(mensaje, icono = 'success', tiempo = 3000) {
        return Swal.fire({
            toast: true,
            position: 'top-end',
            icon: icono,
            title: mensaje,
            showConfirmButton: false,
            timer: tiempo,
            timerProgressBar: true
        });
    },

    exito(titulo = '¡Conseguido!', mensaje = 'La operación se realizó con éxito.', callback = null) {
        return Swal.fire({
            icon: 'success',
            title: titulo,
            text: mensaje,
            confirmButtonText: 'Aceptar'
        }).then((result) => {
            if (result.isConfirmed && typeof callback === 'function') {
                callback();
            }
        });
    },

    advertencia(titulo = 'Atención', mensaje = 'Por favor complete todos los campos requeridos.') {
        return Swal.fire({
            icon: 'warning',
            title: titulo,
            text: mensaje,
            confirmButtonText: 'Entendido'
        });
    },

    error(titulo = 'Error', mensaje = 'Ocurrió un problema al procesar la solicitud.') {
        return Swal.fire({
            icon: 'error',
            title: titulo,
            text: mensaje,
            confirmButtonText: 'Cerrar'
        });
    },

    info(titulo = 'Información', mensaje = '') {
        return Swal.fire({
            icon: 'info',
            title: titulo,
            text: mensaje,
            confirmButtonText: 'Aceptar'
        });
    },

    confirmar(titulo = '¿Está seguro?', mensaje = 'No podrá revertir este cambio.', callbackAccion = null) {
        return Swal.fire({
            icon: 'question',
            title: titulo,
            text: mensaje,
            showCancelButton: true,
            confirmButtonText: 'Sí, continuar',
            cancelButtonText: 'Cancelar'
        }).then((result) => {
            if (result.isConfirmed && typeof callbackAccion === 'function') {
                callbackAccion();
            }
        });
    }
};