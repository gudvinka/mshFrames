# mshFrames v0.4

If you have any suggestions or features you'd like to see regarding raid frames, feel free to share. Please keep in mind the **core concept**: this addon focuses on providing a simplified, lightweight version of the default UI with minimal customization and a "clean-out-of-the-box" approach.

> **Language Support:** You are welcome to post your feedback in **English**, **Ukrainian**, or **Russian**.

---

### Key Features

#### Configuration & GUI
* **In-game Settings:** Access the configuration panel easily using the `/msh` command.
* **Streamlined UI:** Powered by a clean graphical interface for quick adjustments.

#### Visual Customization (LSM Support)
* **Textures:** Full support for **LibSharedMedia**. Choose any status bar texture from the LSM library or use custom ones. *(Note: /reload required to apply changes)*.
* **Typography:** Select fonts from the LSM library or provide your own to ensure perfect readability.
* **Raid Icons:** Integrated support for raid target markers directly on the frames.
* **Role Visibility:** Toggle display for role icons.
* 
#### Name Formatting
* **Clean Names:** Automatically hides server names for players.
* **Truncation:** Ability to truncate long names to keep the frames neat and uniform.
* **UTF-8 Support:** Full support for UTF-8 characters in names.

#### Aura & Indicator Management
> **Important Note:** This addon displays only the icons provided by the default Blizzard API. **NO custom sorting or filtering is applied**, as such manipulations are restricted by Blizzard's current UI policy.

* **Auras Control:** Toggle visibility for buffs and BIG centered defensive cooldowns.
* **Smart Debuffs:** Show or hide debuff icons based on your needs.
* **Dispel Tracking:** Dedicated toggle for dispellable debuff icons to highlight what you can actually remove.

#### Native Integration (CVar Control)
The addon provides minimal yet powerful customization of Blizzard's internal CVars for maximum stability:
* **Health Text:** Toggle and format health strings (`raidFramesHealthText`).
* **Defensives:** Control the display of large central defensive icons (`raidFramesCenterBigDefensive`).
* **Debuff Logic:** Native control over displaying only dispellable or all debuffs (`raidFramesDisplayDebuffs`, `raidFramesDisplayOnlyDispellableDebuffs`).

---

### Commands
* `/msh` — Open the settings GUI.
* `/rl` — Quickly reload the UI (recommended after changing some system-level CVar settings).



### TODO
- [ ] Modular Architecture
- [ ] Secret Value Fix
- [ ] Combat Lockdown / Live Update
- [ ] Debuff Highlight (Диспел)
- [ ] Кэширование имен
- [ ] Test Mode (Тестовый режим)
- [ ] Role Sorting (Танк-Хил-ДД)
- [ ] Лимит дебаффов (Max 3-5)
- [ ] Профили (AceDB)
- [ ] Frame Spacing (Отступы)
- [ ] Формат ХП (К/М)
- [ ] Absorb & Shield Manager
- [ ] Разделение Рейд/Пати
- [ ] Mouseover Highlight
- [ ] Стили диспела (Пунктир)
- [ ] Прозрачность иконок
- [ ] Скрытие заголовков групп
- [ ] Leader/Assist Icons
- [ ] Скрытие себя (Display Self)
- [ ] Убрать тултипы аур