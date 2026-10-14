let personalSeleccionado = null;

document.addEventListener('DOMContentLoaded', function () {
    listarPersonal();

    document.getElementById('btn_nuevo_personal')?.addEventListener('click', abrirModalNuevo);
    document.getElementById('btn_editar_personal')?.addEventListener('click', abrirModalEditar);
    document.getElementById('btn_eliminar_personal')?.addEventListener('click', confirmarEliminar);
    document.getElementById('btn_recargar_personal')?.addEventListener('click', listarPersonal);
    document.getElementById('btn_detalle_personal')?.addEventListener('click', verDetalle);

    document.getElementById('form_personal')?.addEventListener('submit', function (e) {
        e.preventDefault();
        guardarPersonal();
    });

    document.getElementById('txtBuscarPersonal')?.addEventListener('keyup', function () {
        let filtro = this.value.toLowerCase();
        let filas = document.querySelectorAll('#tbody_personal tr');
        filas.forEach(fila => {
            let texto = fila.innerText.toLowerCase();
            fila.style.display = texto.includes(filtro) ? '' : 'none';
        });
    });
});

function listarPersonal() {
    let tbody = document.getElementById('tbody_personal');
    if (!tbody) return;

    fetch('/personal/listar')
        .then(response => response.json())
        .then(res => {
            tbody.innerHTML = '';
            personalSeleccionado = null;

            let lista = res.data || (Array.isArray(res) ? res : []);

            if (!Array.isArray(lista) || lista.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5" class="text-center">No hay registros disponibles</td></tr>';
                return;
            }

            lista.forEach(item => {
                let isChecked = (item.st_registro == 1 || item.st_registro == true) ? 'checked' : '';
                let tr = document.createElement('tr');
                tr.dataset.id = item.idPersonal;
                tr.dataset.json = JSON.stringify(item);

                tr.innerHTML = `
                    <td>${item.nombreCompleto || '-'}</td>
                    <td>${item.dni || '-'}</td>
                    <td>${item.celular || '-'}</td>
                    <td>${item.email || '-'}</td>
                    <td class="text-center">
                        <input type="checkbox" disabled ${isChecked}>
                    </td>
                `;

                tr.addEventListener('click', function () {
                    document.querySelectorAll('#tbody_personal tr').forEach(r => r.classList.remove('table-active', 'selected'));
                    this.classList.add('table-active', 'selected');
                    personalSeleccionado = item;
                });

                tbody.appendChild(tr);
            });
        })
        .catch(error => {
            console.error('Error al listar personal:', error);
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">Error al cargar datos</td></tr>';
        });
}

function abrirModalNuevo() {
    document.getElementById('form_personal').reset();
    document.getElementById('personal_id').value = '';
    document.getElementById('modal_personal_title').textContent = 'Registrar Personal';
    
    let modalEl = document.getElementById('personal_modal');
    let modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
    modal.show();
}

function abrirModalEditar() {
    if (!personalSeleccionado) {
        alert('Por favor, seleccione un registro de la tabla.');
        return;
    }

    document.getElementById('personal_id').value = personalSeleccionado.idPersonal || '';
    document.getElementById('personal_dni').value = personalSeleccionado.dni || '';
    document.getElementById('personal_nombreCompleto').value = personalSeleccionado.nombreCompleto || '';
    document.getElementById('personal_celular').value = personalSeleccionado.celular || '';
    document.getElementById('personal_email').value = personalSeleccionado.email || '';
    document.getElementById('personal_st_registro').value = personalSeleccionado.st_registro ?? 1;

    document.getElementById('modal_personal_title').textContent = 'Editar Personal';
    
    let modalEl = document.getElementById('personal_modal');
    let modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
    modal.show();
}

function guardarPersonal() {
    let formData = new FormData(document.getElementById('form_personal'));
    let token = document.querySelector('meta[name="csrf-token"]')?.content || document.querySelector('input[name="_token"]')?.value;

    fetch('/personal/guardar', {
        method: 'POST',
        body: formData,
        headers: {
            'X-CSRF-TOKEN': token
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.ok || data.success) {
            let modalEl = document.getElementById('personal_modal');
            let modal = bootstrap.Modal.getInstance(modalEl);
            if (modal) modal.hide();
            listarPersonal();
        } else {
            alert(data.msg || data.message || 'Error al guardar el registro.');
        }
    })
    .catch(error => console.error('Error al guardar:', error));
}

function verDetalle() {
    if (!personalSeleccionado) {
        alert('Por favor, seleccione un registro para ver el detalle.');
        return;
    }

    let detDni = document.querySelector('#modalDetallePersonal .det-dni');
    let detNom = document.querySelector('#modalDetallePersonal .det-nombres');
    let detCel = document.querySelector('#modalDetallePersonal .det-cargo');
    let detEmail = document.querySelector('#modalDetallePersonal .det-programa');
    let detEst = document.querySelector('#modalDetallePersonal .det-estado');

    if (detDni) detDni.textContent = personalSeleccionado.dni || '-';
    if (detNom) detNom.textContent = personalSeleccionado.nombreCompleto || '-';
    if (detCel) detCel.textContent = personalSeleccionado.celular || '-';
    if (detEmail) detEmail.textContent = personalSeleccionado.email || '-';
    if (detEst) detEst.textContent = (personalSeleccionado.st_registro == 1) ? 'Activo' : 'Inactivo';

    let modalEl = document.getElementById('modalDetallePersonal');
    let modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
    modal.show();
}

function confirmarEliminar() {
    if (!personalSeleccionado) {
        alert('Por favor, seleccione un registro para eliminar.');
        return;
    }

    if (confirm(`¿Está seguro de eliminar a ${personalSeleccionado.nombreCompleto}?`)) {
        let token = document.querySelector('meta[name="csrf-token"]')?.content || document.querySelector('input[name="_token"]')?.value;

        fetch(`/personal/eliminar/${personalSeleccionado.idPersonal}`, {
            method: 'DELETE',
            headers: {
                'X-CSRF-TOKEN': token,
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
        })
        .then(res => res.json())
        .then(data => {
            if (data.ok) {
                alert(data.msg);
                listarPersonal();
            } else {
                alert(data.msg || 'No se pudo eliminar el registro.');
            }
        })
        .catch(err => {
            console.error('Error al eliminar:', err);
            alert('Ocurrió un error al procesar la solicitud.');
        });
    }
}