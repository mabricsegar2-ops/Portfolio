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

/* ============================================================
   JAUGE DE DÉFILEMENT « LIQUIDE » (accueil uniquement)
   Un récipient qui se remplit selon la progression du scroll.
   La surface ondule en permanence ; défiler vite augmente
   l'amplitude des vagues et incline le liquide (ballottement),
   puis tout s'amortit progressivement pour revenir au calme.
   ============================================================ */
(function initWaterGauge() {
  const canvas = document.getElementById('water-canvas');
  if (!canvas) return; // présent seulement sur l'accueil → autres pages ignorées

  // On respecte la préférence « animations réduites »
  if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    return;
  }

  const ctx = canvas.getContext('2d');
  const dpr = Math.max(1, window.devicePixelRatio || 1);
  let W = 0, H = 0;

  // Adapte la résolution du canvas à sa taille réelle (rendu net)
  function resize() {
    const rect = canvas.getBoundingClientRect();
    W = rect.width;
    H = rect.height;
    canvas.width = Math.round(W * dpr);
    canvas.height = Math.round(H * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }
  resize();
  window.addEventListener('resize', resize);

  // Progression du défilement, de 0 (haut) à 1 (bas de page)
  function scrollProgress() {
    const max = document.documentElement.scrollHeight - window.innerHeight;
    return max > 0 ? Math.min(1, Math.max(0, window.scrollY / max)) : 0;
  }

  let level = scrollProgress();   // niveau affiché (suit la cible en douceur)
  let target = level;             // niveau visé (progression réelle)
  let lastTarget = level;

  window.addEventListener('scroll', () => { target = scrollProgress(); }, { passive: true });

  /* --- Surface du liquide : système de ressorts (physique des vagues) ---
     Chaque colonne a un déplacement h (px, + vers le bas) et une vitesse.
     Un rappel élastique la ramène au repos, un amortissement la calme, et
     la propagation transmet l'onde aux colonnes voisines → vagues réalistes. */
  const N = 16;
  const h = new Array(N).fill(0);
  const vel = new Array(N).fill(0);
  const K = 0.025;     // raideur (rappel vers le repos)
  const DAMP = 0.035;  // amortissement (viscosité)
  const SPREAD = 0.14; // propagation aux voisins

  /* --- Bulles qui montent --- */
  const bubbles = [];
  function spawnBubble() {
    bubbles.push({
      x: 2 + Math.random() * Math.max(1, W - 4),
      y: H - 1,
      r: 0.7 + Math.random() * 1.9,   // rayon
      sp: 0.25 + Math.random() * 0.6, // vitesse de montée
      wob: 0.2 + Math.random() * 0.6, // amplitude d'oscillation horizontale
      ph: Math.random() * Math.PI * 2
    });
  }

  function draw() {
    // Énergie injectée par la vitesse de défilement → ballottement réaliste
    const v = target - lastTarget;
    lastTarget = target;
    if (Math.abs(v) > 0.0002) {
      const slosh = Math.max(-7, Math.min(7, v * 65)); // un côté monte, l'autre descend
      for (let i = 0; i < N; i++) {
        vel[i] += slosh * ((i / (N - 1)) - 0.5) * 2;
        vel[i] += (Math.random() - 0.5) * Math.abs(v) * 34; // clapot aléatoire
      }
    }

    // 1) ressort + amortissement, avec garde-fous de stabilité
    for (let i = 0; i < N; i++) {
      vel[i] += -K * h[i] - DAMP * vel[i];
      if (vel[i] > 10) vel[i] = 10; else if (vel[i] < -10) vel[i] = -10;
      h[i] += vel[i];
      const lim = H * 0.35;
      if (h[i] > lim) h[i] = lim; else if (h[i] < -lim) h[i] = -lim;
    }
    // 2) propagation des vagues aux colonnes voisines
    for (let pass = 0; pass < 2; pass++) {
      for (let i = 0; i < N; i++) {
        if (i > 0)     vel[i - 1] += SPREAD * (h[i] - h[i - 1]);
        if (i < N - 1) vel[i + 1] += SPREAD * (h[i] - h[i + 1]);
      }
    }

    // Niveau qui « coule » vers la progression du scroll (fond mini ~5 %)
    level += (target - level) * 0.10;
    const shown = 0.05 + level * 0.95;
    const baseY = H - shown * H;

    // Ordonnée de la surface à l'abscisse px (interpolation entre colonnes)
    const surfaceYAt = (px) => {
      const fx = Math.max(0, Math.min(N - 1, (px / W) * (N - 1)));
      const i = Math.floor(fx);
      const t = fx - i;
      const hh = i < N - 1 ? h[i] * (1 - t) + h[i + 1] * t : h[i];
      return baseY + hh;
    };

    // Bulles : apparition (plus nombreuses quand l'eau est agitée)
    let energie = 0;
    for (let i = 0; i < N; i++) energie += Math.abs(vel[i]);
    energie /= N;
    if (bubbles.length < 55 && Math.random() < 0.07 + Math.min(0.35, energie * 0.4)) {
      spawnBubble();
    }
    for (let b = bubbles.length - 1; b >= 0; b--) {
      const bb = bubbles[b];
      bb.ph += 0.12;
      bb.y -= bb.sp;
      bb.x += Math.sin(bb.ph) * bb.wob * 0.35;
      // Éclatement en atteignant la surface → petite onde locale
      if (bb.y - bb.r <= surfaceYAt(bb.x) || bb.x < 0 || bb.x > W) {
        const ci = Math.round((bb.x / W) * (N - 1));
        if (ci >= 0 && ci < N) vel[ci] -= 0.9 + bb.r * 0.3;
        bubbles.splice(b, 1);
      }
    }

    // ---- Rendu ----
    ctx.clearRect(0, 0, W, H);

    // Corps du liquide (surface = colonnes du système de ressorts)
    ctx.beginPath();
    ctx.moveTo(0, H);
    ctx.lineTo(0, baseY + h[0]);
    for (let i = 1; i < N; i++) ctx.lineTo((i / (N - 1)) * W, baseY + h[i]);
    ctx.lineTo(W, H);
    ctx.closePath();

    const grad = ctx.createLinearGradient(0, baseY, 0, H);
    grad.addColorStop(0, 'rgba(120, 255, 210, 0.95)');
    grad.addColorStop(1, 'rgba(0, 188, 255, 0.95)');
    ctx.save();
    ctx.fillStyle = grad;
    ctx.shadowColor = 'rgba(46, 255, 200, 0.7)';
    ctx.shadowBlur = 12;
    ctx.fill();
    ctx.restore();

    // Bulles, restreintes au corps du liquide (découpe sur la surface ondulée)
    ctx.save();
    ctx.clip(); // utilise le tracé du liquide ci-dessus comme zone de découpe
    for (const bb of bubbles) {
      ctx.beginPath();
      ctx.arc(bb.x, bb.y, bb.r, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(235, 255, 255, 0.45)';
      ctx.fill();
      ctx.beginPath(); // petit reflet
      ctx.arc(bb.x - bb.r * 0.3, bb.y - bb.r * 0.3, Math.max(0.4, bb.r * 0.35), 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(255, 255, 255, 0.85)';
      ctx.fill();
    }
    ctx.restore();

    // Ligne de surface brillante
    ctx.beginPath();
    ctx.moveTo(0, baseY + h[0]);
    for (let i = 1; i < N; i++) ctx.lineTo((i / (N - 1)) * W, baseY + h[i]);
    ctx.strokeStyle = 'rgba(232, 255, 250, 0.9)';
    ctx.lineWidth = 1.6;
    ctx.stroke();

    requestAnimationFrame(draw);
  }
  requestAnimationFrame(draw);
})();
