// Screenshot gallery.
// Pinned mode: the section sticks to the viewport and vertical page scroll moves the screenshots sideways.
// Fallback (reduced motion, short viewport): a native horizontal scroller.
// The arrow buttons and ←/→ keys step one card in both modes.

const section = document.querySelector<HTMLElement>("[data-gallery-section]");
const pin = document.querySelector<HTMLElement>("[data-gallery-pin]");
const gallery = document.querySelector<HTMLElement>("[data-gallery]");
const track = document.querySelector<HTMLElement>("[data-gallery-track]");
const prev = document.querySelector<HTMLButtonElement>("[data-gallery-prev]");
const next = document.querySelector<HTMLButtonElement>("[data-gallery-next]");
const header = document.querySelector<HTMLElement>("[data-header]");

if (section && pin && gallery && track && prev && next) {
  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  let pinned = false;
  let distance = 0;
  let lastWidth = 0;

  const clamp = (v: number) => Math.min(1, Math.max(0, v));
  const behavior = (): ScrollBehavior => (reduceMotion.matches ? "auto" : "smooth");

  const step = () => {
    const item = gallery.querySelector<HTMLElement>("[data-gallery-item]");
    const gap = parseFloat(getComputedStyle(track).columnGap) || 0;
    return (item?.offsetWidth ?? 260) + gap;
  };

  const progress = () => (distance ? clamp(-section.getBoundingClientRect().top / distance) : 0);

  const updateButtons = () => {
    if (pinned) {
      const p = progress();
      prev.disabled = p <= 0.001;
      next.disabled = p >= 0.999;
    } else {
      prev.disabled = gallery.scrollLeft <= 2;
      next.disabled = gallery.scrollLeft >= gallery.scrollWidth - gallery.clientWidth - 2;
    }
  };

  const render = () => {
    if (pinned) track.style.transform = `translate3d(${-progress() * distance}px, 0, 0)`;
    updateButtons();
  };

  const layout = () => {
    lastWidth = window.innerWidth;
    section.classList.remove("is-pinned");
    section.style.height = "";
    track.style.transform = "";
    pinned = false;

    if (!reduceMotion.matches) {
      const headerH = header?.offsetHeight ?? 72;
      const contentH = pin.offsetHeight; // natural height, measured before pinning
      const fits = contentH + headerH + 32 <= window.innerHeight;
      // Only pin when the window itself scrolls (an auto-height embed would report the whole page as the viewport).
      const windowScrolls =
        document.documentElement.scrollHeight > window.innerHeight + 100 && window.innerHeight <= 2000;
      distance = Math.max(0, gallery.scrollWidth - gallery.clientWidth);

      if (fits && windowScrolls && distance > 40) {
        pinned = true;
        section.style.setProperty("--pin-h", `${window.innerHeight}px`);
        section.style.setProperty("--header-h", `${headerH}px`);
        section.style.height = `${window.innerHeight + distance}px`;
        section.classList.add("is-pinned");
        gallery.scrollLeft = 0;
      }
    }
    render();
  };

  const move = (dir: 1 | -1) => {
    if (pinned) window.scrollBy({ top: dir * step(), behavior: behavior() });
    else gallery.scrollBy({ left: dir * step(), behavior: behavior() });
  };

  prev.addEventListener("click", () => move(-1));
  next.addEventListener("click", () => move(1));
  gallery.addEventListener("keydown", (event) => {
    if (!pinned) return; // native scroller handles arrow keys itself
    if (event.key === "ArrowRight") move(1);
    else if (event.key === "ArrowLeft") move(-1);
    else return;
    event.preventDefault();
  });

  let frame = 0;
  const onScroll = () => {
    if (frame) return;
    frame = requestAnimationFrame(() => {
      frame = 0;
      render();
    });
  };
  window.addEventListener("scroll", onScroll, { passive: true });
  gallery.addEventListener("scroll", updateButtons, { passive: true });

  // Re-measure on width changes only: mobile URL-bar height changes would otherwise make the page jump.
  window.addEventListener("resize", () => {
    if (window.innerWidth !== lastWidth) layout();
  });
  reduceMotion.addEventListener("change", layout);

  layout();
  // Screenshots and fonts can change widths after load
  window.addEventListener("load", layout);
}
