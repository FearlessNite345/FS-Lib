
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
- `handle`: Handle of the closest model.

### `GetClosestPedWithinDistance`

**Description**: Finds the closest pedestrian within a specified distance.

**Usage**:

```lua
local closestPed, closestDistance = exports['FS-Lib']:GetClosestPedWithinDistance(maxDistance)
```

**Parameters**:
- `maxDistance` (number): The maximum distance to search for pedestrians.

**Returns**:
- `ped`: Handle of the closest pedestrian.
- `distance`: Distance to the closest pedestrian.

### `EnumeratePeds`

**Description**: Enumerates through all pedestrians.

**Usage**:

```lua
for ped in exports['FS-Lib']:EnumeratePeds() do
    -- Your code here
end
```

### `SetupModel`

**Description**: Loads a model into memory.

**Usage**:

```lua
exports['FS-Lib']:SetupModel(model)
```

**Parameters**:
- `model` (string|number): The model hash or name to load.

### `RandomLimited`

**Description**: Generates a random number within a specified range and limit.

**Usage**:

```lua
local randomNum = exports['FS-Lib']:RandomLimited(min, max, limit)
```

**Parameters**:
- `min` (number): The minimum value.
- `max` (number): The maximum value.
- `limit` (number): The limit value.

**Returns**:
- `number`: A random number within the specified range and limit.

### `DrawNotification3D`

**Description**: Draws a 3D notification at a given position.

**Usage**:

```lua
exports['FS-Lib']:DrawNotification3D(position, message)
```

**Parameters**:
- `position` (vector3): The position to draw the notification.
- `message` (string): The message to display.

### `PlaceModel`

**Description**: Places a model at a specified position and rotation, with controls to adjust the placement and confirm or cancel.

**Usage**:

```lua
exports['FS-Lib']:PlaceModel(model, position, rotation, callback)
```

**Parameters**:
- `model` (string|number): The model hash or name to place.
- `position` (vector3): The initial position to place the model.
- `rotation` (vector3): The initial rotation to place the model.
- `callback` (function): A callback function to call with `true` if the placement was confirmed, or `false` if it was canceled.

**Example**:

```lua
exports['FS-Lib']:PlaceModel('prop_chair_01a', vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), function(success)
    if success then
        print('Model placed successfully!')
    else
        print('Model placement canceled.')
    end
end)
```
