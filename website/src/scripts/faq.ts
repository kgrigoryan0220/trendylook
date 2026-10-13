// FAQ accordion: animate <details> open/close (height + fade). Native toggle when motion is reduced.
const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

document.querySelectorAll<HTMLDetailsElement>("details.faq").forEach((details) => {
  const summary = details.querySelector("summary");
  const body = details.querySelector<HTMLElement>(".faq-body");
  if (!summary || !body) return;

  let animation: Animation | null = null;
  let closing = false;

  const finish = () => {
    animation = null;
    closing = false;
    details.removeAttribute("data-closing");
  };

  summary.addEventListener("click", (event) => {
    if (reduceMotion.matches) return;
    event.preventDefault();

    // A closed <details> still reports its content height, so start from 0 when closed.
    const from = details.open ? body.getBoundingClientRect().height : 0;
    animation?.cancel();

    if (!details.open || closing) {
      // Open (or reverse a close in progress)
      details.open = true;
      details.removeAttribute("data-closing");
      closing = false;
      const to = body.scrollHeight;
      animation = body.animate(
        [
          { height: `${from}px`, opacity: from ? 1 : 0 },
          { height: `${to}px`, opacity: 1 },
        ],
        { duration: 320, easing: "cubic-bezier(0.2, 0.7, 0.2, 1)" },
      );
      animation.onfinish = finish;
    } else {
      closing = true;
      details.setAttribute("data-closing", "");
      animation = body.animate(
        [
          { height: `${from}px`, opacity: 1 },
          { height: "0px", opacity: 0 },
        ],
        { duration: 260, easing: "cubic-bezier(0.4, 0, 0.6, 1)" },
      );
      animation.onfinish = () => {
        details.open = false;
        finish();
      };
    }
  });
});
