let idInventarioEditando = null;

document.addEventListener('DOMContentLoaded', () => {
    cargarInventarios();

    window.addEventListener("modulo:abrir", function (e) {
        var mod = (e.detail || "").toLowerCase();
        if (mod.includes("inventario") || mod.includes("toma")) {
            const panel = document.getElementById("mpTomaInventario");
            if (panel) panel.hidden = false;
            cargarInventarios();
        }
    });

    const txtBuscar = document.getElementById('txtBuscarInventario');
    if (txtBuscar) {
        txtBuscar.addEventListener('input', function () {
            const criterio = this.value.toLowerCase().trim();
            const filas = document.querySelectorAll('#tblInventarios tbody tr');

            filas.forEach(fila => {
                if (fila.cells.length === 1) return;
                const textoFila = fila.textContent.toLowerCase();
                fila.style.display = textoFila.includes(criterio) ? '' : 'none';
            });
        });
    }

    const tabla = document.getElementById('tblInventarios');
    if (tabla) {
        const tbody = tabla.querySelector('tbody');
        if (tbody) {
            tbody.addEventListener('click', (e) => {
                const fila = e.target.closest('tr');
                if (!fila || fila.cells.length === 1) return;

                tbody.querySelectorAll('tr').forEach(r => r.classList.remove('sel', 'selected', 'table-active'));
                fila.classList.add('sel', 'selected', 'table-active');
            });
        }
    }

    const modalInventario = document.getElementById('modalInventario');
    if (modalInventario) {
        modalInventario.addEventListener('hidden.bs.modal', () => {
            limpiarBackdrops();
            idInventarioEditando = null;

            modalInventario.querySelectorAll('input, select, textarea').forEach(el => el.disabled = false);
            const btnGuardar = document.getElementById('btnGuardarInventario');
            if (btnGuardar) btnGuardar.style.display = 'inline-block';

            const form = document.getElementById('formInventario') || modalInventario.querySelector('form');
            if (form) form.reset();
        });
    }

    const panelInventario = document.getElementById('mpTomaInventario');
    if (panelInventario) {
        panelInventario.querySelectorAll('.tb-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const acc = btn.dataset.acc;

                if (acc === 'nuevo') {
                    idInventarioEditando = null;
                    const form = document.getElementById('formInventario') || modalInventario?.querySelector('form');
                    if (form) form.reset();

                    if (modalInventario) {
                        modalInventario.querySelectorAll('input, select, textarea').forEach(el => el.disabled = false);
                        const btnGuardar = document.getElementById('btnGuardarInventario');
                        if (btnGuardar) btnGuardar.style.display = 'inline-block';
                    }
                    
                    cargarComboboxesInventario().then(() => {
                        abrirModal();
                    });

                } else if (acc === 'editar') {
                    const filaSel = document.querySelector('#tblInventarios tbody tr.sel');
                    if (!filaSel) {
                        alert('Por favor, seleccione un registro de la tabla para editar.');
                        return;
                    }
                    prepararEdicion(filaSel.dataset.id);

                } else if (acc === 'detalle' || acc === 'ver' || acc === 'imprimir') {
                    const filaSel = document.querySelector('#tblInventarios tbody tr.sel');
                    if (!filaSel) {
                        alert('Por favor, seleccione un registro de la tabla para visualizar.');
                        return;
                    }
                    verDetalleInventario(filaSel.dataset.id);

                } else if (acc === 'recargar') {
                    cargarInventarios();

                } else if (acc === 'salir') {
                    panelInventario.hidden = true;
                    const bienvenida = document.getElementById("mpBienvenida");
                    if (bienvenida) bienvenida.hidden = false;
                }
            });
        });
    }

    const btnGuardar = document.getElementById('btnGuardarInventario');
    if (btnGuardar) {
        btnGuardar.addEventListener('click', function (e) {
            e.preventDefault();

            const tokenMeta = document.querySelector('meta[name="csrf-token"]');
            const token = tokenMeta ? tokenMeta.getAttribute('content') : '';

            const data = {
                anio: document.getElementById('txtSerie')?.value || new Date().getFullYear(),
                numero: document.getElementById('txtNumero')?.value || 1,
                estado: document.getElementById('cboEstadoInventario')?.value || 'ABIERTO',
                sala_id: document.getElementById('cboSalaInventario')?.value,
                coordinador_id: document.getElementById('cboCoordinador')?.value,
                asistente1_id: document.getElementById('cboAsistente1')?.value,
                asistente2_id: document.getElementById('cboAsistente2')?.value || null,
                fecha_entrega: document.getElementById('txtFechaEntrega')?.value || null,
                observacion: document.getElementById('txtObservacionInventario')?.value || ''
            };

            if (!data.sala_id || !data.coordinador_id || !data.asistente1_id) {
                alert('Por favor complete todos los campos obligatorios (Sala, Coordinador y Asistente T1).');
                return;
            }

            const url = idInventarioEditando ? `/inventario/actualizar/${idInventarioEditando}` : '/inventario/guardar';
            const method = idInventarioEditando ? 'PUT' : 'POST';

            fetch(url, {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-CSRF-TOKEN': token
                },
                body: JSON.stringify(data)
            })
            .then(async response => {
                const resData = await response.json();
                if (!response.ok) {
                    throw new Error(resData.error || resData.message || 'Error al procesar en el servidor');
                }
                return resData;
            })
            .then(resData => {
                if (resData.success || resData.status) {
                    alert(idInventarioEditando ? '¡Inventario actualizado con éxito!' : '¡Inventario registrado con éxito!');

                    if (modalInventario && typeof bootstrap !== 'undefined') {
                        const modalInstance = bootstrap.Modal.getInstance(modalInventario) || new bootstrap.Modal(modalInventario);
                        modalInstance.hide();
                    }

                    limpiarBackdrops();
                    cargarInventarios();
                } else {
                    alert('Error: ' + (resData.error || resData.message || 'Operación fallida'));
                }
            })
            .catch(err => {
                console.error('Error en el guardado/actualización:', err);
                alert('Error: ' + err.message);
            });
        });
    }
});

