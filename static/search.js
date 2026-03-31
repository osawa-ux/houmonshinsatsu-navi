
(function() {
    const input = document.getElementById('searchInput');
    const cards = document.querySelectorAll('.clinic-card');
    if (!input || !cards.length) return;

    input.addEventListener('input', function() {
        const q = this.value.trim().toLowerCase();
        let shown = 0;
        cards.forEach(function(card) {
            const text = card.textContent.toLowerCase();
            if (!q || text.includes(q)) {
                card.style.display = '';
                shown++;
            } else {
                card.style.display = 'none';
            }
        });
        const counter = document.getElementById('searchCount');
        if (counter) counter.textContent = q ? `${shown}件表示中` : '';
    });
})();
