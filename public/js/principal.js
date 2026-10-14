document.addEventListener("DOMContentLoaded", function() {
    var items = document.querySelectorAll(".mp-item");
    var closeAll = function(ex) {
        items.forEach(function(i) {
            if (i !== ex) i.classList.remove("open");
            i.querySelectorAll(".mp-has.open").forEach(function(h) { h.classList.remove("open"); });
        });
    };

    document.querySelectorAll(".mp-link[data-menu]").forEach(function(btn) {
        btn.addEventListener("click", function(e) {
            e.stopPropagation();
            var item = btn.closest(".mp-item");
            var was = item.classList.contains("open");
            closeAll(item);
            item.classList.toggle("open", !was);
        });
    });

    document.querySelectorAll(".mp-opt[data-sub]").forEach(function(btn) {
        btn.addEventListener("click", function(e) {
            e.stopPropagation();
            var host = btn.closest(".mp-has");
            var was = host.classList.contains("open");
            host.parentElement.querySelectorAll(".mp-has.open").forEach(function(h) {
                if (h !== host) h.classList.remove("open");
            });
            host.classList.toggle("open", !was);
        });
    });

    document.addEventListener("click", function() { closeAll(null); });
    document.addEventListener("keydown", function(e) { if (e.key === "Escape") closeAll(null); });

    function abrirModulo(nombre) {
        var id = "mp" + nombre.charAt(0).toUpperCase() + nombre.slice(1);
        document.querySelectorAll(".mp-panel").forEach(function(p) { p.hidden = true; });
        document.getElementById("mpBienvenida").hidden = true;
        var panel = document.getElementById(id);
        if (panel) panel.hidden = false;
        window.dispatchEvent(new CustomEvent("modulo:abrir", { detail: nombre }));
    }

    document.querySelectorAll("[data-modulo]").forEach(function(b) {
        b.addEventListener("click", function(e) {
            e.stopPropagation();
            abrirModulo(b.dataset.modulo);
        });
    });
});