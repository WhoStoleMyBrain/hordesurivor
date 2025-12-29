# hordesurivor
My very own horde survivor game

Code is licensed under Apache-2.0 (see LICENSE).
Game assets (art, audio, sprites, music, levels) are NOT licensed for reuse and are All Rights Reserved (see ASSETS_LICENSE).
The name/logo are trademarks of <you/company>; forks must use a different name/logo.

## Sprite pipeline workflow
- **Runtime by default:** sprites are generated on game startup from
  `assets/sprites/recipes.json` and cached in-memory for use by render components.
- **Optional export:** run the `SpriteGenDemo` with `exportDirectory` to emit PNGs
  during development when you want to inspect or bake the generated sprites.
