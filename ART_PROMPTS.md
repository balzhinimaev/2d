# Промты для генерации графики Frontier Command

## Что именно нужно проекту

`Frontier Command` — 3D RTS с камерой сверху, поэтому основная графика здесь называется **3D game assets** (игровые 3D-ассеты), а не спрайты. Для юнитов, зданий и ресурсов лучше генерировать отдельные 3D-модели в формате GLB/GLTF. Спрайты пригодятся для иконок интерфейса, портретов и, при желании, для 2D-билбордов.

Чтобы все результаты выглядели как один набор, во всех запросах сохраняйте общий стиль, ракурс и масштаб. Генератору 3D-моделей отдельно указывайте требования к геометрии, материалам, точке опоры и анимациям.

## Общий арт-дирекшен

Добавляйте этот блок в конец каждого промта:

> Stylized low-poly medieval frontier RTS game asset, readable from a high three-quarter isometric camera, chunky proportions, clean silhouette, hand-painted PBR textures, warm natural colors, subtle wear, no text, no logo, no modern objects, game-ready, optimized topology, single UV atlas, consistent scale, neutral studio lighting. Visual quality similar to a polished family-friendly strategy game, but with an original design.

### Negative prompt

> photorealistic, high-poly sculpt, tiny noisy details, thin fragile parts, futuristic, sci-fi, firearms except the specified historical musket, text, letters, logo, watermark, UI, scenery, environment, multiple objects, dramatic camera perspective, depth of field, motion blur, cropped object

## Главный универсальный промт для 3D-генератора

Замените текст в квадратных скобках:

> Create one game-ready 3D asset for a medieval frontier RTS: **[название и подробное описание объекта]**. The object must be instantly recognizable from far away and from a high three-quarter isometric view. Use a stylized low-poly construction with a strong silhouette and large readable shapes. Center the object at world origin, place its lowest point on the ground plane, orient its front toward negative Z, use real-world consistent scale, apply transforms, and include no ground, pedestal, background, labels, or extra props. Deliver as GLB/GLTF with embedded textures, one UV atlas, PBR base color/roughness/normal maps, optimized topology, and no hidden geometry. **[для юнита: Create a humanoid rig and the requested animation clips.]** Stylized low-poly medieval frontier RTS game asset, chunky proportions, clean silhouette, hand-painted PBR textures, warm natural colors, subtle wear, original design.

## Юниты

### Рабочий

> Create one game-ready 3D character: a resourceful medieval frontier worker wearing a beige linen tunic, brown trousers, sturdy boots, leather belt and simple gloves. Give the worker a compact tool kit with a clearly readable axe and hammer, but keep tools separate from the body and suitable for animation. Friendly, practical appearance; broad hands and slightly exaggerated proportions for readability from an RTS camera. Create a humanoid rig with animation clips: idle, walk, chop_tree, mine, hammer_build, carry, hit_reaction, and death. No ground or scenery. [Добавить общий арт-дирекшен.]

### Мечник

> Create one game-ready 3D character: a medieval frontier swordsman with a blue cloth faction accent, short mail shirt, leather armor, simple open helmet, broad one-handed sword and compact wooden shield. Strong triangular silhouette, equipment thick enough to remain visible from a distant isometric RTS camera. Create a humanoid rig with animation clips: idle, walk, run, sword_attack, block, hit_reaction, and death. No ground or scenery. [Добавить общий арт-дирекшен.]

### Мушкетёр

> Create one game-ready 3D character: an early-modern frontier musketeer with a violet cloth faction accent, leather coat, simple brimmed hat, powder pouch and a readable matchlock musket. Historical fantasy rather than modern military; no scope or modern firearm parts. Make the musket and pose easy to read from above. Create a humanoid rig with animation clips: idle, walk, aim, fire, reload, hit_reaction, and death. No muzzle flash, projectile, ground, or scenery. [Добавить общий арт-дирекшен.]

## Здания

Здания должны точно помещаться в игровые footprints: Town Hall — `5×5`, House — `3×3`, Barracks — `4×4`. Во всех моделях вход должен смотреть вперёд, к `-Z`.

### Ратуша — 5×5

