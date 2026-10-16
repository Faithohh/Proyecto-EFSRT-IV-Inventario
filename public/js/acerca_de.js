document.addEventListener("DOMContentLoaded", function () {
    const btnAcercaDe = document.getElementById("btnAcercaDe");
    const modalElemento = document.getElementById("modalAcercaDe");

    if (!btnAcercaDe || !modalElemento) {
        return;
    }

    btnAcercaDe.addEventListener("click", function () {
        const modal = bootstrap.Modal.getOrCreateInstance(modalElemento);
        modal.show();
    });
});