function abrirModal() {
    const elModal = document.getElementById('modalInventario');
    if (elModal && typeof bootstrap !== 'undefined') {
        const modalInstance = bootstrap.Modal.getOrCreateInstance(elModal);
        modalInstance.show();
    }
}

function rellenarFormulario(d) {
    if (document.getElementById('txtSerie')) document.getElementById('txtSerie').value = d.anio || '';
    if (document.getElementById('txtNumero')) document.getElementById('txtNumero').value = d.numero || '';
    if (document.getElementById('cboEstadoInventario')) document.getElementById('cboEstadoInventario').value = d.estado || 'ABIERTO';
    if (document.getElementById('cboSalaInventario')) document.getElementById('cboSalaInventario').value = d.sala_id || '';
    if (document.getElementById('cboCoordinador')) document.getElementById('cboCoordinador').value = d.coordinador_id || '';
    if (document.getElementById('cboAsistente1')) document.getElementById('cboAsistente1').value = d.asistente1_id || '';
    if (document.getElementById('cboAsistente2')) document.getElementById('cboAsistente2').value = d.asistente2_id || '';
    if (document.getElementById('txtFechaEntrega')) document.getElementById('txtFechaEntrega').value = d.fecha_entrega || '';
    if (document.getElementById('txtObservacionInventario')) document.getElementById('txtObservacionInventario').value = d.observacion || '';
}

