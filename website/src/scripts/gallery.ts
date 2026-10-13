// Screenshot gallery: arrow buttons scroll one card at a time; buttons disable at the ends.
const gallery = document.querySelector<HTMLElement>("[data-gallery]");
const prev = document.querySelector<HTMLButtonElement>("[data-gallery-prev]");
const next = document.querySelector<HTMLButtonElement>("[data-gallery-next]");

if (gallery && prev && next) {
  const step = () => {
    const item = gallery.querySelector<HTMLElement>("[data-gallery-item]");
    const gap = parseFloat(getComputedStyle(item?.parentElement ?? gallery).columnGap) || 0;
    return (item?.offsetWidth ?? 260) + gap;
  };

  const update = () => {
    const max = gallery.scrollWidth - gallery.clientWidth - 2;
    prev.disabled = gallery.scrollLeft <= 2;
    next.disabled = gallery.scrollLeft >= max;
  };

  const behavior: ScrollBehavior = window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth";
  prev.addEventListener("click", () => gallery.scrollBy({ left: -step(), behavior }));
  next.addEventListener("click", () => gallery.scrollBy({ left: step(), behavior }));
  gallery.addEventListener("scroll", update, { passive: true });
  window.addEventListener("resize", update);
  update();
}
