# FS-Lib Documentation

FS-Lib is a collection of Lua functions designed for FiveM scripts to streamline various common tasks. It is mainly used in FearlessStudios scripts. Below is a detailed guide on how to use each function exposed by FS-Lib.

## Functions Overview

### `GetKeyStringFromKeyID`

**Description**: Retrieves the key string associated with a given key ID.

**Usage**:

```lua
local keyString = exports['FS-Lib']:GetKeyStringFromKeyID(keyId)
```

**Parameters**:
- `keyId` (number): The key ID you want to convert to a key string.

**Returns**:
- `string`: The key string associated with the key ID.

### `GetClosestModelWithinDistance`

**Description**: Finds the closest model within a specified distance.

**Usage**:

```lua
local closestModelCoords, closestModelHandle = exports['FS-Lib']:GetClosestModelWithinDistance(maxDistance, models)
```

**Parameters**:
- `maxDistance` (number): The maximum distance to search for models.
- `models` (table|string): Either a list of model hashes or a single model hash.

**Returns**:
- `vector3`: Coordinates of the closest model.
- `number`: Handle of the closest model.

### `GetClosestPedWithinDistance`

**Description**: Finds the closest pedestrian within a specified distance.

**Usage**:

```lua
local closestPed, closestDistance = exports['FS-Lib']:GetClosestPedWithinDistance(maxDistance)
```

**Parameters**:
- `maxDistance` (number): The maximum distance to search for pedestrians.

**Returns**:
- `Ped`: Handle of the closest pedestrian.
- `number`: Distance to the closest pedestrian.

### `EnumeratePeds`

**Description**: Enumerates all pedestrians in the world.

**Usage**:

```lua
for ped in exports['FS-Lib']:EnumeratePeds() do
    -- Your code here
end
```

**Returns**:
- `coroutine`: An iterator for iterating through pedestrians.

### `SetupModel`

**Description**: Loads and sets up a model for use.

**Usage**:

```lua
exports['FS-Lib']:SetupModel(model)
```

**Parameters**:
- `model` (string or number): The model hash or name to be loaded.

### `RandomLimited`

**Description**: Generates a random number within a range, ensuring it's above a specified limit.

**Usage**:

```lua
local randomValue = exports['FS-Lib']:RandomLimited(min, max, limit)
```

**Parameters**:
- `min` (number): The minimum value for the random number.
- `max` (number): The maximum value for the random number.
- `limit` (number): The minimum absolute value the result must be greater than.

**Returns**:
- `number`: A random number between `min` and `max` that is greater than `limit`.

### `DrawNotification3D`

**Description**: Draws a 3D notification in the world.

**Usage**:

```lua
exports['FS-Lib']:DrawNotification3D(coords, text, seconds, color)
```

**Parameters**:
- `coords` (vector3): Coordinates where the notification will be drawn.
- `text` (string): The text of the notification.
- `seconds` (number): Duration for which the notification will be displayed.
- `color` (string): Color of the text in hex format (e.g., `#FF0000` for red).

### `DrawNotification2D`

**Description**: Draws a 2D notification on the screen.

**Usage**:

```lua
exports['FS-Lib']:DrawNotification2D(text, seconds, color)
```

**Parameters**:
- `text` (string): The text of the notification.
- `seconds` (number): Duration for which the notification will be displayed.
- `color` (string): Color of the text in hex format (e.g., `#FF0000` for red).

### `DrawText3D`

**Description**: Draws 3D text at specified coordinates.

**Usage**:

```lua
exports['FS-Lib']:DrawText3D(x, y, z, scale, text)
```

**Parameters**:
- `x` (number): X coordinate of the text position.
- `y` (number): Y coordinate of the text position.
- `z` (number): Z coordinate of the text position.
- `scale` (number): Scale of the text.
- `text` (string): The text to be drawn.

### `DrawText2D`

**Description**: Draws 2D text on the screen.

**Usage**:

```lua
exports['FS-Lib']:DrawText2D(x, y, text, scale, center)
```

**Parameters**:
- `x` (number): X coordinate of the text position (0 to 1).
- `y` (number): Y coordinate of the text position (0 to 1).
- `text` (string): The text to be drawn.
- `scale` (number): Scale of the text.
- `center` (boolean): Whether the text should be centered.

### `PlaceModel`

**Description**: Allows you to place a model in the world and adjust its position interactively before confirming its placement.

**Usage**:

```lua
exports['FS-Lib']:PlaceModel(model, position, rotation)
```

**Parameters**:
- `model` (string or number): The model hash or name to be placed.
- `position` (vector3): Initial position where the model will be placed.
- `rotation` (vector3): Initial rotation of the model.
