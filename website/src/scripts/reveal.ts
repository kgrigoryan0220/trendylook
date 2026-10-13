// Fade/slide-in on scroll. CSS only hides [data-reveal] when motion is allowed (see global.css).
const elements = document.querySelectorAll<HTMLElement>("[data-reveal]");

if (!("IntersectionObserver" in window)) {
  elements.forEach((el) => el.classList.add("is-visible"));
} else {
  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      }
    },
    { rootMargin: "0px 0px -8% 0px", threshold: 0.12 },
  );
  elements.forEach((el) => observer.observe(el));
}