function cargarDatosYMostrar(id, esSoloLectura) {
    cargarComboboxesInventario().then(() => {
        fetch(`/inventario/mostrar/${id}`)
            .then(res => res.json())
            .then(resData => {
                if (resData.status && resData.data) {
                    const d = resData.data;
                    idInventarioEditando = esSoloLectura ? null : d.id;

                    const modalEl = document.getElementById('modalInventario');
                    if (modalEl) {
                        modalEl.querySelectorAll('input, select, textarea').forEach(el => el.disabled = esSoloLectura);
                        const btnGuardar = document.getElementById('btnGuardarInventario');
                        if (btnGuardar) btnGuardar.style.display = esSoloLectura ? 'none' : 'inline-block';
                    }

                    rellenarFormulario(d);
                    abrirModal();
                } else {
                    alert('No se pudieron obtener los datos del registro.');
                }
            })
            .catch(err => {
                console.error('Error al obtener datos del inventario:', err);
                alert('Error al conectar con el servidor.');
            });
    });
}

function prepararEdicion(id) {
    cargarDatosYMostrar(id, false);
}

function verDetalleInventario(id) {
    cargarDatosYMostrar(id, true);
}

function limpiarBackdrops() {
    document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
    document.body.classList.remove('modal-open');
    document.body.style.removeProperty('padding-right');
    document.body.style.removeProperty('overflow');
}

function cargarInventarios() {
    const tbody = document.querySelector('#tblInventarios tbody');
    if (!tbody) return;

    tbody.innerHTML = '<tr><td colspan="9" class="text-center">Cargando...</td></tr>';

    fetch('/inventario/listar')
        .then(res => res.json())
        .then(resData => {
            const items = resData.data || [];

            if (items.length === 0) {
                tbody.innerHTML = '<tr><td colspan="9" class="text-center text-muted">No hay registros de inventario.</td></tr>';
                return;
            }

            const fragment = document.createDocumentFragment();

            items.forEach(item => {
                const tr = document.createElement('tr');
                tr.dataset.id = item.idInventario;
                tr.innerHTML = `
                    <td>${item.INVENTARIO || ''}</td>
                    <td>${item.SALA || ''}</td>
                    <td>${item.COORDINADOR || ''}</td>
                    <td>${item.ASISTENTE_T1 || ''}</td>
                    <td>${item.ASISTENTE_T2 || ''}</td>
                    <td>${item.FECHA_ENTREGA || ''}</td>
                    <td>${item.OBSERVACION || ''}</td>
                    <td>${item.CANTIDAD_DE_BIENES ?? 0}</td>
                    <td>${item.ESTADO || ''}</td>
                `;
                fragment.appendChild(tr);
            });

            tbody.innerHTML = '';
            tbody.appendChild(fragment);
        })
        .catch(err => {
            console.error('Error al listar inventarios:', err);
            tbody.innerHTML = '<tr><td colspan="9" class="text-center text-danger">Error al cargar datos.</td></tr>';
        });
}

function cargarComboboxesInventario() {
    const catalogos = [
        { url: '/sala/listar', elementId: 'cboSalaInventario' },
        { url: '/personal/listar', elementId: 'cboCoordinador' },
        { url: '/personal/listar', elementId: 'cboAsistente1' },
        { url: '/personal/listar', elementId: 'cboAsistente2' }
    ];

    const peticiones = new Map();

    return Promise.all(catalogos.map(cat => {
        if (!peticiones.has(cat.url)) {
            peticiones.set(cat.url, fetch(cat.url).then(res => res.json()));
        }

        return peticiones.get(cat.url)
            .then(resData => {
                const items = resData.data || (Array.isArray(resData) ? resData : []);
                const select = document.getElementById(cat.elementId);
                if (!select) return;

                let options = '<option value="">Seleccione...</option>';
                items.forEach(i => {
                    const val = i.idSala || i.idPersonal || i.id || Object.values(i)[0];
                    let txt = i.nombre || i.NOMBRE || i.descripcion;
                    
                    if (!txt && i.nombres) {
                        txt = `${i.nombres} ${i.apellidos || ''}`.trim();
                    } else if (!txt) {
                        txt = Object.values(i)[1] || '';
                    }

                    options += `<option value="${val}">${txt}</option>`;
                });
                select.innerHTML = options;
            })
            .catch(e => console.error('Error al cargar combo ' + cat.elementId + ':', e));
    }));
}