> Create one game-ready 3D building: a medieval frontier town hall occupying a square 5-by-5 RTS grid footprint. Two sturdy timber-and-stone floors, central entrance, small bell tower, warm ochre plaster, wooden beams, blue faction banners without symbols, broad roof shapes and a prestigious but practical frontier character. Keep the footprint square, the entrance unobstructed, and the silhouette readable from every isometric rotation. No surrounding terrain, fence, people, text, or loose props. [Добавить общий арт-дирекшен.]

### Дом — 3×3

> Create one game-ready 3D building: a modest medieval frontier family house occupying a square 3-by-3 RTS grid footprint. Timber frame, pale warm plaster, stone chimney, compact thatched roof and a small covered doorway. Cozy and sturdy, with a simple silhouette distinct from military buildings. No surrounding terrain, fence, people, text, smoke, or loose props. [Добавить общий арт-дирекшен.]

### Казарма — 4×4

> Create one game-ready 3D building: a medieval frontier barracks occupying a square 4-by-4 RTS grid footprint. Heavy timber palisade construction over a low stone base, wide central training-yard gate, red-brown roof, weapon-rack shapes integrated into the walls and muted blue faction cloth accents without symbols. Robust military silhouette, visually distinct from the town hall and house. No surrounding terrain, people, text, weapons lying outside, or loose props. [Добавить общий арт-дирекшен.]

## Ресурсы и окружение

### Дерево

> Create one game-ready 3D resource node: a mature deciduous frontier tree with a thick readable trunk and a clustered low-poly green canopy. The trunk must remain visible from a high isometric camera and have a clear chopping area at its base. One tree only; no ground, grass, rocks, fruit, nest, or scenery. [Добавить общий арт-дирекшен.]

Сделайте 3–5 вариантов формы кроны, не меняя масштаб и палитру.

### Золотая жила

> Create one game-ready 3D resource node: a compact cluster of dark gray angular rocks with several large, clearly visible warm-gold mineral veins. Strong silhouette and readable gold color from a distant isometric RTS camera. One self-contained cluster only; no ground patch, mine cart, tools, text, crystals, or scenery. [Добавить общий арт-дирекшен.]

### Дополнительные наборы окружения

Для улучшения карты полезны модульные ассеты: 4–6 вариантов скал, 3 куста, 3 пня, камыш, мост через реку и бесшовные материалы травы, земли, камня и мелкой воды. Генерируйте каждый объект отдельно и без встроенного ландшафта.

## 2D-иконки интерфейса

Это уже **game UI icons**, а не 3D-модели. Иконки стоит генерировать единым листом только как концепт, а для использования экспортировать каждую отдельно с прозрачным фоном.

> Create a cohesive set of square RTS user-interface icons for: wood, food, gold, population, worker, swordsman, musketeer, town hall, house, barracks, build, move, attack, gather, repair, and stop. Stylized hand-painted low-poly-inspired rendering, bold centered silhouette, large readable shapes, consistent warm medieval frontier palette, subtle dark outline, transparent background, no frame, no text, no numbers, no logo, no watermark. Each icon must remain clear at 32×32 pixels. Export every icon as a separate transparent PNG at 256×256.

## Если всё-таки нужны спрайты

Для полностью 2D-версии термин — **isometric sprite sheet**. Не просите генератор рисовать все анимации одним изображением без строгой сетки: сначала утвердите внешний вид персонажа, затем создавайте каждую анимацию отдельно.

> Create an isometric sprite sheet for **[worker / swordsman / musketeer]** in a stylized medieval frontier RTS. Orthographic high three-quarter view, eight movement directions, **[idle / walk / attack / gather / build / death]**, 8 frames per direction, identical character design and scale in every frame, feet locked to the same ground anchor, even frame spacing, transparent background, no shadows crossing frame boundaries, no text, no UI, no scenery. Arrange frames in a strict labeled-in-metadata grid, but do not draw labels inside the image. Crisp silhouette, limited consistent palette, readable at 96 pixels tall.

## Рекомендуемый порядок производства

1. Сначала утвердить один эталонный рендер рабочего и общую палитру.
2. Создать три юнита в одинаковом масштабе и проверить их сверху в Godot.
3. Создать здания с точными footprints `3×3`, `4×4`, `5×5`.
4. Добавить дерево и золотую жилу, затем вариации окружения.
5. В последнюю очередь сделать UI-иконки по уже утверждённым моделям.
6. Перед импортом проверить pivot, направление вперёд, масштаб, названия анимаций, лицензии генератора и отсутствие чужих логотипов или узнаваемых персонажей.
