# Frontier Command — 3D RTS MVP

Самодостаточный data-driven RTS prototype для Godot 4.7.1, Windows 11. Внешние плагины и ассеты не требуются: placeholder-графика создаётся из 3D-примитивов.

## Запуск

1. Установите Godot 4.x и импортируйте `project.godot`.
2. Нажмите F6/F5 или выполните `godot --path .`.

Управление: WASD или края экрана — камера; колесо — масштаб; ЛКМ/рамка — выбор; Shift+ЛКМ — добавить; ПКМ — движение, атака или добыча; F3 — debug overlay; Esc — пауза.

Рабочий добывает дерево/золото по ПКМ. Выберите рабочего и нажмите Build Barracks/House, разместите фундамент ЛКМ. Рабочий автоматически строит. Выберите готовое здание для производства. Вражеский AI периодически выпускает мечников и атакует.

## Архитектура

- `data/`: типизированные `UnitData`, `BuildingData` и реестр определений.
- `units/`, `buildings/`, `economy/`, `combat/`: универсальные runtime-сущности.
- `navigation/`: A* grid, вода, скалы и footprint зданий блокируют путь.
- `core/`: композиция мира, RTS-камера, selection/orders/UI и AI orchestration.

Чтобы добавить юнита или здание, добавьте определение в `GameDatabase`; универсальный runtime-код менять не нужно. Новый ресурс — строковый ключ экономики и `WorldResource`; логика рабочего не зависит от конкретного ресурса. Следующий шаг расширения — вынести определения из реестра в `.tres` и добавить `FactionData`, содержащий списки доступных ID.

Промты и технические требования для генерации согласованного набора 3D-моделей, UI-иконок или альтернативных изометрических спрайтов находятся в [`ART_PROMPTS.md`](ART_PROMPTS.md).

## Windows export

Установите matching export templates в Godot, создайте `build/windows`, затем: `godot --headless --path . --export-release "Windows Desktop"`. Результат появится в `build/windows/`. Не используйте editor executable как export template: это другой бинарник.

## Статус проверки

Проект импортирован и запущен на 120 кадров в headless Godot 4.7.1 без ошибок GDScript/runtime. Интерактивный Definition of Done и настоящий standalone export требуют GUI-проверки и установленного официального export template соответственно.
