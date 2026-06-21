/* ============================================================
   PORTFOLIO — Maxence ABRIC--SEGARRA
   ============================================================ */

document.addEventListener('DOMContentLoaded', function () {
  /* --- Navigation mobile --- */
  const navToggle = document.getElementById('nav-toggle');
  const navLinks = document.getElementById('nav-links');
  if (navToggle && navLinks) {
    navToggle.addEventListener('click', () => navLinks.classList.toggle('open'));
    navLinks.querySelectorAll('a').forEach(a =>
      a.addEventListener('click', () => navLinks.classList.remove('open'))
    );
  }

  /* --- Filtres de projets (un groupe par grille) --- */
  document.querySelectorAll('.filtre-buttons').forEach(group => {
    const grid = document.getElementById(group.dataset.grid);
    if (!grid) return;
    const buttons = group.querySelectorAll('.filtre-btn');

    buttons.forEach(button => {
      button.addEventListener('click', () => {
        buttons.forEach(b => b.classList.remove('active'));
        button.classList.add('active');
        const filtre = button.getAttribute('data-filtre');

        grid.querySelectorAll('.carre-projet').forEach(item => {
          const categories = (item.getAttribute('data-categories') || '').split(' ');
          const visible = filtre === 'all' || categories.includes(filtre);
          item.style.display = visible ? 'block' : 'none';
          if (visible) item.style.animation = 'fadeInUp 0.5s ease-out';
        });
      });
    });
  });

  /* --- Initialisation de chaque carrousel --- */
  document.querySelectorAll('.carrousel-container').forEach(container => {
    showSlideInContainer(container, 0);
  });
});

/* ============================================================
   CARROUSEL (chaque instance est indépendante)
   ============================================================ */
function showSlideInContainer(container, index) {
  if (!container) return;
  const slides = container.querySelectorAll('.carrousel-slide');
  const indicators = container.querySelectorAll('.indicator');
  const track = container.querySelector('.carrousel-slides');
  if (!slides.length || !track) return;

  const i = (index + slides.length) % slides.length;
  container.dataset.current = i;
  track.style.transform = `translateX(-${i * 100}%)`;

  slides.forEach((slide, k) => slide.classList.toggle('active', k === i));
  indicators.forEach((ind, k) => ind.classList.toggle('active', k === i));
}

function carouselFromEvent() {
  const e = window.event;
  return e && e.target ? e.target.closest('.carrousel-container') : null;
}

function moveSlide(n) {
  const container = carouselFromEvent();
  if (!container) return;
  const current = parseInt(container.dataset.current || '0', 10);
  showSlideInContainer(container, current + n);
}

function goToSlide(n) {
  const container = carouselFromEvent();
  showSlideInContainer(container, n);
}

/* ============================================================
   LIGHTBOX (images)
   ============================================================ */
function openLightbox(src) {
  const lightbox = document.getElementById('custom-lightbox');
  const lightboxImg = document.getElementById('lightbox-img');
  if (!lightbox || !lightboxImg) return;
  lightboxImg.src = src;
  lightbox.style.display = 'flex';
}

function closeLightbox(e) {
  if (e.target.id === 'custom-lightbox' || e.target.classList.contains('lightbox-close')) {
    document.getElementById('custom-lightbox').style.display = 'none';
  }
}

/* ============================================================
   VISIONNEUSE PDF
   ============================================================ */
function openPDF(src) {
  const viewer = document.getElementById('pdf-viewer');
  const frame = document.getElementById('pdf-frame');
  if (!viewer || !frame) return;
  frame.src = src;
  viewer.style.display = 'flex';
}

function closePDF() {
  const viewer = document.getElementById('pdf-viewer');
  const frame = document.getElementById('pdf-frame');
  if (!viewer) return;
  viewer.style.display = 'none';
  if (frame) frame.src = '';
}

/* --- Fermeture au clavier (Échap) --- */
document.addEventListener('keydown', function (e) {
  if (e.key === 'Escape') {
    const lb = document.getElementById('custom-lightbox');
    const pdf = document.getElementById('pdf-viewer');
    if (lb) lb.style.display = 'none';
    if (pdf) { pdf.style.display = 'none'; }
  }
});
