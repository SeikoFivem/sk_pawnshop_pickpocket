# SK Pawnshop & Pickpocket

Un script complet pour FiveM (ESX) ajoutant un système de **Recéleur évolutif** (Pawn Shop) avec réputation et une fonctionnalité de **Pickpocket** sur les PNJ.

## 👀 Preview

**[PREVIEW](https://www.youtube.com/watch?v=qYL53FlDIMY)**

## 📋 Fonctionnalités

### 🏪 Recéleur (Pawn Shop)
*   **Vente d'objets illégaux** à un PNJ caché.
*   **Système de Réputation (XP)** :
    *   Gagnez de l'expérience à chaque vente.
    *   Montez en grade : *Petite Frappe* ➔ *Affranchi* ➔ *Parrain*.
    *   **Débloquez des objets** : Certains objets de grande valeur (ex: Diamants) ne peuvent être vendus qu'à un certain niveau.
*   **Interface UI** propre pour la vente.
*   Protection anti-triche (vérification côté serveur).
*   Paiement en liquide, banque ou argent sale (configurable).

### 🕵️ Pickpocket (Vol à la tire)
*   **Volez les PNJ** dans la rue via `ox_target`.
*   **Mini-jeu** (Skill Check) pour réussir le vol.
*   **Risques** : En cas d'échec, le PNJ s'enfuit et peut alerter la police.
*   **Loot aléatoire & Réaliste** : Système de rareté pondéré (Common, Rare, Legendary).
    *   *Argent* (50%)
    *   *Déchets* (25%)
    *   *iPhone* (12%)
    *   *Bijoux* (Rare)
    *   *Rolex* (1% - Jackpot)
    *   *Diamant* (1% - Nécessite Niveau 2)
*   **Cooldown** : Impossible de voler le même PNJ deux fois de suite.

## 🛠 Prérequis

Ce script nécessite l'écosystème **OX** :

*   [ESX Legacy](https://github.com/esx-framework)
*   [ox_lib]([https://github.com/overextended/ox_lib](https://github.com/overextended/ox_lib))
*   [ox_inventory]([https://github.com/overextended/ox_inventory](https://github.com/overextended/ox_inventory))
*   [ox_target]([https://github.com/overextended/ox_target](https://github.com/overextended/ox_target))

## 💿 Installation

1.  **Téléchargement** : Placez le dossier `sk` dans votre dossier `resources`.
2.  **Base de données** : Importez le fichier `pawnshop.sql` dans votre base de données.
    ```sql
    CREATE TABLE IF NOT EXISTS `sk_reputation` (
      `identifier` varchar(60) NOT NULL,
      `xp` int(11) NOT NULL DEFAULT 0,
      PRIMARY KEY (`identifier`)
    );
    ```
3.  **Ajout des Items** :
    *   Ouvrez le fichier `sk/items/items.lua`.
    *   Copiez l'intégralité du contenu.
    *   Collez-le dans le fichier `ox_inventory/data/items.lua` de votre serveur (à la suite des autres items).
4.  **Ajout des Images** :
    *   Ouvrez le dossier `sk/items/image/`.
    *   Copiez toutes les images qui s'y trouvent.
    *   Collez-les dans le dossier `ox_inventory/web/images/` de votre serveur.
5.  **Server.cfg** : Ajoutez la ligne suivante à votre `server.cfg` (après les dépendances ox_*) :
    ```cfg
    ensure sk
    ```

## ⚙️ Configuration

Tout est configurable dans `config.lua` :

*   **PNJ Recéleur** : Modèle, coordonnées, blip.
*   **Économie** : Prix des objets, type de paiement.
*   **Réputation** : XP par vente, paliers de niveaux.
*   **Pickpocket** : Chances de réussite, loot table, temps d'animation, alerte police.

Exemple de configuration d'items :
```lua
Config.ItemsToSell = {
    { label = "Montre de luxe", item = "rolex",     price = 250, minLevel = 1 },
    { label = "Diamant",        item = "diamond",   price = 500, minLevel = 2 }, -- Niveau 2 requis
}
```

## 🎮 Utilisation

*   **Pickpocket** : Approchez-vous d'un PNJ, ciblez-le avec `Alt` (ox_target) et choisissez "Faire les poches". Vous recevrez donc un item ou pas
*   **Recéleur** : Allez au point indiqué sur la carte (blip caché ou non selon config), parlez au PNJ via `Alt` pour ouvrir le menu de vente.

## 👨‍💻 Crédits
Créé par Seîko.
