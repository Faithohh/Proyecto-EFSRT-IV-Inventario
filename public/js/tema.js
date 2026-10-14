document.addEventListener("DOMContentLoaded", () => {
    const BTN = document.getElementById("btnTema");
    const KEY = "siin-tema";
    const root = document.documentElement;
    const saved = (() => {
        try {
            return localStorage.getItem(KEY);
        } catch (e) {
            return null;
        }
    })();
    if (saved === "light" || saved === "dark") root.dataset.theme = saved;
    else if (!root.dataset.theme) root.dataset.theme = "dark";
    const pintar = () => {
        const t = root.dataset.theme === "light" ? "light" : "dark";
        if (BTN)
            BTN.setAttribute(
                "aria-label",
                t === "light"
                    ? "Cambiar a modo oscuro"
                    : "Cambiar a modo claro",
            );
    };
    pintar();
    if (!BTN) return;
    BTN.addEventListener("click", () => {
        root.classList.remove("tema-anim");
        void root.offsetWidth;
        root.classList.add("tema-anim");
        BTN.classList.remove("gira");
        void BTN.offsetWidth;
        BTN.classList.add("gira");
        root.dataset.theme = root.dataset.theme === "light" ? "dark" : "light";
        try {
            localStorage.setItem(KEY, root.dataset.theme);
        } catch (e) {}
        pintar();
        clearTimeout(BTN._tTema);
        BTN._tTema = setTimeout(() => {
            root.classList.remove("tema-anim");
            BTN.classList.remove("gira");
        }, 760);
    });
});
