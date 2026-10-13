// Hero score ring: counts 0 → value in ~1.4s, then a short confetti burst.
// With prefers-reduced-motion the final state is shown as rendered (no count, no confetti).

const DURATION = 1400;
const CONFETTI_COLORS = ["#FF3D8A", "#C6FF3D", "#7B5CFF", "#FFFFFF"];

const easeOutCubic = (t: number) => 1 - Math.pow(1 - t, 3);

function burst(host: HTMLElement) {
  const layer = document.createElement("div");
  layer.setAttribute("aria-hidden", "true");
  layer.style.cssText = "position:absolute;inset:0;pointer-events:none;overflow:visible;z-index:5";
  host.appendChild(layer);

  const pieces = 42;
  for (let i = 0; i < pieces; i++) {
    const piece = document.createElement("span");
    const size = 5 + Math.random() * 6;
    const isStrip = Math.random() > 0.45;
    piece.style.cssText = [
      "position:absolute",
      "left:50%",
      "top:50%",
      `width:${isStrip ? size * 0.5 : size}px`,
      `height:${isStrip ? size * 1.6 : size}px`,
      `background:${CONFETTI_COLORS[i % CONFETTI_COLORS.length]}`,
      `border-radius:${isStrip ? "2px" : "50%"}`,
    ].join(";");
    layer.appendChild(piece);

    const angle = (Math.PI * 2 * i) / pieces + (Math.random() - 0.5) * 0.5;
    const distance = 90 + Math.random() * 110;
    const x = Math.cos(angle) * distance;
    const y = Math.sin(angle) * distance;
    const rotate = (Math.random() - 0.5) * 720;

    piece.animate(
      [
        { transform: "translate(-50%, -50%) scale(0.4) rotate(0deg)", opacity: 1 },
        { transform: `translate(calc(-50% + ${x}px), calc(-50% + ${y}px)) scale(1) rotate(${rotate / 2}deg)`, opacity: 1, offset: 0.55 },
        { transform: `translate(calc(-50% + ${x * 1.15}px), calc(-50% + ${y * 1.15 + 70}px)) scale(0.9) rotate(${rotate}deg)`, opacity: 0 },
      ],
      { duration: 1100 + Math.random() * 500, easing: "cubic-bezier(0.15, 0.7, 0.3, 1)", fill: "forwards" },
    );
  }

  window.setTimeout(() => layer.remove(), 1800);
}

function run(ring: HTMLElement) {
  const target = Number(ring.dataset.value ?? 0);
  const numberEl = ring.querySelector<HTMLElement>("[data-ring-number]");
  const progress = ring.querySelector<SVGCircleElement>("[data-ring-progress]");
  if (!numberEl || !progress) return;

  const circumference = Number(progress.getAttribute("stroke-dasharray"));
  const setValue = (v: number) => {
    numberEl.textContent = String(Math.round(v));
    progress.style.strokeDashoffset = String(circumference * (1 - v / 100));
  };

  setValue(0);
  let start: number | null = null;
  const step = (now: number) => {
    start ??= now;
    const t = Math.min((now - start) / DURATION, 1);
    setValue(target * easeOutCubic(t));
    if (t < 1) requestAnimationFrame(step);
    else burst(ring);
  };
  requestAnimationFrame(step);
}

const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

if (!reducedMotion) {
  document.querySelectorAll<HTMLElement>("[data-score-ring]").forEach((ring) => {
    // Reset immediately so the user never sees the final value flash before counting.
    const progress = ring.querySelector<SVGCircleElement>("[data-ring-progress]");
    const numberEl = ring.querySelector<HTMLElement>("[data-ring-number]");
    if (progress) progress.style.strokeDashoffset = progress.getAttribute("stroke-dasharray") ?? "0";
    if (numberEl) numberEl.textContent = "0";

    const observer = new IntersectionObserver(
      (entries) => {
        if (entries.some((e) => e.isIntersecting)) {
          observer.disconnect();
          window.setTimeout(() => run(ring), 350);
        }
      },
      { threshold: 0.5 },
    );
    observer.observe(ring);
  });
}
