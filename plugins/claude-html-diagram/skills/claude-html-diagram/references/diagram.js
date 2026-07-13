/* Generic diagram interactivity — identical for every diagram.
   Authored files provide the data (const DETAIL, const FLOWS) in an inline
   <script> that runs BEFORE this one; classic scripts share top-level scope,
   so those globals are visible here. The assembly shell inlines this file, so
   it never goes through the model's tokens and never needs re-typing. */
const stage = document.getElementById('stage');
const nodes = document.querySelectorAll('.node');
const edges = document.querySelectorAll('.edge');
const elbls = document.querySelectorAll('.elbl');
const chips = document.querySelectorAll('#chips .chip');
const fcap = document.getElementById('flowcap');
const svg = stage.querySelector('svg');
const SVGNS = 'http://www.w3.org/2000/svg';

// Step badges — numbered circles placed at the midpoint of each lit edge, in
// FLOWS[key].edges order. Rebuilt on every flow change; never authored by hand.
function drawBadges(edgeIds) {
  svg.querySelectorAll('.badge').forEach(b => b.remove());
  edgeIds.forEach((id, i) => {
    const p = document.getElementById(id);
    if (!p || !p.getTotalLength) return;
    const pt = p.getPointAtLength(p.getTotalLength() / 2);
    const g = document.createElementNS(SVGNS, 'g');
    g.setAttribute('class', 'badge');
    const c = document.createElementNS(SVGNS, 'circle');
    c.setAttribute('cx', pt.x); c.setAttribute('cy', pt.y); c.setAttribute('r', 9);
    const t = document.createElementNS(SVGNS, 'text');
    t.setAttribute('x', pt.x); t.setAttribute('y', pt.y + 4);
    t.setAttribute('text-anchor', 'middle');
    t.textContent = i + 1;
    g.append(c, t);
    svg.append(g);
  });
}

function setFlow(key) {
  chips.forEach(c => c.classList.toggle('on', c.dataset.flow === key));
  edges.forEach(e => e.classList.remove('lit'));
  elbls.forEach(l => l.classList.remove('lit'));
  nodes.forEach(n => n.classList.remove('lit'));
  if (key === 'all') { stage.classList.remove('flowing'); fcap.classList.remove('show'); drawBadges([]); return; }
  const f = FLOWS[key];
  stage.classList.add('flowing');
  drawBadges(f.edges);
  f.edges.forEach(id => document.getElementById(id)?.classList.add('lit'));
  elbls.forEach(l => { if (f.edges.includes(l.dataset.e)) l.classList.add('lit'); });
  f.nodes.forEach(k => document.querySelector(`.node[data-k="${k}"]`)?.classList.add('lit'));
  document.getElementById('f-name').textContent = f.name;
  document.getElementById('f-steps').innerHTML = f.steps.map(s => `<li>${s}</li>`).join('');
  fcap.classList.add('show');
}
chips.forEach(c => c.addEventListener('click', () => setFlow(c.dataset.flow)));

nodes.forEach(n => n.addEventListener('click', () => {
  nodes.forEach(x => x.classList.remove('sel'));
  n.classList.add('sel');
  const d = DETAIL[n.dataset.k];
  if (!d) return;
  document.getElementById('d-title').textContent = d.t;
  document.getElementById('d-meta').textContent = d.m;
  document.getElementById('d-body').innerHTML = d.b;
}));

// show/hide the floating cards so they never cover the diagram
const detailCard = document.getElementById('detail');
const panelToggle = document.getElementById('panelToggle');
let panelsHidden = false;
panelToggle.addEventListener('click', () => {
  panelsHidden = !panelsHidden;
  const d = panelsHidden ? 'none' : '';
  detailCard.style.display = d;      // inline style overrides the .card / .show classes
  fcap.style.display = d;
  panelToggle.textContent = panelsHidden ? 'Show panels' : 'Hide panels';
  panelToggle.classList.toggle('on', panelsHidden);
});

document.getElementById('themeToggle').addEventListener('click', () => {
  const dark = !document.documentElement.classList.contains('dark');
  document.documentElement.classList.toggle('dark', dark);
  localStorage.setItem('theme', dark ? 'dark' : 'light');
});
