const app = document.getElementById('app');
const itemsContainer = document.getElementById('items-container');
const totalPriceEl = document.getElementById('total-price');
const sellAllBtn = document.querySelector('.sell-all-btn');

// Réputation Elements
const repLabelStr = document.getElementById('rep-label');
const repLevelStr = document.getElementById('rep-level');
const repFillStr = document.getElementById('rep-fill');
const repNextStr = document.getElementById('rep-next');

// Static Elements we want to translate
const uiTitle = document.querySelector('h1');
const totalLabel = document.querySelector('.total-info span:first-child');

let currentItems = [];
let locales = {};

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'open') {
        currentItems = data.items;
        if (data.locales) {
            locales = data.locales;
            applyLocales();
        }
        updateUI(data.reputation);
        app.style.display = 'flex';
    } else if (data.action === 'close') {
        app.style.display = 'none';
        post('close');
    }
});

function applyLocales() {
    if (uiTitle) uiTitle.innerHTML = `<i class="fas fa-sack-dollar"></i> ${locales.ui_title || 'Recéleur'}`;
    if (totalLabel) totalLabel.innerText = (locales.ui_total_estimated || 'Total Estimé') + ':';
    if (sellAllBtn) sellAllBtn.innerText = locales.ui_sell_all || 'TOUT VENDRE';
}

function updateUI(reputation) {
    itemsContainer.innerHTML = '';
    let total = 0;

    // Update Reputation Reputation UI
    if (reputation) {
        repLabelStr.innerText = reputation.label;
        repLevelStr.innerText = `${locales.ui_level || 'Niv'} ${reputation.level}`;

        let nextXp = reputation.nextLevelXp;
        let currentXp = reputation.xp;

        if (nextXp === 'Max') {
            repFillStr.style.width = '100%';
            repNextStr.innerText = locales.ui_level_max || 'Niveau Max';
        } else {
            // Calculer pourcentage progression vers niveau suivant
            let percentage = Math.min(100, nextXp > 0 ? (currentXp / nextXp) * 100 : 0);
            repFillStr.style.width = `${percentage}%`;
            repNextStr.innerText = `${currentXp} / ${nextXp} XP`;
        }
    }

    // Render Items
    currentItems.forEach(item => {
        const itemEl = document.createElement('div');
        itemEl.classList.add('item-card');

        if (item.locked) {
            itemEl.classList.add('locked');
            // Format "Level %s required"
            let lockedText = locales.ui_level_required ? locales.ui_level_required.replace('%s', item.minLevel) : `Lvl ${item.minLevel}`;
            itemEl.title = lockedText;
        } else {
            total += item.totalPrice;
        }

        let lockedBtnText = locales.ui_locked || 'Verrouillé';
        let sellBtnText = locales.ui_sell_btn || 'VENDRE';
        let lvlText = locales.ui_level || 'Lvl';

        const btnHtml = item.locked
            ? `<button class="sell-btn" style="background: #555; cursor: not-allowed;" disabled>${lockedBtnText} (${lvlText} ${item.minLevel})</button>`
            : `<button class="sell-btn" onclick="sellItem('${item.item}')">${sellBtnText} (${item.totalPrice}$)</button>`;

        itemEl.innerHTML = `
            <span class="item-count">x${item.count}</span>
            <img src="nui://ox_inventory/web/images/${item.item}.png" alt="${item.label}" class="item-icon" onerror="this.src='https://placehold.co/64'">
            <div class="item-info">
                <h3>${item.label}</h3>
                <p>${item.price}$ / unit</p>
            </div>
            ${btnHtml}
        `;
        itemsContainer.appendChild(itemEl);
    });

    totalPriceEl.innerText = `${total}$`;

    // Disable sell all if 0 items valid
    if (total === 0) {
        sellAllBtn.style.opacity = '0.5';
        sellAllBtn.style.pointerEvents = 'none';
    } else {
        sellAllBtn.style.opacity = '1';
        sellAllBtn.style.pointerEvents = 'all';
    }
}

function sellItem(itemName) {
    const item = currentItems.find(i => i.item === itemName);
    if (item && !item.locked) {
        post('sell', {
            item: item.item,
            price: item.price,
            count: item.count
        });

        // Optimistic UI Update (En attendant que le serveur renvoie l'info - on ferme pour refresh souvent)
        app.style.display = 'none';
        post('close');
    }
}

function SellAll() {
    currentItems.forEach(item => {
        if (!item.locked) {
            post('sell', {
                item: item.item,
                price: item.price,
                count: item.count
            });
        }
    });
    app.style.display = 'none';
    post('close');
}

function CloseUI() {
    app.style.display = 'none';
    post('close');
}

function post(endpoint, data = {}) {
    fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
}

// Close on Escape
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') CloseUI();
});
